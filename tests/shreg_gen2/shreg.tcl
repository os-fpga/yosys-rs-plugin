# Copyright (C) 2022 RapidSilicon
#
yosys echo on

yosys -import
plugin -i synth-rs
yosys -import  ;# import plugin commands

# Tests for genesis2 tech
# SH_DFF
yosys read -vlog2k $::env(DESIGN_TOP).v
synth_rs -tech genesis2 -top top -goal area -de
yosys cd top
stat
select -assert-count 0 t:sh_dff
design -reset
