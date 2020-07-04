#!/usr/bin/env bats

load vars
load deck
cd $STATE || exit

@test "ensure_drawable_policy_deck" {
  tee $SECRET/policy-deck <<EOF >/dev/null
card1
card2
EOF
  tee $SECRET/policy-discard <<EOF >/dev/null
card3
card4
card5
EOF

  ensure_drawable_policy_deck

  diff -U3 - <(tail -n+1 $SECRET/policy-* | sed "s:$BATS_TMPDIR\/::g") <<EOF
==> state/__SECRET__/policy-deck <==
card1
card2
card3
card4
card5

==> state/__SECRET__/policy-discard <==
EOF
}

teardown() {
  rm -r ${STATE:?}/*
}
