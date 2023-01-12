#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <regex>
#include <stdexcept>
#include <stdio.h>
#include <algorithm>
#include "/nfs_scratch/scratch/FV/awais/Synthesis_FV_Poject/yosys_verific_rs/analyze/third_party/nlohmann_json/json.hpp"

using json =  nlohmann::json;
using namespace std;

string  tb_body(string port_info,vector<string> &inputs_,  vector<string> &outputs_);

void module_head(std::ofstream &module, string& port_inf);

vector<string> print_clk_gen(std::ofstream& clock_gen,string& clock_ports);

vector<string> print_rst_gen(std::ofstream& file, vector <string> inputs,string& reset_ports,string& reset_value);

string  ini_param(string port_info, vector<string> &clks_val, vector<string> &rst_val);

string  ini_rand(string port_info, vector<string> &clks_val, vector<string> &rst_val);

void compare(std::ofstream &compare_task, vector <string> _output_ports_);

void display(std::ofstream &display_stimulus, vector <string> _input_ports_);

void dump(std::ofstream &dump_vcd);

void ending_module(std::ofstream &module_end);

void print_finish(std::ofstream& clock_gen,string& clock_ports);

string exec(string command);

void update_netlist_name(string post_synth_net_dir,string &top_module);

void launching_varilator(string & rtl_files,string &cells_sim,string post_synth_net_dir,string &top_module);

void write_tb(string& synth_dir,string& clock_ports,string& reset_port,string& reset_value,vector<string> hdl_files);

// int main();
 
 
