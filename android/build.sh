#!/bin/bash

set -e -x

export SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

target-cabal update

$SCRIPT_DIR/user-scripts/cabal-install-zlib.sh
$SCRIPT_DIR/user-scripts/cabal-install-setup.sh distributive 0.5.0.2
$SCRIPT_DIR/user-scripts/cabal-install-setup.sh comonad 5
$SCRIPT_DIR/user-scripts/install-happy.sh

target-cabal install -flibrary-only
