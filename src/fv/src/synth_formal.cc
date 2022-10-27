
#include <iostream>
#include <vector>
#include <fstream>
#include <string>
#include <regex>
#include <stdexcept>
#include <stdio.h>
#include "synthesis_watcher.h"
#include "synth_formal.h"
using namespace std; 

string exec_pipe(string command) {
   char buffer[256];
   string result = "";

   command.append(" 2>&1");
   FILE* pipe = popen(command.c_str(), "r");
   if (!pipe) {
      return "popen failed!";
   }
   else{
    while (!feof(pipe)) {
        if (fgets(buffer, 256, pipe) != NULL) result.append(buffer);
    }

   }

   pclose(pipe);
   
   return result;
}


bool moniter_netlist(std::string *design_stage,std::string *synthesis_dir){
    std::string nstage_netlist = *synthesis_dir + *design_stage;
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};
    bool test;
    // std::cout<<"Netlist Path: "<<nstage_netlist<<std::endl;
    test = fw.start_monitoring([] (std::string synthesis_netlist_path, std::string _revised_netlist_, FileStatus status) -> void {
        if(!fs::is_regular_file(fs::path(synthesis_netlist_path)) && status != FileStatus::erased) {
            return;
        }
        if (status == FileStatus::netlist_generated){
            if (synthesis_netlist_path == _revised_netlist_){
                std::cout << "File created: " << synthesis_netlist_path << '\n';
            }
        }
    });
    return test;
}

void load_settings(std::ofstream& fv_script)
{
  
    fv_script<<"load_settings ec_fpga_rtl\n";

}

void read_hdl(std::ofstream& fv_script,vector<string>& path_golden,vector<string>& path_revised)
{
    // cout<<"Creating HDL desing\n";

    if (regex_match (path_golden[0], regex("(.*..*vh)") ) | regex_match (path_golden[0], regex("(.*.v)") ) | regex_match (path_golden[0], regex("(.*.sv)") ))
    {   
        fv_script<<"\nread_verilog -golden  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        fv_script<< *i <<"\t\\\n";
        fv_script<<"}\n"; 
        fv_script<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        fv_script<< *j <<"\t\\\n";
    }
    else if (regex_match (path_golden[0], regex("(.*.vhd)") ) | regex_match (path_golden[0], regex("(.*.vhdl)") ))
    {    
        fv_script<<"\nread_vhdl -golden  -pragma_ignore {}  -version 2008 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        fv_script<< *i <<"\t\\\n";
        fv_script<<"}\n"; 
        fv_script<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        fv_script<< *j <<"\t\\\n";

    } 
    
}

void elaboration (std::ofstream& fv_script,vector<string>& path_golden,vector<string>& top)
{
    
    if (regex_match (path_golden[0], regex("(.*..*vh)") ) | regex_match (path_golden[0], regex("(.*.v)") ) | regex_match (path_golden[0], regex("(.*.sv)") ))
    {
        fv_script<<"}\n\nset_elaborate_option -both -top {Verilog!work."<<top[0]<<"}\n";
    }

    else if (regex_match (path_golden[0], regex("(.*.vhd)") ) | regex_match (path_golden[0], regex("(.*.vhdl)") ))
    { 
        fv_script<<"}\n\nset_elaborate_option -revised -top {Verilog!work."<<top[0]<<"}\n";
    }
    fv_script<<"\nelaborate -both\n";
 
}

void compile(std::ofstream& fv_script)
{
    
    fv_script<<"compile -both\n";
   
}

void mapping(std::ofstream& fv_script, bool extra_map)
{
    
    fv_script<<"set_mode ec\n";
    if (!extra_map)
    {
    fv_script<<"map\n"; 
    }
    else{
    fv_script<<"\nmap -input -output -state -style quartus -nonameonly -no_phase -effort_phase {10} -port_complement_naming_style {BAR} -delimiters {,_.()[]<>/} -exclude {} -ignored_substrings {\\ { }} -fsm {} -nofsm {} -effort_fsm {-1} -reset {} -vif_file {} -vif_submodule_prefix {} -replace_regexp { {@.*@} {}}\n";   
    }

}

void compare(std::ofstream& fv_script,vector<string>& top,std::string *design_stage)
{

    fv_script<<"compare\n"; 
    fv_script<<"\n\nsave_result_file "<<top[0]<<"_"<<*design_stage<<"_results.log\nexit -force";
 
}

void gen_tcl(vector<string>& path_golden,vector<string>& path_revised,vector<string>& top, std::string *tclout_path, std::string *design_stage){
    std::ofstream fv_script;     
    fv_script.open(*tclout_path,ios::app);
    load_settings(fv_script);
    read_hdl(fv_script,path_golden,path_revised);
    elaboration(fv_script,path_golden,top);
    compile(fv_script);
    mapping(fv_script, false);
    compare(fv_script,top,design_stage);
    fv_script.close();
}

void get_rtl(fs::path ys_script, vector<string> &rtl_files){
   if (fs::exists(ys_script)){
      ifstream inp;
      string line;
      smatch match;
      inp.open(ys_script);
      if(inp.is_open()){
         while(inp.good()){
            getline(inp,line);
            string hdl_mode[] = {"-vhdl",  "-vlog2k", "-vlog95", "-sv"};
            for (auto mode:hdl_mode){
               regex _rstr("(verific.*"+mode+"?)");
               regex_search(line, match, _rstr);
               if(match[1].str().length()>0){
                  istringstream ss(line);
                  string word{};
                  regex str2("("+mode+"?)");
                  while (ss >> word){
                     regex_search(word, match, str2);
                     if ((word !="verific") & !(match[1].str().length()>0) & (word != "\\"))  {
                        rtl_files.push_back(word);
                     }
                  }
               }
            }
         }
     }
     inp.close();
   }
}

string tcl_process(std::string design_stage ,std::string rev_stage ,std:: string *synth_dir_,string final_net,string top_mod){
    bool net_status;
    string synth_desig_stage;
    string rev_net;
    if (rev_stage=="final"){
        synth_desig_stage = final_net;
        if (synth_desig_stage=="post_synthesis.v"){
            rev_net = *synth_dir_+synth_desig_stage;
        }
        else{
            rev_net = synth_desig_stage;
        }
    }
    else{
        synth_desig_stage = rev_stage+".v";
        rev_net = *synth_dir_+synth_desig_stage;
    }
    fs::path p = *synth_dir_ + rev_stage + "_onespin.tcl";
    std::string p1 = p.generic_string();
    vector<string> path_golden;
    fs::path ys_script=*synth_dir_+"/b01.ys";
    if (design_stage=="RTL"){get_rtl(ys_script,path_golden);}
    else{
        path_golden.push_back(*synth_dir_+design_stage+".v");
        path_golden.push_back(*synth_dir_+"../yosys_verific_rs/yosys-rs-plugin/sim_models.v");
    }
    vector<string> top;
    top.push_back(top_mod);
    
    vector<string> path_revised;
    path_revised.push_back(rev_net);
    cout<<"Final Netlist Name "<<synth_desig_stage<<" Revised Netlist: "<<rev_stage<<endl;
    path_revised.push_back(*synth_dir_+"../yosys_verific_rs/yosys-rs-plugin/sim_models.v");
    if (synth_desig_stage=="post_synthesis.v"){
        net_status = moniter_netlist(&synth_desig_stage,synth_dir_);
    }
    else{
        std:: string dir = "./";
        net_status = moniter_netlist(&synth_desig_stage,&dir);
    }

    // std::cout<<"Netlist Status: "<<net_status<<std::endl;
    if (fs::exists(p)){
        remove(p);
    }
    if (net_status){
        gen_tcl(path_golden, path_revised , top, &p1,&rev_stage);
        // std::cout<<"File does not exist"<<std::endl;
    }
    return p1;
}

void run_stage(std::vector<std::string> &design_stages,string synth_dir_,string des_stages,string final_net,string top){
    istringstream ss(des_stages);
    string word{};
    design_stages.clear();
    while (ss>>word){
        design_stages.push_back(word);
    }
    for (int stage=0; stage<(design_stages.size()-1);stage++){
        std::string tcl_path;
        tcl_path= tcl_process(design_stages.at(stage),design_stages.at(stage+1), &synth_dir_,final_net,top);
        // string result = exec_pipe("onespin_sh "+tcl_path);
    }
}

void process_stage(struct fv_args *stage_arg){
    fs::path cwd_dir_ = fs::current_path();
    string synth_dir_ = (cwd_dir_.generic_string()+"/");

    int test_convd = *stage_arg->dsp_inf?1:0;
    int test_convb = *stage_arg->bram_inf?1:0;
    int test_convr = *stage_arg->retiming?1:0;
    int out = (!(*stage_arg->fv_cec)<<3)|(test_convd << 2) | (test_convb<<1) | test_convr;
    std::string final_net = *stage_arg->final_stage;
    istringstream ss(*stage_arg->top_module);
    string word{};
    string top_mod{};
    while (ss>>word){
        top_mod=word;
        
    }
    cout<< "Top Module of HDL: "<<top_mod<<" DSP: "<<*stage_arg->final_stage<<endl;
    std::vector<std::string> design_stages;

    switch(out){
        case(0):{
            // highly optimized configuration
            string des_stages = "RTL after_flatten after_dsp_map4 after_bram_map before_simplify after_simplify final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(1):{
            string des_stages = "RTL after_flatten after_dsp_map4 after_bram_map final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(2):{
            string des_stages = "RTL after_flatten after_dsp_map4 before_simplify after_simplify final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(3):{
            string des_stages = "RTL after_flatten after_dsp_map4 after_opt-fast-full final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(4):{
            string des_stages = "RTL after_flatten after_bram_map before_simplify after_simplify final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(5):{
            string des_stages = "RTL after_flatten after_bram_map after_opt-fast-full final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(6):{
            string des_stages = "RTL after_flatten before_simplify after_simplify final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        case(7):{
            // least optimized configuration
            string des_stages = "RTL after_flatten after_opt-fast-full final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
        default:{
            string des_stages = "RTL final";
            run_stage(design_stages,synth_dir_,des_stages,final_net,top_mod);
            break;
        }
    }
}

void *run_fv(void* flow) {
    struct fv_args *fvargs = (struct fv_args *)flow;
    std::string ref_net = *fvargs->ref_net;
    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;
    process_stage(fvargs);
    int fV_timeout = *fvargs->fv_timeout;

    std::this_thread::sleep_for(std::chrono::seconds(5)); 
    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;

    pthread_exit(NULL);
    return NULL;
}