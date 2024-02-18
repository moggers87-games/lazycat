NAME := $(shell cat .name)
SOURCE := $(shell find $(NAME) -type f)
VERSION := $(shell cat .version || git describe --long --dirty || git describe --long --dirty --all | sed 's/\//-/g')
UNAME := $(shell uname)

CFLAGS = -O3
LIBFLAGS =
LIBOPENGL = -lGL
TAR_CMD = tar
DATE_CMD = date
LIB_EXT = so

ifeq ($(UNAME),Darwin)
# taken from hashlink's Makefile
CFLAGS += -I /usr/local/include -I /usr/local/opt/libjpeg-turbo/include -I /usr/local/opt/jpeg-turbo/include -I /usr/local/opt/sdl2/include/SDL2 -I /usr/local/opt/libvorbis/include -I /usr/local/opt/openal-soft/include -Dopenal_soft
LIBFLAGS += -L/usr/local/opt/libjpeg-turbo/lib -L/usr/local/opt/jpeg-turbo/lib -L/usr/local/lib -L/usr/local/opt/libvorbis/lib -L/usr/local/opt/openal-soft/lib
LIBOPENGL = -framework OpenGL
TAR_CMD = gtar
DATE_CMD = gdate
LIB_EXT = dylib
endif

HASHLINK_VERSION = df137d0408725ef564fd8d9defd3322a3cd3b91a
HASHLINK_DIR = hashlink-$(HASHLINK_VERSION)
HASHLINK_URL = https://github.com/HaxeFoundation/hashlink/archive/$(HASHLINK_VERSION).tar.gz
HASHLINK_LIBS = libhl.$(LIB_EXT) fmt.hdll ui.hdll uv.hdll sdl.hdll openal.hdll

.PHONY: all
all: export/js export/hl export/native

.PHONY: release
release: all export/source

.PHONY: clean-hashlink
clean-hashlink:
	(cd $(HASHLINK_DIR) && make clean) || true

.PHONY: clean
clean: clean-hashlink
	rm -rf export

.PHONY: clean-all
clean-all: clean
	git clean -dfx

.PHONY: lint
lint: .haxelib
	haxelib install checkstyle
	haxelib run checkstyle -s $(NAME) --exitcode

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

$(HASHLINK_DIR):
	curl -L $(HASHLINK_URL) | tar -xz

$(HASHLINK_DIR)/hl $(HASHLINK_DIR)/libhl.a: $(HASHLINK_DIR)
	cd $(@D) && make

export/hl/$(NAME): $(HASHLINK_DIR)/hl
	cp $(HASHLINK_DIR)/hl $@

$(foreach lib,$(HASHLINK_LIBS),export/hl/$(lib)): $(HASHLINK_DIR)/hl
	cp $(HASHLINK_DIR)/$(@F) $@

export/hl/hlboot.dat: $(SOURCE) .installed-deps-haxe-hl
	mkdir -p $(@D)
	haxe hl.hxml

export/hl/assets:
	mkdir -p $@
	cp $(NAME)/assets/* $@
	rm -f $@/*.mp3

export/hl/README.md:
	cp misc/README-hl.md $@ || cp README.md $@

export/hl: export/hl/hlboot.dat export/hl/assets export/hl/README.md export/hl/$(NAME) $(foreach lib,$(HASHLINK_LIBS),export/hl/$(lib))
	$(TAR_CMD) --create --gzip --file $(NAME)-hl-$(VERSION).tar.gz --exclude=$@/src --transform "s/^export\/hl/$(NAME)/" $@
	mv $(NAME)-hl-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/native/src/$(NAME).c: $(SOURCE) .installed-deps-haxe-native
	mkdir -p $(@D)
	haxe native.hxml
	touch $@

export/native/$(NAME): export/native/src/$(NAME).c $(HASHLINK_DIR)/libhl.a
	mkdir -p $(@D)
	gcc $(CFLAGS) -o $@ -std=c11 -I$(@D)/src -I$(HASHLINK_DIR)/src $(@D)/src/$(NAME).c $(HASHLINK_DIR)/libhl.a $(LIBFLAGS) -lSDL2 -lm -lopenal -lpthread -lpng -lz -lvorbisfile -luv -lturbojpeg $(LIBOPENGL)

export/native/assets:
	mkdir -p $@
	cp $(NAME)/assets/* $@
	rm -f $@/*.mp3

export/native/README.md:
	cp misc/README-native.md $@ || cp README.md $@

export/native: export/native/$(NAME) export/native/assets export/native/README.md
	$(TAR_CMD) --create --gzip --file $(NAME)-native-$(UNAME)-$(VERSION).tar.gz --exclude=$@/src --transform "s/^export\/native/$(NAME)/" $@
	mv $(NAME)-native-$(UNAME)-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/js/assets:
	mkdir -p $@
	cp $(NAME)/assets/* $@
	rm -f $@/*.ogg

export/js/$(NAME).js: $(SOURCE) .installed-deps-haxe-js
	mkdir -p $(@D)
	haxe js.hxml

export/js/index.html: $(NAME)/data/index.html
	mkdir -p $(@D)
	cp $(NAME)/data/index.html $@

export/js/README.md:
	cp misc/README-js.md $@ || cp README.md $@

export/js: export/js/$(NAME).js export/js/index.html export/js/assets export/js/README.md
	$(TAR_CMD) --create --gzip --file $(NAME)-js-$(VERSION).tar.gz --transform "s/^export\/js/$(NAME)/" $@
	mv $(NAME)-js-$(VERSION).tar.gz $@
	$(DATE_CMD) -Iseconds

export/source: $(SOURCE)
	mkdir -p $@
	echo $(VERSION) > .version
	git archive --output=export/source/$(NAME)-source-$(VERSION).tar.gz --prefix=$(NAME)/ --format=tar.gz --add-file=.version HEAD
	rm .version
	$(DATE_CMD) -Iseconds

.PHONY: test-js
test-js: export/js
	python -m http.server --directory export/js

.PHONY: test-hl
test-hl: export/hl
	cd export/hl && ./$(NAME)

.PHONY: test-native
test-native: export/native
	cd export/native && ./$(NAME)
