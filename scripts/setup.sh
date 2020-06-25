#!/usr/bin/env bash
set -x
cd "$(dirname "$0")"

# assign player roles
gpaste \
  ../state/public/players-init.txt \
  <( cat ../assets/player-slots.txt \
    | head -n $(wc -l ../state/public/players.txt | awk '{print $1}') \
    | gshuf \
  ) \
  |  sudo tee       ../state/__SECRET__/player-roles.txt &> /dev/null
  && sudo chmod 600 ../state/__SECRET__/player-roles.txt

sudo jq -rR ../state/__SECRET__/players.txt '
    | "twilio --to=... --body=... --media-url=..."
    | xargs -n1 \{\}
  ''
