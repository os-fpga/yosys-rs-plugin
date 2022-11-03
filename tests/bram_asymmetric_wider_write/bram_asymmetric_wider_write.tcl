# Copyright (C) 2022 RapidSilicon
#
yosys -import

plugin -i synth-rs
yosys -import  ;

read_verilog bram_asymmetric_wider_write.v
design -save bram_tdp

select spram_16x1024_8x2048
select *
synth_rs -tech genesis -top spram_16x1024_8x2048 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_16x1024_8x2048_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp

select spram_16x2048_8x4096
select *
synth_rs -tech genesis -top spram_16x2048_8x4096 -goal area -de 
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_16x2048_8x4096_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp

select spram_32x1024_16x2048
select *
synth_rs -tech genesis -top spram_32x1024_16x2048 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_32x1024_16x2048_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*

select -clear
design -load bram_tdp

select spram_32x1024_8x4096
select *
synth_rs -tech genesis -top spram_32x1024_8x4096 -goal area -de
opt_expr -undriven
opt_clean
stat
write_verilog sim/spram_32x1024_8x4096_post_synth.v
select -assert-count 1 t:TDP36K
select -assert-count 1 t:*



