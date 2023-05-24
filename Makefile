# Copyright (C) 2022 RapidSilicon..

# Either find yosys in system and use its path or use the given path
YOSYS_PATH ?= $(realpath $(dir $(shell which yosys))/..)

# Find yosys-config, throw an error if not found
YOSYS_CONFIG ?= $(YOSYS_PATH)/bin/yosys-config
ifeq (,$(wildcard $(YOSYS_CONFIG)))
$(error "Didn't find 'yosys-config' under '$(YOSYS_PATH)'")
endif

CXX ?= $(shell $(YOSYS_CONFIG) --cxx)
CXXFLAGS ?= $(shell $(YOSYS_CONFIG) --cxxflags) #-DSDC_DEBUG
LDFLAGS ?= $(shell $(YOSYS_CONFIG) --ldflags)
LDLIBS ?= $(shell $(YOSYS_CONFIG) --ldlibs)
PLUGINS_DIR ?= $(shell $(YOSYS_CONFIG) --datdir)/plugins
DATA_DIR ?= $(shell $(YOSYS_CONFIG) --datdir)
EXTRA_FLAGS ?=
CXXFLAGS += -Isrc/include/boost_lib/
LDFLAGS += -Lsrc/include/boost_lib/
CXXFLAGS += -std=c++17

COMMON			= common
GENESIS			= genesis
GENESIS2		= genesis2
GENESIS3		= genesis3
VERILOG_MODULES	= $(COMMON)/cells_sim.v \
				  $(COMMON)/simlib.v \
				  $(GENESIS)/cells_sim.v \
				  $(GENESIS)/dsp_sim.v \
				  $(GENESIS)/ffs_map.v \
				  $(GENESIS)/dsp_map.v \
				  $(GENESIS)/dsp_final_map.v \
				  $(GENESIS)/arith_map.v \
				  $(GENESIS)/all_arith_map.v \
				  $(GENESIS)/brams_map.v \
				  $(GENESIS)/brams_map_new.v \
				  $(GENESIS)/brams_final_map.v \
				  $(GENESIS)/brams_final_map_new.v \
				  $(GENESIS)/brams.txt \
				  $(GENESIS)/brams_new.txt \
				  $(GENESIS)/brams_async.txt \
				  $(GENESIS)/TDP18K_FIFO.v \
				  $(GENESIS)/sram1024x18.v \
				  $(GENESIS)/ufifo_ctl.v \
				  $(GENESIS)/cells_sim.vhd \
				  $(GENESIS)/adder_carry.vhdl \
				  $(GENESIS)/dffnsre.vhdl \
				  $(GENESIS)/dffsre.vhdl \
				  $(GENESIS)/latchsre.vhdl \
				  $(GENESIS)/lut.vhdl \
				  $(GENESIS)/shr.vhdl \
				  $(GENESIS2)/cells_sim.v \
				  $(GENESIS2)/cells_sim.vhd \
				  $(GENESIS2)/dsp_sim.v \
				  $(GENESIS2)/brams_sim.v \
				  $(GENESIS2)/ffs_map.v \
				  $(GENESIS2)/dsp_map.v \
				  $(GENESIS2)/dsp_final_map.v \
				  $(GENESIS2)/arith_map.v \
				  $(GENESIS2)/all_arith_map.v \
				  $(GENESIS2)/brams_map.v \
				  $(GENESIS2)/brams_map_new.v \
				  $(GENESIS2)/brams_final_map.v \
				  $(GENESIS2)/brams_final_map_new.v \
				  $(GENESIS2)/brams.txt \
				  $(GENESIS2)/brams_new.txt \
				  $(GENESIS2)/brams_new_swap.txt \
				  $(GENESIS2)/brams_async.txt \
				  $(GENESIS2)/TDP18K_FIFO.v \
				  $(GENESIS2)/sram1024x18.v \
				  $(GENESIS2)/ufifo_ctl.v \
				  $(GENESIS2)/cell_sim_blackbox.v \
				  $(GENESIS3)/cells_sim.v \
				  $(GENESIS3)/cells_sim.vhd \
				  $(GENESIS3)/dsp_sim.v \
				  $(GENESIS3)/brams_sim.v \
				  $(GENESIS3)/ffs_map.v \
				  $(GENESIS3)/dsp_map.v \
				  $(GENESIS3)/dsp_final_map.v \
				  $(GENESIS3)/arith_map.v \
				  $(GENESIS3)/all_arith_map.v \
				  $(GENESIS3)/brams_map.v \
				  $(GENESIS3)/brams_map_new.v \
				  $(GENESIS3)/brams_final_map.v \
				  $(GENESIS3)/brams_final_map_new.v \
				  $(GENESIS3)/brams.txt \
				  $(GENESIS3)/brams_new.txt \
				  $(GENESIS3)/brams_new_swap.txt \
				  $(GENESIS3)/brams_async.txt \
				  $(GENESIS3)/TDP18K_FIFO.v \
				  $(GENESIS3)/sram1024x18.v \
				  $(GENESIS3)/ufifo_ctl.v \
				  $(GENESIS3)/cell_sim_blackbox.v \
			      sim_models.v

NAME = synth-rs
SOURCES = src/rs-dsp.cc \
		  src/rs-dsp-macc.cc \
		  src/rs-dsp-simd.cc \
		  src/synth_rapidsilicon.cc \
          src/rs-dsp-io-regs.cc \
		  src/rs-dffsr-conv.cc \
		  src/rs-bram-split.cc \
		  src/rs-bram-asymmetric.cc \
		  src/rs-pack-dsp-regs.cc \
		  src/synth_validation/synth_formal/src/synth_formal.cc \
		  src/synth_validation/synth_formal/src/test_report.cc \
		  src/synth_validation/synth_simulation/TBG.cc \
		  src/synth_validation/synth_simulation/run_verilator.cc



simulation_model = src/synth_validation/synth_formal/src/sim_par.cc
execute_Sim_parse:
	g++  -lstdc++fs -std=c++17  $(simulation_model)  -o sim_par 
	./sim_par

DEPS = pmgen/rs-dsp-pm.h \
	   pmgen/rs-dsp-macc.h \
	   pmgen/rs-bram-asymmetric-wider-write.h \
	   pmgen/rs-bram-asymmetric-wider-read.h \
	   src/synth_validation/synth_formal/src/synth_formal.h \
	   src/synth_validation/synth_formal/src/report_fv.h \
	   src/synth_validation/synth_simulation/TBG.h
pmgen:
	mkdir -p pmgen

pmgen/rs-dsp-pm.h: rs_dsp.pmg | pmgen
	python3 pmgen.py -o $@ -p rs_dsp rs_dsp.pmg

pmgen/rs-dsp-macc.h:  rs-dsp-macc.pmg | pmgen
	python3 pmgen.py -o $@ -p rs_dsp_macc rs-dsp-macc.pmg

pmgen/rs-bram-asymmetric-wider-write.h: rs-bram-asymmetric-wider-write.pmg | pmgen
	python3 pmgen.py -o $@ -p rs_bram_asymmetric_wider_write rs-bram-asymmetric-wider-write.pmg

pmgen/rs-bram-asymmetric-wider-read.h: rs-bram-asymmetric-wider-read.pmg | pmgen
	python3 pmgen.py -o $@ -p rs_bram_asymmetric_wider_read rs-bram-asymmetric-wider-read.pmg

# pmgen.py:
# 	wget -nc -O $@ https://raw.githubusercontent.com/YosysHQ/yosys/master/passes/pmgen/pmgen.py

OBJS := $(SOURCES:cc=o)

fv_srcs_obj := $(fv_srcs:cc=o)

all: $(NAME).so

$(OBJS): %.o: %.cc $(DEPS)
	$(CXX) $(CXXFLAGS) $(CPPFLAGS) $(EXTRA_FLAGS) -c -o $@ $(filter %.cc, $^)

$(NAME).so: $(OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -shared -o $@ $^ $(LDLIBS)

install_plugin: $(NAME).so
	install -D $< $(PLUGINS_DIR)/$<

install_modules: $(VERILOG_MODULES)
	$(foreach f,$^,install -D $(f) $(DATA_DIR)/rapidsilicon/$(f);)

.PHONY: install
install: execute_Sim_parse install_plugin install_modules

valgrind_gen:
	$(MAKE) -C tests valgrind_gen YOSYS_PATH=$(YOSYS_PATH)

valgrind:
	$(MAKE) -C tests valgrind_gen2 YOSYS_PATH=$(YOSYS_PATH)

test_gen:
	$(MAKE) -C tests tests_gen YOSYS_PATH=$(YOSYS_PATH)

test:
	$(MAKE) -C tests tests_gen2 YOSYS_PATH=$(YOSYS_PATH)

clean:
	rm -rf src/*.d src/*.o *.so pmgen/ src/synth_validation/synth_formal/src/*.o src/synth_validation/synth_formal/src/*.d src/synth_validation/synth_simulation/*.o src/synth_validation/synth_simulation/*.d
	$(MAKE) -C tests clean_tests YOSYS_PATH=$(YOSYS_PATH)

clean_test:
	$(MAKE) -C tests clean_tests YOSYS_PATH=$(YOSYS_PATH)
