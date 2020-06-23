#!/usr/bin/env bash
cd $(basename $0)

cat ../assets/players.txt \
  | head -n $(wc -l ../state/public/players.txt)
  ../state/public/players.txt
