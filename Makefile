.DELETE_ON_ERROR:

BABEL_OPTIONS = --stage 0
BIN           = ./node_modules/.bin
TESTS         = $(shell find src -path '*/__tests__/*-test.js')
SRC           = $(filter-out $(TESTS), $(shell find src -name '*.js'))
LIB           = $(SRC:src/%=lib/%)
NODE          = $(BIN)/babel-node $(BABEL_OPTIONS)
MOCHA_OPTIONS = --require ./src/__tests__/setup.js
MOCHA         = $(BIN)/_mocha $(MOCHA_OPTIONS)
NYC_OPTIONS   = --all --require babel-core/register
NYC           = $(BIN)/nyc $(NYC_OPTIONS)

build:
	@$(MAKE) -j 8 $(LIB)

lint:
	@$(BIN)/eslint src

test::
	@NODE_ENV=test $(BIN)/babel-node $(MOCHA) -- $(TESTS)

ci:
	@NODE_ENV=test $(BIN)/babel-node $(MOCHA) --watch -- $(TESTS)

test-cov::
	@NODE_ENV=test $(NYC) --check-coverage $(MOCHA) -- $(TESTS)

report-cov::
	@$(BIN)/nyc report --reporter html

report-cov-coveralls::
	@$(BIN)/nyc report --reporter=text-lcov | $(BIN)/coveralls

version-major version-minor version-patch: lint test
	@npm version $(@:version-%=%)

push:
	@git push --tags origin HEAD:master

clean:
	@rm -rf lib

lib/%: src/%
	@echo "Building $<"
	@mkdir -p $(@D)
	@$(BIN)/babel $(BABEL_OPTIONS) -o $@ $<
