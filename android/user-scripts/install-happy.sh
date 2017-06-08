#!/bin/bash

source /home/androidbuilder/ghc-build/set-env.sh
####################################################################################################

#
# Terminology:
#   build platform: The system platform we're building on. Build platform
#     executables can be executed during build.
#   host platform: The system platform we're building *for*. Host executables
#     can run on the device we're building for, but can't run during build.
#
# We first install happy for the build platform, then for the host platform, and
# then we overwrite the host platform's happy with the build platform's happy.
#
# We do this because otherwise packages depending on happy will try to build a
# host happy and run it during build.
#
# We also use cabal-install-setup.sh to build happy for the host platform,
# because it uses a non-simple setup, so we need to first build the setup
# program for the build platform.
#

cabal install happy
./cabal-install-setup.sh happy 1.19.5
cp /home/androidbuilder/.cabal/bin/happy $PLATFORM_PREFIX/.cabal/bin/
