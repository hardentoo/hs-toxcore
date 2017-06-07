#!/bin/bash

source /home/androidbuilder/ghc-build/set-env.sh
####################################################################################################

${NDK_TARGET}-cabal fetch zlib-0.6.1.1
tar zxf $NDK/cabal/packages/hackage.haskell.org/zlib/0.6.1.1/zlib-0.6.1.1.tar.gz
pushd zlib-0.6.1.1
patch -p1 < $SCRIPT_DIR/patches/hs-zlib-ffi.patch
${NDK_TARGET}-cabal install
popd

rm -rf zlib*
