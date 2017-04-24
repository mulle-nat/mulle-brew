SCRIPTS=install.sh

CHECKSTAMPS=$(SCRIPTS:.sh=.chk)
SHELLFLAGS=-x -e SC2164,SC2166,SC2006,SC1091,SC2039,SC2181,SC2059 -s sh

.PHONY: all
.PHONY: clean
.PHONY: shellcheck_check

%.chk:	%.sh
	- shellcheck $(SHELLFLAGS) $<
	(shellcheck -f json $(SHELLFLAGS) $< | jq '.[].level' | grep -w error > /dev/null ) && exit 1 || touch $@

all:	$(CHECKSTAMPS) mulle-brew.chk shellcheck_check jq_check

mulle-brew.chk:	mulle-brew
	- shellcheck $(SHELLFLAGS) $<
	(shellcheck -f json $(SHELLFLAGS) $< | jq '.[].level' | grep -w error > /dev/null ) && exit 1 || touch $@

install:
	@ ./install.sh

clean:
	@- rm *.chk

shellcheck_check:
	which shellcheck || brew install shellcheck

jq_check:
	which shellcheck || brew install shellcheck
