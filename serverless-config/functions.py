import json
import re
from pathlib import Path
import sys


print()
print('# https://www.serverless.com/framework/docs/providers/aws/guide/functions')
print('# https://www.serverless.com/framework/docs/providers/aws/events/http-api')

for path in sorted(Path('src/functions').glob('*.sh')):
  fn_name = ''.join(map(str.capitalize, path.stem.split('-'))) # camel case
  fn_body = path.read_text()

  if not (http_events := re.findall((_re := r'^# httpApi:\s*(.*)$'), fn_body, re.M)):
    print(f"warning: file {path} does not contain line matching re {_re!r}", file=sys.stderr)
    continue

  print()
  print(fn_name + ": " + json.dumps(indent=2, obj={
    "handler": str(path),
    "events": [
      { "httpApi": event }
      for event in http_events
    ]
  }))

print()
