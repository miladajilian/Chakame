# Chakame developer commands. Used by humans, AI agents and CI alike.
# Simulator: a booted iPhone, else the newest one. Override with
#   make test SIM="iPhone 17"     or     make test SIM_ID=<udid>

PROJECT     := Chakame.xcodeproj
SCHEME      := Chakame
DEST        ?= $(shell ./scripts/sim-destination.sh)
DERIVED     := build/DerivedData
RESULTS     := build/TestResults.xcresult
XCB         := $(shell command -v xcbeautify >/dev/null 2>&1 && echo "| xcbeautify" || echo "")
XCODEBUILD  := set -o pipefail && xcodebuild -project $(PROJECT) -scheme $(SCHEME) -destination '$(DEST)' -derivedDataPath $(DERIVED)

SHELL := /bin/bash
.PHONY: help build test test-ui test-all lint format format-check clean

help: ## List available commands
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-14s %s\n", $$1, $$2}'

build: ## Build the app for the simulator
	$(XCODEBUILD) build $(XCB)

test: ## Run unit tests (ChakameTests)
	@rm -rf $(RESULTS)
	$(XCODEBUILD) test -only-testing:ChakameTests -resultBundlePath $(RESULTS) $(XCB)

test-ui: ## Run UI tests (ChakameUITests)
	$(XCODEBUILD) test -only-testing:ChakameUITests $(XCB)

test-all: ## Run unit and UI tests
	@rm -rf $(RESULTS)
	$(XCODEBUILD) test -resultBundlePath $(RESULTS) $(XCB)

lint: ## Run SwiftLint (strict)
	swiftlint lint --strict --quiet

format: ## Format all Swift code with SwiftFormat
	swiftformat .

format-check: ## Check formatting without changing files
	swiftformat --lint .

clean: ## Remove build output
	rm -rf build
