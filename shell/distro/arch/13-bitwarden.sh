bw_run() {
  with_repo_secrets bw "$@"
}

bw_status() {
  bw_run status "$@"
}

bw_sync() {
  bw_run sync "$@"
}

bw_login() {
  bw_run login "$@"
}

bw_unlock() {
  local session

  session="$(bw_run unlock --raw "$@")" || return $?
  export BW_SESSION="$session"
  printf '%s\n' 'BW_SESSION exported for current shell'
}

bw_lock() {
  bw_run lock "$@"
  unset BW_SESSION
}

bw_logout() {
  bw_run logout "$@"
  unset BW_SESSION
}
