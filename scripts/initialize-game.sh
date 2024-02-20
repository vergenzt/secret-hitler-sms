#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1

if [[ -f $SECRET/player-roles.txt ]]; then
  echo "Error: $SECRET/player-roles.txt already exists."
  echo -e "Is a game in progress?\n"
  echo "Please reset game state if you're sure you want to start a new game."
  exit 1
fi

echo -n "Assigning player roles... "
SECRET_PLAYER_ROLES=$(echo "$PUBLIC_ROLES_ACTIVE" | gshuf | tee $SECRET/player-roles.txt)
echo "Done."

echo -n "Initializing & shuffling decks... "
touch $SECRET/policy-{deck,options,discard}.txt
touch $PUBLIC/policies-enacted.txt
ensure_drawable_policy_deck
echo "Done."

echo -n "Distributing secret player roles via SMS... "
parallel \
  send_sms \
    "$PUBLIC_PHONE" \
    "Hi $PUBLIC_NAME! Here's your SECRET (🤫) role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
    "$(image_url party "$SECRET_PARTY")" \
    "$(image_url role "$SECRET_ROLE")"
done < <(\
  gpaste \
  <(echo "$PUBLIC_PLAYER_NAMES") \
  <(echo "$PUBLIC_PLAYER_PHONES") \
  <(echo "$SECRET_PLAYER_ROLES" | tr ':' ' ') \
)
echo "Done."
echo
echo "Let the games begin!!!"
