SOURCE := $(shell find lazycat -type f)
VERSION := $(shell cat .version || git describe --long --dirty)
UNAME := $(shell uname)

CFLAGS = -O3
LIBFLAGS =
LIBOPENGL = -lGL
TAR_CMD = tar
DATE_CMD = date

ifeq ($(UNAME),Darwin)
# taken from hashlink's Makefile
CFLAGS += -I /usr/local/include -I /usr/local/opt/libjpeg-turbo/include -I /usr/local/opt/jpeg-turbo/include -I /usr/local/opt/sdl2/include/SDL2 -I /usr/local/opt/libvorbis/include -I /usr/local/opt/openal-soft/include -Dopenal_soft
LIBFLAGS += -L/usr/local/opt/libjpeg-turbo/lib -L/usr/local/opt/jpeg-turbo/lib -L/usr/local/lib -L/usr/local/opt/libvorbis/lib -L/usr/local/opt/openal-soft/lib
LIBOPENGL = -framework OpenGL
TAR_CMD = gtar
DATE_CMD = gdate
endif

.PHONY: all
all: export/js export/hl export/native

.PHONY: release
release: all export/source

.PHONY: clean
clean:
	rm -rf export

.PHONY: lint
lint: .haxelib
	haxelib install checkstyle
	haxelib run checkstyle -s lazycat --exitcode

.haxelib:
	haxelib newrepo

.installed-deps-haxe-js: js.hxml compile.hxml .haxelib
	haxelib install js.hxml --always
	touch $@

.installed-deps-haxe-hl: hl.hxml hashlink.hxml compile.hxml .haxelib
	haxelib install hl.hxml --always
	touch $@

.installed-deps-haxe-native: native.hxml hashlink.hxml compile.hxml .haxelib
	haxelib install native.hxml --always
	touch $@

export/hl/lazycat.hl: $(SOURCE) .installed-deps-haxe-hl
	mkdir -p $(@D)
	haxe hl.hxml

export/hl/assets:
	mkdir -p $@
	cp lazycat/assets/* $@

export/hl: export/hl/lazycat.hl export/hl/assets
	$(TAR_CMD) --create --gzip --file lazycat-hl-$(VERSION).tar.gz --exclude=$@/src --transform "s/^export\/native/lazycat/" $@
	mv lazycat-hl-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/native/src/lazycat.c: $(SOURCE) .installed-deps-haxe-native
	mkdir -p $(@D)
	haxe native.hxml
	touch $@

export/native/game.bin: export/native/src/lazycat.c
	mkdir -p $(@D)
	cp /usr/local/lib/fmt.hdll $(@D)
	cp /usr/local/lib/openal.hdll $(@D)
	cp /usr/local/lib/sdl.hdll $(@D)
	cp /usr/local/lib/ui.hdll $(@D)
	cp /usr/local/lib/libhl.* $(@D)
	cd $(@D); gcc $(CFLAGS) -o $(@F) -std=c11 -Isrc src/lazycat.c $(LIBFLAGS) -lhl sdl.hdll ui.hdll fmt.hdll openal.hdll ui.hdll -lSDL2 -lm -lopenal $(LIBOPENGL)

export/native/lazycat: export/native/game.bin scripts/native.sh
	cp scripts/native.sh $@

export/native/assets:
	mkdir -p $@
	cp lazycat/assets/* $@

export/native: export/native/lazycat export/native/assets
	$(TAR_CMD) --create --gzip --file lazycat-$(UNAME)-$(VERSION).tar.gz --exclude=$@/src --transform "s/^export\/native/lazycat/" $@
	mv lazycat-$(UNAME)-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/js/assets:
	mkdir -p $@
	cp lazycat/assets/* $@

export/js/lazycat.js: $(SOURCE) .installed-deps-haxe-js
	mkdir -p $(@D)
	haxe js.hxml

export/js/index.html: lazycat/data/index.html
	mkdir -p $(@D)
	cp lazycat/data/index.html $@

export/js: export/js/lazycat.js export/js/index.html export/js/assets
	$(TAR_CMD) --create --gzip --file lazycat-js-$(VERSION).tar.gz --transform "s/^export\/js/lazycat/" $@
	mv lazycat-js-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/source: $(SOURCE)
	rm -f $@/*.zip
	mkdir -p $@
	echo $(VERSION) > .version
	git archive --output=export/source/lazycat-source-$(VERSION).zip --prefix=lazycat/ --format=zip --add-file=.version HEAD
	rm .version
	$(DATE_CMD) -Iseconds

.PHONY: test-js
test-js: export/js
	python -m http.server --directory export/js

.PHONY: test-hl
test-hl: export/hl
	cd export/hl; hl lazycat.hl

.PHONY: test-native
test-native: export/native
	export/native/lazycat
