#!/usr/bin/env bash
set -eu -o pipefail
set -o allexport

if [ -z "${LIB_SOURCED:-}" ]; then
  LIB_SOURCED=true

  # https://stackoverflow.com/a/58098360
  CODE_CHARS=(C D E F H J K M N P R T V W X Y 2 3 4 5 6 8 9)
  CODE_LEN=4

  # https://stackoverflow.com/a/37840948
  function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

  function uuid64() {
    uuidgen | tr -d - | xxd -r -p | base64
  }

  function parse_body() {
    exp_type="application/x-www-form-urlencoded"
    act_type=$(echo "$1" | jq '.headers["content-type"]')
    if ! test "$act_type" = "$exp_type"; then
      RESP_STATUS=415
      echo "Content-Type must be $exp_type!" >&2
      return 1
    fi
    body=$(echo "$1" | jq -r .body)

    # shellcheck disable=SC2016
    params_jq_cmd=(jq -nce '$ARGS.named')
    for keyval in $(echo "$body" | tr '&' '\n'); do
      key=$(urldecode "$(echo "$keyval" | cut -d= -f1)")
      val=$(urldecode "$(echo "$keyval" | cut -d= -f2-)")
      params_jq_cmd+=(--arg "$key" "$val")
    done
    "${params_jq_cmd[@]}" # execute jq cmd
  }

  STATIC=https://secret-h-sms.com

  GAME_INITIALIZED=$S3_DATA/game/%s/initialized
  GAME_STARTED=$S3_DATA/game/%s/started

  IMAGES_BASE_URL=$STATIC/img
  image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

  PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
  PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt
fi
