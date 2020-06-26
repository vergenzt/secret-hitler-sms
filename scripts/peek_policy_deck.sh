#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

while [[ -z "$PEEKER" || "$PEEKER" != "$PEEKER_CONFIRM" ]]; do
  read -p "Who gets to peek at the policy deck? ($PUBLIC_PLAYER_NAMES_PROMPT): " PEEKER
  read -p "Type again to confirm: " PEEKER_CONFIRM
done

ensure_drawable_policy_deck

echo -n "Sending preview of top three policies to $PEEKER... "
PEEKER_PHONE=$(lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PEEKER")
PEEKER_MSG="$PEEKER, here are the current top three policies on the policy deck."
PEEKER_IMG=`image_url policycombo "$(echo $(head -n3 $SECRET/policy-deck.txt) | tr -d '[[:digit:]]' | tr '\n' '-')"`
send_sms "$PEEKER_PHONE" "$PEEKER_MSG" "$PEEKER_IMG"
echo "Done."
