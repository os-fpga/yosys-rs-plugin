# Copyright (C) 2022 RapidSilicon..

TESTS_GEN = dffs_gen\
            latches_gen\
            shreg_gen\
            full_adder_gen\
            dsp_macc_gen\
            dsp_mult_gen\
            dsp_simd_gen\
            pack_dsp_regs_gen\
            bram_tdp_gen\
            bram_sdp_gen\
            bram_sdp_split_gen\
            bram_tdp_split_gen
        #bram_asymmetric_wider_read\
        #bram_asymmetric_wider_write

TESTS_GEN2 = dffs_gen2\
             latches_gen2\
             full_adder_gen2\
             dsp_macc_gen2\
             dsp_mult_gen2\
             pack_dsp_regs_gen2\
             bram_tdp_gen2\
             bram_sdp_gen2\
             bram_sdp_split_gen2\
             bram_tdp_split_gen2

VALGRIND_TESTS_GEN = valgrind/dffs_gen\
                     valgrind/latches_gen\
                     valgrind/shreg_gen\
                     valgrind/full_adder_gen\
                     valgrind/dsp_macc_gen\
                     valgrind/dsp_mult_gen\
                     valgrind/dsp_simd_gen\
                     valgrind/pack_dsp_regs_gen\
                     valgrind/bram_tdp_gen\
                     valgrind/bram_sdp_gen\
                     valgrind/bram_sdp_split_gen\
                     valgrind/bram_tdp_split_gen

VALGRIND_TESTS_GEN2 = valgrind/dffs_gen2\
                      valgrind/latches_gen2\
                      valgrind/full_adder_gen2\
                      valgrind/dsp_macc_gen2\
                      valgrind/dsp_mult_gen2\
                      valgrind/pack_dsp_regs_gen2\
                      valgrind/bram_tdp_gen2\
                      valgrind/bram_sdp_gen2\
                      valgrind/bram_sdp_split_gen2\
                      valgrind/bram_tdp_split_gen2
                 #valgrind/bram_asymmetric_wider_read\
                 #valgrind/bram_asymmetric_wider_write

OPTION_1 = "--tool=memcheck"
OPTION_2 = "--log-file=valgrind.log"

# Find yosys, throw an error if not found
YOSYS = $(YOSYS_PATH)/bin/yosys
ifeq (,$(wildcard $(YOSYS)))
$(error "Didn't find 'yosys' under '$(YOSYS_PATH)'")
endif

TEST_UTILS ?= $(abspath test-utils.tcl)

define test_tpl =
$(3)$(2)$(1): $(1)/$(3)ok
	@set +e; \
	if [ -f "$(CURDIR)/$(1)/$(3)ok" ]; then \
		printf "Test %-20s \e[32mPASSED\e[0m @ %s\n" $(3)/$(1) $(CURDIR); \
		true;\
	fi

$(1)/$(3)ok: $(1)/$$(notdir $(1).v)
	@set +e; \
	cd $(1); \
	echo "source $(TEST_UTILS)" > run-$$(notdir $(1)).tcl ;\
	cp $$(notdir $(1)).tcl $$(notdir $(1))_test$(3).tcl; \
	sed -i "s/$$$$::env(DESIGN_TOP)/$$(notdir $(1))/g" $$(notdir $(1))_test$(3).tcl; \
	echo "source $$(notdir $(1))_test$(3).tcl" >> run-$$(notdir $(1)).tcl ;\
	$(3) $(4) $(5) $(YOSYS) -c "run-$$(notdir $(1)).tcl" -q -q -l $$(notdir $(1)).log; \
	RETVAL=$$$$?;\
	if [ ! -z $(3) ]; then\
		if [ $$$$RETVAL -eq 0 ]; then \
			grep "ERROR SUMMARY: 0" valgrind.log; \
			RETVAL=$$$$?;\
			if [ $$$$RETVAL -ne 0 ]; then \
				printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(3)/$(1) $(CURDIR); \
				false; \
			else \
				touch $(CURDIR)/$(1)/$(3)ok; \
			fi \
		else \
			printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(3)/$(1) $(CURDIR); \
			false;\
		fi; \
	else \
		if [ ! -z "$$($(1)_negative)" ] && [ $$($(1)_negative) -eq 1 ]; then \
			if [ $$$$RETVAL -ne 0 ]; then \
				printf "Negative test %-20s \e[32mPASSED\e[0m @ %s\n" $(1) $(CURDIR); \
				true; \
			else \
				printf "Negative test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(1) $(CURDIR); \
				false; \
			fi; \
		else \
			if [ $$$$RETVAL -ne 0 ]; then \
				printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(1) $(CURDIR); \
				false; \
			else \
				touch $(CURDIR)/$(1)/ok; \
			fi; \
		fi \
	fi;\
	rm -f run-$$(notdir $(1)).tcl; \
	rm -f $$(notdir $(1))_test$(3).tcl;
endef

all: tests_gen tests_gen2
tests_gen: $(TESTS_GEN)
tests_gen2: $(TESTS_GEN2)

.PHONY: all clean $(TESTS_GEN) $(TEST_GEN2)

$(foreach test,$(TESTS_GEN2),$(eval $(call test_tpl,$(test))))
$(foreach test,$(TESTS_GEN),$(eval $(call test_tpl,$(test))))
$(foreach test,$(TESTS_GEN2),$(eval $(call test_tpl,$(test),/,valgrind, $(OPTION_1), $(OPTION_2))))
$(foreach test,$(TESTS_GEN),$(eval $(call test_tpl,$(test),/,valgrind, $(OPTION_1), $(OPTION_2))))

clean_tests:
	@find . -name "ok" | xargs rm -rf
	@find . -name "*.log" | xargs rm -rf
	@find . -name "valgrindok" | xargs rm -rf
	@find . -name "*.eqn" | xargs rm -rf
	@find . -name "*post_synth.v" | xargs rm -rf

all_valgrind: valgrind_gen valgrind_gen2
valgrind_gen: $(VALGRIND_TESTS_GEN)
valgrind_gen2: $(VALGRIND_TESTS_GEN2)
