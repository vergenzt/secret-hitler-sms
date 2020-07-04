#!/usr/bin/env bats

load vars
load deck
cd $STATE || exit

# override shuffle function so we can compare
gshuf() { sort "$@"; }

@test "ensure_drawable_policy_deck" {
  cat > $SECRET/policy-deck <<EOF
card1
card2
EOF
  tee $SECRET/policy-discard <<EOF >/dev/null
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
