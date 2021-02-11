#!/usr/bin/env bats

setup() {
  export STATE=$BATS_TMPDIR/state
  rm -rf "${BATS_TMPDIR:?}/*"
  send_sms() { echo -e "SEND_SMS:\n" "$@"; }
}

@test "initialize-game" {

  ./scripts/initialize-game
  #tail -n+0 $BATS_TMPDIR/diff -u <<EOF -


}
