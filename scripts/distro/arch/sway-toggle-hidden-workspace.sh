#!/usr/bin/env bash
set -euo pipefail

state_file="${XDG_RUNTIME_DIR:-/tmp}/sway-scratchpad-stash-state"

focused_ws="$(swaymsg -t get_workspaces | python3 -c 'import json,sys; d=json.load(sys.stdin); print(next((w["name"] for w in d if w.get("focused")), ""))')"

if [[ -f "$state_file" ]]; then
    target_ws="$(sed -n '1p' "$state_file")"
    ids="$(sed -n '2,$p' "$state_file")"

    if [[ -n "$ids" ]]; then
        while IFS= read -r con_id; do
            [[ -z "$con_id" ]] && continue
            swaymsg "[con_id=${con_id}] move container to workspace \"${target_ws}\", floating disable" >/dev/null
        done <<<"$ids"
        swaymsg "workspace \"${target_ws}\"" >/dev/null
        rm -f "$state_file"
        exit 0
    fi
fi

tree_json="$(swaymsg -t get_tree)"
focused_ids="$(python3 -c 'import json,sys
root=json.load(sys.stdin)
ws_name=sys.argv[1]

def find_workspace_by_name(n, name):
    if isinstance(n, dict):
        if n.get("type") == "workspace" and n.get("name") == name:
            return n
        for k in ("nodes", "floating_nodes"):
            for c in n.get(k, []):
                r=find_workspace_by_name(c, name)
                if r is not None:
                    return r
    return None

def collect_leaf_container_ids(n, out):
    if not isinstance(n, dict):
        return
    ntype=n.get("type")
    if ntype == "con" and not n.get("nodes") and not n.get("floating_nodes") and n.get("id") is not None:
        out.append(str(n["id"]))
        return
    for k in ("nodes", "floating_nodes"):
        for c in n.get(k, []):
            collect_leaf_container_ids(c, out)

ws=find_workspace_by_name(root, ws_name)
ids=[]
if ws is not None:
    collect_leaf_container_ids(ws, ids)
print("\n".join(ids))
' "$focused_ws" <<<"$tree_json")"

[[ -n "$focused_ws" ]] || exit 0
printf '%s\n' "$focused_ws" > "$state_file"
if [[ -n "$focused_ids" ]]; then
    printf '%s\n' "$focused_ids" >> "$state_file"
    while IFS= read -r con_id; do
        [[ -z "$con_id" ]] && continue
        swaymsg "[con_id=${con_id}] move container to scratchpad" >/dev/null
    done <<<"$focused_ids"
fi
