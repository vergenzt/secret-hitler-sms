#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

SECRET=../state/__SECRET__
PUBLIC=../state/public
sudo chown $STATE_S && sudo chmod 600 $STATE_S

PNAMES=awk '{print $1}' $PUBLIC/players-init.txt
PHONES=awk '{print $2}' $PUBLIC/players-init.txt

NUM_PLAYERS=wc -l $PUBLIC/players-init.txt

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
