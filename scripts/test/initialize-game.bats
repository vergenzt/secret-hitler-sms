#!/usr/bin/env bats

setup() {
  export STATE=$BATS_TMPDIR/state
  rm -rf "${BATS_TMPDIR:?}/*"
  send_sms() { echo -e "SEND_SMS:\n" "$@"; }
}

@test "initialize-game" {

  ./initialize-game


}
