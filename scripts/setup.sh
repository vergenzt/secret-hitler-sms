#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

PLAYERS_INIT_F=../state/public/players-init.txt

PLAYERS=awk '{print $1}'
 PHONES=awk '{print $2}' ../state/public/players-init.txt

NUM_PLAYERS=wc -l ../state/public/players-init.txt

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
