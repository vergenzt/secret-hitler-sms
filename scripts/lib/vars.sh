#!/usr/bin/env bash

SECRET=state/__SECRET__
PUBLIC=state/public

if [ ! -z "$BATS_TMPDIR" ]; then
  SECRET=$BATS_TMPDIR/$SECRET
  PUBLIC=$BATS_TMPDIR/$PUBLIC
fi

STATIC=static
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.txt
F_PUBLIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_PUBLIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE 2>/dev/null`
PUBLIC_PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^#'`
PUBLIC_PLAYER_TITLES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_NAMES=`awk '{print $2}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_PHONES=`awk '{print $3}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`

PUBLIC_NUM_PLAYERS=`echo "$PUBLIC_PLAYER_INFO" | wc -l`
PUBLIC_ROLES_ACTIVE=`head -n $PUBLIC_NUM_PLAYERS $F_PUBLIC_ROLES_AVAILABLE`

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_SECRET_POLICY_DECK=$SECRET/policy-deck.txt
F_SECRET_POLICY_OPTIONS=$SECRET/policy-options.txt
F_SECRET_POLICY_DISCARD=$SECRET/policy-discard.txt

F_SECRET_NGROK_LOG=$SECRET/ngrok.json
