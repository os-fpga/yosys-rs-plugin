# Copyright (C) 2022 RapidSilicon
#
yosys -import

plugin -i synth-rs
yosys -import  ;
read_verilog bram_asymmetric_wider_read.v
design -save bram_tdp

select spram_16x2048_32x1024
select *
synth_rs -tech genesis -top spram_16x2048_32x1024 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_16x2048_32x1024_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp 

select spram_8x4096_16x2048
select *
synth_rs -tech genesis -top spram_8x4096_16x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_8x4096_16x2048_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp 

select spram_8x2048_16x1024
select *
synth_rs -tech genesis -top spram_8x2048_16x1024 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_8x2048_16x1024_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp 

select spram_8x4096_32x1024
select *
synth_rs -tech genesis -top spram_8x4096_32x1024 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_8x4096_32x1024_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

