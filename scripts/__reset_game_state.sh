#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
trap "kill 0" EXIT
source scripts/__lib.sh

read -p "To reset game state, please type RESET: "
rm -f $SECRET/{policy-{deck,options,discard,record},player-roles}.txt
