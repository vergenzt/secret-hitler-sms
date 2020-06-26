#!/usr/bin/env bash
lookup() {
  echo "$1" | awk "\$1 == \"$2\" { print \$$3 }"
}

STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

# shellcheck disable=SC2206
send_sms() {
  PUBLIC_PHONE="$1"
  SECRET_MESSAGE=$(echo -en "\n\n$2")
  shift 2
  SECRET_PHOTOS=($@)
  twilio api:core:messages:create \
    --from "$PUBLIC_SOURCE_PHONE" \
    --to "$PUBLIC_PHONE" \
    --body "$SECRET_MESSAGE" \
    ${SECRET_PHOTOS[@]/#/--media-url } \
    >/dev/null
}

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

F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.txt
F_PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE 2>/dev/null`
PUBLIC_PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^(#|\s*$)'`
PUBLIC_PLAYER_NAMES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`

PUBLIC_NUM_PLAYERS=`cat $F_PUBLIC_PLAYER_INFO | wc -l`
PUBLIC_ROLES_ACTIVE=`head -n $PUBLIC_NUM_PLAYERS $F_PUBLIC_ROLES_AVAILABLE`

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_SECRET_POLICY_DECK=$SECRET/policy-deck.txt
F_SECRET_POLICY_DISCARD=$SECRET/policy-discard.txt

SECRET_POLICY_DECK_LENGTH=`cat $F_SECRET_POLICY_DECK 2>/dev/null | wc -l`
