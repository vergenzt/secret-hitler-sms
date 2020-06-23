#!/usr/bin/env bash
cd "$(dirname "$0")"

gpaste \
  <(awk '{print $1}' ../state/public/players.txt) \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt | awk '{print $1}') \
    | gshuf \
  ) \
  > ../state/__SECRET__/players-with-roles.txt
