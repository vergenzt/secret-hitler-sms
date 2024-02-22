#!/usr/bin/env bash
set -eu -o pipefail

if [ -z "${LIB_SOURCED:-}" ]; then
  LIB_SOURCED=true

  # https://stackoverflow.com/a/58098360
  CODE_CHARS=(C D E F H J K M N P R T V W X Y 2 3 4 5 6 8 9)
  CODE_LEN=4

  STATIC=https://secret-h-sms.com

  IMAGES_BASE_URL=$STATIC/img
  image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

  PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
  PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt
fi
