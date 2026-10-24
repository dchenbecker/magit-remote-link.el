# Development tasks for magit-remote-link.
#
#   make deps   install magit and its dependencies into $(DEPS_DIR)
#   make test   run the ERT tests
#   make lint   byte-compile with warnings as errors, then run checkdoc
#
# EMACS selects the Emacs binary.  To use dependencies that are already on
# disk instead of `make deps', pass their directories as EMACSFLAGS, e.g.
#   make test EMACSFLAGS="-L ~/src/magit/lisp -L ~/src/llama"

EMACS ?= emacs
DEPS_DIR ?= .deps
EMACSFLAGS ?=

SRC = magit-remote-link.el
TESTS = test/magit-remote-link-test.el

# Dependencies installed by `make deps' are found through package.el, which
# is harmless when $(DEPS_DIR) doesn't exist.
BATCH = $(EMACS) -Q --batch -L . $(EMACSFLAGS) \
	--eval "(progn (require 'package) \
	  (setq package-user-dir (expand-file-name \"$(DEPS_DIR)\")) \
	  (package-initialize))"

.PHONY: all deps test lint clean

all: lint test

deps:
	$(EMACS) -Q --batch --eval "(progn (require 'package) \
	  (setq package-user-dir (expand-file-name \"$(DEPS_DIR)\") \
	        package-archives '((\"gnu\" . \"https://elpa.gnu.org/packages/\") \
	                           (\"nongnu\" . \"https://elpa.nongnu.org/nongnu/\") \
	                           (\"melpa\" . \"https://melpa.org/packages/\"))) \
	  (package-initialize) \
	  (package-refresh-contents) \
	  (package-install 'magit))"

test:
	$(BATCH) -l $(TESTS) -f ert-run-tests-batch-and-exit

# checkdoc only warns, so fail if it left any warnings behind.  The .elc is
# a by-product of checking the byte compiler, not something to keep.
lint:
	$(BATCH) --eval "(setq byte-compile-error-on-warn t)" -f batch-byte-compile $(SRC)
	@rm -f $(SRC)c
	$(BATCH) --eval "(progn (require 'checkdoc) \
	  (checkdoc-file \"$(SRC)\") \
	  (when (get-buffer \"*Warnings*\") (kill-emacs 1)))"

clean:
	rm -f *.elc test/*.elc
