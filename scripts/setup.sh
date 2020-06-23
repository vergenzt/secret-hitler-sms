#!/usr/bin/env bash
cd $(basename $0)

cat ../assets/player-slots.txt \
  | head -n $(wc -l ../state/public/players.txt) \
  | gshuf \
  | gpaste -d ' ' ../state/public/players.txt -
