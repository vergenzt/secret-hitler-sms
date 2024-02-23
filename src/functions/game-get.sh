#!/usr/bin/env bash
source src/lib.sh

# httpApi: GET /game/{GAME_ID}

function game-init() {
  GAME_ID=$(echo "$1" | jq -e .pathParameters.GAME_ID)

  if ! aws s3 ls "$(printf "$GAME_INITIALIZED" "$GAME_ID")" >/dev/null; then
    RESP_STATUS=404
    echo "No game found with this ID."
    return
  fi

  if ! aws s3 ls "$(printf "$GAME_STARTED" "$GAME_ID")" >/dev/null; then
    echo "This game is waiting for players!"


}
