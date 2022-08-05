######################################################################
#
# DESCRIPTION: Make Verilator model and run coverage
#
######################################################################

# check current directory path
ifneq ($(words $(CURDIR)),1)
 $(error Unsupported: GNU Make cannot build in directories containing spaces, build elsewhere: '$(CURDIR)')
endif

######################################################################
# Set up variables

FUSESOC = fusesoc
BENDER = bender
MORTY = morty
GENHTML = genhtml

######################################################################
# Set up variables

# If $VERILATOR_ROOT isn't in the environment, we assume it is part of a
# package install, and verilator is in your path. Otherwise find the
# binary relative to $VERILATOR_ROOT (such as when inside the git sources).
ifeq ($(VERILATOR_ROOT),)
VERILATOR = verilator
VERILATOR_COVERAGE = verilator_coverage
VERILATOR_PROFCFUNC = verilator_profcfunc
VERILATOR_GANTT = verilator_gantt
else
export VERILATOR_ROOT
VERILATOR = $(VERILATOR_ROOT)/bin/verilator
VERILATOR_COVERAGE = $(VERILATOR_ROOT)/bin/verilator_coverage
VERILATOR_PROFCFUNC = $(VERILATOR_ROOT)/bin/verilator_profcfunc
VERILATOR_GANTT = $(VERILATOR_ROOT)/bin/verilator_gantt
endif

VERILATOR_FLAGS =
# Generate C++ in executable form
VERILATOR_FLAGS += --cc --exe
# Generate makefile dependencies
VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -x-assign 0
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wall
# Make waveforms
VERILATOR_FLAGS += --trace
# Check SystemVerilog assertions
VERILATOR_FLAGS += --assert
# Generate coverage analysis
VERILATOR_FLAGS += --coverage
# Enable profiling
VERILATOR_FLAGS += --prof-cfuncs --prof-exec
# Run make to compile model, with as many CPUs as are free
VERILATOR_FLAGS += --build -j
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt
# Name of top module
VERILATOR_FLAGS += --top-module tb_top

######################################################################

# Create annotated source
VERILATOR_COV_FLAGS += --annotate logs/annotated
# A single coverage hit is considered good enough
VERILATOR_COV_FLAGS += --annotate-min 1
# Create LCOV info
VERILATOR_COV_FLAGS += --write-info logs/coverage.info
# Input file from Verilator
VERILATOR_COV_FLAGS += logs/coverage.dat

######################################################################

default: run

run:
	@echo
	@echo "-- Verilator tempalte exmaple"

	@echo
	@echo "-- ADD LIBRARY ----------------"
	$(FUSESOC) library add common_cells https://github.com/pulp-platform/common_cells

	@echo
	@echo "-- LINT ----------------"
	$(FUSESOC) --cores-root=. run --target=lint --setup --build --run qian-gu::dic_template

	@echo
	@echo "-- VERILATE ----------------"
	$(FUSESOC) --cores-root=. run --target=sim --setup --build --run qian-gu::dic_template

	@echo
	@echo "-- RUN ---------------------"
	cd build/qian-gu__dic_template_0.1.0/sim-verilator/ && \
	rm -rf logs && \
	mkdir -p logs && \
	./Vtb_top +trace

	@echo
	@echo "-- COVERAGE ----------------"
	cd build/qian-gu__dic_template_0.1.0/sim-verilator/ && \
	rm -rf logs/annotated && \
	$(VERILATOR_COVERAGE) $(VERILATOR_COV_FLAGS)

	@echo
	@echo "-- CODE PROFILING ----------------"
	cd build/qian-gu__dic_template_0.1.0/sim-verilator/ && \
	rm -rf logs/gprof.out logs/profcfunc.out && \
	gprof Vtb_top gmon.out > logs/gprof.out && \
	$(VERILATOR_PROFCFUNC) logs/gprof.out > logs/profcfunc.out

	@echo
	@echo "-- EXECUTION PROFILING ----------------"
	cd build/qian-gu__dic_template_0.1.0/sim-verilator/ && \
	rm -rf profile_exec.vcd && \
	$(VERILATOR_GANTT) profile_exec.dat

	@echo
	@echo "-- DONE --------------------"


######################################################################
# Other targets

show-config:
	$(VERILATOR) -V

genhtml:
	@echo "-- GENHTML --------------------"
	@echo "-- Note not installed by default, so not in default rule"
	cd build/qian-gu__dic_template_0.1.0/sim-verilator/ && \
	$(GENHTML) logs/coverage.info --output-directory logs/html

gendoc:
	@echo "-- Generate documents --------------------"
	$(MORTY) rtl/*.sv --doc doc

maintainer-copy::
clean mostlyclean distclean maintainer-clean::
	-rm -rf build doc
