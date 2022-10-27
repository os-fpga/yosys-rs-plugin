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
#include <filesystem>
using namespace std; 

struct fv_args{
    std::string *ref_net;
    int *fv_timeout;
    bool *bram_inf;
    bool *dsp_inf;
    bool *retiming;
    std::string *strategy;
    bool synth_status;
    bool *fv_cec;
    std::string *top_module;
    std::string *final_stage;
};


void process_stage(struct fv_args *stage_arg);

void *run_fv(void* flow);