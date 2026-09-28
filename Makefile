# Validate and publish the Corsair Virtuoso device packages: the headset
# and its receiver (the dongle), each a device of its own.
#
#   make check                              schema + V2W profile validation
#   make publish REGISTRY=../registry-out KEY=publisher.key
#   make install-local                      use it on this machine without a registry

PY ?= .venv/bin/python
PACKAGES := corsair.virtuoso corsair.virtuoso-receiver
LOCAL_DIR ?= $(or $(XDG_DATA_HOME),$(HOME)/.local/share)/borochid/local-packages

.PHONY: check publish install-local

check:
	$(PY) -m borochid.service.registry.build check $(PACKAGES)
	$(PY) -m borochid_corsair_v2w.profile $(addsuffix /manifest.json,$(PACKAGES))

publish: check
	@test -n "$(REGISTRY)" -a -n "$(KEY)" || { echo "usage: make publish REGISTRY=dir KEY=file"; exit 1; }
	$(PY) -m borochid.service.registry.build build $(PACKAGES) -o $(REGISTRY) --key $(KEY)

install-local: check
	mkdir -p $(LOCAL_DIR)
	for p in $(PACKAGES); do ln -sfn $(abspath .)/$$p $(LOCAL_DIR)/$$p; done
