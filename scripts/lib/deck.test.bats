#!/usr/bin/env bats

load vars
load deck
cd $STATE || exit


@test "ensure_drawable_policy_deck" {

  # override shuffle function so we can compare
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

teardown() {
  rm -r ${STATE:?}/*
}
