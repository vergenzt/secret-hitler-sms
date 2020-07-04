#!/usr/bin/env bats

setup() {
  export STATE=$BATS_TMPDIR/state
}

@test "initialize-game" {
  send_sms() { echo -e "SEND_SMS:\n" "$@"; }

  ./

}
