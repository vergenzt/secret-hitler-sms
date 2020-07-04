#!/usr/bin/env bats

load vars
load deck
cd $STATE || exit

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

	echo `deck_length $SECRET/policy-discard.txt` >&3
	ensure_drawable_policy_deck

	diff -U3 - <(tail -n+1 $SECRET/policy-*.txt | sed "s:$BATS_TMPDIR\/::g") <<EOF
==> state/__SECRET__/policy-deck.txt <==
card1
card2
card3
card4
card5

==> state/__SECRET__/policy-discard.txt <==
EOF
}
