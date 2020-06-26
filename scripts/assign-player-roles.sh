#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
trap "kill 0" EXIT
source scripts/_lib.sh

if [[ -f $F_SECRET_PLAYER_ROLES ]]; then
  echo "Error: $F_SECRET_PLAYER_ROLES already exists."
  echo -e "Is a game in progress?\n"
  echo "Please delete it if you're sure you want to start a new game."
  exit 1
fi

echo -n "Assigning & sending player roles... "
SECRET_PLAYER_ROLES=`echo "$PUBLIC_ROLES_ACTIVE" | gshuf | tee $F_SECRET_PLAYER_ROLES`
echo "Done."

while read PUBLIC_NAME PUBLIC_PHONE SECRET_ROLE SECRET_PARTY; do
  send_sms \
    "$PUBLIC_PHONE" \
    "Hi $PUBLIC_NAME! Here's your SECRET (🤫) role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
    "`image_url party $SECRET_PARTY`" \
    "`image_url role $SECRET_ROLE`"
done < <(\
  gpaste \
  <(echo "$PUBLIC_PLAYER_NAMES") \
  <(echo "$PUBLIC_PLAYER_PHONES") \
  <(echo "$SECRET_PLAYER_ROLES" | tr ':' ' ') \
)
