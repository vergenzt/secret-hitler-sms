#!/usr/bin/env bash
cd "$(dirname "$0")"/.. || exit 1
#set -x

STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.txt
F_PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE`
PUBLIC_PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^(#|\s*$)'`
PUBLIC_PLAYER_NAMES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
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
  SECRET_PLAYER_ROLES=`gpaste <(echo "$PUBLIC_PLAYER_NAMES") <(echo "$PUBLIC_ROLES_ACTIVE" | gshuf)`

  # save
  echo "$SECRET_PLAYER_ROLES" > $F_SECRET_PLAYER_ROLES

  # send texts
  while read PUBLIC_NAME PUBLIC_PHONE SECRET_ROLE SECRET_PARTY; do
    twilio api:core:messages:create \
      --from "$PUBLIC_SOURCE_PHONE" \
      --to "$PUBLIC_PHONE" \
      --body "Hi $PUBLIC_NAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
      --media-url "`image_url party $SECRET_PARTY`" \
      --media-url "`image_url role $SECRET_ROLE`"
  done < <(join $F_PUBLIC_PLAYER_INFO $F_SECRET_PLAYER_ROLES | tr ':' ' ')
}

ensure_drawable_policy_deck() {
  if [[ "$SECRET_POLICY_DECK_LENGTH" -lt 3 ]]; then
    echo "$SECRET_POLICY_DECK_LENGTH policies remaining; re-shuffling policy deck."
    cat "$F_PUBLIC_POLICIES_AVAILABLE" | gshuf > $F_SECRET_POLICY_DECK
  fi
}

legislate() {
  # who's president?
  PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`
  read -p "Who's President? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
  read -p "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_CHANCELLOR_NAME

  if [[ "$PUBLIC_PRESIDENT_NAME" = "$PUBLIC_CHANCELLOR_NAME" ]]; then
    echo "Error: President must be different than chancellor!"
    exit 1
  fi

  # generate deck if needed
  ensure_drawable_policy_deck

  # listen for discard choices
  #- useful commands:
  ngrok http --log=stdout --log-format=json 80
  #- parse ngrok url from log output
  #- twilio phone-numbers:update $SOURCE_PHONE --sms-url=$NGROK_URL
  #- twilio

  # send to president

  # await discard choice

  # discard

  # send remainder to chancellor

  # await discard choice

  # discard

  # send remainder to everybody else

}
