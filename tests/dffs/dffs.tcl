yosys -import
plugin -i synth-rs
yosys -import  ;# import plugin commands

yosys echo on

# DFF on rs_k6n10 device
read_verilog $::env(DESIGN_TOP).v
design -save read

# DFF
hierarchy -top my_dff
yosys proc
equiv_opt -assert -map +/rapidsilicon/rs_k6n10/cells_sim.v synth_rs -tech rs_k6n10 -top my_dff -goal area
design -load postopt
yosys cd my_dff
stat
select -assert-count 1 t:dff

# DFFR (posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffr_p -goal area
yosys cd my_dffr_p
stat
select -assert-count 1 t:dffr

# DFFR (posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffr_p_2 -goal area
yosys cd my_dffr_p_2
stat
select -assert-count 2 t:dffr

# DFFR (negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffr_n -goal area
yosys cd my_dffr_n
stat
select -assert-count 1 t:dffr
select -assert-count 1 t:\$lut

#DFFRE (posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffre_p -goal area
yosys cd my_dffre_p
stat
select -assert-count 1 t:dffre

#DFFRE (negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffre_n -goal area
yosys cd my_dffre_n
stat
select -assert-count 1 t:dffre
select -assert-count 1 t:\$lut

# DFFS (posedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffs_p -goal area
yosys cd my_dffs_p
stat
select -assert-count 1 t:dffs

# DFFS (negedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffs_n -goal area
yosys cd my_dffs_n
stat
select -assert-count 1 t:dffs
select -assert-count 1 t:\$lut

# DFFSE (posedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffse_p -goal area
yosys cd my_dffse_p
stat
select -assert-count 1 t:dffse

# DFFSE (negedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffse_n -goal area
yosys cd my_dffse_n
stat
select -assert-count 1 t:dffse

# DFFN
design -load read
synth_rs -tech rs_k6n10 -top my_dffn -goal area
yosys cd my_dffn
stat
select -assert-count 1 t:dff
select -assert-count 1 t:\$lut

# DFFNR (negedge CLK posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffnr_p -goal area
yosys cd my_dffnr_p
stat
select -assert-count 1 t:dffr
select -assert-count 1 t:\$lut

# DFFNR (negedge CLK negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffnr_n -goal area
yosys cd my_dffnr_n
stat
select -assert-count 1 t:dffr
select -assert-count 2 t:\$lut

# DFFNS (negedge CLK posedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffns_p -goal area
yosys cd my_dffns_p
stat
select -assert-count 1 t:dffs
select -assert-count 1 t:\$lut

# DFFS (negedge CLK negedge SET)
design -load read
synth_rs -tech rs_k6n10 -top my_dffns_n -goal area
yosys cd my_dffns_n
stat
select -assert-count 1 t:dffs
select -assert-count 2 t:\$lut

# DFFSR (posedge CLK posedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_ppp -goal area
yosys cd my_dffsr_ppp
stat
select -assert-count 1 t:dffsr
select -assert-count 1 t:\$lut

# DFFSR (posedge CLK negedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_pnp -goal area
yosys cd my_dffsr_pnp
stat
select -assert-count 1 t:dffsr
select -assert-count 1 t:\$lut

# DFFSR (posedge CLK posedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_ppn -goal area
yosys cd my_dffsr_ppn
stat
select -assert-count 1 t:dffsr
select -assert-count 2 t:\$lut

# DFFSR (posedge CLK negedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_pnn -goal area
yosys cd my_dffsr_pnn
stat
select -assert-count 1 t:dffsr
select -assert-count 2 t:\$lut

# DFFSR (negedge CLK posedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_npp -goal area
yosys cd my_dffsr_npp
stat
select -assert-count 1 t:dffsr
select -assert-count 2 t:\$lut

# DFFSR (negedge CLK negedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_nnp -goal area
yosys cd my_dffsr_nnp
stat
select -assert-count 1 t:dffsr
select -assert-count 2 t:\$lut

# DFFSR (negedge CLK posedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_npn -goal area
yosys cd my_dffsr_npn
stat
select -assert-count 1 t:dffsr
select -assert-count 3 t:\$lut

# DFFSR (negedge CLK negedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsr_nnn -goal area
yosys cd my_dffsr_nnn
stat
select -assert-count 1 t:dffsr
select -assert-count 3 t:\$lut

# DFFSRE (posedge CLK posedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_ppp -goal area
yosys cd my_dffsre_ppp
stat
select -assert-count 1 t:dffsre
select -assert-count 1 t:\$lut

# DFFSRE (posedge CLK negedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_pnp -goal area
yosys cd my_dffsre_pnp
stat
select -assert-count 1 t:dffsre
select -assert-count 1 t:\$lut

# DFFSRE (posedge CLK posedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_ppn -goal area
yosys cd my_dffsre_ppn
stat
select -assert-count 1 t:dffsre
select -assert-count 2 t:\$lut

# DFFSRE (posedge CLK negedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_pnn -goal area
yosys cd my_dffsre_pnn
stat
select -assert-count 1 t:dffsre
select -assert-count 2 t:\$lut

# DFFSRE (negedge CLK posedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_npp -goal area
yosys cd my_dffsre_npp
stat
select -assert-count 1 t:dffsre
select -assert-count 2 t:\$lut

# DFFSRE (negedge CLK negedge SET posedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_nnp -goal area
yosys cd my_dffsre_nnp
stat
select -assert-count 1 t:dffsre
select -assert-count 2 t:\$lut

# DFFSRE (negedge CLK posedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_npn -goal area
yosys cd my_dffsre_npn
stat
select -assert-count 1 t:dffsre
select -assert-count 3 t:\$lut

# DFFSRE (negedge CLK negedge SET negedge RST)
design -load read
synth_rs -tech rs_k6n10 -top my_dffsre_nnn -goal area
yosys cd my_dffsre_nnn
stat
select -assert-count 1 t:dffsre
select -assert-count 3 t:\$lut

design -reset
