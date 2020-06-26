#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

FROM="$1"
TO="$2"

echo "You are about to show $FROM's Party Membership card to $TO."
while [[ "$RESET" != "RESET" ]]; do
  read -p "To reset game state, please type RESET: " RESET
done
rm -f $SECRET/{policy-{deck,options,discard},player-roles}.txt
rm -f $PUBLIC/policies-enacted.txt
send_sms "$(lookup "$PUBLIC_PLAYER_PHONES"
