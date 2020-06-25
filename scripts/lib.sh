cd "$(dirname "$0")"/..
set -x

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/STATIC/images
STATIC=static
SECRET=state/__SECRET__
PUBLIC=state/public

F_PUBLIC_SOURCE_PHONE=$PUBLIC/source-phone.txt
F_PUBLIC_PLAYER_INFO=$PUBLIC/players-init.txt

F_STATIC_ROLES_AVAILABLE=$STATIC/roles-available.txt
F_STATIC_POLICIES_AVAILABLE=$STATIC/policies-available.txt

PUBLIC_SOURCE_PHONE=`cat $F_PUBLIC_SOURCE_PHONE`
PUBLIC_PLAYER_INFO=`cat $F_PUBLIC_PLAYER_INFO | grep -v '^(#|\s*$)'`
PUBLIC_PLAYER_NAMES=`awk '{print $1}' <(echo "$PUBLIC_PLAYER_INFO")`
PUBLIC_PLAYER_PHONES=`awk '{print $2}' <(echo "$PUBLIC_PLAYER_INFO")`

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt

PUBLIC_NUM_PLAYERS=`cat $F_PUBLIC_PLAYER_INFO | wc -l`
STATIC_ACTIVE_ROLES=`head -n $NUM_PLAYERS $F_STATIC_ROLES_AVAILABLE`
PLAYER_ROLES=`gpaste <(echo $PNAMES) <(echo "$ACTIVE_ROLES" | gshuf)`

assign_player_roles() {

  if [[ -f $SECRET_PLAYER_ROLES_F ]]; then
    echo "Error: $SECRET_PLAYER_ROLES_F already exists."
    echo -e "Is a game in progress?\n"
    echo "Please delete it if you're sure you want to start a new game."
    exit 1
  fi

}

NUM_PLAYERS=`cat $PUBLIC/players-init.txt | wc -l`
ACTIVE_ROLES=`head -n $NUM_PLAYERS $STATIC/roles-available.txt`
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
