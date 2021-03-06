SOURCE_PDF=Secret_Hitler_PnP_color_with_backface.pdf
SHELL=bash
CONVERT_FLAGS=-density 300 -define png:include-chunk=none

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

all: roles parties policies policycombos boards
clean:
	rm *.png
rebuild: clean all

roles: $(shell echo role-{fascist-{1..3},hitler,liberal-{1..6}}.png)
parties: $(shell echo party-{fascist,liberal}.png)
boards: $(shell echo board-{5or6,7or8,9or10}.png)
policies: $(shell echo policy-{fascist,liberal}.png)
policycombos: $(shell echo policycombo-{fascist,liberal}-{fascist,liberal}{,-{fascist,liberal}}.png)

role-%.png: GRID=4x2@
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

party-%.png: GRID=4x2@
party-%.png: PAGE=2
party-fascist.png: RANGE=2
party-liberal.png: RANGE=4

party-%:
	$(split-page)

policy-%: GRID=6x3@
policy-%: PAGE=12
policy-fascist.png: RANGE=0
policy-liberal.png: RANGE=12

policy-%.png:
	$(split-page)

# explanation: bash expands "abc-{1,2,3}.png" into "abc-1.png abc-2.png abc-3.png", so if
# target is policies-fascist-liberal-liberal.png, then then statement below evaluates to:
#   $ convert policy-fascist.png policy-liberal.png +append policies-fascist-liberal-liberal.png
policycombo-%.png:
	convert $(shell eval "echo policy-{$$(echo "$*" | tr '-' ',')}.png") +append $@

board-%.png: boardpart-fascist-%.png boardpart-liberal.png
	convert $^ -append $@

boardpart-fascist-5or6.png:  PAGE=14
boardpart-fascist-7or8.png:  PAGE=15
boardpart-fascist-9or10.png: PAGE=16
boardpart-liberal.png:       PAGE=17

boardpart-%.png:
	$(split-and-rotate)
