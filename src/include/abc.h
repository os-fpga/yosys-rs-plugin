/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */

#ifndef ABC_H
#define ABC_H

#include "util.h"

// Design Explorer template script. TARGET and DEPTH are the template arguments.
auto de_template_encrypt = OBFUSCATED(
    "write_eqn input.eqn;"
    "&de -i input.eqn -o netlist.eqn -t TARGET -d DEPTH;"
    "read_eqn netlist.eqn;");

auto abc_base6_a21_start = OBFUSCATED(
    "&get -n -m; "
    "&dch ; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m;  &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m;  &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &mfs -W 4 -M 500 -C 7000; &save -a;"
    "&ps;"
    "&dch; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &satlut; &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &satlut; &save -a;"
    "&ps;");

auto abc_base6_a21_end = OBFUSCATED(
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &satlut; &save -a;"
    "&ps;"
    "&dch; &if -K 6 -a; &mfs -W 4 -M 500 -C 7000; &satlut; &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &mfs; &satlut; &save -a;"
    "&ps;"
    "&synch2 -K 6 -C 500; &if -K 6 -a; &mfs; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &satlut; &save -a;"
    "&ps;"
    "&st; &if -K 6 -a; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &mfs; &satlut; &save -a;"
    "&ps;"
    "&st; &if -K 6 -a; &mfs; &put; mfs2 -W 4 -M 500 -C 7000; &get -n -m; &satlut; &save -a;"
    "&ps;"
    "&load;"
    "&ps;"
    "&satlut;"
    "&ps;"
    "&put;"
    "lutpack;"
    "&get -m -n ; &ps;"
    "&put;");

std::string de_template = DEOBFUSCATED(de_template_encrypt);
std::string abc_base6_a21 = DEOBFUSCATED(abc_base6_a21_start) + DEOBFUSCATED(abc_base6_a21_end);

#endif
