#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
trap "kill 0" EXIT
source scripts/__lib.sh

rm $SECRET/policy-{deck,options,discard,record}.txt
