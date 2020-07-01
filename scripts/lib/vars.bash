#!/usr/bin/env bash
# shellcheck disable=SC2155
set -o errexit

export SECRET=state/__SECRET__
export PUBLIC=state/public

# set up temporary test state directories
if [ ! -z "$BATS_TMPDIR" ]; then
  SECRET=$BATS_TMPDIR/$SECRET
  PUBLIC=$BATS_TMPDIR/$PUBLIC
fi

mkdir -p "$SECRET"
mkdir -p "$PUBLIC"

STATIC=static
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }


# check file presence
[ -f "$PUBLIC/source-phone.txt" ]
[ -f "$PUBLIC/player-info.txt" ]
[ -f "$STATIC/roles-available.txt" ]

read_yaml() {
  BASENAME="$1"
  DATA="$BASENAME".yaml
  SCHEMA="$BASENAME".schema.yaml
  YAMLPATH="$2"
  pajv validate -s "$SCHEMA" -d "$DATA"
  yq read "$DATA" "$YAMLPATH"
}

public_source_phone() { read_yaml $PUBLIC/source-phone.yaml

export PUBLIC_SOURCE_PHONE=`cat $PUBLIC/source-phone.txt 2>/dev/null`
export PUBLIC_PLAYER_INFO=`cat $PUBLIC/player-info.txt | grep -v '^#'`
export PUBLIC_PLAYER_TITLES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
export PUBLIC_PLAYER_NAMES=`awk '{print $2}' <(echo "$PUBLIC_PLAYER_INFO")`
export PUBLIC_PLAYER_PHONES=`awk '{print $3}' <(echo "$PUBLIC_PLAYER_INFO")`
export PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`

export PUBLIC_NUM_PLAYERS=`echo "$PUBLIC_PLAYER_INFO" | wc -l`
export PUBLIC_ROLES_ACTIVE=`head -n $PUBLIC_NUM_PLAYERS $STATIC/roles-available.txt`
