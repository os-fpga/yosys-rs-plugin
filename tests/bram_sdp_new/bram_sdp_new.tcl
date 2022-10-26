# Copyright (C) 2022 RapidSilicon
#
yosys -import

plugin -i synth-rs
yosys -import  ;

yosys read -sv bram_sdp_new.v

select BRAM_SDP_36x1024
select *
synth_rs -tech genesis -top BRAM_SDP_36x1024 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_36x1024_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_32x1024
select *
synth_rs -tech genesis -top BRAM_SDP_32x1024 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_32x1024_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_18x2048
select *
synth_rs -tech genesis -top BRAM_SDP_18x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_18x2048_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_16x2048
select *
synth_rs -tech genesis -top BRAM_SDP_16x2048 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_16x2048_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_9x4096
select *
synth_rs -tech genesis -top BRAM_SDP_9x4096 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_9x4096_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_8x4096
select *
synth_rs -tech genesis -top BRAM_SDP_8x4096 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_8x4096_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_4x8192
select *
synth_rs -tech genesis -top BRAM_SDP_4x8192 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_4x8192_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_2x16384
select *
synth_rs -tech genesis -top BRAM_SDP_2x16384 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_2x16384_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -reset

yosys read -sv bram_sdp_new.v
select BRAM_SDP_1x32768
select *
synth_rs -tech genesis -top BRAM_SDP_1x32768 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_sdp_1x32768_post_synth.v
select -assert-count 1 t:TDP36K

design -reset
