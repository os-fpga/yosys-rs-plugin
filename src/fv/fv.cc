#include <iostream>
#include "monitor_synthesis_project_dir.h"
<<<<<<< HEAD

bool moniter_netlist(std::string *design_stage,std::string *synthesis_dir){
    std::string nstage_netlist = *synthesis_dir + *design_stage;
    
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};
    bool test;
    test = fw.start_monitoring([] (std::string synthesis_netlist_path, std::string _revised_netlist_, FileStatus status) -> void {
=======
#include <vector>
#include <fstream>
#include <string>
#include <regex>
void moniter_netlist(std::std::string *design_stage,std::std::string *synthesis_dir){
    std::std::string nstage_netlist = *synthesis_dir + *design_stage;
    
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};

    fw.start_monitoring([] (std::std::string synthesis_netlist_path, std::std::string _revised_netlist_, FileStatus status) -> void {
>>>>>>> 1ddbc07125ef16f5a936b8882dd1722ca2a40ffa
        if(!std::filesystem::is_regular_file(std::filesystem::path(synthesis_netlist_path)) && status != FileStatus::erased) {
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

void load_settings(ofstream& new_file)
{
  
    new_file<<"load_settings ec_fpga_rtl\n";

}

void read_hdl(ofstream& new_file,vector<string>& path_golden,vector<string>& path_revised)
{
    

    if (regex_match (path_golden[0], regex("(.*..*vh)") ) | regex_match (path_golden[0], regex("(.*.v)") ) | regex_match (path_golden[0], regex("(.*.sv)") ))
    {   
        new_file<<"\nread_verilog -golden  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        new_file<< *i <<"\t\\\n";
        new_file<<"}\n"; 
        new_file<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        new_file<< *j <<"\t\\\n";
    }
    else if (regex_match (path_golden[0], regex("(.*.vhd)") ) | regex_match (path_golden[0], regex("(.*.vhdl)") ))
    {    
        new_file<<"\nread_vhdl -golden  -pragma_ignore {}  -version 2008 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        new_file<< *i <<"\t\\\n";
        new_file<<"}\n"; 
        new_file<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        new_file<< *j <<"\t\\\n";

    } 
    
}

void elaboration (ofstream& new_file,vector<string>& path_golden,vector<string>& path_revised,vector<string>& top)
{
    
    if (regex_match (path_golden[0], regex("(.*..*vh)") ) | regex_match (path_golden[0], regex("(.*.v)") ) | regex_match (path_golden[0], regex("(.*.sv)") ))
    {
        new_file<<"}\n\nset_elaborate_option -both -top {Verilog!work."<<top[0]<<"}\n";
    }

    else if (regex_match (path_golden[0], regex("(.*.vhd)") ) | regex_match (path_golden[0], regex("(.*.vhdl)") ))
    { 
        new_file<<"}\n\nset_elaborate_option -revised-top {Verilog!work."<<top[0]<<"}\n";
    }
    new_file<<"\nelaborate -both\n";
 
}

void compile(ofstream& new_file)
{
    
    new_file<<"compile -both\n";
   
}

void mapping(ofstream& new_file, bool extra_map)
{
    
    new_file<<"set_mode ec\n";
    if (!extra_map)
    {
    new_file<<"map\n"; 
    }
    else{
    new_file<<"\nmap -input -output -state -style quartus -nonameonly -no_phase -effort_phase {10} -port_complement_naming_style {BAR} -delimiters {,_.()[]<>/} -exclude {} -ignored_substrings {\\ { }} -fsm {} -nofsm {} -effort_fsm {-1} -reset {} -vif_file {} -vif_submodule_prefix {} -replace_regexp { {@.*@} {}}\n";   
    }

}

void compare(ofstream& new_file,vector<string>& top)
{

    new_file<<"compare\n"; 
    new_file<<"\n\nsave_result_file "<<top[0]<<"_results.log\nexit -force";
 
}

void gen_tcl(vector<string>& path_golden,vector<string>& path_revised,vector<string>& top)
{
    
  
    ofstream new_file;     
    new_file.open("onespin_try.tcl",ios::app);
    load_settings(new_file);
    read_hdl(new_file,path_golden,path_revised);
    elaboration(new_file,path_golden,path_revised,top);
    compile(new_file);
    mapping(new_file, false);
    compare(new_file,top);
    new_file.close();
}
int main() {

<<<<<<< HEAD
    std::string synthesis_dir = "/nfs_scratch/scratch/FV/awais/file_watcher/";
    std::string design_stage = "after_fsm1.v";
    bool net_status;
    std::filesystem::path p = "/nfs_scratch/scratch/FV/awais/file_watcher/after_fsm.v";
    net_status = moniter_netlist(&design_stage,&synthesis_dir);
=======
    std::std::string synthesis_dir = "/nfs_scratch/scratch/FV/awais/file_watcher/";
    std::std::string design_stage = "after_fsm.v";

    moniter_netlist(&design_stage,&synthesis_dir);
>>>>>>> 1ddbc07125ef16f5a936b8882dd1722ca2a40ffa

    if (std::filesystem::exists(p)){
        remove(p);
    }
    else{
        if (net_status){
            std::cout<<"File does not exist"<<std::endl;
        }
    }
}