#include <iostream>
#include <fstream>
#include <regex>
#include <thread>
#include <chrono>
#include <tuple>
#include <map>

using namespace std; 
#ifndef SYNTH_FORMAL_H
#define SYNTH_FORMAL_H

extern string top_mod_;
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

void *run_fv(void* flow);

#endif