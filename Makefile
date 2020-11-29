source := $(shell find lazycat -type f) .installed-deps-haxe

.PHONY: all
all: export/js

.PHONY: lint
lint: .haxelib
	haxelib install checkstyle
	haxelib run checkstyle -s lazycat --exitcode

.haxelib:
	haxelib newrepo

.installed-deps-haxe: compile.hxml .haxelib
	haxelib install compile.hxml
	touch $@

export/js/lazycat.js: $(source)
	haxe compile.hxml --js $@

export/js/index.html: lazycat/data/index.html
	cp lazycat/data/index.html $@

export/js: export/js/lazycat.js export/js/index.html
	mkdir -p $@
	date -Iseconds

.PHONY: test-js
test-js: export/js
	python -m http.server --directory export/js
