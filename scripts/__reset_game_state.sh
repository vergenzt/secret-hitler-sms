#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

while [[ "$RESET" != "RESET" ]]; do
  read -rp "To reset game state, please type RESET: " RESET
done
rm -f $SECRET/{policy-{deck,options,discard},player-roles}.txt
rm -f $PUBLIC/policies-enacted.txt
