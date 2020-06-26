#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
# set -x
trap "set +x; kill 0" EXIT
source scripts/_lib.sh

start_sms_reply_tunnel() {
  ngrok http --log=stdout --log-format=json 8080 > $F_SECRET_NGROK_LOG &
  while true; do
    SECRET_NGROK_URL=`jq -r --unbuffered 'select(.msg == "started tunnel" and .name == "command_line") | .url' $F_SECRET_NGROK_LOG`
    if [[ -z "$SECRET_NGROK_URL" ]]; then
      sleep 1
    else
      twilio phone-numbers:update $PUBLIC_SOURCE_PHONE --sms-url=$SECRET_NGROK_URL >/dev/null
      break
    fi
  done
}

await_sms_reply_from() {
  SMS_FROM_EXPECTED="$1"
  if [[ -z "$SMS_FROM_EXPECTED" ]]; then
    echo "Error: No phone number provided to expect an SMS from!" >/dev/stderr
    return 1
  fi
  while sleep 1; do
    SMS_INFO=`nc -l localhost 8080 < $STATIC/twilio-empty-response.xml | tail -n1 | tr '&=' '\n '`
    echo $SMS_INFO >/dev/stderr
    SMS_FROM=`urldecode "$(lookup "$SMS_INFO" "From")"`
    SMS_BODY=`urldecode "$(lookup "$SMS_INFO" "Body")"`

    case "$SMS_FROM" in
      "$SMS_FROM_EXPECTED")
        echo "$SMS_BODY"
        return;;
      *)
        echo "Received SMS from wrong number. Expected: $SMS_FROM_EXPECTED. Received from: $SMS_FROM." >/dev/stderr
        break;;
    esac
  done
}

legislate() {
  ensure_drawable_policy_deck
  echo
  (cd $SECRET && wc -l policy-*.txt)
  echo

  # who's president?
  read -p "Who's President?  ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
  read -p "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_CHANCELLOR_NAME
  PUBLIC_PRESIDENT_PHONE=`lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_PRESIDENT_NAME"`
  PUBLIC_PRESIDENT_TITLE=`lookup "$PUBLIC_PLAYER_TITLES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_PRESIDENT_NAME"`
  PUBLIC_CHANCELLOR_PHONE=`lookup "$PUBLIC_PLAYER_PHONES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_CHANCELLOR_NAME"`
  PUBLIC_CHANCELLOR_TITLE=`lookup "$PUBLIC_PLAYER_TITLES" "$PUBLIC_PLAYER_NAMES" "$PUBLIC_CHANCELLOR_NAME"`

  if [[ "$1" != "-f" && "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
    echo "Error: President must be different than chancellor!"
    return
  fi

  draw_cards 3 "$F_SECRET_POLICY_DECK" "$F_SECRET_POLICY_OPTIONS"
  P1=`pick_card 1 "$F_SECRET_POLICY_OPTIONS"`
  P2=`pick_card 2 "$F_SECRET_POLICY_OPTIONS"`
  P3=`pick_card 3 "$F_SECRET_POLICY_OPTIONS"`

  echo -n "Sending policy options to President $PUBLIC_PRESIDENT_NAME... "
  PRESIDENT_MSG=$(
    echo -en "Congratulations on your election, $PUBLIC_PRESIDENT_TITLE President! "
    echo -en "Here are your policy choices.\n\n"
    echo -en "Reply 1 to discard the left $P1 policy and pass $P2-$P3 to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"
    echo -en "Reply 2 to discard the middle $P2 policy and pass $P1-$P3 to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"
    echo -en "Reply 3 to discard the right $P3 policy and pass $P1-$P2 to Chancellor $PUBLIC_CHANCELLOR_NAME."
  )
  PRESIDENT_IMAGE=`image_url policycombo "$P1-$P2-$P3"`
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"
  echo "Sent. Awaiting response."

  while sleep 1; do
    PRESIDENT_RESPONSE=`await_sms_reply_from "$PUBLIC_PRESIDENT_PHONE"`
    case "$PRESIDENT_RESPONSE" in
      [1-3]) break;;
      *) echo "Error: Invalid response: $PRESIDENT_RESPONSE! Please reply again.";;
    esac
  done

  move_card "$PRESIDENT_RESPONSE" "$F_SECRET_POLICY_OPTIONS" "$F_SECRET_POLICY_DISCARD"
  unset P1 P2 P3
  P1=`pick_card 1 "$F_SECRET_POLICY_OPTIONS"`
  P2=`pick_card 2 "$F_SECRET_POLICY_OPTIONS"`

  echo -n "Sending remaining policy options to Chancellor $PUBLIC_CHANCELLOR_NAME... "
  CHANCELLOR_MSG=$(
    echo -en "Congratulations on your election, $PUBLIC_CHANCELLOR_TITLE Chancellor! "
    echo -en "Here are your policy choices.\n\n"
    echo -en "Reply 1 to discard the left $P1 policy and pass $P2.\n\n"
    echo -en "Reply 2 to discard the right $P2 policy and pass $P1."
  )
  CHANCELLOR_IMAGE=`image_url policycombo "$P1-$P2"`
  send_sms "$PUBLIC_CHANCELLOR_PHONE" "$CHANCELLOR_MSG" "$CHANCELLOR_IMAGE"
  echo "Sent. Awaiting response."

  while true; do
    CHANCELLOR_RESPONSE=`await_sms_reply_from "$PUBLIC_CHANCELLOR_PHONE"`
    case "$CHANCELLOR_RESPONSE" in
      [1-2]) break;;
      *) echo "Error: Invalid response: $CHANCELLOR_RESPONSE! Please reply again.";;
    esac
  done

  move_card "$CHANCELLOR_RESPONSE" "$F_SECRET_POLICY_OPTIONS" "$F_SECRET_POLICY_DISCARD"
  unset P1 P2
  PUBLIC_POLICY_PASSED=`pick_card 1 "$F_SECRET_POLICY_OPTIONS"`

  echo "$PUBLIC_PLAYER_PHONES" \
    xargs send_sms \{\} \
      "President $PUBLIC_PRESIDENT_NAME and Chancellor $PUBLIC_CHANCELLOR_NAME have passed a $PUBLIC_POLICY_PASSED policy." \
      "`image_url policy "$PUBLIC_POLICY_PASSED"`"
}

legislate
