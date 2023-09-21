# For some tests the equiv_induct pass seems to hang if opt_expr + opt_clean
# are not invoked after techmapping. Therefore this function is used instead
# of the equiv_opt pass.

proc check_equiv {top technology} {
    synth_rs -tech ${technology} -goal area -de -top ${top}
    return
}

proc test_dsp_design {top dff_count expected_cell_suffix} {

    set TOP ${top}
    logger -debug
    design -reset

    # Infer Genesis2 DSP
    # We expect RS_DSP_MULT_REGIN cells inferred
    yosys read -vlog2k pack_dsp_regs_gen2.v
    set TECHNOLOGY genesis2
    check_equiv ${TOP} ${TECHNOLOGY}
    select -assert-count 1 t:RS_DSP${expected_cell_suffix}
    select -assert-count ${dff_count} t:dffr
    design -reset
    return
}

yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands
yosys echo on

test_dsp_design "dsp_is_driven_only_by_dffs"                            "0"    "_MULT_REGIN_REGOUT"
test_dsp_design "dsp_is_driven_by_different_clk_dffs"                   "38"    "_MULT_REGOUT"
test_dsp_design "dsp_is_driven_only_by_dffs_which_drive_other_cell"     "59"   "_MULT_REGIN_REGOUT"
test_dsp_design "dsp_is_driven_by_multiple_dffs"                        "0"    "_MULT_REGIN_REGOUT"
test_dsp_design "dsp_is_not_driven_only_by_dffs"                        "36"    "_MULT_REGOUT"
