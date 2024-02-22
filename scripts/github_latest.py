import hashlib
import json
import subprocess as sp
import textwrap

def github_latest_url(pfx: str, repo: str, asset_name: str) -> str:
  version_url = f"https://api.github.com/repos/{repo}/releases/latest"
  version = json.loads(sp.check_output(["curl", "-sS", version_url], text=True))
  asset_url = f"https://github.com/{repo}/releases/download/{version['tag_name']}/{asset_name}"
  asset_bytes = sp.check_output(["curl", "-sSL", asset_url])
  asset_sha = hashlib.sha256(asset_bytes).hexdigest()
  return textwrap.dedent(f"""
    {pfx}_LATEST_URL={asset_url}
    {pfx}_LATEST_SHA={asset_sha}
  """).strip()
