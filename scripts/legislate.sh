#!/usr/bin/env bash
cd "$(dirname "$0")"
set -x

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets/images
ASSETS=../assets
SECRET=../state/__SECRET__
PUBLIC=../state/public
SOURCE_PHONE=`cat $STATE/source-phone.txt`

# who's president?
# who's chancellor?

# generate deck if needed

# draw top 3

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
