# For some tests the equiv_induct pass seems to hang if opt_expr + opt_clean
# are not invoked after techmapping. Therefore this function is used instead
# of the equiv_opt pass.
proc check_equiv {top} {
    hierarchy -top ${top}

    design -save preopt

    stat
    synth_rs -tech genesis3 -no_iobuf -goal area -de -top ${top}

    design -stash postopt

    design -copy-from preopt  -as gold A:top
    design -copy-from postopt -as gate A:top

    techmap -wb -autoproc -map +/rapidsilicon/genesis3/sim_includes.v
    techmap -wb -autoproc -map +/rapidsilicon/genesis3/FPGA_PRIMITIVES_MODELS/sim_models/verilog/DSP38.v
    yosys proc
    opt_expr
    opt_clean -purge

    async2sync
    equiv_make gold gate equiv
    equiv_induct equiv
    equiv_status -assert equiv

    return
}

# Test inference of 2 available DSP variants
# * top - design name
# * expected_cell_suffix - suffix of the cell that should be the result
#           of the inference, eg. _MULT, _MACC_REGIN, MADD_REGIN_REGOUT
proc test_dsp_design {top expected_cell_suffix} {
    set TOP ${top}
    # Infer DSP with configuration bits passed through ports
    # We expect RS_DSP2 cells inferred
    design -load read
    hierarchy -top $TOP
    check_equiv ${TOP}
    design -load postopt
    yosys cd ${top}
    select -assert-count 1 t:${expected_cell_suffix}
    select -assert-min 1 t:*

    return
}

yosys -import
if { [info procs synth_rs] == {} } { plugin -i synth-rs}
yosys -import  ;# ingest plugin commands

read_verilog dsp_macc_gen3.v
design -save read

test_dsp_design "macc_simple"               "DSP38"
test_dsp_design "macc_simple_clr"           "DSP38"
test_dsp_design "macc_simple_arst"          "DSP38"
test_dsp_design "macc_simple_ena"           "DSP38"
test_dsp_design "macc_simple_arst_clr_ena"  "DSP38"
#test_dsp_design "macc_simple_preacc"        "DSP38"
#test_dsp_design "macc_simple_preacc_clr"    "DSP38"

