#!/usr/bin/env bash
source "$LAMBDA_TASK_ROOT"/src/lib.sh

## httpApi: POST /game/{GAME_ID}/legislate/{PRESIDENT_ID}/{CHANCELLOR_ID}

legislate-start() {
  ensure_drawable_policy_deck

  # who's president?
  while sleep 1; do
    read -rp "Who's President?  ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
    read -rp "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_CHANCELLOR_NAME
    PUBLIC_PRESIDENT_PHONE=$(lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_PRESIDENT_NAME")
    PUBLIC_PRESIDENT_TITLE=$(lookup "$PUBLIC_PLAYER_TITLES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_PRESIDENT_NAME")

    if [[ "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
      echo "Error: President must be different than chancellor!"
      continue
    fi

    PUBLIC_CHANCELLOR_PHONE=$(lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_CHANCELLOR_NAME")
    PUBLIC_CHANCELLOR_TITLE=$(lookup "$PUBLIC_PLAYER_TITLES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_CHANCELLOR_NAME")

    if [[ "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
      echo "Error: President must be different than chancellor!"
      continue
    fi

    read -rp "Confirm? (Y/N) " CONTINUE
    case $CONTINUE in
      y|Y|yes|YES) break;
    esac
  done

  draw_cards 3 "$SECRET/policy-deck.txt" "$SECRET/policy-options.txt"
  P1=$(pick_card 1 "$SECRET/policy-options.txt")
  P2=$(pick_card 2 "$SECRET/policy-options.txt")
  P3=$(pick_card 3 "$SECRET/policy-options.txt")

  echo -n "Sending policy options to President $PUBLIC_PRESIDENT_NAME... "
  PRESIDENT_MSG=$(
    echo -en "Congratulations on your election, $PUBLIC_PRESIDENT_TITLE President! "
    echo -en "Here are your policy choices.\n\n"
    echo -en "Reply 1 to discard the left $P1 policy and pass $P2-$P3 to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"
    echo -en "Reply 2 to discard the middle $P2 policy and pass $P1-$P3 to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"
    echo -en "Reply 3 to discard the right $P3 policy and pass $P1-$P2 to Chancellor $PUBLIC_CHANCELLOR_NAME."
  )
  PRESIDENT_IMAGE=$(image_url policycombo "$P1-$P2-$P3")
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"
  echo "Sent. Awaiting response."
  start_sms_reply_tunnel

  while sleep 1; do
    PRESIDENT_RESPONSE=$(await_sms_reply_from "$PUBLIC_PRESIDENT_PHONE")
    case "$PRESIDENT_RESPONSE" in
      [1-3]) break;;
      *) echo "Error: Invalid response: $PRESIDENT_RESPONSE! Please reply again.";;
    esac
  done

  move_card "$PRESIDENT_RESPONSE" "$SECRET/policy-options.txt" "$SECRET/policy-discard.txt"
  unset P1 P2 P3
  P1=$(pick_card 1 "$SECRET/policy-options.txt")
  P2=$(pick_card 2 "$SECRET/policy-options.txt")

  echo -n "Sending remaining policy options to Chancellor $PUBLIC_CHANCELLOR_NAME... "
  CHANCELLOR_MSG=$(
    echo -en "Congratulations on your election, $PUBLIC_CHANCELLOR_TITLE Chancellor. "
    echo -en "Here are your remaining policy choices.\n\n"
    echo -en "Reply 1 to discard the left $P1 policy and pass a $P2 policy.\n\n"
    echo -en "Reply 2 to discard the right $P2 policy and pass a $P1 policy."
  )
  CHANCELLOR_IMAGE=$(image_url policycombo "$P1-$P2")
  send_sms "$PUBLIC_CHANCELLOR_PHONE" "$CHANCELLOR_MSG" "$CHANCELLOR_IMAGE"
  echo "Sent. Awaiting response."

  while true; do
    CHANCELLOR_RESPONSE=$(await_sms_reply_from "$PUBLIC_CHANCELLOR_PHONE")
    case "$CHANCELLOR_RESPONSE" in
      [1-2]) break;;
      *) echo "Error: Invalid response: $CHANCELLOR_RESPONSE! Please reply again.";;
    esac
  done

  move_card "$CHANCELLOR_RESPONSE" "$SECRET/policy-options.txt" "$SECRET/policy-discard.txt"
  unset P1 P2
  PUBLIC_POLICY_PASSED=$(pick_card 1 "$SECRET/policy-options.txt")
  move_card 1 "$SECRET/policy-options.txt" "$PUBLIC/policies-enacted.txt"

  MSG="President $PUBLIC_PRESIDENT_NAME and Chancellor $PUBLIC_CHANCELLOR_NAME have passed a $PUBLIC_POLICY_PASSED policy." \

  for PHONE in $PUBLIC_PLAYER_PHONES; do
    send_sms "$PHONE" \
      "President $PUBLIC_PRESIDENT_NAME and Chancellor $PUBLIC_CHANCELLOR_NAME have passed a $PUBLIC_POLICY_PASSED policy." \
      "$(image_url policy "$PUBLIC_POLICY_PASSED")"
  done

  sleep 3
  echo
  echo "$MSG"
  echo

  echo
  wc -l $SECRET/policy-*.txt $PUBLIC/policies-enacted.txt
  echo
  ensure_drawable_policy_deck

}
