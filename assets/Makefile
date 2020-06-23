SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf

all: $(shell echo \
	board-{fascist-{5or6,7or8,9or10},liberal}.png \
)

board:
	convert \
		$SOURCE_PDF[$PAGE] \
		-trim \
		-shave 3 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$<

board-fascist-5or6.png:  PAGE=14 board
board-fascist-7or8.png:  PAGE=15
board-fascist-9or10.png: PAGE=16
board-liberal.png:       PAGE=17
