#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

while [[ "${RESET:-}" != "RESET" ]]; do
  read -rp "To reset game state, please type RESET: " RESET
done

STATE_FILES=(
  "$SECRET"/player-roles.txt
  "$SECRET"/policy-{deck,options,discard}.txt
  "$PUBLIC"/policies-enacted.txt
)

set -x
rm -f "${STATE_FILES[@]}"
