#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
debug() {
  trap 'kill $(jobs -p) &>/dev/null; set +x' EXIT SIGINT
  set -x
  "$@"
}

lookup() {
  echo "$1" | awk "\$1 == \"$2\" { print \$$3 }"
}

STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public
GAVEL=gavel.js/bin/gavel

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

# shellcheck disable=SC2206
send_sms() {
  PUBLIC_PHONE="$1"
  SECRET_MESSAGE="$2"
  shift 2
  SECRET_PHOTOS=($@)
  twilio api:core:messages:create \
    --from "$PUBLIC_SOURCE_PHONE" \
    --to "$PUBLIC_PHONE" \
    --body "$SECRET_MESSAGE" \
    ${SECRET_PHOTOS[@]/#/--media-url }
}

start_sms_reply_listener() {
  # set up server to listen for discard choices
  echo -n "Starting ngrok server... "
  F_SECRET_NGROK_LOG=$SECRET/ngrok.json
  (ngrok http --log=stdout --log-format=json 8080 > $F_SECRET_NGROK_LOG &) 2>/dev/null
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

assign_player_roles() {
  if [[ -f $F_SECRET_PLAYER_ROLES ]]; then
    echo "Error: $F_SECRET_PLAYER_ROLES already exists."
    echo -e "Is a game in progress?\n"
    echo "Please delete it if you're sure you want to start a new game."
    exit 1
  fi

  # assign
  echo "Assigning player roles!"
  SECRET_PLAYER_ROLES=`gpaste <(echo "$PUBLIC_PLAYER_NAMES") <(echo "$PUBLIC_ROLES_ACTIVE" | gshuf)`

  # save
  echo "$SECRET_PLAYER_ROLES" > $F_SECRET_PLAYER_ROLES

  # send texts
  while read PUBLIC_NAME PUBLIC_PHONE SECRET_ROLE SECRET_PARTY; do
    send_sms \
      "$PUBLIC_PHONE" \
      "Hi $PUBLIC_NAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
      "`image_url party $SECRET_PARTY`" \
      "`image_url role $SECRET_ROLE`"
  done < <(join $F_PUBLIC_PLAYER_INFO $F_SECRET_PLAYER_ROLES | tr ',' ' ')
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
  PRESIDENT_MSG=$(echo \
    "Congratulations on the election, $PUBLIC_PRESIDENT_PREFIX $PUBLIC_PRESIDENT_NAME. " \
    "Here are your policy choices. Please reply:\n" \
    " 1) to discard the ${SECRET_POLICIES[0]} and pass ${SECRET_POLICIES[1]}-${SECRET_POLICIES[2]} to $PUBLIC_CHANCELLOR_NAME." \
    " 2) to discard the ${SECRET_POLICIES[1]} and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[2]} to $PUBLIC_CHANCELLOR_NAME." \
    " 3) to discard the ${SECRET_POLICIES[2]} and pass ${SECRET_POLICIES[0]}-${SECRET_POLICIES[1]} to $PUBLIC_CHANCELLOR_NAME." \
  PRESIDENT_IMAGE=`image_url policycombo $(IFS="-"; echo "${SECRET_POLICIES[*]}")`
  send_sms "$PUBLIC_PRESIDENT_PHONE" "$PRESIDENT_MSG" "$PRESIDENT_IMAGE"

  # send to president

  # await discard choice

  # discard

  # send remainder to chancellor

  # await discard choice

  # discard

  # send remainder to everybody else

}
