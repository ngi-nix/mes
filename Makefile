PKGS := hex0 kaem-0 \
	catm-0 hex1 hex2-0 m0 \
	cc m2-minimal blood-elf-0 m1-0 hex2-1 \
	kaem mkdir \
	blood-elf get_machine hex2 m1 m2-planet \
	catm mes-m2 sha256sum ungz untar

all: $(PKGS)

$(PKGS):
	nix build --no-link -L .#$@

define check_pkg
	$(eval $@_DRV_PATH := $(shell nix eval --raw .#$(1).drvPath))
	nix-build --check $($@_DRV_PATH)
endef

ifndef TARGET
check: $(PKGS)
	$(foreach pkg,$(PKGS),$(call check_pkg,$(pkg)))
	nix flake check
else
check: $(TARGET)
	$(call check_pkg,$(TARGET))
endif

define delete_pkg
	$(eval $@_STORE_PATH := $(shell nix eval --impure --raw .#$(1)))
	sudo nix-store --delete --ignore-liveness $($@_STORE_PATH)

endef

clean:
	$(foreach pkg,$(PKGS),$(call delete_pkg,$(pkg)))
