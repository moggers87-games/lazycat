source := $(shell find lazycat -type f) .installed-deps-haxe
version := $(shell cat .version || git describe --long --dirty)

.PHONY: all
all: export/js

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

.installed-deps-haxe: compile.hxml .haxelib
	haxelib install compile.hxml --always
	touch $@

export/js/lazycat.js: $(source)
	haxe compile.hxml --js $@

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
