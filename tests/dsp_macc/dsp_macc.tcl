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

yosys read -sv dsp_macc.v

hierarchy -check -top macc_simple
yosys proc
check_equiv macc_simple
design -load postopt
yosys cd macc_simple
select -assert-count 1 t:RS_DSP2_MULTACC
#select -assert-count 1 t:*

design -reset

yosys read -sv dsp_macc.v
hierarchy -check -top macc_simple_clr
check_equiv macc_simple_clr
design -load postopt
yosys cd macc_simple_clr
select -assert-count 1 t:RS_DSP2_MULTACC
#select -assert-count 1 t:*

design -reset

yosys read -sv dsp_macc.v
hierarchy -top macc_simple_arst 
check_equiv macc_simple_arst
design -load postopt
yosys cd macc_simple_arst
select -assert-count 1 t:RS_DSP2_MULTACC
#select -assert-count 1 t:*

design -reset

yosys read -sv dsp_macc.v
hierarchy -check -top macc_simple_ena
check_equiv macc_simple_ena
design -load postopt
yosys cd macc_simple_ena
select -assert-count 1 t:RS_DSP2_MULTACC
select -assert-count 1 t:*

design -reset

yosys read -sv dsp_macc.v
hierarchy -check -top macc_simple_arst_clr_ena
check_equiv macc_simple_arst_clr_ena
design -load postopt
yosys cd macc_simple_arst_clr_ena
select -assert-count 1 t:RS_DSP2_MULTACC
select -assert-count 1 t:*

design -reset

yosys read -sv dsp_macc.v
hierarchy -check -top macc_simple_preacc
check_equiv macc_simple_preacc
design -load postopt
yosys cd macc_simple_preacc
select -assert-count 1 t:RS_DSP2_MULTADD
#select -assert-count 1 t:*

design -reset 

yosys read -sv dsp_macc.v
hierarchy -check -top macc_simple_preacc_clr
check_equiv macc_simple_preacc_clr
design -load postopt
yosys cd macc_simple_preacc_clr
select -assert-count 1 t:RS_DSP2_MULTADD
#select -assert-count 1 t:*

design -reset

