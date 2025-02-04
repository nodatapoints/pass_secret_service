projectdir ::= $(realpath .)
relgnupghome ::= test/.gnupghome
export GNUPGHOME ::= $(projectdir)/$(relgnupghome)
gpg_key_id ::= "8c2a59a7"
relpassstore ::= test/.test-password-store
pass ::= pypass
export PASSWORD_STORE_DIR ::= $(projectdir)/$(relpassstore)

.PHONY: all test coverage style clean clean-pycache clean-build

all: style test

test: | $(relpassstore)
	dbus-run-session -- pytest-3 -v test --asyncio-mode=auto

coverage: | $(relpassstore)
	dbus-run-session -- python3 -m coverage run -m pytest -v test
	python3 -m coverage report

style:
	pycodestyle --max-line-length=159 .
	black --diff .

$(relgnupghome): test/test_key.asc test/test_ownertrust.txt
	@echo "===== Preparing gpg test keys in $(relgnupghome) ====="
	mkdir -p -m 700 $(relgnupghome)
	gpg --allow-secret-key-import --import test/test_key.asc
	gpg --import-ownertrust test/test_ownertrust.txt

$(relpassstore): | $(relgnupghome)
	@echo "===== Preparing password store in $(relpassstore) ====="
	$(pass) init -p $(relpassstore) $(gpg_key_id)

clean: clean-test-environment clean-pycache clean-build

clean-test-environment:
	$(RM) -r $(relpassstore)
	$(RM) -r $(relgnupghome)

clean-pycache:
	find . -name '__pycache__' -exec $(RM) -r {} +

clean-build:
	$(RM) -r build/
	$(RM) -r dist/
	$(RM) -r *.egg-info
