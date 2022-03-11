# Copyright (C) 2022 RapidSilicon
#
yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands

# Equivalence check for adder synthesis for qlf-k6n10
read_verilog -icells -DWIDTH=4 $::env(DESIGN_TOP).v
#hierarchy -check -top full_adder
#yosys proc
#equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area
synth_rs -tech genesis -goal area -top full_adder
#design -load postopt
yosys cd full_adder
stat
#select -assert-count 6 t:adder_carry

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
read_verilog -icells -DWIDTH=4 $::env(DESIGN_TOP).v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area
design -load postopt
yosys cd subtractor
stat
#select -assert-count 6 t:adder_carry

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
read_verilog -icells -DWIDTH=4 $::env(DESIGN_TOP).v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area
design -load postopt
yosys cd comparator
stat
#select -assert-count 5 t:adder_carry

design -reset
