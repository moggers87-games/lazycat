# LazyCat

![Build status badge](https://github.com/moggers87-games/lazycat/workflows/LazyCat%20Build/badge.svg)

LazyCat! A cat with laser eyes hunts down some lasermice.

## Build LazyCat

All builds require Haxe 4.x to be installed.

### JS

Run the following:

```
make export/js
```

This will produce a JS file, a HTML file, and a zip file containing the former
and license files.

Run `make test-js` to start a simple HTTP server that your browesr can connect
to.

### Hashlink

Install Hashlink and then run:

```
make export/hl
```

Run `make test-hl` to start the game.

### Native binary

Hashlink's requirements and then run:

```
make export/native
```

Run `make test-native` to start the game.

Cross-compiling is not supported.

### Build everything

If you have all requirements installed and ready you can run:

```
make
```

This will build all targets. You can also run:

```
make release
```

This will also build a source archive.

### Clean

Run `make clean` to remove all builds. Run `git clean -dfx` to completely reset
the repo.

## Linting

To lint code, run:

```
make lint
```
