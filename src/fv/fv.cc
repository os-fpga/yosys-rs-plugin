#include <iostream>
#include "monitor_synthesis_project_dir.h"

void moniter_netlist(std::string *design_stage,std::string *synthesis_dir){
    std::string nstage_netlist = *synthesis_dir + *design_stage;
    
    monitor_synthesis_project_dir fw{*synthesis_dir,nstage_netlist, std::chrono::milliseconds(5)};

    fw.start_monitoring([] (std::string synthesis_netlist_path, std::string _revised_netlist_, FileStatus status) -> void {
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

int main() {

    std::string synthesis_dir = "/nfs_scratch/scratch/FV/awais/file_watcher/";
    std::string design_stage = "after_fsm.v";

    moniter_netlist(&design_stage,&synthesis_dir);

}