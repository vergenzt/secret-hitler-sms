#!/usr/bin/env bash
(return 0 2>/dev/null) || cd "$(dirname "$0")"/.. || exit 1
source scripts/__lib.sh

while [[ "$PEEKER" != "$PEEKER_CONFIRM" ]]; do
  read -p "Who gets to peek at the policy deck? ($PUBLIC_PLAYER_NAMES_PROMPT): " PEEKER
  read -p "Type again to confirm: " PEEKER_CONFIRM
done
