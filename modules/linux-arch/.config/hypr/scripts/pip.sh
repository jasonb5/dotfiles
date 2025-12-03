#!/usr/bin/env bash

active="$(hyprctl activewindow -j)"
tag="$(echo ${active} | jq -r '.tags | map(select(. | test("pip-.*"))) | if (. | length) > 0 then .[0] else "" end')"

if [[ -z "${tag}" ]]; then
    batch=""
    tag_postfix=""
    floating="$(echo ${active} | jq -r '.floating')"

    if [[ "${floating}" == "true" ]]; then
        size="$(echo ${active} | jq -r '.size | join("_")')"
        at="$(echo ${active} | jq -r '.at | join("_")')"

        tag_postfix="-${size}-${at}"
    else
        batch+="dispatch setfloating"
    fi

    batch+="; dispatch resizeactive exact 20% 20%; dispatch moveactive exact 75% 5%; dispatch tagwindow pip-${floating}${tag_postfix}"

    hyprctl --batch "${batch}"
else
    batch=""

    if [[ "$(echo ${tag} | cut -d'-' -f2 )" == "false" ]]; then
        batch+="dispatch settiled"
    else
        size="$(echo ${tag} | cut -d'-' -f3 | tr '_' ' ')"
        at="$(echo ${tag} | cut -d'-' -f4 | tr '_' ' ')"

        batch+="dispatch moveactive exact ${at}; dispatch resizeactive exact ${size}"
    fi

    batch+="; dispatch tagwindow ${tag}"

    hyprctl --batch "${batch}"
fi
