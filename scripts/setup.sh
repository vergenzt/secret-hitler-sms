#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

PLAYERS=

# assign player roles
gpaste \
  <( cat ../state/public/players-init.txt | awk '{print $1}' ) \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt) \
    | gshuf \
  ) \
  |  sudo tee       ../state/__SECRET__/player-roles.txt &> /dev/null
  && sudo chmod 600 ../state/__SECRET__/player-roles.txt

while read

done < ../state/__SECRET__/players.txt '
