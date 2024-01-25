# Copyright (C) 2022 RapidSilicon
#
yosys -import

plugin -i synth-rs
yosys -import  ;

yosys read -sv bram_sdp_gen3.v

select BRAM_SDP_36x1024
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_36x1024 -goal area -de 
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_32x1024
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_32x1024 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_18x2048
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_18x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_16x2048
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_16x2048 -goal area -de 
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_9x4096
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_9x4096 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_8x4096
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_8x4096 -goal area -de 
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_4x8192
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_4x8192 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_2x16384
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_2x16384 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

select -clear
design -reset

yosys read -sv bram_sdp_gen3.v
select BRAM_SDP_1x32768
select *
synth_rs -tech genesis3 -no_iobuf -new_tdp36k -top BRAM_SDP_1x32768 -goal area -de
opt_expr -undriven
opt_clean
stat
select -assert-count 1 t:TDP_RAM36K

design -reset
