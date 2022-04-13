# Copyright (C) 2022 RapidSilicon..

TESTS = dffs\
        latches\
        shreg\
        full_adder

# Find yosys, throw an error if not found
YOSYS = $(YOSYS_PATH)/bin/yosys
ifeq (,$(wildcard $(YOSYS)))
$(error "Didn't find 'yosys' under '$(YOSYS_PATH)'")
endif

TEST_UTILS ?= $(abspath test-utils.tcl)

define test_tpl =
$(1): $(1)/ok
	@set +e; \
	$$($$(subst /,-,$(1)_verify)); \
	if [ $$$$? -eq 0 ]; then \
		printf "Test %-20s \e[32mPASSED\e[0m @ %s\n" $(1) $(CURDIR); \
		touch $$<; \
		true; \
	else \
		printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(1) $(CURDIR); \
		false; \
	fi

$(1)/ok: $(1)/$$(notdir $(1).v)
	@set +e; \
	cd $(1); \
	echo "source $(TEST_UTILS)" > run-$$(notdir $(1)).tcl ;\
	echo "source $$(notdir $(1)).tcl" >> run-$$(notdir $(1)).tcl ;\
	DESIGN_TOP=$$(notdir $(1)) TEST_OUTPUT_PREFIX=./ \
	$(YOSYS) -c "run-$$(notdir $(1)).tcl" -q -q -l $$(notdir $(1)).log; \
	RETVAL=$$$$?; \
	rm -f run-$$(notdir $(1)).tcl; \
	if [ ! -z "$$($(1)_negative)" ] && [ $$($(1)_negative) -eq 1 ]; then \
		if [ $$$$RETVAL -ne 0 ]; then \
			printf "Negative test %-20s \e[32mPASSED\e[0m @ %s\n" $(1) $(CURDIR); \
			true; \
		else \
			printf "Negative test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(1) $(CURDIR); \
			false; \
		fi \
	else \
		if [ $$$$RETVAL -ne 0 ]; then \
		    printf "Test %-20s \e[31;1mFAILED\e[0m @ %s\n" $(1) $(CURDIR); \
			false; \
		fi \
	fi

endef

all: $(TESTS)

.PHONY: all clean $(TESTS)

$(foreach test,$(TESTS),$(eval $(call test_tpl,$(test))))

clean:
	@find . -name "ok" -or -name "*.log" | xargs rm -rf

dffs_verify = true
latches_verify = true
shreg_verify = true
full_adder_verify = true
