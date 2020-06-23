#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

gpaste \
  <(awk '{print $1}' ../state/public/players.txt) \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt | awk '{print $1}') \
    | gshuf \
  ) \
  > ../state/__SECRET__/players-with-roles.txt

chmod 600 ../state/__SECRET__/players-with-roles.txt

join \
  ../state/public/players.txt \
  ../state/__SECRET__/player-roles.txt
  | xargs awk '{ print }'
