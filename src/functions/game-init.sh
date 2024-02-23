#!/usr/bin/env bash
source src/lib.sh

# httpApi: POST /game

function game-init() {

  while [ -z "${GAME_ID:-}" ] || aws s3 ls "$(printf "$GAME_INITIALIZED" "$GAME_ID")"
  do
    GAME_ID=$(
      for _i in $(seq "$CODE_LEN"); do
        k=$(shuf -n1 -i 1-"${#CODE_CHARS}")
        echo -n "${CODE_CHARS[$k]}"
      done
    )
  done

  aws s3 cp - "$(printf "$GAME_INITIALIZED" "$GAME_ID")" </dev/null

  jq -nc '{
    statusCode: 303,
    headers: {
      location: ("/" + $ENV.GAME_ID)
    }
  }'
}
