#!/usr/bin/env bash
source "$LAMBDA_TASK_ROOT"/src/lib.sh

# httpApi: POST /game

function game-init() {

  INITIALIZED=game-initialized

  while [ -z "${GAME_ID:-}" ] || aws s3 ls "$S3_DATA/${GAME_ID:-}/$INITIALIZED"
  do
    GAME_ID=$(
      for _ in $(seq "$CODE_LEN"); do
        k=$(shuf -n1 -i 1-"${CODE_CHARS[#]}")
        echo -n "${CODE_CHARS[$k]}"
      done
    )
  done

  aws s3 cp - "$S3_DATA/$GAME_ID/$INITIALIZED" </dev/null

}
