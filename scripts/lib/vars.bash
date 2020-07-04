#!/usr/bin/env bash

export STATE=state

# set up temporary test state directories
if [ ! -z "$BATS_TMPDIR" ]; then
  SECRET=$BATS_TMPDIR/$SECRET
  PUBLIC=$BATS_TMPDIR/$PUBLIC
fi

export SECRET=state/__SECRET__
export PUBLIC=state/public

mkdir -p "$SECRET"
mkdir -p "$PUBLIC"

STATIC=static
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

read_yaml() {
  BASENAME="$1"
  DATA="$BASENAME".yaml
  SCHEMA="$BASENAME".schema.yaml
  YAMLPATH="$2"
  pajv validate -s "$SCHEMA" -d "$DATA"
  yq read "$DATA" "$YAMLPATH"
}

public_source_phone() { read_yaml $PUBLIC/source-phone; }
public_player_names() { read_yaml $PUBLIC/player-info *.name; }
public_player_phones() { read_yaml $PUBLIC/player-info *.phone; }
public_player_honorifics() { read_yaml $PUBLIC/player-info *.honorific; }

public_player_names_prompt() { public_player_names | tr '\n' '/'; }
public_num_players() { public_player_names | wc -l; }
public_roles_active() { head -n "`public_num_players`" $STATIC/roles-available.txt; }

secret_player_role() { read_yaml $SECRET/player-roles "$1"; }
