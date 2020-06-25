#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

SECRET=../state/__SECRET__
PUBLIC=../state/public

PNAMES=`awk '{print $1}' $PUBLIC/players-init.txt`
PHONES=`awk '{print $2}' $PUBLIC/players-init.txt`

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $PUBLIC/players-init.txt`
PLAYER_ROLES=`gpaste <(echo "$PNAMES") <(echo "$ACTIVE_ROLES" | shuf)`

# assign player roles
gpaste \
  <() \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt) \
    | gshuf \
  ) \
  |  sudo tee       ../state/__SECRET__/player-roles.txt &> /dev/null
  && sudo chmod 600 ../state/__SECRET__/player-roles.txt

while read

done < ../state/__SECRET__/players.txt '
