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

yosys read -sv dsp_mult.v

check_equiv mult_16x16
design -load postopt
yosys cd mult_16x16
select -assert-count 1 t:RS_DSP2

design -reset

yosys read -sv dsp_mult.v
check_equiv mult_20x18
design -load postopt
yosys cd mult_20x18
select -assert-count 1 t:RS_DSP2

design -reset

yosys read -sv dsp_mult.v 
check_equiv mult_8x8
design -load postopt
yosys cd mult_8x8
select -assert-count 1 t:RS_DSP2

design -reset

yosys read -sv dsp_mult.v 
check_equiv mult_10x9
design -load postopt
yosys cd mult_10x9
select -assert-count 1 t:RS_DSP2

design -reset

yosys read -sv dsp_mult.v 
check_equiv mult_8x8_s
design -load postopt
yosys cd mult_8x8_s
select -assert-count 1 t:RS_DSP2

design -reset
