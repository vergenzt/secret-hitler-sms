#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

read -p "Who gets to peek at the policy deck?  ($PUBLIC_PLAYER_NAMES_PROMPT): " PEEKER
read -p "Confirm: " PEEKER_CONFIRM
