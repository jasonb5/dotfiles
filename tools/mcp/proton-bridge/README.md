# proton-bridge MCP

MCP server for talking to a running Proton Mail Bridge instance over its local IMAP and SMTP endpoints.

## What it does

- Connects to Proton Bridge IMAP to list mailboxes and read messages
- Connects to Proton Bridge SMTP to send mail
- Avoids driving the interactive Bridge CLI entirely

## Configuration

Set these environment variables from your Proton Bridge mailbox details:

- `PROTON_BRIDGE_HOST`: Bridge host, default `127.0.0.1`
- `PROTON_BRIDGE_IMAP_PORT`: IMAP port, default `1143`
- `PROTON_BRIDGE_SMTP_PORT`: SMTP port, default `1025`
- `PROTON_BRIDGE_USERNAME`: Bridge mailbox username
- `PROTON_BRIDGE_PASSWORD`: Bridge mailbox password
- `PROTON_BRIDGE_IMAP_SECURITY`: `ssl`, `starttls`, or `plain`, default `starttls`
- `PROTON_BRIDGE_SMTP_SECURITY`: `ssl`, `starttls`, or `plain`, default `starttls`
- `PROTON_BRIDGE_TIMEOUT`: socket timeout in seconds, default `20`
- `PROTON_BRIDGE_AUTOSTART`: set to `1` to launch the Bridge GUI if its local ports are down
- `PROTON_BRIDGE_AUTOSTART_COMMAND`: command to launch the Bridge GUI, default `protonmail-bridge`

If your Bridge is configured for SSL instead of STARTTLS, set the security variables accordingly.

## OpenCode integration

Example MCP entry:

```json
{
  "mcp": {
    "proton_bridge": {
      "type": "local",
      "enabled": true,
      "command": [
        "uv",
        "run",
        "--directory",
        "/home/titters/devel/personal/dotfiles/tools/mcp/proton-bridge",
        "python",
        "-m",
        "proton_bridge_mcp.server"
      ],
      "environment": {
        "PROTON_BRIDGE_HOST": "{env:PROTON_BRIDGE_HOST}",
        "PROTON_BRIDGE_IMAP_PORT": "{env:PROTON_BRIDGE_IMAP_PORT}",
        "PROTON_BRIDGE_SMTP_PORT": "{env:PROTON_BRIDGE_SMTP_PORT}",
        "PROTON_BRIDGE_USERNAME": "{env:PROTON_BRIDGE_USERNAME}",
        "PROTON_BRIDGE_PASSWORD": "{env:PROTON_BRIDGE_PASSWORD}",
        "PROTON_BRIDGE_IMAP_SECURITY": "{env:PROTON_BRIDGE_IMAP_SECURITY}",
        "PROTON_BRIDGE_SMTP_SECURITY": "{env:PROTON_BRIDGE_SMTP_SECURITY}",
        "PROTON_BRIDGE_AUTOSTART": "{env:PROTON_BRIDGE_AUTOSTART}",
        "PROTON_BRIDGE_AUTOSTART_COMMAND": "{env:PROTON_BRIDGE_AUTOSTART_COMMAND}"
      },
      "timeout": 20000
    }
  }
}
```

## Tools

- `bridge_config`: show sanitized IMAP/SMTP runtime settings
- `bridge_status`: test IMAP and SMTP connectivity/authentication
- `bridge_start`: launch Proton Bridge and wait for IMAP/SMTP to become reachable
- `bridge_stop`: stop Proton Bridge and wait for IMAP/SMTP to go away
- `bridge_mailboxes`: list available IMAP mailboxes, including `Folders/...` and `Labels/...`
- `bridge_create_mailbox`: create a folder, label, or raw mailbox path
- `bridge_delete_mailbox`: delete a folder, label, or raw mailbox path
- `bridge_list_messages`: list mailbox messages by UID, newest first, with `offset` pagination
- `bridge_get_message`: fetch a full message body and metadata by UID
- `bridge_copy_message`: copy a message into another mailbox or label
- `bridge_move_message`: move a message into another mailbox or folder
- `bridge_send_email`: send a plaintext message through Bridge SMTP

## Notes

- This server can optionally launch the Bridge GUI, but Bridge still needs an existing logged-in profile.
- It uses the local TLS endpoints exposed by Bridge and intentionally skips certificate verification, matching the common local-client setup for Bridge.
- It does not manage Bridge settings or interactive login.
- Proton Bridge exposes folders and labels as IMAP mailboxes. In this MCP, folders map to `Folders/<name>` and labels map to `Labels/<name>`.
- Applying a label is modeled as copying a message into a label mailbox. Moving a message is intended for folders or other mailboxes.
- `bridge_list_messages` pages over IMAP `UID SEARCH` results in memory. Use `offset=0` for the newest page, then pass the returned `next_offset` to fetch older pages.

## Local development

```sh
uv run --directory tools/mcp/proton-bridge python -m proton_bridge_mcp.server
```
