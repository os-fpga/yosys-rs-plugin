# Copyright (C) 2022 RapidSilicon
#
yosys echo on

yosys -import
plugin -i synth-rs
yosys -import  ;# import plugin commands

# Tests for genesis2 tech
# LATCHP
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis2 -top latchp -goal area -de
yosys cd latchp
stat
select -assert-count 1 t:latchsre
design -reset

# LATCHN
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis2 -top latchn -goal area -de
yosys cd latchn
stat
select -assert-count 1 t:\$lut
select -assert-count 1 t:latchsre
design -reset

# LATCHSRE
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis2 -top my_latchsre -goal area -de
yosys cd my_latchsre
stat
select -assert-count 2 t:\$lut
select -assert-count 1 t:latchsre
design -reset
