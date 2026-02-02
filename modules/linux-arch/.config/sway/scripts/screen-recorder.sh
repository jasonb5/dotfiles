#!/bin/bash

# Check for region flag
REGION=""
if [[ "$1" == "-r" ]]; then
    REGION=$(slurp)
    # If user cancels, exit
    [[ -z "$REGION" ]] && exit 1
    REGION_OPT="-g $REGION"
else
    REGION_OPT=""
fi

pid=$(pgrep wf-recorder)

if [[ "$?" != 0 ]]; then
    wf-recorder $REGION_OPT -f "$(xdg-user-dir VIDEOS)/$(date +'%Y-%m-%d_%H-%M-%S').mkv"
else
    pkill --signal SIGINT wf-recorder
fi

