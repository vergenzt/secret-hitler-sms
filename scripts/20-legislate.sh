#!/usr/bin/env bash
source lib.sh

# who's president?
PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`
read -p "Who's President? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
read -p "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME

# generate deck if needed
ensure_drawable_policy_deck

# draw top 3
tail -n3 $F_SECRET_POLICY_DECK

# listen for discard choices
#- useful commands:
ngrok http --log=stdout --log-format=json 80
#- parse ngrok url from log output
#- twilio phone-numbers:update $SOURCE_PHONE --sms-url=$NGROK_URL
#- twilio

# send to president

# await discard choice

# discard

# send remainder to chancellor

# await discard choice

# discard

# send remainder to everybody else
