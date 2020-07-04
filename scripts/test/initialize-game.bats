#!/usr/bin/env bats

setup() {
  export STATE=$BATS_TMPDIR/state
  rm -r "${BATS_TMPDIR:?}/*"
}

@test "initialize-game" {
  send_sms() { echo -e "SEND_SMS:\n" "$@"; }



}
