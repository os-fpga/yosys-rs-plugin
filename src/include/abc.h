/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */

#ifndef ABC_H
#define ABC_H

#include "util.h"

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

#endif
