cd "$(dirname "$0")"/..
set -x

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets/images
ASSETS=assets
SECRET=state/__SECRET__
PUBLIC=state/public

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/player-info.txt

SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE`
PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^(#|\s*$)'`

assign_player_roles() {

  if [[ -f $SECRET_PLAYER_ROLES_F ]]; then
    echo "Error: $SECRET_PLAYER_ROLES_F already exists."
    echo -e "Is a game in progress?\n"
    echo "Please delete it if you're sure you want to start a new game."
    exit 1
  fi

}

PNAMES=`awk '{print $1}' <<<$PLAYER_INFO`
PHONES=`awk '{print $2}' <<<$PLAYER_INFO`

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $ASSETS/roles-available.txt`
PLAYER_ROLES=`gpaste <(echo $PNAMES) <(echo "$ACTIVE_ROLES" | gshuf)`

# save roles
echo "$PLAYER_ROLES" > $SECRET/player-roles.txt

# send texts
while read PNAME PHONE ROLE PARTY; do
  twilio api:core:messages:create \
    --from "$SOURCE_PHONE" \
    --to "$PHONE" \
    --body "Hi $PNAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
    --media-url "$IMAGES_BASE_URL/party-$PARTY.png" \
    --media-url "$IMAGES_BASE_URL/role-$ROLE.png"
done < <(join $PUBLIC/players-init.txt $SECRET/player-roles.txt)

ensure_drawable_policy_deck() {

}
