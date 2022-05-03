yosys -import

plugin -i synth-rs
yosys -import  ;

read_verilog $::env(DESIGN_TOP).v
design -save bram_tdp

select BRAM_TDP_32x512
select *
synth_rs -tech genesis -goal area -de -top BRAM_TDP_32x512
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_32x512_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -load bram_tdp
select BRAM_TDP_16x1024
select *
synth_rs -tech genesis -goal area -de -top BRAM_TDP_16x1024
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_16x1024_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -load bram_tdp
select BRAM_TDP_8x2048
select *
synth_rs -tech genesis -goal area -de -top BRAM_TDP_8x2048
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_8x2048_post_synth.v
select -assert-count 1 t:TDP36K

select -clear
design -load bram_tdp
select BRAM_TDP_4x4096
select *
synth_rs -tech genesis -goal area -de -top BRAM_TDP_4x4096
opt_expr -undriven
opt_clean
stat
write_verilog sim/bram_tdp_4x4096_post_synth.v
select -assert-count 1 t:TDP36K

