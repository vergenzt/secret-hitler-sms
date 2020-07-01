#!/usr/bin/env bats

load vars
load deck

@test "ensure_drawable_policy_deck" {
  tee $SECRET/policy-deck.txt <<-EOF
}
