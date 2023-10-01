BESM666_FAKEROOT ?= $(PWD)/../sysroot
JOBS ?= 1

.PHONY: all
all: build

.PHONY: build
build:
	cmake -S $(PWD) -B $(PWD)/build -DBESM666_FAKEROOT=$(BESM666_FAKEROOT) \
		-DBESM666_SKIP_TOOLCHAIN_BUILD=ON
	cmake --build $(PWD)/build --parallel $(JOBS)

.PHONY: clean
.SILENT: clean
clean:
	rm -rf build
