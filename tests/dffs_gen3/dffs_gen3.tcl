# Copyright (C) 2022 RapidSilicon
#

yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands

# DFF
yosys read -vlog2k $::env(DESIGN_TOP).v
hierarchy -top my_dff
yosys proc
equiv_opt -assert -async2sync -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dff
design -load postopt
yosys cd my_dff
stat
select -assert-count 1 t:DFFRE
design -reset

# DFFR (posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffr_p
yosys cd my_dffr_p
stat
select -assert-count 1 t:DFFRE
design -reset

# DFFR (posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffr_p_2
yosys cd my_dffr_p_2
stat
select -assert-count 2 t:DFFRE
design -reset

# DFFR (negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffr_n
yosys cd my_dffr_n
stat
select -assert-count 1 t:DFFRE
design -reset

#DFFRE (posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffre_p
yosys cd my_dffre_p
stat
select -assert-count 1 t:DFFRE
design -reset

#DFFRE (negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffre_n
yosys cd my_dffre_n
stat
select -assert-count 1 t:DFFRE
design -reset

# DFFS (posedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffs_p
yosys cd my_dffs_p
stat
select -assert-count 1 t:DFFRE
select -assert-count 3 t:LUT1
design -reset

# DFFS (negedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffs_n
yosys cd my_dffs_n
stat
select -assert-count 1 t:DFFRE
select -assert-count 2 t:LUT1
design -reset

# DFFSE (posedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffse_p
yosys cd my_dffse_p
stat
select -assert-count 1 t:DFFRE
select -assert-count 3 t:LUT1
design -reset

# DFFSE (negedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffse_n
yosys cd my_dffse_n
stat
select -assert-count 1 t:DFFRE
select -assert-count 2 t:LUT1
design -reset

# DFFN
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffn
yosys cd my_dffn
stat
select -assert-count 1 t:DFFNRE
design -reset

# DFFNRE (negedge CLK posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffnr_p
yosys cd my_dffnr_p
stat
select -assert-count 1 t:DFFNRE
design -reset

# DFFNRE (negedge CLK negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffnr_n
yosys cd my_dffnr_n
stat
select -assert-count 1 t:DFFNRE
design -reset

# DFFNS (negedge CLK posedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffns_p
yosys cd my_dffns_p
stat
select -assert-count 1 t:DFFNRE
select -assert-count 3 t:LUT1
design -reset

# DFFS (negedge CLK negedge SET)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffns_n
yosys cd my_dffns_n
stat
select -assert-count 1 t:DFFNRE
select -assert-count 2 t:LUT1
design -reset

# DFFSR (posedge CLK posedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_ppp
yosys cd my_dffsr_ppp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (posedge CLK negedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_pnp
yosys cd my_dffsr_pnp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (posedge CLK posedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_ppn
yosys cd my_dffsr_ppn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (posedge CLK negedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_pnn
yosys cd my_dffsr_pnn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (negedge CLK posedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_npp
yosys cd my_dffsr_npp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (negedge CLK negedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_nnp
yosys cd my_dffsr_nnp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (negedge CLK posedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_npn
yosys cd my_dffsr_npn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSR (negedge CLK negedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsr_nnn
yosys cd my_dffsr_nnn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (posedge CLK posedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_ppp
yosys cd my_dffsre_ppp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (posedge CLK negedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_pnp
yosys cd my_dffsre_pnp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (posedge CLK posedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_ppn
yosys cd my_dffsre_ppn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (posedge CLK negedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_pnn
yosys cd my_dffsre_pnn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
# select -assert-max 4 t:\$lut
# select -assert-min 3 t:\$lut
design -reset

# DFFSRE (negedge CLK posedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_npp
yosys cd my_dffsre_npp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (negedge CLK negedge SET posedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_nnp
yosys cd my_dffsre_nnp
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (negedge CLK posedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_npn
yosys cd my_dffsre_npn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset

# DFFSRE (negedge CLK negedge SET negedge RST)
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -goal area -de -top my_dffsre_nnn
yosys cd my_dffsre_nnn
stat
select -assert-count 3 t:DFFRE
select -assert-count 2 t:LUT1
select -assert-count 1 t:LUT2
select -assert-count 1 t:LUT3
design -reset
