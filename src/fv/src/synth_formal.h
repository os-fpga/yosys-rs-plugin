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
    
    string *stage1;
    string *stage2;
    std::string *ref_net;
    int *fv_timeout;
    std::string *top_module;
    std::string *shared_dir_path;
};

// void process_stage(struct fv_args *stage_arg);

void *run_fv(void* flow);