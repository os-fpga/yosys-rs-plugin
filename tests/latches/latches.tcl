# Copyright (C) 2022 RapidSilicon
#
yosys echo on

yosys -import
plugin -i synth-rs
yosys -import  ;# import plugin commands

# Tests for rs_k6n10f tech
# LATCHP
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech rs_k6n10f -top latchp -goal area
yosys cd latchp
stat
select -assert-count 1 t:latchsre
design -reset

# LATCHN
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech rs_k6n10f -top latchn -goal area
yosys cd latchn
stat
select -assert-count 1 t:\$lut
select -assert-count 1 t:latchsre
design -reset

# LATCHSRE
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech rs_k6n10f -top my_latchsre -goal area
yosys cd my_latchsre
stat
select -assert-count 2 t:\$lut
select -assert-count 1 t:latchsre
design -reset
