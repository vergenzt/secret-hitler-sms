from ..lib import PUBLIC, SECRET

def reset_game():
  while input("To reset game state, please type RESET: ") != "RESET":
    pass

  for path in *PUBLIC.glob("*"), *SECRET.glob("*"):
    if path.is_file():
      path.unlink()
