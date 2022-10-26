
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
   char buffer[128];
   string result = "";

   // Open pipe to file
   FILE* pipe = popen(command.c_str(), "r");
   if (!pipe) {
      return "popen failed!";
   }

   // read till end of process:
   while (!feof(pipe)) {

      // use buffer to read and add to result
      if (fgets(buffer, 128, pipe) != NULL)
         result += buffer;
   }

   pclose(pipe);
   return result;
}

bool moniter_netlist(std::string *design_stage,std::string *synthesis_dir){
    std::string nstage_netlist = *synthesis_dir + *design_stage;
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};
    bool test;
    std::cout<<"Netlist Path: "<<nstage_netlist<<std::endl;
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
    cout<<"Creating HDL desing\n";

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

void elaboration (std::ofstream& fv_script,vector<string>& path_golden,vector<string>& path_revised,vector<string>& top)
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

void gen_tcl(vector<string>& path_golden,vector<string>& path_revised,vector<string>& top, std::string *tclout_path, std::string *design_stage)
{
    
    cout<<"TCL Path"<<*tclout_path<<endl;
    std::ofstream fv_script;     
    fv_script.open(*tclout_path,ios::app);
    load_settings(fv_script);
    read_hdl(fv_script,path_golden,path_revised);
    elaboration(fv_script,path_golden,path_revised,top);
    compile(fv_script);
    mapping(fv_script, false);
    compare(fv_script,top,design_stage);
    fv_script.close();
}

void get_rtl(vector<string*> rtl_path){

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
                     if ((word !="verific") & !(match[1].str().length()>0) & word != "\\")  {
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
string tcl_process(std::string design_stage ,std::string rev_stage ,std:: string *synth_dir_){
    bool net_status;
    string synth_desig_stage = rev_stage+".v";
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
    top.push_back("b01");
    string rev_net = *synth_dir_+synth_desig_stage;
    vector<string> path_revised;
    path_revised.push_back(rev_net);

    path_revised.push_back(*synth_dir_+"../yosys_verific_rs/yosys-rs-plugin/sim_models.v");
    net_status = moniter_netlist(&synth_desig_stage,synth_dir_);

    std::cout<<"Netlist Status: "<<net_status<<std::endl;
    if (fs::exists(p)){
        remove(p);
    }
    if (net_status){
        gen_tcl(path_golden, path_revised , top, &p1,&synth_desig_stage);
        std::cout<<"File does not exist"<<std::endl;
    }
    return p1;
}

void process_stage(struct fv_args *stage_arg){
    // struct fv_args *stage_arg = (struct fv_args *)fvarg;
    // synth_configuration configuration;
    fs::path cwd_dir_ = fs::current_path();
    std:: string synth_dir_ = (cwd_dir_.generic_string()+"/");
    std::cout<<"DSP Inference "<<*stage_arg->dsp_inf<<std::endl;

    int test_convd = *stage_arg->dsp_inf?1:0;
    int test_convb = *stage_arg->bram_inf?1:0;
    int test_convr = *stage_arg->retiming?1:0;
    int out = (test_convd << 2) | (test_convb<<1) | test_convr;
    
    std::cout<<"Case: "<<out<<std::endl;
    std::vector<std::string> design_stages;

    switch(out){
        case(7):{
            // bool net_status;
            std::string des_stages[] = {"RTL","after_flatten","after_opt-fast-full", "b01_post_synth"};
            if (design_stages.empty()){
                design_stages.insert(design_stages.begin(),begin(des_stages),end(des_stages));
            }
            else{
                design_stages.clear();
                design_stages.insert(design_stages.begin(),begin(des_stages),end(des_stages));
            }
            // for (auto &stage:design_stages){
            std::cout<<"Stage Size: "<<design_stages.size()<<std::endl;
            for (int stage=0; stage<(design_stages.size()-1);stage++){
                std::string tcl_path;
                std::cout<<"Stage : "<<stage<<" "<<design_stages.at(stage)<<std::endl;
                tcl_path= tcl_process(design_stages.at(stage),design_stages.at(stage+1), &synth_dir_);
                if (design_stages.at(stage)!="b01_post_synth"){
                    std::cout<<"Onespin Script Path: "<<design_stages.at(stage)<<design_stages.at(stage+1)<<tcl_path<<std::endl;
                }
                string result = exec_pipe("onespin_sh "+tcl_path);

                // cout << result;
            }
            break;
        }
        case(1):
            std::cout<<"Case 2"<<std::endl;
            break;
        case(2):
            std::cout<<"Case 3"<<std::endl;
            break;
        case(3):
            std::cout<<"Case 4"<<std::endl;
            break;
        case(4):
            std::cout<<"Case 5"<<std::endl;
            break;
        case(5):
            std::cout<<"Case 6"<<std::endl;
            break;
        case(6):
            std::cout<<"Case 7"<<std::endl;
            break;
        case(0):
            std::cout<<"Case 8"<<std::endl;
            break;
        default:
            std::cout<<"DSP inference is turned default"<<std::endl;
            break;
    }
}

void *run_fv(void* flow) {
    struct fv_args *fvargs = (struct fv_args *)flow;
    std::string ref_net = *fvargs->ref_net;
    process_stage(fvargs);
    int fV_timeout = *fvargs->fv_timeout;

    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;
    std::this_thread::sleep_for(std::chrono::seconds(5)); 
    std::cout<<"Synthesis Status "<<fvargs->synth_status<<std::endl;

    pthread_exit(NULL);
    return NULL;
}