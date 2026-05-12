wg_setup() {
  local configure_now interface_name private_key interface_addresses dns_servers mtu
  local peer_public_key preshared_key peer_endpoint allowed_ips keepalive tmp_conf enable_now
  local generate_keypair client_public_key generate_preshared_key

  if [[ ! -t 0 ]]; then
    printf 'wg_setup: interactive terminal required\n' >&2
    return 1
  fi

  read -r -p "Configure a WireGuard tunnel now? [y/N]: " configure_now
  case "${configure_now,,}" in
    y|yes) ;;
    *)
      printf 'wg_setup: skipped\n'
      return 0
      ;;
  esac

  read -r -p "Interface name [wg0]: " interface_name
  interface_name="${interface_name:-wg0}"

  read -r -p "Generate client keypair now? [Y/n]: " generate_keypair
  case "${generate_keypair,,}" in
    ""|y|yes)
      if ! command -v wg >/dev/null 2>&1; then
        printf 'wg_setup: wg command not found (install wireguard-tools)\n' >&2
        return 1
      fi
      private_key="$(wg genkey)"
      client_public_key="$(printf '%s' "$private_key" | wg pubkey)"
      printf 'wg_setup: generated client keypair\n'
      printf 'wg_setup: client public key: %s\n' "$client_public_key"
      ;;
    *)
      read -r -s -p "Private key: " private_key
      printf '\n'
      [[ -n "$private_key" ]] || {
        printf 'wg_setup: private key is required\n' >&2
        return 1
      }
      client_public_key="$(printf '%s' "$private_key" | wg pubkey 2>/dev/null || true)"
      ;;
  esac

  read -r -p "Interface address(es) (comma separated CIDRs): " interface_addresses
  [[ -n "$interface_addresses" ]] || {
    printf 'wg_setup: at least one interface address is required\n' >&2
    return 1
  }

  read -r -p "DNS server(s) (optional, comma separated): " dns_servers
  read -r -p "MTU (optional): " mtu

  read -r -p "Peer public key: " peer_public_key
  [[ -n "$peer_public_key" ]] || {
    printf 'wg_setup: peer public key is required\n' >&2
    return 1
  }

  read -r -p "Generate preshared key now? [Y/n]: " generate_preshared_key
  case "${generate_preshared_key,,}" in
    ""|y|yes)
      if ! command -v wg >/dev/null 2>&1; then
        printf 'wg_setup: wg command not found (install wireguard-tools)\n' >&2
        return 1
      fi
      preshared_key="$(wg genpsk)"
      printf 'wg_setup: generated preshared key\n'
      ;;
    *)
      read -r -s -p "Preshared key: " preshared_key
      printf '\n'
      [[ -n "$preshared_key" ]] || {
        printf 'wg_setup: preshared key is required\n' >&2
        return 1
      }
      ;;
  esac

  read -r -p "Peer endpoint (host:port): " peer_endpoint
  [[ -n "$peer_endpoint" ]] || {
    printf 'wg_setup: peer endpoint is required\n' >&2
    return 1
  }

  read -r -p "Allowed IPs [0.0.0.0/0,::/0]: " allowed_ips
  allowed_ips="${allowed_ips:-0.0.0.0/0,::/0}"

  read -r -p "PersistentKeepalive (seconds, optional, default 25): " keepalive
  keepalive="${keepalive:-25}"

  tmp_conf="$(mktemp)"
  trap 'rm -f -- "$tmp_conf"' RETURN

  umask 077
  {
    printf '[Interface]\n'
    printf 'PrivateKey = %s\n' "$private_key"
    printf 'Address = %s\n' "$interface_addresses"
    if [[ -n "$dns_servers" ]]; then
      printf 'DNS = %s\n' "$dns_servers"
    fi
    if [[ -n "$mtu" ]]; then
      printf 'MTU = %s\n' "$mtu"
    fi
    printf '\n[Peer]\n'
    printf 'PublicKey = %s\n' "$peer_public_key"
    printf 'PresharedKey = %s\n' "$preshared_key"
    printf 'Endpoint = %s\n' "$peer_endpoint"
    printf 'AllowedIPs = %s\n' "$allowed_ips"
    if [[ -n "$keepalive" ]]; then
      printf 'PersistentKeepalive = %s\n' "$keepalive"
    fi
  } >"$tmp_conf"

  sudo install -Dm600 "$tmp_conf" "/etc/wireguard/${interface_name}.conf"
  printf 'wg_setup: wrote /etc/wireguard/%s.conf\n' "$interface_name"

  read -r -p "Enable and start wg-quick@${interface_name}.service now? [y/N]: " enable_now
  case "${enable_now,,}" in
    y|yes)
      sudo systemctl enable --now "wg-quick@${interface_name}.service"
      printf 'wg_setup: enabled wg-quick@%s.service\n' "$interface_name"
      ;;
    *)
      printf 'wg_setup: service left disabled\n'
      ;;
  esac

  if [[ -n "$client_public_key" ]]; then
    printf 'wg_setup: client public key (share with server): %s\n' "$client_public_key"
  fi
}
