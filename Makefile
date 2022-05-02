# Copyright (C) 2022 RapidSilicon..

# Either find yosys in system and use its path or use the given path
YOSYS_PATH ?= $(realpath $(dir $(shell which yosys))/..)

# Find yosys-config, throw an error if not found
YOSYS_CONFIG ?= $(YOSYS_PATH)/bin/yosys-config
ifeq (,$(wildcard $(YOSYS_CONFIG)))
$(error "Didn't find 'yosys-config' under '$(YOSYS_PATH)'")
endif

CXX ?= $(shell $(YOSYS_CONFIG) --cxx)
CXXFLAGS ?= $(shell $(YOSYS_CONFIG) --cxxflags) -DDEV_BUILD #-DSDC_DEBUG
LDFLAGS ?= $(shell $(YOSYS_CONFIG) --ldflags)
LDLIBS ?= $(shell $(YOSYS_CONFIG) --ldlibs)
PLUGINS_DIR ?= $(shell $(YOSYS_CONFIG) --datdir)/plugins
DATA_DIR ?= $(shell $(YOSYS_CONFIG) --datdir)
EXTRA_FLAGS ?=

COMMON			= common
GENESIS			= genesis
VERILOG_MODULES	= $(COMMON)/cells_sim.v \
				  $(GENESIS)/cells_sim.v \
				  $(GENESIS)/ffs_map.v \
				  $(GENESIS)/arith_map.v \
				  $(GENESIS)/all_arith_map.v\

NAME = synth-rs
SOURCES = src/synth_rapidsilicon.cc 

OBJS := $(SOURCES:cc=o)

all: $(NAME).so

$(OBJS): %.o: %.cc
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(EXTRA_FLAGS) -c -o $@ $^

$(NAME).so: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared -o $@ $^ $(LDLIBS)

install_plugin: $(NAME).so
	install -D $< $(PLUGINS_DIR)/$<

install_modules: $(VERILOG_MODULES)
	$(foreach f,$^,install -D $(f) $(DATA_DIR)/rapidsilicon/$(f);)

.PHONY: install
install: install_plugin install_modules

valgrind:
	$(MAKE) -C tests valgrind YOSYS_PATH=$(YOSYS_PATH)

test:
	$(MAKE) -C tests all YOSYS_PATH=$(YOSYS_PATH)

clean:
	rm -f src/*.d src/*.o *.so
	$(MAKE) -C tests clean YOSYS_PATH=$(YOSYS_PATH)

clean_test:
	$(MAKE) -C tests clean YOSYS_PATH=$(YOSYS_PATH)
