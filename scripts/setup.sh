#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

ASSETS=../assets
SECRET=../state/__SECRET__
PUBLIC=../state/public

PNAMES=`awk '{print $1}' $PUBLIC/players-init.txt`
PHONES=`awk '{print $2}' $PUBLIC/players-init.txt`

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $ASSETS/roles-available.txt`
PLAYER_ROLES=`echo "$ACTIVE_ROLES" | gshuf`

# save roles
gpaste <(echo "$PNAMES") <(echo "$PLAYER_ROLES") > $SECRET/player-roles.txt

# send texts
join $PUBLIC/players-init.txt $SECRET/player-roles.txt \
  | while read PNAME PHONE ROLE; do
    echo "Hi $PNAME! Your phone is $PHONE and role is $ROLE."
  done <
