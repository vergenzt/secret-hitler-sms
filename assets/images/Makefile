SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

define split-page
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) -shave 10 \) \
		-delete 0--2 \
		$@
endef

define split-page-and-choose
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) -shave 10 \) \
		\( -clone -$(shell echo "$@" | tr -dc 0-9) \) \
		-delete 0--2 \
		$@
endef

define split-and-rotate
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-shave 3 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$@
endef

all: players policies boards
.INTERMEDIATE: role-hitler.png

players: $(shell echo player-{fascist-{1..3},hitler,liberal-{1..6}}.png)
policies: $(shell echo policy-{fascist,liberal}.png)
boards: $(shell echo board-{fascist-{5or6,7or8,9or10},liberal}.png)

player-fascist-%.png: role-fascist-%.png party-fascist.png
	convert role-fascist-$*.png party-fascist.png +append $@
player-hitler.png: role-hitler.png party-fascist.png
	convert role-hitler.png party-fascist.png +append $@
player-liberal-%.png: role-liberal-%.png party-liberal.png
	convert role-liberal-$*.png party-liberal.png +append $@

role-%: GRID=4x2@
role-fascist-%.png: PAGE=0
role-fascist-%.png: RANGE=0,2-3
role-hitler.png: PAGE=0
role-hitler.png: RANGE=1
role-liberal-%.png: PAGE=0,2
role-liberal-%.png: RANGE=4-9

role-fascist-%.png:
	$(split-page-and-choose)
role-hitler.png:
	$(split-page)
role-liberal-%.png:
	$(split-page-and-choose)

party-%: GRID=4x2@
party-%: PAGE=2
party-fascist.png: RANGE=2
party-liberal.png: RANGE=4

party-%:
	$(split-page)

policy-%: GRID=6x3@
policy-%: PAGE=12
policy-fascist.png: RANGE=0
policy-liberal.png: RANGE=12

policy-%:
	$(split-page)

board-fascist-5or6.png:  PAGE=14
board-fascist-7or8.png:  PAGE=15
board-fascist-9or10.png: PAGE=16
board-liberal.png:       PAGE=17

board-%:
	$(split-and-rotate)
