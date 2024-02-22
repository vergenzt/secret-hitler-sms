#!/usr/bin/env bash
source "$LAMBDA_TASK_ROOT"/src/lib.sh

## httpApi: POST /game/{GAME_ID}/peek-policy-deck/{PRESIDENT_ID}

function peek-policy-deck() {

  while [[ -z "$PEEKER" || "$PEEKER" != "$PEEKER_CONFIRM" ]]; do
    read -rp "Who gets to peek at the policy deck? ($PUBLIC_PLAYER_NAMES_PROMPT): " PEEKER
    read -rp "Type again to confirm: " PEEKER_CONFIRM
  done

  ensure_drawable_policy_deck

  echo -n "Sending preview of top three policies to $PEEKER... "
  PEEKER_PHONE=$(lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PEEKER")
  PEEKER_MSG="$PEEKER, here are the current top three policies on the policy deck."
  PEEKER_IMG=$(image_url policycombo "$(echo -n "$(head -n3 "$SECRET/policy-deck.txt")" | tr -d '[:digit:]' | tr '\n' '-')")
  send_sms "$PEEKER_PHONE" "$PEEKER_MSG" "$PEEKER_IMG"
  echo "Done."

}
