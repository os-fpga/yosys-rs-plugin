# Copyright (C) 2022 RapidSilicon
#
yosys echo on

yosys -import
plugin -i synth-rs
yosys -import  ;# import plugin commands

# Tests for genesis3 tech
# LATCHP
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -top latchp -goal area -de
yosys cd latchp
stat
select -assert-count 1 t:LATCH
design -reset

# LATCHN
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf  -top my_latchn -goal area -de
yosys cd my_latchn
stat
select -assert-count 1 t:LATCHN
design -reset

# LATCHSRE
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis3 -no_iobuf -top my_latchsre -goal area -de
yosys cd my_latchsre
stat
select -assert-count 2 t:LUT3
select -assert-max 3 t:LATCHN
select -assert-min 0 t:LATCHN
design -reset
