# Copyright (C) 2022 RapidSilicon
#
yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry all
#synth_rs -tech genesis -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-max 5 t:adder_carry

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry all
design -load postopt
yosys cd subtractor
stat
select -assert-max 5 t:adder_carry

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry all
design -load postopt
yosys cd comparator
stat
select -assert-max 4 t:adder_carry

design -reset

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry auto
#synth_rs -tech genesis -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-count 0 t:adder_carry
# comment for now
select -assert-max 6 t:\$lut

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry auto
design -load postopt
yosys cd subtractor
stat
select -assert-count 0 t:adder_carry
select -assert-max 6 t:\$lut

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry auto
design -load postopt
yosys cd comparator
stat
select -assert-count 0 t:adder_carry
select -assert-max 2 t:\$lut

design -reset

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry no
#synth_rs -tech genesis -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-count 0 t:adder_carry

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry no
design -load postopt
yosys cd subtractor
stat
select -assert-count 0 t:adder_carry

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis/cells_sim.v synth_rs -tech genesis -goal area -de -carry no
design -load postopt
yosys cd comparator
stat
select -assert-count 0 t:adder_carry

design -reset
