#!/usr/bin/env bash
set -eu -o pipefail

# lookup() {
#   gpaste <(echo "$2") <(echo "$1") | awk "\$1 == \"$3\" { print \$2 }"
# }

# https://stackoverflow.com/a/37840948
function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.toml
F_PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_PLAYER_INFO=$(python -c 'import sys, tomllib, json; json.dump(tomllib.load(sys.stdin)["player"], sys.stdout)' < $F_PUBLIC_PLAYER_INFO)
PUBLIC_PLAYER_TITLES=$(awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO"))
PUBLIC_PLAYER_NAMES=$(awk '{print $2}' <(echo "$PUBLIC_PLAYER_INFO"))
PUBLIC_PLAYER_PHONES=$(awk '{print $3}' <(echo "$PUBLIC_PLAYER_INFO"))
PUBLIC_PLAYER_NAMES_PROMPT=$(echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/')

PUBLIC_NUM_PLAYERS=$(echo "$PUBLIC_PLAYER_INFO" | wc -l)
PUBLIC_ROLES_ACTIVE=$(head -n "$PUBLIC_NUM_PLAYERS" "$F_PUBLIC_ROLES_AVAILABLE")

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_SECRET_POLICY_DECK=$SECRET/policy-deck.txt
F_SECRET_POLICY_OPTIONS=$SECRET/policy-options.txt
F_SECRET_POLICY_DISCARD=$SECRET/policy-discard.txt

F_SECRET_NGROK_LOG=$SECRET/ngrok.json

TWILIO_CURLARGS=(
  --fail-with-body
  --no-progress-meter
  --variable %TWILIO_ACCOUNT_SID
  --variable %TWILIO_AUTH_TOKEN
  --expand-user "{{TWILIO_ACCOUNT_SID}}:{{TWILIO_AUTH_TOKEN}}"
  --expand-variable "BASE_URL=https://api.twilio.com/2010-04-01/Accounts/{{TWILIO_ACCOUNT_SID}}"
)

TWILIO_PHONES_JSON=$(curl "${TWILIO_CURLARGS[@]}" --expand-url "{{BASE_URL}}/IncomingPhoneNumbers.json")
TWILIO_PHONE_SID=$(echo "$TWILIO_PHONES_JSON" | jq .incoming_phone_numbers[0].sid)
TWILIO_PHONE_NUMBER=$(echo "$TWILIO_PHONES_JSON" | jq .incoming_phone_numbers[0].phone_number)

send_sms() {
  TO="$1"
  BODY=$(echo -en "\n\n$2")
  shift 2

  SMS_CURLARGS=(
    --expand-url "{{BASE_URL}}/Messages.json"
    --form "From=$TWILIO_PHONE_NUMBER"
    --form "To=$TO"
    --form "Body=$BODY"
  )

  for SECRET_PHOTO_URL in "$@"; do
    SMS_CURLARGS+=( --form MediaUrl="$SECRET_PHOTO_URL" )
  done

  curl "${TWILIO_CURLARGS[@]}" "${SMS_CURLARGS[@]}" >&2
}

policy_deck_length() {
  cat $SECRET/policy-deck.txt 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ $(policy_deck_length) -lt 3 ]]; then
    echo "$(policy_deck_length) policies in deck; shuffling."
    cat "$SECRET/policy-discard.txt" "$SECRET/policy-deck.txt" | gshuf | sponge $SECRET/policy-deck.txt
  fi
  true
}

# draw $N cards from head of $FROM_DECK and append to tail of $TO_DECK
draw_cards() {
  N=$1; FROM_DECK=$2; TO_DECK=$3
  cat "$FROM_DECK" | awk "NR <= $N { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR >  $N { print \$0 }" | sponge "$FROM_DECK"
}

# move 1 card from position $I of $FROM_DECK and append to tail of $TO_DECK
move_card() {
  I=$1; FROM_DECK=$2; TO_DECK=$3
  cat "$FROM_DECK" | awk "NR == $I { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR != $I { print \$0 }" | sponge "$FROM_DECK"
}

# pick a card from position $I of $FROM_DECk
pick_card() {
  I=$1; FROM_DECK=$2
  awk "NR == $I { print \$0 }" "$FROM_DECK" \
    | tr -d '[:digit:]' # get rid of unique policy identifiers
}
