#!/usr/bin/env bash
source src/lib.sh

# httpApi: POST /game

INITIALIZED=game-initialized

function game-init() {

  while [ -z "${GAME_ID:-}" ] || aws s3 ls "$S3_DATA/${GAME_ID:-}/$INITIALIZED"
  do
    GAME_ID=$(
      for _i in $(seq "$CODE_LEN"); do
        k=$(shuf -n1 -i 1-"${CODE_CHARS[#]}")
        echo -n "${CODE_CHARS[$k]}"
      done
    )
  done

  aws s3 cp - "$S3_DATA/$GAME_ID/$INITIALIZED" </dev/null

  jq -nc '{ $GAME_ID }' --var GAME_ID "$GAME_ID"
}
