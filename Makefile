CABAL_VER_NUM := $(shell cabal --numeric-version)
CABAL_VER_MAJOR := $(shell echo $(CABAL_VER_NUM) | cut -f1 -d.)
CABAL_VER_MINOR := $(shell echo $(CABAL_VER_NUM) | cut -f2 -d.)
CABAL_GT_1_22 := $(shell [ $(CABAL_VER_MAJOR) -gt 1 -o \( $(CABAL_VER_MAJOR) -eq 1 -a $(CABAL_VER_MINOR) -ge 22 \) ] && echo true)

ifeq ($(CABAL_GT_1_22),true)
ENABLE_COVERAGE	= --enable-coverage
else
ENABLE_COVERAGE	= --enable-library-coverage
endif

DIRS	:= msgpack src test-server test-tox test-toxcore
SOURCES	:= $(shell find $(DIRS) -name "*.*hs" -or -name "*.c" -or -name "*.h")

ifneq ($(wildcard ../tox-spec/pandoc.mk),)
ifneq ($(shell which pandoc),)
DOCS	:= ../tox-spec/spec.md
include ../tox-spec/pandoc.mk
endif
endif

EXTRA_DIRS :=							\
	--extra-include-dirs=$(HOME)/.cabal/extra-dist/include	\
	--extra-lib-dirs=$(HOME)/.cabal/extra-dist/lib


all: check $(DOCS)


check:
	$(MAKE) check-server
	$(MAKE) check-toxcore

check-%: .build.stamp
	-for pid in $(wildcard .*.pid); do kill `cat $$pid`; done
	dist/build/test-$*/test-$* & echo $$! > .$*.pid
	dist/build/test-tox/test-tox --seed=0
	kill `cat .$*.pid`
	rm .$*.pid

repl: .build.stamp
	cabal repl

clean:
	cabal clean
	for pid in $(wildcard .*.pid); do kill `cat $$pid`; done
	rm -f $(wildcard .*.stamp .*.pid)


build: .build.stamp
.build.stamp: $(SOURCES) .configure.stamp .format.stamp .lint.stamp
	rm -f $(wildcard *.tix)
	cabal build
	@touch $@

configure: .configure.stamp
.configure.stamp: .libsodium.stamp
	cabal update
	cabal install --enable-tests $(EXTRA_DIRS) --only-dependencies hstox.cabal
	cabal configure --enable-tests $(EXTRA_DIRS) $(ENABLE_COVERAGE)
	@touch $@

doc: $(DOCS)
../tox-spec/spec.md: src/Network/Tox.lhs $(shell find src -name "*.lhs") ../tox-spec/pandoc.mk
	echo '% The Tox Reference' > $@
	echo '' >> $@
	pandoc $< $(PANDOC_ARGS)							\
		-f latex+lhs								\
		-t $(FORMAT)								\
		| perl -pe 'BEGIN{undef $$/} s/\`\`\` sourceCode\n.*?\`\`\`\n\n//sg'	\
		>> $@
	pandoc $(PANDOC_ARGS) -f $(FORMAT) -t $(FORMAT) $@ -o $@
	if which mdl; then $(MAKE) -C ../tox-spec check; fi
	if test -d ../toktok.github.io; then $(MAKE) -C ../toktok.github.io push; fi

libsodium: .libsodium.stamp
.libsodium.stamp: tools/install-libsodium
	$<
	@touch $@

format: .format.stamp
.format.stamp: $(SOURCES) .configure.stamp
	if which stylish-haskell; then tools/format-haskell -i src; fi
	@touch $@

lint: .lint.stamp
.lint.stamp: $(SOURCES) .configure.stamp
	if which hlint; then hlint --cross src; fi
	@touch $@
