from __future__ import annotations

import email
import imaplib
import os
import shlex
import shutil
import smtplib
import socket
import ssl
import subprocess
import threading
import time
from dataclasses import dataclass
from email.message import EmailMessage
from email.utils import getaddresses, make_msgid
import re
from typing import Any

from mcp.server.fastmcp import FastMCP


mcp = FastMCP("proton_bridge")


def _env_str(name: str, default: str = "") -> str:
    value = os.environ.get(name)
    if value is None:
        return default
    return value.strip()


def _env_int(name: str, default: int) -> int:
    value = _env_str(name)
    if not value:
        return default

    try:
        return int(value)
    except ValueError:
        return default


def _env_bool(name: str, default: bool = False) -> bool:
    value = _env_str(name)
    if not value:
        return default
    return value.lower() in {"1", "true", "yes", "on"}


def _preview_text(text: str, limit: int = 240) -> str:
    compact = " ".join(text.split())
    if len(compact) <= limit:
        return compact
    return compact[: limit - 1] + "..."


def _quote_mailbox(mailbox: str) -> str:
    return '"' + mailbox.replace('\\', '\\\\').replace('"', '\\"') + '"'


def _normalize_mailbox_name(name: str, kind: str = "mailbox") -> str:
    trimmed = name.strip().strip('"')
    if not trimmed:
        raise BridgeError("mailbox name is required")

    if kind == "folder":
        return trimmed if trimmed.startswith("Folders/") else f"Folders/{trimmed}"
    if kind == "label":
        return trimmed if trimmed.startswith("Labels/") else f"Labels/{trimmed}"
    return trimmed


def _parse_mailbox_line(line: str) -> dict[str, Any]:
    match = re.match(r'^\((?P<flags>[^)]*)\)\s+"(?P<delimiter>[^"]*)"\s+"(?P<name>.*)"$', line)
    if not match:
        return {"raw": line, "name": line, "kind": "mailbox", "flags": [], "selectable": True}

    flags = [flag for flag in match.group("flags").split() if flag]
    name = match.group("name")
    kind = "mailbox"
    if name == "Folders":
        kind = "folders_root"
    elif name == "Labels":
        kind = "labels_root"
    elif name.startswith("Folders/"):
        kind = "folder"
    elif name.startswith("Labels/"):
        kind = "label"

    return {
        "raw": line,
        "name": name,
        "kind": kind,
        "flags": flags,
        "delimiter": match.group("delimiter"),
        "selectable": "\\Noselect" not in flags,
    }


@dataclass(slots=True)
class BridgeSettings:
    host: str = _env_str("PROTON_BRIDGE_HOST", "127.0.0.1")
    imap_port: int = _env_int("PROTON_BRIDGE_IMAP_PORT", 1143)
    smtp_port: int = _env_int("PROTON_BRIDGE_SMTP_PORT", 1025)
    username: str = _env_str("PROTON_BRIDGE_USERNAME")
    password: str = _env_str("PROTON_BRIDGE_PASSWORD")
    imap_security: str = _env_str("PROTON_BRIDGE_IMAP_SECURITY", "starttls").lower()
    smtp_security: str = _env_str("PROTON_BRIDGE_SMTP_SECURITY", "starttls").lower()
    timeout_seconds: int = _env_int("PROTON_BRIDGE_TIMEOUT", 20)
    autostart: bool = _env_bool("PROTON_BRIDGE_AUTOSTART", False)
    autostart_command: str = _env_str("PROTON_BRIDGE_AUTOSTART_COMMAND", "protonmail-bridge")


class BridgeError(RuntimeError):
    pass


settings = BridgeSettings()
_bridge_autostart_lock = threading.Lock()
_bridge_autostart_attempted = False


def _error_payload(message: str) -> dict[str, Any]:
    return {"ok": False, "error": message}


def _masked_settings() -> dict[str, Any]:
    return {
        "host": settings.host,
        "imap_port": settings.imap_port,
        "smtp_port": settings.smtp_port,
        "username": settings.username,
        "password_configured": bool(settings.password),
        "imap_security": settings.imap_security,
        "smtp_security": settings.smtp_security,
        "timeout_seconds": settings.timeout_seconds,
        "autostart": settings.autostart,
        "autostart_command": settings.autostart_command,
    }


def _port_reachable(port: int) -> bool:
    try:
        with socket.create_connection((settings.host, port), timeout=1):
            return True
    except OSError:
        return False


def _bridge_reachable() -> bool:
    return _port_reachable(settings.imap_port) and _port_reachable(settings.smtp_port)


def _bridge_command() -> list[str]:
    command = shlex.split(settings.autostart_command)
    if not command:
        raise BridgeError("Bridge autostart command is empty")

    executable = command[0]
    if not shutil.which(executable):
        raise BridgeError(f"Bridge autostart command not found: {settings.autostart_command}")

    return command


def _start_bridge(wait: bool = True) -> None:
    global _bridge_autostart_attempted

    with _bridge_autostart_lock:
        if not _bridge_reachable():
            command = _bridge_command()
            try:
                subprocess.Popen(  # noqa: S603
                    command,
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                    stdin=subprocess.DEVNULL,
                    start_new_session=True,
                )
            except OSError as exc:
                raise BridgeError(f"failed to start Bridge GUI: {exc}") from exc

            _bridge_autostart_attempted = True

    if not wait:
        return

    deadline = time.monotonic() + settings.timeout_seconds
    while time.monotonic() < deadline:
        if _bridge_reachable():
            return
        time.sleep(0.5)

    raise BridgeError("Bridge GUI started but IMAP/SMTP ports did not become ready in time")


def _ensure_bridge_running() -> None:
    if _bridge_reachable() or not settings.autostart:
        return

    _start_bridge(wait=True)


def _stop_bridge() -> bool:
    global _bridge_autostart_attempted

    executable = os.path.basename(_bridge_command()[0])
    patterns = [executable, "/usr/lib/protonmail/bridge/bridge"]
    stopped = False

    for pattern in patterns:
        try:
            proc = subprocess.run(  # noqa: S603
                ["pkill", "-f", pattern],
                check=False,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
            )
        except OSError as exc:
            raise BridgeError(f"failed to stop Bridge GUI: {exc}") from exc

        if proc.returncode == 0:
            stopped = True
        elif proc.returncode not in {0, 1}:
            raise BridgeError(f"failed to stop Bridge GUI for pattern: {pattern}")

    deadline = time.monotonic() + settings.timeout_seconds
    while time.monotonic() < deadline:
        if not _bridge_reachable():
            _bridge_autostart_attempted = False
            return stopped
        time.sleep(0.5)

    raise BridgeError("Bridge stop command ran but IMAP/SMTP ports are still reachable")


def _require_config() -> None:
    missing: list[str] = []
    if not settings.username:
        missing.append("PROTON_BRIDGE_USERNAME")
    if not settings.password:
        missing.append("PROTON_BRIDGE_PASSWORD")
    if missing:
        raise BridgeError(
            "missing required Bridge mailbox settings: " + ", ".join(missing)
        )

    valid_security = {"ssl", "starttls", "plain"}
    if settings.imap_security not in valid_security:
        raise BridgeError(
            "invalid PROTON_BRIDGE_IMAP_SECURITY; expected one of: ssl, starttls, plain"
        )
    if settings.smtp_security not in valid_security:
        raise BridgeError(
            "invalid PROTON_BRIDGE_SMTP_SECURITY; expected one of: ssl, starttls, plain"
        )

    _ensure_bridge_running()


def _ssl_context() -> ssl.SSLContext:
    context = ssl.create_default_context()
    context.check_hostname = False
    context.verify_mode = ssl.CERT_NONE
    return context


def _decode_header_value(value: str | None) -> str:
    if not value:
        return ""
    parts = email.header.decode_header(value)
    decoded: list[str] = []
    for chunk, encoding in parts:
        if isinstance(chunk, bytes):
            decoded.append(chunk.decode(encoding or "utf-8", errors="replace"))
        else:
            decoded.append(chunk)
    return "".join(decoded)


def _extract_text_body(message: email.message.Message) -> str:
    if message.is_multipart():
        for part in message.walk():
            if part.get_content_maintype() == "multipart":
                continue
            if part.get_content_disposition() == "attachment":
                continue
            if part.get_content_type() == "text/plain":
                payload = part.get_payload(decode=True) or b""
                charset = part.get_content_charset() or "utf-8"
                return payload.decode(charset, errors="replace")
        return ""

    payload = message.get_payload(decode=True) or b""
    charset = message.get_content_charset() or "utf-8"
    return payload.decode(charset, errors="replace")


def _address_list(message: email.message.Message, header_name: str) -> list[str]:
    return [address for _, address in getaddresses(message.get_all(header_name, [])) if address]


def _summarize_message(uid: bytes, message: email.message.Message) -> dict[str, Any]:
    text_body = _extract_text_body(message)
    flags = message.get("X-Keywords", "")
    return {
        "uid": uid.decode(),
        "message_id": _decode_header_value(message.get("Message-ID")),
        "subject": _decode_header_value(message.get("Subject")),
        "from": _decode_header_value(message.get("From")),
        "to": _address_list(message, "To"),
        "date": _decode_header_value(message.get("Date")),
        "preview": _preview_text(text_body),
        "flags": flags,
    }


class IMAPClient:
    def __enter__(self) -> "IMAPClient":
        _require_config()
        socket.setdefaulttimeout(settings.timeout_seconds)
        context = _ssl_context()

        if settings.imap_security == "ssl":
            client: imaplib.IMAP4 | imaplib.IMAP4_SSL = imaplib.IMAP4_SSL(
                settings.host,
                settings.imap_port,
                ssl_context=context,
            )
        else:
            client = imaplib.IMAP4(settings.host, settings.imap_port)
            if settings.imap_security == "starttls":
                client.starttls(context)

        client.login(settings.username, settings.password)
        self.client = client
        return self

    def __exit__(self, exc_type: Any, exc: Any, tb: Any) -> None:
        try:
            self.client.logout()
        except Exception:
            pass

    def list_mailboxes(self) -> list[dict[str, Any]]:
        status, data = self.client.list()
        if status != "OK":
            raise BridgeError("failed to list IMAP mailboxes")
        return [
            _parse_mailbox_line(item.decode("utf-8", errors="replace"))
            for item in data
            if item
        ]

    def mailbox_exists(self, mailbox: str) -> bool:
        return any(entry["name"] == mailbox for entry in self.list_mailboxes())

    def select_mailbox(self, mailbox: str, readonly: bool = True) -> None:
        status, _ = self.client.select(_quote_mailbox(mailbox), readonly=readonly)
        if status != "OK":
            raise BridgeError(f"failed to select mailbox: {mailbox}")

    def create_mailbox(self, mailbox: str) -> bool:
        if self.mailbox_exists(mailbox):
            return False

        status, data = self.client.create(_quote_mailbox(mailbox))
        if status != "OK":
            message = data[0].decode("utf-8", errors="replace") if data and data[0] else "unknown error"
            raise BridgeError(f"failed to create mailbox {mailbox}: {message}")
        return True

    def delete_mailbox(self, mailbox: str) -> bool:
        if not self.mailbox_exists(mailbox):
            return False

        status, data = self.client.delete(_quote_mailbox(mailbox))
        if status != "OK":
            message = data[0].decode("utf-8", errors="replace") if data and data[0] else "unknown error"
            raise BridgeError(f"failed to delete mailbox {mailbox}: {message}")
        return True

    def search_uids(self, mailbox: str, unread_only: bool) -> list[bytes]:
        self.select_mailbox(mailbox)
        criterion = "UNSEEN" if unread_only else "ALL"
        status, data = self.client.uid("search", None, criterion)
        if status != "OK":
            raise BridgeError(f"failed to search mailbox: {mailbox}")
        raw = data[0] if data and data[0] else b""
        return [item for item in raw.split() if item]

    def fetch_headers(self, mailbox: str, uids: list[bytes]) -> list[dict[str, Any]]:
        self.select_mailbox(mailbox)
        messages: list[dict[str, Any]] = []
        for uid in uids:
            status, data = self.client.uid(
                "fetch",
                uid,
                "(BODY.PEEK[HEADER.FIELDS (DATE FROM TO SUBJECT MESSAGE-ID X-KEYWORDS)])",
            )
            if status != "OK" or not data or not data[0]:
                continue

            header_bytes = data[0][1] if isinstance(data[0], tuple) else b""
            message = email.message_from_bytes(header_bytes)
            messages.append(_summarize_message(uid, message))
        return messages

    def copy_message(self, source_mailbox: str, uid: str, destination_mailbox: str) -> None:
        self.select_mailbox(source_mailbox)
        status, data = self.client.uid("copy", uid, _quote_mailbox(destination_mailbox))
        if status != "OK":
            message = data[0].decode("utf-8", errors="replace") if data and data[0] else "unknown error"
            raise BridgeError(
                f"failed to copy message uid={uid} from {source_mailbox} to {destination_mailbox}: {message}"
            )

    def move_message(self, source_mailbox: str, uid: str, destination_mailbox: str) -> str:
        self.select_mailbox(source_mailbox, readonly=False)
        status, data = self.client.uid("move", uid, _quote_mailbox(destination_mailbox))
        if status == "OK":
            return "move"

        self.copy_message(source_mailbox, uid, destination_mailbox)
        self.select_mailbox(source_mailbox, readonly=False)
        status, data = self.client.uid("store", uid, "+FLAGS.SILENT", r"(\\Deleted)")
        if status != "OK":
            message = data[0].decode("utf-8", errors="replace") if data and data[0] else "unknown error"
            raise BridgeError(
                f"copied message uid={uid} but failed to mark source deleted in {source_mailbox}: {message}"
            )

        status, data = self.client.expunge()
        if status != "OK":
            message = data[0].decode("utf-8", errors="replace") if data and data[0] else "unknown error"
            raise BridgeError(
                f"copied message uid={uid} but failed to expunge source mailbox {source_mailbox}: {message}"
            )

        return "copy-delete"

    def fetch_message(self, mailbox: str, uid: str) -> dict[str, Any]:
        self.select_mailbox(mailbox)
        status, data = self.client.uid("fetch", uid, "(RFC822)")
        if status != "OK" or not data or not data[0]:
            raise BridgeError(f"failed to fetch message uid={uid} from {mailbox}")

        raw_bytes = data[0][1] if isinstance(data[0], tuple) else b""
        message = email.message_from_bytes(raw_bytes)
        attachments: list[dict[str, Any]] = []
        for part in message.walk():
            filename = part.get_filename()
            if not filename:
                continue
            payload = part.get_payload(decode=True) or b""
            attachments.append(
                {
                    "filename": _decode_header_value(filename),
                    "content_type": part.get_content_type(),
                    "size": len(payload),
                }
            )

        text_body = _extract_text_body(message)
        return {
            "ok": True,
            "mailbox": mailbox,
            "uid": uid,
            "message_id": _decode_header_value(message.get("Message-ID")),
            "subject": _decode_header_value(message.get("Subject")),
            "from": _decode_header_value(message.get("From")),
            "to": _address_list(message, "To"),
            "cc": _address_list(message, "Cc"),
            "bcc": _address_list(message, "Bcc"),
            "reply_to": _address_list(message, "Reply-To"),
            "date": _decode_header_value(message.get("Date")),
            "text_body": text_body,
            "preview": _preview_text(text_body, limit=600),
            "attachments": attachments,
        }


class SMTPClient:
    def __enter__(self) -> "SMTPClient":
        _require_config()
        socket.setdefaulttimeout(settings.timeout_seconds)
        context = _ssl_context()

        if settings.smtp_security == "ssl":
            client: smtplib.SMTP | smtplib.SMTP_SSL = smtplib.SMTP_SSL(
                settings.host,
                settings.smtp_port,
                timeout=settings.timeout_seconds,
                context=context,
            )
        else:
            client = smtplib.SMTP(
                settings.host,
                settings.smtp_port,
                timeout=settings.timeout_seconds,
            )
            client.ehlo()
            if settings.smtp_security == "starttls":
                client.starttls(context=context)
                client.ehlo()

        client.login(settings.username, settings.password)
        self.client = client
        return self

    def __exit__(self, exc_type: Any, exc: Any, tb: Any) -> None:
        try:
            self.client.quit()
        except Exception:
            pass


@mcp.tool(description="Show Proton Bridge IMAP/SMTP MCP runtime configuration")
def bridge_config() -> dict[str, Any]:
    return {"ok": True, "settings": _masked_settings()}


@mcp.tool(description="Check whether the configured Proton Bridge IMAP and SMTP endpoints are reachable")
def bridge_status() -> dict[str, Any]:
    try:
        _require_config()
        imap_ok = False
        smtp_ok = False
        imap_error = None
        smtp_error = None

        try:
            with IMAPClient():
                imap_ok = True
        except Exception as exc:
            imap_error = str(exc)

        try:
            with SMTPClient():
                smtp_ok = True
        except Exception as exc:
            smtp_error = str(exc)

        return {
            "ok": imap_ok and smtp_ok,
            "imap": {"ok": imap_ok, "error": imap_error},
            "smtp": {"ok": smtp_ok, "error": smtp_error},
            "settings": _masked_settings(),
        }
    except BridgeError as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Start the Proton Bridge GUI and wait for IMAP/SMTP")
def bridge_start() -> dict[str, Any]:
    try:
        _require_config()
        already_running = _bridge_reachable()
        if not already_running:
            _start_bridge(wait=True)
        return {
            "ok": True,
            "already_running": already_running,
            "reachable": _bridge_reachable(),
        }
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Stop the Proton Bridge GUI and wait for IMAP/SMTP to close")
def bridge_stop() -> dict[str, Any]:
    try:
        stopped = _stop_bridge()
        return {
            "ok": True,
            "stopped": stopped,
            "reachable": _bridge_reachable(),
        }
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="List available mailboxes exposed by Proton Bridge IMAP")
def bridge_mailboxes() -> dict[str, Any]:
    try:
        with IMAPClient() as imap:
            mailboxes = imap.list_mailboxes()
            return {"ok": True, "count": len(mailboxes), "mailboxes": mailboxes}
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Create a Proton Bridge folder or label mailbox")
def bridge_create_mailbox(name: str, kind: str = "folder") -> dict[str, Any]:
    try:
        if kind not in {"folder", "label", "mailbox"}:
            raise BridgeError("kind must be one of: folder, label, mailbox")

        mailbox = _normalize_mailbox_name(name, kind)
        with IMAPClient() as imap:
            created = imap.create_mailbox(mailbox)
            return {"ok": True, "mailbox": mailbox, "kind": kind, "created": created}
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Delete a Proton Bridge folder, label, or raw mailbox path")
def bridge_delete_mailbox(name: str, kind: str = "folder") -> dict[str, Any]:
    try:
        if kind not in {"folder", "label", "mailbox"}:
            raise BridgeError("kind must be one of: folder, label, mailbox")

        mailbox = _normalize_mailbox_name(name, kind)
        with IMAPClient() as imap:
            deleted = imap.delete_mailbox(mailbox)
            return {"ok": True, "mailbox": mailbox, "kind": kind, "deleted": deleted}
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="List mailbox messages from newest to oldest with pagination")
def bridge_list_messages(
    mailbox: str = "INBOX",
    limit: int = 10,
    unread_only: bool = False,
    offset: int = 0,
) -> dict[str, Any]:
    try:
        safe_limit = max(1, min(limit, 100))
        safe_offset = max(0, offset)
        with IMAPClient() as imap:
            uids = imap.search_uids(mailbox, unread_only)
            total_matches = len(uids)

            # IMAP SEARCH returns UIDs in ascending order, so slice from the end
            # to page newest-first without losing access to older messages.
            end = total_matches - safe_offset
            start = max(0, end - safe_limit)
            selected = uids[start:end]
            selected.reverse()
            messages = imap.fetch_headers(mailbox, selected)
            next_offset = safe_offset + len(messages)
            return {
                "ok": True,
                "mailbox": mailbox,
                "offset": safe_offset,
                "limit": safe_limit,
                "total_matches": total_matches,
                "count": len(messages),
                "messages": messages,
                "has_more": start > 0,
                "next_offset": next_offset if start > 0 else None,
            }
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Fetch one message body and metadata from Proton Bridge IMAP by UID")
def bridge_get_message(uid: str, mailbox: str = "INBOX") -> dict[str, Any]:
    try:
        with IMAPClient() as imap:
            return imap.fetch_message(mailbox, uid)
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Copy a message into a Proton Bridge label or mailbox")
def bridge_copy_message(uid: str, source_mailbox: str = "INBOX", destination: str = "", destination_kind: str = "mailbox") -> dict[str, Any]:
    try:
        if destination_kind not in {"folder", "label", "mailbox"}:
            raise BridgeError("destination_kind must be one of: folder, label, mailbox")

        target_mailbox = _normalize_mailbox_name(destination, destination_kind)
        with IMAPClient() as imap:
            if not imap.mailbox_exists(target_mailbox):
                raise BridgeError(f"destination mailbox does not exist: {target_mailbox}")
            imap.copy_message(source_mailbox, uid, target_mailbox)
            return {
                "ok": True,
                "uid": uid,
                "source_mailbox": source_mailbox,
                "destination_mailbox": target_mailbox,
                "operation": "copy",
            }
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Move a message into a Proton Bridge folder or mailbox")
def bridge_move_message(uid: str, source_mailbox: str = "INBOX", destination: str = "", destination_kind: str = "mailbox") -> dict[str, Any]:
    try:
        if destination_kind not in {"folder", "mailbox"}:
            raise BridgeError("destination_kind must be one of: folder, mailbox")

        target_mailbox = _normalize_mailbox_name(destination, destination_kind)
        with IMAPClient() as imap:
            if not imap.mailbox_exists(target_mailbox):
                raise BridgeError(f"destination mailbox does not exist: {target_mailbox}")
            method = imap.move_message(source_mailbox, uid, target_mailbox)
            return {
                "ok": True,
                "uid": uid,
                "source_mailbox": source_mailbox,
                "destination_mailbox": target_mailbox,
                "operation": method,
            }
    except Exception as exc:
        return _error_payload(str(exc))


@mcp.tool(description="Send an email through Proton Bridge SMTP")
def bridge_send_email(
    to: list[str],
    subject: str,
    body_text: str,
    cc: list[str] | None = None,
    bcc: list[str] | None = None,
    reply_to: str | None = None,
) -> dict[str, Any]:
    try:
        if not to:
            raise BridgeError("at least one recipient is required")

        cc = cc or []
        bcc = bcc or []

        message = EmailMessage()
        message["From"] = settings.username
        message["To"] = ", ".join(to)
        if cc:
            message["Cc"] = ", ".join(cc)
        if reply_to:
            message["Reply-To"] = reply_to
        message["Subject"] = subject
        message["Message-ID"] = make_msgid()
        message.set_content(body_text)

        recipients = [*to, *cc, *bcc]

        with SMTPClient() as smtp:
            smtp.client.send_message(message, from_addr=settings.username, to_addrs=recipients)

        return {
            "ok": True,
            "from": settings.username,
            "to": to,
            "cc": cc,
            "bcc_count": len(bcc),
            "subject": subject,
            "message_id": message["Message-ID"],
        }
    except Exception as exc:
        return _error_payload(str(exc))


def main() -> None:
    mcp.run()


if __name__ == "__main__":
    main()
