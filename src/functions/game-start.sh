#!/usr/bin/env bash
source src/lib.sh

## httpApi: POST /game/{GAME_ID}/start

function game-start() {
  GAME_ID=$(echo "$1" | jq -e .pathParameters.GAME_ID)

  PLAYERS=$(aws s3 ls "$(printf "$GAME_PLAYERS" "$GAME_ID" "")" | wc -l)

  ROLES_ACTIVE=($(aws s3 cp "$STATIC/roles-available.txt" - | head -n "$NUM_PLAYERS" | gshuf))

  for role in "$ROLES_ACTIVE"

  SECRET_PLAYER_ROLES=$(echo "$PUBLIC_ROLES_ACTIVE" | gshuf | tee $SECRET/player-roles.txt)
  echo "Done."

  echo -n "Initializing & shuffling decks... "
  touch $SECRET/policy-{deck,options,discard}.txt
  touch $PUBLIC/policies-enacted.txt
  ensure_drawable_policy_deck
  echo "Done."

  echo -n "Distributing secret player roles via SMS... "
  parallel \
    send_sms \
      "$PUBLIC_PHONE" \
      "Hi $PUBLIC_NAME! Here's your SECRET (🤫) role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
      "$(image_url party "$SECRET_PARTY")" \
      "$(image_url role "$SECRET_ROLE")"

  echo "Done."
  echo
  echo "Let the games begin!!!"

}
