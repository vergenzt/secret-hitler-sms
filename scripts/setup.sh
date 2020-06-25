#!/usr/bin/env bash
cd "$(dirname "$0")"

SOURCE_PHONE=+19044789601
ASSET_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets
ASSETS=../assets
SECRET=../state/__SECRET__
PUBLIC=../state/public

test \! -f $SECRET/player-roles.txt

PNAMES=`awk '{print $1}' $PUBLIC/players-init.txt`
PHONES=`awk '{print $2}' $PUBLIC/players-init.txt`

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $ASSETS/roles-available.txt`
PLAYER_ROLES=`echo "$ACTIVE_ROLES" | gshuf`

# save roles
gpaste <(echo "$PNAMES") <(echo "$PLAYER_ROLES") > $SECRET/player-roles.txt

# send texts
while read PNAME PHONE ROLE; do
  twilio api:core:messages:create \
    --from "$SOURCE_PHONE" \
    --to "$PHONE" \
    --body "Hi $PNAME! Here's your role for Secret Hitler:" \
    --media-url "$ASSET_BASE_URL/player-$ROLE.png"
done < <(join $PUBLIC/players-init.txt $SECRET/player-roles.txt)
