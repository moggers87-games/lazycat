#!/bin/sh

set -euxo pipefail

cd "${0%/*}"

export LD_LIBRARY_PATH=.

./game.bin
