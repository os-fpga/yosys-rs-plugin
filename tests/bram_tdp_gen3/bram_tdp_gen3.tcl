# Copyright (C) 2022 RapidSilicon
#
yosys -import
plugin -i synth-rs
yosys -import;

yosys read -sv bram_tdp_gen3.v

select BRAM_TDP_36x1024
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_36x1024
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_32x1024
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_32x1024
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_18x2048
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_18x2048
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_16x2048
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_16x2048
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_9x4096
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_9x4096
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_8x4096
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_8x4096
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_4x8192
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_4x8192
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_2x16384
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_2x16384
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_tdp_gen3.v
select BRAM_TDP_1x32768
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -goal area -de -top BRAM_TDP_1x32768
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

design -reset
