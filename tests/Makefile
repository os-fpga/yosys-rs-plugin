# Copyright (C) 2022 RapidSilicon..

TESTS = dffs\
		latches\
        shreg\
		full_adder

VALGRIND_TESTS = valgrind/dffs\
				 valgrind/latches\
                 valgrind/shreg\
				 valgrind/full_adder

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
	if [ ! -z $(3) ]; then\
		cp $$(notdir $(1)).tcl $$(notdir $(1))_valgrind.tcl; \
		sed -i "s/$$$$::env(DESIGN_TOP)/$$(notdir $(1))/g" $$(notdir $(1))_valgrind.tcl; \
		echo "source $$(notdir $(1))_valgrind.tcl" >> run-$$(notdir $(1)).tcl ;\
		$(3) $(4) $(5) $(YOSYS) -c "run-$$(notdir $(1)).tcl" -q -q -l $$(notdir $(1)).log; \
		RETVALUE=$$$$?;\
		if [ $$$$RETVALUE -eq 0 ]; then \
			grep "ERROR SUMMARY: 0" valgrind.log; \
			RETVALUE=$$$$?;\
			if [ $$$$RETVALUE -ne 0 ]; then \
				printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(3)/$(1) $(CURDIR); \
				false; \
			else \
				touch $(CURDIR)/$(1)/$(3)ok; \
			fi \
		else \
			printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(3)/$(1) $(CURDIR); \
			false;\
		fi; \
		rm -f run-$$(notdir $(1)).tcl; \
		rm -f $$(notdir $(1))_valgrind.tcl; \
	else \
		cp $$(notdir $(1)).tcl $$(notdir $(1))_test.tcl; \
		sed -i "s/$$$$::env(DESIGN_TOP)/$$(notdir $(1))/g" $$(notdir $(1))_test.tcl; \
		echo "source $$(notdir $(1))_test.tcl" >> run-$$(notdir $(1)).tcl ;\
		$(YOSYS) -c "run-$$(notdir $(1)).tcl" -q -q -l $$(notdir $(1)).log; \
		RETVAL=$$$$?; \
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
			rm -f run-$$(notdir $(1)).tcl; \
			rm -f $$(notdir $(1))_test.tcl; \
		fi \
	fi 
endef

all: $(TESTS)

.PHONY: all clean $(TESTS)

$(foreach test,$(TESTS),$(eval $(call test_tpl,$(test))))
$(foreach test,$(TESTS),$(eval $(call test_tpl,$(test),/,valgrind, $(OPTION_1), $(OPTION_2))))

clean:
	@find . -name "ok" | xargs rm -rf
	@find . -name "*.log" | xargs rm -rf
	@find . -name "valgrindok" | xargs rm -rf
	@find . -name "*.eqn" | xargs rm -rf

valgrind: $(VALGRIND_TESTS)

dffs_verify = true
latches_verify = true
shreg_verify = true
full_adder_verify = true
