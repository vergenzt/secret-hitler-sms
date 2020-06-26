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
  PUBLIC_PRESIDENT_PHONE=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_PRESIDENT_NAME" 2`
  PUBLIC_PRESIDENT_PREFIX=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_PRESIDENT_NAME" 3`
  PUBLIC_CHANCELLOR_PHONE=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_CHANCELLOR_NAME" 2`
  PUBLIC_CHANCELLOR_PREFIX=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_CHANCELLOR_NAME" 3`

  if [[ "$1" != "-f" && "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
    echo "Error: President must be different than chancellor!"
    return
  fi

  ensure_drawable_policy_deck

  SECRET_POLICY_OPTIONS=("$(head -n3 "$F_SECRET_POLICY_DECK")")
  tail -n+3 "$F_SECRET_POLICY_DECK" | sponge > "$F_SECRET_POLICY_DECK"

  PRESIDENT_MSG=$(echo -e \
    "Congratulations on the election, $PUBLIC_PRESIDENT_PREFIX President."\
    "Here are your policy choices.\n\n"\
    "Reply 1 to discard the left ${SECRET_POLICIES[0]} policy and pass ${SECRET_POLICIES[1]}-${SECRET_POLICIES[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    "Reply 2 to discard the middle ${SECRET_POLICIES[1]} policy and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    "Reply 3 to discard the right ${SECRET_POLICIES[2]} policy and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[1]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
  )
  PRESIDENT_IMAGE=`image_url policycombo $(IFS="-"; echo "${SECRET_POLICIES[*]}")`
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"

  while true; do
    PRESIDENT_RESPONSE=`await_sms_reply_from "$PUBLIC_PRESIDENT_PHONE"`
    case "$PRESIDENT_RESPONSE" in
      1) test; break;;
      2) test; break;;
      3) test; break;;
      *) echo "Invalid selection! Please submit again.";;
    esac
  done

  # discard

  # send remainder to chancellor

  # await discard choice

  # discard

  # send remainder to everybody else

}
