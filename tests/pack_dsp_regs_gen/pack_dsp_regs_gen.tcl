# For some tests the equiv_induct pass seems to hang if opt_expr + opt_clean
# are not invoked after techmapping. Therefore this function is used instead
# of the equiv_opt pass.

proc check_equiv {top use_cfg_params technology} {
    if {${use_cfg_params} == 1} {
        synth_rs -tech ${technology} -goal area -de -top ${top} -use_dsp_cfg_params
    } else {
        synth_rs -tech ${technology} -goal area -de -top ${top}
    }
    return
}

proc test_dsp_design {top dff_count expected_cell_suffix} {

    set TOP ${top}
    logger -debug
    # Infer DSP with configuration bits passed through ports
    # We expect RS_DSP2_MULT_REGIN cells inferred
    yosys read -vlog2k pack_dsp_regs_gen.v
    set USE_DSP_CFG_PARAMS 0
    set TECHNOLOGY genesis
    check_equiv ${TOP} ${USE_DSP_CFG_PARAMS} ${TECHNOLOGY}
    select -assert-count 1 t:RS_DSP2${expected_cell_suffix}
    select -assert-count ${dff_count} t:dffsre
    design -reset

    # Infer DSP with configuration bits passed through parameters
    # We expect RS_DSP3_MULT_REGIN cells inferred
    yosys read -vlog2k pack_dsp_regs_gen.v
    set USE_DSP_CFG_PARAMS 1
    set TECHNOLOGY genesis
    check_equiv ${TOP} ${USE_DSP_CFG_PARAMS} ${TECHNOLOGY}
    select -assert-count 1 t:RS_DSP3${expected_cell_suffix}
    select -assert-count ${dff_count} t:dffsre
    design -reset
    return
}

yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands
yosys echo on

test_dsp_design "dsp_is_driven_only_by_dffs"                            "38"    "_MULT_REGIN"
test_dsp_design "dsp_is_driven_by_different_clk_dffs"                   "76"    "_MULT"
test_dsp_design "dsp_is_driven_only_by_dffs_which_drive_other_cell"     "114"   "_MULT_REGIN"
test_dsp_design "dsp_is_driven_by_multiple_dffs"                        "38"    "_MULT_REGIN"
test_dsp_design "dsp_is_not_driven_only_by_dffs"                        "74"    "_MULT"
