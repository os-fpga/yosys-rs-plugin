# Copyright (C) 2022 RapidSilicon
#
yosys -import

plugin -i synth-rs
yosys -import  ;

yosys read -sv bram_sdp_split_gen.v

select BRAM_SDP_SPLIT_2x18x1024
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x18x1024 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x16x1024
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x16x1024 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x9x2048
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x9x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x8x2048
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x8x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x4x4096
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x4x4096 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x2x8192
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x2x8192 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_split_gen.v
select BRAM_SDP_SPLIT_2x1x16384
select *
synth_rs -no_libmap -tech genesis -top BRAM_SDP_SPLIT_2x1x16384 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP36K

design -reset
