SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

define split-page =
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) \) \
		-delete 0--2 \
		$<
endef

define split-and-rotate =
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-shave 3 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$<
endef

all: players policies boards

players: $(shell echo player-{fascist,hitler,liberal}.png)
policies: $(shell echo policy-{fascist,liberal}.png)
boards: $(shell echo board-{fascist-{5or6,7or8,9or10},liberal}.png)

player-%: role-% party-%
	convert $^ +append $@

role-%:
	$(split-page)
party-%:
	$(split-page)
policy-%:
	$(split-page)
board-%:
	$(split-and-rotate)

role-* party-*: GRID=4x2@

role-fascist*.png: PAGE=0   RANGE=1,3-4
role-hitler.png:  GRID=4x2@ PAGE=0   RANGE=2
role-liberal*.png: GRID=4x2@ PAGE=0,2 RANGE=5-10

party-fascist.png: GRID=4x2@ PAGE=2 RANGE=3
party-liberal.png: GRID=4x2@ PAGE=2 RANGE=5

policy-fascist.png: GRID=6x3@ PAGE=12 RANGE=1
policy-liberal.png: GRID=6x3@ PAGE=12 RANGE=13

board-fascist-5or6.png:  PAGE=14
board-fascist-7or8.png:  PAGE=15
board-fascist-9or10.png: PAGE=16
board-liberal.png:       PAGE=17
