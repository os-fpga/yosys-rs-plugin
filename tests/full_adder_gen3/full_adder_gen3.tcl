# Copyright (C) 2022 RapidSilicon
#
yosys -import
plugin -i synth-rs
yosys -import  ;# ingest plugin commands

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf -goal area -de -carry all
#synth_rs -tech genesis3 -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-max 3 t:LUT2
select -assert-max 2 t:LUT3
select -assert-max 0 t:LUT5
select -assert-max 0 t:LUT6
select -assert-max 5 t:CARRY

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry all
design -load postopt
yosys cd subtractor
stat
select -assert-max 3 t:LUT2
select -assert-max 2 t:LUT3
select -assert-max 5 t:CARRY

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry all
design -load postopt
yosys cd comparator
stat
select -assert-max 4 t:CARRY

design -reset

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry auto
#synth_rs -tech genesis3 -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-max 1 t:LUT2
select -assert-max 2 t:LUT3
select -assert-max 1 t:LUT4
select -assert-max 2 t:LUT6
select -assert-max 5 t:CARRY
#select -assert-min 5 t:\$lut

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry auto
design -load postopt
yosys cd subtractor
stat
#select -assert-count 5 t:CARRY
#select -assert-count 6 t:\$lut
select -assert-max 6 t:LUT*

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry auto
design -load postopt
yosys cd comparator
stat
select -assert-count 0 t:CARRY
select -assert-max 1 t:LUT3
select -assert-max 1 t:LUT6

design -reset

# Equivalence check for adder synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top full_adder
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry no
#synth_rs -tech genesis3 -goal area -de -top full_adder -carry
design -load postopt
yosys cd full_adder
stat
select -assert-count 0 t:CARRY

design -reset

# Equivalence check for subtractor synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top subtractor
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry no
design -load postopt
yosys cd subtractor
stat
select -assert-count 0 t:CARRY

design -reset

# Equivalence check for comparator synthesis for qlf-k6n10
yosys read -define WIDTH=4
yosys read -sv full_adder_gen3.v
hierarchy -check -top comparator
yosys proc
equiv_opt -assert  -map +/rapidsilicon/genesis3/sim_includes.v synth_rs -tech genesis3 -no_iobuf  -goal area -de -carry no
design -load postopt
yosys cd comparator
stat
select -assert-count 0 t:CARRY

design -reset
