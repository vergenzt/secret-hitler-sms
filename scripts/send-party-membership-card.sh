#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

send_sms "$(lookup "$PUBLIC_PLAYER_PHONES"
