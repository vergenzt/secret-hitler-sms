#!/usr/bin/env bats

setup() {
  rm -r ${BATS_TMPDIR:?}/*
  export STATE=$BATS_TMPDIR/state
  load vars
  load deck
}

@test "ensure_drawable_policy_deck" {
  # override shuffle function for test
  gshuf() { sort "$@"; }

  cat >$SECRET/policy-deck <<EOF
card1
card2
EOF
  cat >$SECRET/policy-discard <<EOF
card3
card4
card5
EOF

  ensure_drawable_policy_deck

  diff -u - <(tail -n+1 $SECRET/policy-*) <<EOF
==> $SECRET/policy-deck <==
card1
card2
card3
card4
card5

==> $SECRET/policy-discard <==
EOF
}

@test "deck_length" {
  cat >$SECRET/policy-deck <<EOF
card1
card2
EOF
  [ "`deck_length $SECRET/policy-deck`" -eq 2 ]
}
