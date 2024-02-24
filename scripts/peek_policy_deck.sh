#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

while [[ -z "$PEEKER" || "$PEEKER" != "$PEEKER_CONFIRM" ]]; do
  read -p "Who gets to peek at the policy deck? ($PUBLIC_PLAYER_NAMES_PROMPT): " PEEKER
  read -p "Type again to confirm: " PEEKER_CONFIRM
done

ensure_drawable_policy_deck

echo -n "Sending preview of top three policies to $PEEKER... "
TOP_POLICIES=$(echo -n "$(head -n3 $SECRET/policy-deck.txt)" | tr -d '[[:digit:]]' | tr '\n' '-')
PEEKER_PHONE=$(lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PEEKER")
PEEKER_IMG=$(image_url policycombo "$TOP_POLICIES")
PEEKER_MSG="$(printf "%s\n" \
  "$PEEKER, here are the current top three policies on the policy deck:" \
  "" \
  "${TOP_POLICIES^^}" \
  "$PEEKER_IMG" \
)"

send_sms -d phone="$PEEKER_PHONE" -d message="$PEEKER_MSG"
echo "Done."
