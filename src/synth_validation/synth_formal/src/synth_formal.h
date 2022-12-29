// #include "kernel/celltypes.h"
// #include "kernel/log.h"
// #include "kernel/register.h"
// #include "kernel/rtlil.h"
// #include "kernel/yosys.h"
// #include "kernel/mem.h"
// #include "include/abc.h"

#include <iostream>
#include <fstream>
#include <regex>
#include <thread>
#include <chrono>
#include <tuple>
#include <map>
#include <filesystem>

using namespace std; 
#ifndef SYNTH_FORMAL_H
#define SYNTH_FORMAL_H


extern map<string, tuple<string,string,string,string,string,string,int>> fv_results;

struct fv_args{
    
    string *stage1;
    string *stage2;
    std::string *ref_net;
    string *fv_tool;
    string *fv;
    int *fv_timeout;
    std::string *top_module;
    std::string *shared_dir_path;
    std::string  *sim_clock_ports;
    std::string  *sim_reset_ports;
    std::string  *sim_reset_state;
};

// void process_stage(struct fv_args *stage_arg);

void *run_fv(void* flow);

#endif