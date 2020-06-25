#!/usr/bin/env bash
cd "$(dirname "$0")"
set -x

SOURCE_PHONE=+19044789601
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets/images
ASSETS=../assets
SECRET=../state/__SECRET__
PUBLIC=../state/public

if [[ -f $SECRET/player-roles.txt ]]; then
  echo "Error: $SECRET/player-roles.txt already exists."
  echo "Is a game in progress?"
  echo
  echo "Please delete it if you're sure you want to start a new game."
  exit 1
fi

PLAYER_INFO=`cat $PUBLIC/players-init.txt | grep -v '^(#|\s*$)'`
PNAMES=`awk '{print $1}' <<<$PLAYER_INFO`
PHONES=`awk '{print $2}' <<<$PLAYER_INFO`

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $ASSETS/roles-available.txt`
PLAYER_ROLES=`gpaste <<<$PNAMES <<<$ACTIVE_ROLES" | gshuf`

# save roles
<<<"$PLAYER_ROLES" > $SECRET/player-roles.txt

# send texts
while read PNAME PHONE ROLE PARTY; do
  twilio api:core:messages:create \
    --from "$SOURCE_PHONE" \
    --to "$PHONE" \
    --body "Hi $PNAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
    --media-url "$IMAGES_BASE_URL/party-$PARTY.png" \
    --media-url "$IMAGES_BASE_URL/role-$ROLE.png"
done < <(join $PUBLIC/players-init.txt $SECRET/player-roles.txt)
