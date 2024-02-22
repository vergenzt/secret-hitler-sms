import json
import subprocess as sp

def github_latest_url(repo: str, asset_name: str) -> str:
  version_url = f"https://api.github.com/repos/{repo}/releases/latest"
  version = json.loads(sp.check_output(["curl", "-sS", version_url], text=True))
  asset_url = f"https://github.com/{repo}/releases/download/{version['tag_name']}/{asset_name}"
  return asset_url
