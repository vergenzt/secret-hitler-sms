#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
trap "kill 0" EXIT
source scripts/_lib.sh

start_sms_reply_listener() {
  # set up server to listen for discard choices
  echo -n "Starting ngrok server... "
  F_SECRET_NGROK_LOG=$SECRET/ngrok.json
  ngrok http --log=stdout --log-format=json 8080 > $F_SECRET_NGROK_LOG &
  sleep 5 # workaround cause tail -f way wasn't terminating
  SECRET_NGROK_URL=$(
    cat $F_SECRET_NGROK_LOG \
      | grep ',"msg":"started tunnel","name":"command_line"' \
      | head -n1 \
      | jq -r .url
  )
  echo "Done."
  echo -n "Updating Twilio callback URL... "
  twilio phone-numbers:update $PUBLIC_SOURCE_PHONE --sms-url=$SECRET_NGROK_URL >/dev/null
  echo "Done."
}

await_sms_reply_from() {
  FROM=$1
  TWILIO_RESP=""
  echo -n "Listening for SMS reply... "
  until grep -q "&From=$(echo $FROM | tr '+' '%2B')&" <(echo $TWILIO_RESP); do
    TWILIO_RESP=`nc -l localhost 8080 < $STATIC/twilio-empty-response.xml | tee /dev/stderr`
  done
  echo "Done."
  echo "$TWILIO_RESP"
}

ensure_drawable_policy_deck() {
  if [[ "$SECRET_POLICY_DECK_LENGTH" -lt 3 ]]; then
    echo "$SECRET_POLICY_DECK_LENGTH policies remaining; re-shuffling policy deck."
    cat "$F_PUBLIC_POLICIES_AVAILABLE" | gshuf > $F_SECRET_POLICY_DECK
  fi
}

legislate() {
  # who's president?
  read -p "Who's President?  ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
  read -p "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_CHANCELLOR_NAME
  PUBLIC_PRESIDENT_PHONE=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_PRESIDENT_NAME" 2`
  PUBLIC_PRESIDENT_PREFIX=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_PRESIDENT_NAME" 3`
  PUBLIC_CHANCELLOR_PHONE=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_CHANCELLOR_NAME" 2`
  PUBLIC_CHANCELLOR_PREFIX=`lookup "$PUBLIC_PLAYER_INFO" "$PUBLIC_CHANCELLOR_NAME" 3`

  # if [[ "$1" != "-f" && "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
  #   echo "Error: President must be different than chancellor!"
  #   return
  # fi
  #
  ensure_drawable_policy_deck

  SECRET_POLICIES=($(tail -n3 "$F_SECRET_POLICY_DECK"))

  PRESIDENT_MSG=$(echo -e \
    "Congratulations on the election, $PUBLIC_PRESIDENT_PREFIX President."\
    "Here are your policy choices.\n\n"\
    "Reply 1 to discard the left ${SECRET_POLICIES[0]} policy and pass ${SECRET_POLICIES[1]}-${SECRET_POLICIES[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    "Reply 2 to discard the middle ${SECRET_POLICIES[1]} policy and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[2]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
    "Reply 3 to discard the right ${SECRET_POLICIES[2]} policy and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[1]} to Chancellor $PUBLIC_CHANCELLOR_NAME.\n\n"\
  )
  PRESIDENT_IMAGE=`image_url policycombo $(IFS="-"; echo "${SECRET_POLICIES[*]}")`
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"

  # discard

  # send remainder to chancellor

  # await discard choice

  # discard

  # send remainder to everybody else

}
