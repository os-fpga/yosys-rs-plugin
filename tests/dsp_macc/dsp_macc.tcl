# For some tests the equiv_induct pass seems to hang if opt_expr + opt_clean
# are not invoked after techmapping. Therefore this function is used instead
# of the equiv_opt pass.
proc check_equiv {top} {
    hierarchy -top ${top}

    design -save preopt
    synth_rs -tech genesis -goal area -de -top ${top}
    design -stash postopt

    design -copy-from preopt  -as gold A:top
    design -copy-from postopt -as gate A:top

    techmap -wb -autoproc -map +/rapidsilicon/genesis/cells_sim.v
    yosys proc
    opt_expr
    opt_clean -purge

    async2sync
    equiv_make gold gate equiv
    equiv_induct equiv
    equiv_status -assert equiv

    return
}

yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands

read_verilog dsp_macc.v
design -save read

set TOP "macc_simple"
design -load read
hierarchy -top $TOP
check_equiv $TOP
design -load postopt
yosys cd $TOP
select -assert-count 1 t:RS_DSP2
select -assert-count 1 t:*

set TOP "macc_simple_clr"
design -load read
hierarchy -top $TOP
check_equiv $TOP
design -load postopt
yosys cd $TOP
select -assert-count 1 t:RS_DSP2
select -assert-count 1 t:*

set TOP "macc_simple_arst"
design -load read
hierarchy -top $TOP
check_equiv $TOP
design -load postopt
yosys cd $TOP
select -assert-count 1 t:RS_DSP2
select -assert-count 1 t:*

set TOP "macc_simple_preacc"
design -load read
hierarchy -top $TOP
check_equiv $TOP
design -load postopt
yosys cd $TOP
select -assert-count 1 t:RS_DSP2
select -assert-count 1 t:*

set TOP "macc_simple_preacc_clr"
design -load read
hierarchy -top $TOP
check_equiv $TOP
design -load postopt
yosys cd $TOP
select -assert-count 1 t:RS_DSP2
select -assert-count 1 t:*

