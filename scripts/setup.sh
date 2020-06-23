#!/usr/bin/env bash
cd "$(dirname "$0")"

gpaste \
  ../state/public/players.txt \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt | awk '$1') \
    | gshuf \
  )
