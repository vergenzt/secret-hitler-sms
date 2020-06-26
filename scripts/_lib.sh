#!/usr/bin/env bash
lookup() {
  gpaste <(echo "$1") <(echo "$2") | awk "\$1 == \"$3\" { print \$2 }"
}

# https://stackoverflow.com/a/37840948
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.txt
F_PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE 2>/dev/null`
PUBLIC_PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^#'`
PUBLIC_PLAYER_TITLES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_NAMES=`awk '{print $2}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_PHONES=`awk '{print $3}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`

PUBLIC_NUM_PLAYERS=`echo "$PUBLIC_PLAYER_INFO" | wc -l`
PUBLIC_ROLES_ACTIVE=`head -n $PUBLIC_NUM_PLAYERS $F_PUBLIC_ROLES_AVAILABLE`

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_SECRET_POLICY_DECK=$SECRET/policy-deck.txt
F_SECRET_POLICY_OPTIONS=$SECRET/policy-options.txt
F_SECRET_POLICY_DISCARD=$SECRET/policy-discard.txt

F_SECRET_NGROK_LOG=$SECRET/ngrok.json

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

policy_deck_length() {
  cat $F_SECRET_POLICY_DECK 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ `policy_deck_length` -lt 3 ]]; then
    echo "$(policy_deck_length) policies in deck; shuffling."
    cat "$F_PUBLIC_POLICIES_AVAILABLE" | gshuf > $F_SECRET_POLICY_DECK
  fi
}

# draw $N cards from head of $FROM_DECK and append to tail of $TO_DECK
draw_cards() {
  N=$1; FROM_DECK=$2; TO_DECK=$3
  awk "NR <= $N { print \$0 }" "$FROM_DECK" >> "$TO_DECK"
  awk "NR >  $N { print \$0 }" "$FROM_DECK" | sponge > "$FROM_DECK"
}

# move 1 card from position $I of $FROM_DECK and append to tail of $TO_DECK
move_card() {
  I=$1; FROM_DECK=$2; TO_DECK=$3
  awk "NR == $I { print \$0 }" "$FROM_DECK" >> "$TO_DECK"
  awk "NR != $I { print \$0 }" "$FROM_DECK" | sponge > "$FROM_DECK"
}

# pick a card from position $I of $FROM_DECk
pick_card() {
  I=$1; FROM_DECK=$2
  awk "NR == $I { print \$0 }" "$FROM_DECK" >> "$TO_DECK"
