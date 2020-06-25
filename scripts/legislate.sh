#!/usr/bin/env bash
cd "$(dirname "$0")"
set -x

SOURCE_PHONE=+19044789601
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets/images
ASSETS=../assets
SECRET=../state/__SECRET__
PUBLIC=../state/public

# generate deck if needed
