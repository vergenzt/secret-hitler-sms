#!/usr/bin/env bash
set -euo pipefail

# [[[cog print(github_latest_url('CURL', 'moparisthebest/static-curl', 'curl-amd64'))]]]
CURL_LATEST_URL=https://github.com/moparisthebest/static-curl/releases/download/v8.5.0/curl-amd64
CURL_LATEST_SHA=2a329772e1a01cf967ddd2963592851f75279c4a2b5e38a303d5dd16ec085e5b
# [[[end]]] (checksum: da6ea243dba236d4ce526784ddc0f167)

# [[[cog print(github_latest_url('JQ', 'jqlang/jq', 'jq-linux-amd64'))]]]
JQ_LATEST_URL=https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64
JQ_LATEST_SHA=5942c9b0934e510ee61eb3e30273f1b3fe2590df93933a93d7c58b81d19c8ff5
# [[[end]]] (checksum: 002ebc5ee4e465e6c4c446b9e1dea722)

# [[[cog print(github_latest_url('JSV', 'neilpa/yajsv', 'yajsv.linux.amd64'))]]]
JSV_LATEST_URL=https://github.com/neilpa/yajsv/releases/download/v1.4.1/yajsv.linux.amd64
JSV_LATEST_SHA=4bd6d2b1d6292ab1f7ba63db83c182a603a790d431429cf71f05cb0fcc677def
# [[[end]]] (checksum: f1f0e13ffb9dde3479409d6263721aaa)

for bin in curl jq jsv; do
  urlvar=${bin^^}_LATEST_URL
  shavar=${bin^^}_LATEST_SHA
  if [ ! -f "$BIN/$bin" ]; then
    "${curl[@]}" "${!urlvar}" -o $BIN/$bin
    chmod +x $BIN/$bin
  fi
  echo "${!shavar}  $BIN/$bin" | sha256sum --check -
done
