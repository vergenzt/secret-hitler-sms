#!/usr/bin/env bats

load vars
load deck

@test "ensure_drawable_policy_deck" {
	tee $SECRET/policy-deck.txt <<-EOF
	card1
	card2
	EOF
	tee $SECRET/policy-discard.txt <<-EOF
	card3
	card4
	card5
	EOF

	ensure_drawable_policy_deck

	diff -U1 "`sort $SECRET/policy-deck.txt`" <<-EOF
	card1
	card2
	card3
	card4
	card5
	EOF
	diff -U1 "`sort $SECRET/policy-discard.txt`" <<-EOF
	EOF
}
