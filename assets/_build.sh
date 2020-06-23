#!/usr/bin/env bash


format-card() {
  PAGENUM=$1
  GRID=$2
  RANGE=$3
  FILENAME=$4
  convert \
    $SOURCE_PDF[$PAGENUM] \
    -trim \
    -crop $GRID \
    \( -clone $RANGE \) \
    -delete 0--2 \
    $FILENAME
}

format-card 0 4x2@ 0,2-3 role-fascist.png

format-board() {
  PAGENUM=$1
  FILENAME=$2
}
