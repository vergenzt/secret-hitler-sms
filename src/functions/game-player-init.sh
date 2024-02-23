#!/usr/bin/env bash
source src/lib.sh

## httpApi: POST /game/{GAME_ID}/player

BODY_SCHEMA=$(mktemp -d)/body-schema.yaml
cat <<EOF > "$BODY_SCHEMA"
properties:

  phone:
    type: string
    pattern: ^\d{10}$

  name:
    type: string
    maxLength: 20

    # https://andrewwoods.net/blog/2018/name-validation-regex/
    pattern: ^[A-Za-z\x{00C0}-\x{00FF}][A-Za-z\x{00C0}-\x{00FF}\'\-]+([\ A-Za-z\x{00C0}-\x{00FF}][A-Za-z\x{00C0}-\x{00FF}\'\-]+)*

EOF

function game-player-init() {
  body=$(parse_body "$1") || return
  if ! checkschema -q -s "$BODY_SCHEMA" <(echo "$body"); then
    RESP_STATUS=400
    return
  fi

  player_id=$(uuidgen | tr '[:upper:]' '[:lower:]' | tr -d - | head -c16)

}
