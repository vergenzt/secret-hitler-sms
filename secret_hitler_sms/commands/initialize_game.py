import random

from ..lib import State, image_url, send_sms


def initialize_game(state: State):
  assert not state.secret.player_roles

  print("Assigning player roles... ", end="")
  state.secret.player_roles = {
    name: role
    for name, role in zip(
      state.static.player_info.keys(),
      random.sample(
        state.static.roles_available[:len(state.static.player_info)],
        k=len(state.static.player_info),
      )
    )
  }
  print("Done.")

  print("Initializing & shuffling decks... ", end="")
  state.secret.policy_disc = state.static.policies_available
  state.ensure_drawable_policy_deck()
  print("Done.")

  print("Distributing secret player roles via SMS... ", end="")
  for name, player_info in state.static.player_info.items():
    secret_role, secret_party = state.secret.player_roles[name].split(':')
    message = f"Hi {name}! Here's your SECRET (🤫) role and party membership cards for Secret Hitler. 🙂 Enjoy the game!"
    send_sms(
      player_info["phone"],
      message,
      image_url("role", secret_role),
      image_url("party", secret_party),
    )
  print("Done.")

  print()
  print("Let the games begin!!!")
