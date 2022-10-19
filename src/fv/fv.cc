#include <iostream>
#include "monitor_synthesis_project_dir.h"
#include <vector>
#include <fstream>
#include <string>
#include <regex>
void moniter_netlist(std::std::string *design_stage,std::std::string *synthesis_dir){
    std::std::string nstage_netlist = *synthesis_dir + *design_stage;
    
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};

    fw.start_monitoring([] (std::std::string synthesis_netlist_path, std::std::string _revised_netlist_, FileStatus status) -> void {
        if(!std::filesystem::is_regular_file(std::filesystem::path(synthesis_netlist_path)) && status != FileStatus::erased) {
            return;
        }
        if (status == FileStatus::netlist_generated){
            if (synthesis_netlist_path == _revised_netlist_){
                std::cout << "File created: " << synthesis_netlist_path << '\n';
            }
        }
    });
}

void gen_tcl(vector<std::string>& path_golden,vector<std::string>& path_revised,vector<std::string>& top)
{
    ofstream new_file; 
    new_file.open("onespin_try.tcl"); 
    new_file.close();

    
if (regex_match (path_golden[0], regex("(.*..*vh)") ) | regex_match (path_golden[0], regex("(.*.v)") ) | regex_match (path_golden[0], regex("(.*.sv)") ))
    {   
        cout << "verilog files => matched\n";
        new_file.open("onespin_try.tcl",ios::app);
        new_file<<"load_settings ec_fpga_rtl\n";
        new_file<<"\nread_verilog -golden  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        new_file<< *i <<"\t\\\n";
        new_file<<"}\n"; 
        new_file<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        new_file<< *j <<"\t\\\n";
        new_file<<"}\n\nset_elaborate_option -both -top {Verilog!work."<<top[0]<<"}\n";
        new_file<<"\nelaborate -both\ncompile -both\nset_mode ec\nmap\ncompare\n"; 
        new_file<<"\n\nsave_result_file "<<top[0]<<"_results.log\nexit -force";
        new_file.close(); 
    }
else if (regex_match (path_golden[0], regex("(.*.vhd)") ) | regex_match (path_golden[0], regex("(.*.vhdl)") ))
    {
        cout << "VHDL files => matched\n";
        new_file.open("onespin_try.tcl",ios::app);
        new_file<<"load_settings ec_fpga_rtl\n";
        new_file<<"\nread_vhdl -golden  -pragma_ignore {}  -version 2008 {\\\n";
        for (auto i = path_golden.begin(); i != path_golden.end(); ++i) 
        new_file<< *i <<"\t\\\n";
        new_file<<"}\n"; 
        new_file<<"\n\nread_verilog -revised  -pragma_ignore {}  -version sv2012 {\\\n";
        for (auto j = path_revised.begin(); j != path_revised.end(); ++j) 
        new_file<< *j <<"\t\\\n";
        new_file<<"}\n\nset_elaborate_option -revised-top {Verilog!work."<<top[0]<<"}\n";
        new_file<<"\nelaborate -both\ncompile -both\nset_mode ec\nmap\ncompare\n"; 
        new_file<<"\n\nsave_result_file "<<top[0]<<"_results.log\nexit -force";
        new_file.close(); 
    }
}
int main() {

    std::std::string synthesis_dir = "/nfs_scratch/scratch/FV/awais/file_watcher/";
    std::std::string design_stage = "after_fsm.v";

    moniter_netlist(&design_stage,&synthesis_dir);

}