#!/usr/bin/env bash

SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

format-card() {
  PAGENUM=$1
  GRID=$2
  RANGE=$3
  FILENAME=$4
  convert \
    $SOURCE_PDF[$PAGENUM] \
    -trim \
    -crop $GRID \
}

format-board() {
  PAGENUM=$1
  FILENAME=$2
  convert \
    $SOURCE_PDF[$PAGENUM] \
    -trim \
    -shave 3 \
    -crop 2x1@ \
    \( -clone -2 -rotate -90 \) \
    \( -clone -2 -rotate  90 \) \
    -delete 0-1 \
    +append \
    $FILENAME
}

format-board 14 board-fascist-5or6.png
format-board 15 board-fascist-7or8.png
format-board 16 board-fascist-9or10.png
format-board 17 board-liberal.png
