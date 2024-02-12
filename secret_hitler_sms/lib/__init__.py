from dataclasses import dataclass
import json
import os
import random
import subprocess as sp
import tomllib
from pathlib import Path
from typing import Callable, Generic, Protocol, TypedDict, TypeVar

# lookup() {
#   paste <(echo "$2") <(echo "$1") | awk "\$1 = =  \"$3\" { print \$2 }"
# }

STATIC = Path("static")
SECRET = Path("state/__SECRET__")
PUBLIC = Path("state/public")

IMAGES_BASE_URL = f"https://raw.githubusercontent.com/vergenzt/secret-hitler-sms/master/{STATIC}/images"

def image_url(cat: str, subcat: str)
  return f"{IMAGES_BASE_URL}/{cat}-{subcat}.png"


TWILIO_PHONE_NUMBER = os.environ["TWILIO_PHONE_NUMBER"]
TWILIO_BASE_URL = "https://api.twilio.com/2010-04-01/Accounts/{TWILIO_ACCOUNT_SID}".format_map(os.environ)
TWILIO_AUTH = "{TWILIO_ACCOUNT_SID}:{TWILIO_AUTH_TOKEN}".format_map(os.environ)


def twilio(*curl_args: str):
  return sp.check_output([
    "curl",
    "--user", TWILIO_AUTH,
    "--variable", f"BASE={TWILIO_BASE_URL}",
    *curl_args,
  ])


def send_sms(To: str, Body: str, *MediaUrls: str):
  From = TWILIO_PHONE_NUMBER
  return twilio(
    "--expand-url", "{{BASE}}/Messages.json",
    "-F", f"{From=}",
    "-F", f"{To=}",
    "-F", f"{Body=}",
    *([
      arg
      for MediaUrl in MediaUrls
      for arg in ["-F", f"{MediaUrl=}"]
    ])
  )


class HasPath(Protocol):
  path: Path


T = TypeVar('T')

@dataclass
class FileBacked(Generic[T]):
  subpath: Path
  to_str: Callable[[T], str]
  from_str: Callable[[str], T]

  def __set_name__(self, state: HasPath, name: str):
    (state.path / self.subpath).touch()
  
  def __get__(self, state: HasPath, _ = None) -> T:
    return self.from_str((state.path / self.subpath).read_text())

  def __set__(self, state: HasPath, value: T):
    (state.path / self.subpath).write_text(self.to_str(value))


Deck = FileBacked[list[str]]


class SecretState:
  path = Path('state/__SECRET__')

  player_roles = FileBacked[dict[str, str]](Path('player-roles.json'), json.dumps, json.loads)
  policy_deck = Deck(Path('policy-deck.txt'), "\n".join, str.splitlines)
  policy_disc = Deck(Path('policy-discard.txt'), "\n".join, str.splitlines)
  policy_opts = Deck(Path('policy-options.txt'), "\n".join, str.splitlines)


class PlayerInfo(TypedDict):
  title: str
  phone: str


class PublicState:
  path = Path('state/public')

  policy_hist = Deck(Path('policies-enacted.txt'), "\n".join, str.splitlines)


class StaticFiles:
  path = Path('static')

  player_info = FileBacked[dict[str, PlayerInfo]](Path('player-info.toml'), str, tomllib.loads)
  roles_available = Deck(Path('roles-available.txt'), "\n".join, str.splitlines)
  policies_available = Deck(Path('policies-available.txt'), "\n".join, str.splitlines)


@dataclass
class State:
  static = StaticFiles()
  secret = SecretState()
  public = PublicState()

  def ensure_drawable_policy_deck(self):
    if (num_policies := len(self.secret.policy_deck)) < 3:

      print(f"{num_policies} policies in deck; shuffling.")
      self.secret.policy_deck = random.sample(
        population=(combined := (
          self.secret.policy_deck +
          self.secret.policy_disc
        )),
        k=len(combined), 
      )
      self.secret.policy_disc = []

  def draw_policy_opts(self):
    self.ensure_drawable_policy_deck()
    assert not self.secret.policy_opts
    self.secret.policy_opts = self.secret.policy_deck[:3]
    self.secret.policy_deck = self.secret.policy_deck[3:]

  def discard_policy_opt(self, i: int = 1):
    assert len(self.secret.policy_opts) > i
    self.secret.policy_disc += [self.secret.policy_opts[i]]
    self.secret.policy_opts = [opt for j, opt in enumerate(self.secret.policy_opts) if j != i]
