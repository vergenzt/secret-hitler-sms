#!/usr/bin/env bash

policy_deck_length() {
  cat $SECRET/policy-deck.txt 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ `policy_deck_length` -lt 3 ]]; then
    echo "$(policy_deck_length) policies in deck; shuffling."
    draw_cards `policy_deck_length` >> $SECRET/policy-deck.txt
    cat "$SECRET/policy-discard.txt" "$SECRET/policy-deck.txt" | gshuf | sponge $SECRET/policy-deck.txt
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
