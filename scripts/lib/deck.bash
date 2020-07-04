#!/usr/bin/env bash

deck_length() {
  cat "$1".yaml 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ `deck_length $SECRET/policy-deck.yaml` -lt 3 ]]; then
    echo "$(deck_length $SECRET/policy-deck.yaml) policies in deck; shuffling."
    draw_cards "`deck_length $SECRET/policy-discard.yaml`" $SECRET/policy-discard.yaml >> $SECRET/policy-deck.yaml
    gshuf "$SECRET/policy-deck.txt" | sponge $SECRET/policy-deck.txt
  fi
}

# remove $N cards from head of $FROM_DECK and send to stdout
draw_cards() {
  N=$1; FROM_DECK=$2
  cat "$FROM_DECK" | awk "NR <= $N { print \$0 }"
  cat "$FROM_DECK" | awk "NR >  $N { print \$0 }" | sponge "$FROM_DECK"
}

# remove 1 card from position $I of $FROM_DECK and send to stdout
remove_card() {
  I=$1; FROM_DECK=$2
  cat "$FROM_DECK" | awk "NR == $I { print \$0 }"
  cat "$FROM_DECK" | awk "NR != $I { print \$0 }" | sponge "$FROM_DECK"
}

# pick a card from position $I of $FROM_DECK
show_card() {
  I=$1; FROM_DECK=$2
  cat "$FROM_DECK" | awk "NR == $I { print \$0 }"
}
