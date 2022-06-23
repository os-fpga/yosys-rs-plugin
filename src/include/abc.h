/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */

#ifndef ABC_H
#define ABC_H

#include <string>

// Design Explorer template script. TARGET and DEPTH are the template arguments.
const std::string de_template = 
    "write_eqn TMP_PATH/input.eqn;"
    "&de -i TMP_PATH/input.eqn -o TMP_PATH/netlist.eqn -t TARGET -d DEPTH -p TMP_PATH -n THREAD_NUMBER;"
    "read_eqn TMP_PATH/netlist.eqn;";

const std::string abc_base6_a21 =
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
    "&ps;"
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
    "&put;";

#endif
