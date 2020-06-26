#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
trap "kill 0" EXIT
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
  if [[ -z "$1" ]]; then
    echo "Error: No phone number provided to expect an SMS from!" >/dev/stderr
    return 1
  fi
  while true; do
    SMS_INFO=`nc -l localhost 8080 < $STATIC/twilio-empty-response.xml | tail -n1 | tr '&=' '\n '`
    echo $SMS_INFO >/dev/stderr
    SMS_FROM=`urldecode "$(lookup "$SMS_INFO" "From")"`
    SMS_BODY=`urldecode "$(lookup "$SMS_INFO" "Body")"`

    if [[ "$SMS_FROM" = "$1" ]]; then
      echo "$SMS_BODY"
      break
    else
      echo "Received SMS from wrong number. Expected: $1. Received from: $SMS_FROM." >/dev/stderr
    fi
  done
}

legislate() {
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

  ensure_drawable_policy_deck
  draw_cards 3 "$F_SECRET_POLICY_DECK" "$F_SECRET_POLICY_OPTIONS"
  SECRET_POLICY_OPTIONS=`cat "$F_SECRET_POLICY_OPTIONS"`

  echo -n "Sending policy options to President $PUBLIC_PRESIDENT_NAME... "
  PRESIDENT_MSG=$(
    echo -en "Congratulations on the election, $PUBLIC_PRESIDENT_TITLE President. "
    echo -en "Here are your policy choices.\n\n"
    echo -en "Reply 1 to discard the left ${SECRET_POLICY_OPTIONS[0]} policy and pass ${SECRET_POLICY_OPTIONS[1]}-${SECRET_POLICY_OPTIONS[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    echo -en "Reply 2 to discard the middle ${SECRET_POLICY_OPTIONS[1]} policy and pass ${SECRET_POLICY_OPTIONS[0]}-${SECRET_POLICY_OPTIONS[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    echo -en "Reply 3 to discard the right ${SECRET_POLICY_OPTIONS[2]} policy and pass ${SECRET_POLICY_OPTIONS[0]}-${SECRET_POLICY_OPTIONS[1]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
  )
  PRESIDENT_IMAGE=`image_url policycombo "$(IFS="-"; echo "${SECRET_POLICY_OPTIONS[*]}")"`
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"
  echo "Sent. Awaiting response."

  while true; do
    PRESIDENT_RESPONSE=`await_sms_reply_from "$PUBLIC_PRESIDENT_PHONE"`
    case "$PRESIDENT_RESPONSE" in
      [1-3]) break;;
      *) echo "Error: Invalid response: $PRESIDENT_RESPONSE! Please reply again.";;
    esac
  done

  # discard

  # send remainder to chancellor

  # await discard choice

  # discard

  # send remainder to everybody else

}
