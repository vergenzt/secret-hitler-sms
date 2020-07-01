#!/usr/bin/env bash

policy_deck_length() {
  cat $SECRET/policy-deck.txt 2>/dev/null | wc -l
}

ensure_drawable_policy_deck() {
  if [[ `policy_deck_length` -lt 3 ]]; then
    echo "$(policy_deck_length) policies in deck; shuffling."
    cat "$SECRET/policy-discard.txt" "$SECRET/policy-deck.txt" | gshuf | sponge $SECRET/policy-deck.txt
  fi
}

# draw $N cards from head of $FROM_DECK and append to tail of $TO_DECK
draw_cards() {
  N=$1; FROM_DECK=$2; TO_DECK=$3
  cat "$FROM_DECK" | awk "NR <= $N { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR >  $N { print \$0 }" | sponge "$FROM_DECK"
}

# move 1 card from position $I of $FROM_DECK and append to tail of $TO_DECK
move_card() {
  I=$1; FROM_DECK=$2; TO_DECK=$3
  cat "$FROM_DECK" | awk "NR == $I { print \$0 }" >> "$TO_DECK"
  cat "$FROM_DECK" | awk "NR != $I { print \$0 }" | sponge "$FROM_DECK"
}

# pick a card from position $I of $FROM_DECk
pick_card() {
  I=$1; FROM_DECK=$2
  awk "NR == $I { print \$0 }" "$FROM_DECK" \
    | tr -d '[[:digit:]]' # get rid of unique policy identifiers
}
