# Validate and publish the Corsair Virtuoso device package.
#
#   make check                              schema + V2W profile validation
#   make publish REGISTRY=../registry-out KEY=publisher.key
#   make install-local                      use it on this machine without a registry

PY ?= .venv/bin/python
PACKAGE := corsair.virtuoso
LOCAL_DIR ?= $(or $(XDG_DATA_HOME),$(HOME)/.local/share)/borochid/local-packages

.PHONY: check publish install-local

check:
	$(PY) -m borochid.service.registry.build check $(PACKAGE)
	$(PY) -m borochid_corsair_v2w.profile $(PACKAGE)/manifest.json

publish: check
	@test -n "$(REGISTRY)" -a -n "$(KEY)" || { echo "usage: make publish REGISTRY=dir KEY=file"; exit 1; }
	$(PY) -m borochid.service.registry.build build $(PACKAGE) -o $(REGISTRY) --key $(KEY)

install-local: check
	mkdir -p $(LOCAL_DIR)
	ln -sfn $(abspath $(PACKAGE)) $(LOCAL_DIR)/$(PACKAGE)
