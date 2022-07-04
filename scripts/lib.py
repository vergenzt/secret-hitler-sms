
from dataclasses import dataclass
from itertools import starmap
import os
from pathlib import Path
from typing import TypeVar

twilio = twilio.rest.Client(os.environ['TWILIO_ACCOUNT_SID'], os.environ['TWILIO_AUTH_TOKEN'])

T = TypeVar('T')
U = TypeVar('U')

def lookup(in_list: list[T], lookup_list: list[U], lookup_val: U) -> T:
  return in_list[lookup_list.index(lookup_val)]

STATIC = Path('static')
SECRET = Path('state/__SECRET__')
PUBLIC = Path('state/public')

IMAGES_BASE_URL = f'https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/$STATIC/images'

def image_url(img_class: str, img_instance: str):
  return f'{IMAGES_BASE_URL}/{img_class}-{img_instance}.png'

F_PUBLIC_SOURCE_PHONE = PUBLIC / 'source-phone.txt'
F_PUBLIC_PLAYER_INFO = PUBLIC / 'player-info.txt'
F_PUBLIC_ROLES_AVAILABLE = STATIC / 'roles-available.txt'
F_PUBLIC_POLICIES_AVAILABLE = STATIC / 'policies-available.txt'

@dataclass
class Player:
  title: str
  name: str
  phone: str

PUBLIC_SOURCE_PHONE = F_PUBLIC_SOURCE_PHONE.read_text().strip()
PUBLIC_PLAYER_INFO  = list(starmap(Player, map(str.split, F_PUBLIC_PLAYER_INFO.read_text().splitlines())))

PUBLIC_PLAYER_NAMES_PROMPT = '/'.join(p.name for p in PUBLIC_PLAYER_INFO)

PUBLIC_NUM_PLAYERS = len(PUBLIC_PLAYER_INFO)
PUBLIC_ROLES_ACTIVE = F_PUBLIC_ROLES_AVAILABLE.read_text().splitlines()[:PUBLIC_NUM_PLAYERS]

F_SECRET_PLAYER_ROLES = SECRET / 'player-roles.txt'
F_SECRET_POLICY_DECK = SECRET / 'policy-deck.txt'
F_SECRET_POLICY_OPTIONS = SECRET / 'policy-options.txt'
F_SECRET_POLICY_DISCARD = SECRET / 'policy-discard.txt'

# shellcheck disable = SC2206
send_sms(to_phone: str, secret_message: str, *photos: Path) {
  PUBLIC_PHONE = "$1"
  SECRET_MESSAGE = $(echo -en "\n\n$2")
  shift 2
  SECRET_PHOTOS = ($@)
  twilio api:core:messages:create \
    --from "$PUBLIC_SOURCE_PHONE" \
    --to "$PUBLIC_PHONE" \
    --body "$SECRET_MESSAGE" \
    "${SECRET_PHOTOS[@]/#/--media-url }" \
    >/dev/null
}

policy_deck_length() {
  cat $SECRET/policy-deck.txt 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ $(policy_deck_length) -lt 3 ]]; then
    echo "$(policy_deck_length) policies in deck; shuffling."
    cat "$SECRET/policy-discard.txt" "$SECRET/policy-deck.txt" | shuf | sponge $SECRET/policy-deck.txt
  fi
}

# draw $N cards from head of $FROM_DECK and append to tail of $TO_DECK
draw_cards() {
  N = $1; FROM_DECK = $2; TO_DECK = $3
  cat "$FROM_DECK" | awk "NR <= $N { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR >  $N { print \$0 }" | sponge "$FROM_DECK"
}

# move 1 card from position $I of $FROM_DECK and append to tail of $TO_DECK
move_card() {
  I = $1; FROM_DECK = $2; TO_DECK = $3
  cat "$FROM_DECK" | awk "NR == $I { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR != $I { print \$0 }" | sponge "$FROM_DECK"
}

# pick a card from position $I of $FROM_DECk
pick_card() {
  I = $1; FROM_DECK = $2
  awk "NR == $I { print \$0 }" "$FROM_DECK" \
    | tr -d '[[:digit:]]' # get rid of unique policy identifiers
}
