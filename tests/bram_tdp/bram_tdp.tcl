# Copyright (C) 2022 RapidSilicon
#
yosys -import
plugin -i synth-rs
yosys -import;

yosys read -sv bram_tdp.v
select BRAM_TDP_36x1024
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_36x1024
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_36x1024_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_32x1024
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_32x1024
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_32x1024_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_18x2048
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_18x2048
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_18x2048_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_16x2048
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_16x2048
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_16x2048_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_9x4096
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_9x4096
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_9x4096_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_8x4096
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_8x4096
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_8x4096_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_4x8192
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_4x8192
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_4x8192_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_2x16384
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_2x16384
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_2x16384_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_1x32768
select *
synth_rs -no_libmap -tech genesis -goal area -de -top BRAM_TDP_1x32768
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_1x32768_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

#################################################################
# GENESIS2
#################################################################

yosys read -sv bram_tdp.v
select BRAM_TDP_36x1024
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_36x1024
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_36x1024_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_32x1024
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_32x1024
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_32x1024_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_18x2048
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_18x2048
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_18x2048_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_16x2048
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_16x2048
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_16x2048_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_9x4096
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_9x4096
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_9x4096_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_8x4096
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_8x4096
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_8x4096_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_4x8192
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_4x8192
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_4x8192_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_2x16384
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_2x16384
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_2x16384_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset

yosys read -sv bram_tdp.v
select BRAM_TDP_1x32768
select *
synth_rs -tech genesis2 -goal area -de -top BRAM_TDP_1x32768
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_1x32768_post_synth.v
select -assert-count 1 t:RS_TDP36K

select -clear
design -reset
