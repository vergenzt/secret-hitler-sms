SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

all: $(shell echo \
	player-{fascist,hitler,liberal}.png
	board-{fascist-{5or6,7or8,9or10},liberal}.png \
)

players:

player-%: role-% party-%
	convert $^ +append $@

role-%: GRID=4x2@ split-page
role-fascist.png: PAGE=0 RANGE=1-4
party-%: GRID=4x2@ split-page

board-%: split-and-rotate
board-fascist-5or6.png:  PAGE=14
board-fascist-7or8.png:  PAGE=15
board-fascist-9or10.png: PAGE=16
board-liberal.png:       PAGE=17

split-page:
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) \) \
		-delete 0--2 \
		$@

split-and-rotate:
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-shave 3 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$@
