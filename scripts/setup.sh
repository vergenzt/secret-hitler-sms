#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

gpaste \
  ../state/public/players-init.txt \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt | awk '{print $1}') \
    | gshuf \
  ) \
  > ../state/__SECRET__/players.txt

chmod 600 ../state/__SECRET__/players.txt

jq -rR ../state/__SECRET__/players.txt \
  | awk '{print }'
  # ...
  | xargs -n1 twilio --to=... --body=... --media-url=...
