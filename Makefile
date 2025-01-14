# Default makefile distributed with pods version: 11.03.11

default_target: all

# prefix defaults to /usr/local
PREFIX ?= /usr/local

# Default to a less-verbose build.  If you want all the gory compiler output,
# run "make VERBOSE=1"
$(VERBOSE).SILENT:

# Figure out where to build the software.
#   Use BUILD_PREFIX if it was passed in.
#   If not, search up to four parent directories for a 'build' directory.
#   Otherwise, use ./build.
ifeq "$(BUILD_PREFIX)" ""
BUILD_PREFIX:=$(shell for pfx in ./ .. ../.. ../../.. ../../../..; do d=`pwd`/$$pfx/build;\
               if [ -d $$d ]; then echo $$d; exit 0; fi; done; echo `pwd`/build)
endif
# create the build directory if needed, and normalize its path name
BUILD_PREFIX:=$(shell mkdir -p $(BUILD_PREFIX) && cd $(BUILD_PREFIX) && echo `pwd`)

# create a variable with all the headers
APRILTAG_HEADERS_APRILTAGS := $(shell cd AprilTags && ls *.h)
APRILTAG_HEADERS_EXAMPLES := $(shell ls example/*.h)

# Default to a release build.  If you want to enable debugging flags, run
# "make BUILD_TYPE=Debug"
ifeq "$(BUILD_TYPE)" ""
BUILD_TYPE="Release"
endif

all: pod-build/Makefile
	$(MAKE) -C pod-build all

pod-build/Makefile:
	$(MAKE) configure

.PHONY: doc
doc:
	@$(MAKE) -C pod-build doc

.PHONY: configure
configure:
	@echo "\nBUILD_PREFIX: $(BUILD_PREFIX)\n\n"

	# create the temporary build directory if needed
	@mkdir -p pod-build

	# run CMake to generate and configure the build scripts
	@cd pod-build && cmake -DCMAKE_INSTALL_PREFIX=$(BUILD_PREFIX) \
		   -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) ..

.PHONY: install
install: pod-build/libapriltags.a
	@chmod +x install.sh
	@cd pod-build && ./../install.sh $(PREFIX)/lib libapriltags.a
	@cd AprilTags && ./../install.sh $(PREFIX)/include/ApriltagsCPP $(APRILTAG_HEADERS_APRILTAGS)
	@./install.sh $(PREFIX)/include/ApriltagsCPP $(APRILTAG_HEADERS_EXAMPLES)

clean:
	-if [ -e pod-build/install_manifest.txt ]; then rm -f `cat pod-build/install_manifest.txt`; fi
	-if [ -d pod-build ]; then $(MAKE) -C pod-build clean; rm -rf pod-build; fi

# other (custom) targets are passed through to the cmake-generated Makefile 
%::
	$(MAKE) -C pod-build $@
