#include "synthesis_watcher.h"

bool monitor_synthesis_project_dir::start_monitoring(const std::function<void (std::string, std::string, FileStatus)> &action) {
        while(running_) {
            std::this_thread::sleep_for(delay);

            auto it = _file_in_dir_.begin();
            while (it != _file_in_dir_.end()) {
                if (!std::filesystem::exists(it->first)) {
                    action(it->first, _current_stage_, FileStatus::erased);
                    it = _file_in_dir_.erase(it);
                }
                else {
                    it++;
                }                    
            }

            for(auto &netlist : std::filesystem::recursive_directory_iterator(synthesis_netlist_path)) {
                if (netlist.path().string()==_current_stage_){
                    action(netlist.path().string(),_current_stage_, FileStatus::netlist_generated);
                    running_ = false;
                    return true;
                }
                auto current_file_last_write_time = std::filesystem::last_write_time(netlist);
                if(!contains(netlist.path().string())) {
                    _file_in_dir_[netlist.path().string()] = current_file_last_write_time;
                    action(netlist.path().string(),_current_stage_, FileStatus::netlist_generated);
                    if (netlist.path().string()==_current_stage_){
                        running_ = false;
                        return true;
                    }
                }
            }
        }
        return false;
}

bool monitor_synthesis_project_dir::contains(const std::string &key) {
        auto el = _file_in_dir_.find(key);
        return el != _file_in_dir_.end();
    }
