source := $(shell find lazycat -type f)
version := $(shell cat .version || git describe --long --dirty)

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

export/hl/lazycat.hl: $(source) .installed-deps-haxe-hl
	mkdir -p $(@D)
	haxe hl.hxml

export/hl: export/hl/lazycat.hl
	cp /usr/local/lib/fmt.hdll $@
	cp /usr/local/lib/openal.hdll $@
	cp /usr/local/lib/sdl.hdll $@
	cp /usr/local/lib/ui.hdll $@

export/native/src/lazycat.c: $(source) .installed-deps-haxe-native
	mkdir -p $(@D)
	haxe native.hxml

export/native/lazycat: export/native/src/lazycat.c
	gcc -O3 -o $@ -std=c++03 -I$(@D)/src $(@D)/src/lazycat.c /usr/local/lib/sdl.hdll /usr/local/lib/ui.hdll /usr/local/lib/fmt.hdll /usr/local/lib/openal.hdll /usr/local/lib/ui.hdll -lhl -lSDL2 -lm -lopenal -lGL

export/native: export/native/lazycat

export/js/lazycat.js: $(source) .installed-deps-haxe-js
	mkdir -p $(@D)
	haxe js.hxml

export/js/index.html: lazycat/data/index.html
	mkdir -p $(@D)
	cp lazycat/data/index.html $@

export/js: export/js/lazycat.js export/js/index.html
	rm -f $@/*.zip
	zip -j $@/lazycat-$(version).zip $@/*
	cp $@/lazycat-$(version).zip $@/lazycat-game.zip
	date -Iseconds

export/source: $(source)
	rm -f $@/*.zip
	mkdir -p $@
	echo $(version) > .version
	git archive --output=export/source/lazycat-source-$(version).zip --prefix=lazycat/ --format=zip --add-file=.version HEAD
	rm .version
	date -Iseconds

.PHONY: test-js
test-js: export/js
	python -m http.server --directory export/js

.PHONY: test-hl
test-hl: export/hl
	cd export/hl; hl lazycat.hl

.PHONY: test-native
test-native: export/native
	cd export/native; ./lazycat
