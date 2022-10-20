#include <iostream>
#include "monitor_synthesis_project_dir.h"

bool moniter_netlist(std::string *design_stage,std::string *synthesis_dir){
    std::string nstage_netlist = *synthesis_dir + *design_stage;
    
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};
    bool test;
    test = fw.start_monitoring([] (std::string synthesis_netlist_path, std::string _revised_netlist_, FileStatus status) -> void {
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

int main() {

    std::string synthesis_dir = "/nfs_scratch/scratch/FV/awais/file_watcher/";
    std::string design_stage = "after_fsm1.v";
    bool net_status;
    std::filesystem::path p = "/nfs_scratch/scratch/FV/awais/file_watcher/after_fsm.v";
    net_status = moniter_netlist(&design_stage,&synthesis_dir);

    if (std::filesystem::exists(p)){
        remove(p);
    }
    else{
        if (net_status){
            std::cout<<"File does not exist"<<std::endl;
        }
    }
}