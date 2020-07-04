#!/usr/bin/env bats

load vars
load deck
cd $STATE

@test "ensure_drawable_policy_deck" {
	tee $SECRET/policy-deck.txt <<EOF >/dev/null
card1
card2
EOF
	tee $SECRET/policy-discard.txt <<EOF >/dev/null
card3
card4
card5
EOF

	ensure_drawable_policy_deck

	diff -U0 <(tail -n+1 $SECRET/policy-*.txt) - <<EOF
==> state/__SECRET__/policy-deck.txt <==
card2
card1

==> state/__SECRET__/policy-discard.txt <==
card3
card4
card5
EOF
}
