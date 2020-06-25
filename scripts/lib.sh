cd "$(dirname "$0")"/..
set -x

IMAGES_BASE_URL=https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/assets/images
ASSETS=assets
SECRET=state/__SECRET__
PUBLIC=state/public
SOURCE_PHONE=`cat $STATE/source-phone.txt`

SECRET_PLAYER_ROLES_F=$SECRET/player-roles.txt

ensure_drawable_policy_deck() {

}
