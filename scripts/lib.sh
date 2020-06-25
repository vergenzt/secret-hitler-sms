cd "$(dirname "$0")"/..
set -x

STATIC=static
IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images
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
PUBLIC_NUM_PLAYERS=`cat $F_PUBLIC_PLAYER_INFO | wc -l`
PUBLIC_ROLES_ACTIVE=`head -n $PUBLIC_NUM_PLAYERS $F_STATIC_ROLES_AVAILABLE`

F_SECRET_PLAYER_ROLES=$SECRET/player-roles.txt
F_SECRET_POLICY_DECK=$SECRET/policy-deck.txt
F_SECRET_POLICY_DISCARD=$SECRET/policy-discard.txt

image_url() { echo "$IMAGES_BASE_URL/$1-$2.png"; }

assign_player_roles() {
  if [[ -f $SECRET_PLAYER_ROLES_F ]]; then
    echo "Error: $SECRET_PLAYER_ROLES_F already exists."
    echo -e "Is a game in progress?\n"
    echo "Please delete it if you're sure you want to start a new game."
    exit 1
  fi

  # assign
  SECRET_PLAYER_ROLES=`gpaste <(echo "$PUBLIC_PLAYER_NAMES") <(echo "$PUBLIC_ROLES_ACTIVE" | gshuf)`

  # save
  echo "$SECRET_PLAYER_ROLES" > $F_SECRET_PLAYER_ROLES

  # send texts
  while read PUBLIC_NAME PUBLIC_PHONE SECRET_ROLE SECRET_PARTY; do
    twilio api:core:messages:create \
      --from "$STATIC_SOURCE_PHONE" \
      --to "$PUBLIC_PHONE" \
      --body "Hi $PUBLIC_NAME! Here's your secret role and party membership cards for Secret Hitler. 🙂 Enjoy the game!" \
      --media-url `image_url party $SECRET_PARTY` \
      --media-url `image_url role $SECRET_ROLE`
  done < <(join $F_PUBLIC_PLAYER_INFO $F_SECRET_PLAYER_ROLES | tr ':' ' ')
}

ensure_drawable_policy_deck() {

}

legislate() {
# who's president?
PUBLIC_PLAYER_NAMES_PROMPT=`echo "$PUBLIC_PLAYER_NAMES" | tr '\n' '/'`
read -p "Who's President? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME
read -p "Who's Chancellor? ($PUBLIC_PLAYER_NAMES_PROMPT): " PUBLIC_PRESIDENT_NAME

# generate deck if needed
ensure_drawable_policy_deck

# draw top 3
tail -n3 $F_SECRET_POLICY_DECK


}
