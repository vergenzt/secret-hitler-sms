SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf
SHELL=bash
CONVERT_FLAGS=-density 300 -strip

define split-page
	convert \
	  $(CONVERT_FLAGS) \
		$(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) -shave 40 \) \
		-delete 0--2 \
		$@
endef

define split-page-and-choose
	convert \
	  $(CONVERT_FLAGS) \
		$(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-crop $(GRID) \
		\( -clone $(RANGE) -shave 40 \) \
		\( -clone -$(shell echo "$@" | tr -dc 0-9) \) \
		-delete 0--2 \
		$@
endef

define split-and-rotate
	convert \
	  $(CONVERT_FLAGS) \
		$(SOURCE_PDF)[$(PAGE)] \
		-trim \
		-shave 11x11 \
		-crop 2x1@ \
		\( -clone -2 -rotate -90 \) \
		\( -clone -2 -rotate  90 \) \
		-delete 0-1 \
		+append \
		$@
endef

all: build
build: roles parties policies policycombos boards
clean:
	rm -f *.jpg
rebuild:
	$(MAKE) clean
	$(MAKE) build

roles: $(shell echo rl-{f-{1..3},h,l-{1..6}}.jpg)
parties: $(shell echo pa-{f,l}.jpg)
boards: $(shell echo board-{5or6,7or8,9or10}.jpg)
policies: $(shell echo po-{f,l}.jpg)
policycombos: $(shell echo pos-{f,l}{f,l}{,{f,l}}.jpg)

rl-%.jpg: GRID=4x2@
rl-f-%.jpg: PAGE=0
rl-f-%.jpg: RANGE=0,2-3
rl-h.jpg: PAGE=0
rl-h.jpg: RANGE=1
rl-l-%.jpg: PAGE=0,2
rl-l-%.jpg: RANGE=4-9

rl-f-%.jpg:
	$(split-page-and-choose)
rl-h.jpg:
	$(split-page)
rl-l-%.jpg:
	$(split-page-and-choose)

pa-%.jpg: GRID=4x2@
pa-%.jpg: PAGE=2
pa-f.jpg: RANGE=2
pa-l.jpg: RANGE=4

pa-%:
	$(split-page)

po-%: GRID=6x3@
po-%: PAGE=12
po-f.jpg: RANGE=0
po-l.jpg: RANGE=12

po-%.jpg:
	$(split-page)

pos-%.jpg: po-f.jpg po-l.jpg
	convert $(shell for c in $$(echo "$*" | grep -o .); do echo po-$$c.jpg; done) +append $@

board-%.jpg: boardpart-f-%.jpg boardpart-l.jpg
	convert $^ -append $@

boardpart-f-5or6.jpg:  PAGE=14
boardpart-f-7or8.jpg:  PAGE=15
boardpart-f-9or10.jpg: PAGE=16
boardpart-l.jpg:       PAGE=17

boardpart-%.jpg:
	$(split-and-rotate)
