SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

all: players policies boards

players: $(shell echo player-{fascist,hitler,liberal}.png)
policies: $(shell echo policy-{fascist,liberal}.png)
boards: $(shell echo board-{fascist-{5or6,7or8,9or10},liberal}.png)

player-%: role-% party-%
	convert $^ +append $@

board-%:  split-and-rotate

role-fascist.png: GRID=4x2@ PAGE=0   RANGE=1,3-4 split-page
role-hitler.png:  GRID=4x2@ PAGE=0   RANGE=2 split-page
role-liberal.png: GRID=4x2@ PAGE=0,2 RANGE=5-10 split-page

party-fascist.png: GRID=4x2@ PAGE=2 RANGE=3 split-page
party-liberal.png: GRID=4x2@ PAGE=2 RANGE=5 split-page

policy-fascist.png: GRID=6x3@ PAGE=12 RANGE=1 split-page
policy-liberal.png: GRID=6x3@ PAGE=12 RANGE=13 split-page

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
		$<

split-and-rotate:
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-shave 3 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$<
