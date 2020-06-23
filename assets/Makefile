SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

define split-page
	convert $(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) -trim \) \
		\( -clone -$(INDEX) \)
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

players: $(shell echo player-{fascist-{1..3},hitler,liberal-{1..6}}.png)
policies: $(shell echo policy-{fascist,liberal}.png)
boards: $(shell echo board-{fascist-{5or6,7or8,9or10},liberal}.png)

player-fascist-%.png: role-fascist-%.png party-fascist.png
player-hitler.png:  role-hitler.png   party-fascist.png
player-liberal-%.png: role-liberal-%.png party-liberal.png

player-%:
	convert $^ +append $@

role-%: GRID=4x2@
role-fascist-%.png: PAGE=0
role-fascist-%.png: RANGE=1,3-4
role-fascist-%.png: INDEX=$*
role-hitler.png: PAGE=0
role-hitler.png: RANGE=2
role-liberal-%.png: PAGE=0,2
role-liberal-%.png: RANGE=5-10
role-liberal-%.png: INDEX=$*

role-%:
	$(split-page)

party-%: GRID=4x2@
party-%: PAGE=2
party-fascist.png: RANGE=3
party-liberal.png: RANGE=5

party-%:
	$(split-page)

policy-%: GRID=6x3@
policy-%: PAGE=12
policy-fascist.png: RANGE=1
policy-liberal.png: RANGE=13

policy-%:
	$(split-page)

board-fascist-5or6.png:  PAGE=14
board-fascist-7or8.png:  PAGE=15
board-fascist-9or10.png: PAGE=16
board-liberal.png:       PAGE=17

board-%:
	$(split-and-rotate)
