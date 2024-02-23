#!/usr/bin/env bash
source src/lib.sh

# httpApi: GET /utils/list-aws-bins

function util-get-bins() {
  { IFS=:; ls -H "$PATH" 2>/dev/null; } | sort | uniq
}
