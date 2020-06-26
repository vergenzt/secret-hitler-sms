#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/_lib.sh

assign_player_roles() {
  if [[ -f $F_SECRET_PLAYER_ROLES ]]; then
    echo "Error: $F_SECRET_PLAYER_ROLES already exists."
    echo -e "Is a game in progress?\n"
    echo "Please delete it if you're sure you want to start a new game."
    exit 1
  fi

  # assign
  echo "Assigning player roles!"
  SECRET_PLAYER_ROLES=`gpaste <(echo "$PUBLIC_PLAYER_NAMES") <(echo "$PUBLIC_ROLES_ACTIVE" | gshuf)`

  # save
  echo "$SECRET_PLAYER_ROLES" > $F_SECRET_PLAYER_ROLES

  # send texts
  while read PUBLIC_NAME PUBLIC_PHONE SECRET_ROLE SECRET_PARTY; do
    send_sms \
      "$PUBLIC_PHONE" \
      "Hi $PUBLIC_NAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
      "`image_url party $SECRET_PARTY`" \
      "`image_url role $SECRET_ROLE`"
  done < <(join $F_PUBLIC_PLAYER_INFO $F_SECRET_PLAYER_ROLES | tr ',' ' ')
}
