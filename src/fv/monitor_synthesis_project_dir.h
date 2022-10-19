#pragma once

#include <filesystem>
#include <chrono>
#include <thread>
#include <unordered_map>
#include <string>
#include <functional>


enum class FileStatus {netlist_generated, erased};

class monitor_synthesis_project_dir {
public:
    std::string synthesis_netlist_path;
    std::chrono::duration<int, std::milli> delay;
    std::string _current_stage_;
    
    monitor_synthesis_project_dir(std::string synthesis_netlist_path, std::string _current_stage_, std::chrono::duration<int, std::milli> delay) : synthesis_netlist_path{synthesis_netlist_path}, _current_stage_(_current_stage_),delay{delay} {
        for(auto &netlist : std::filesystem::recursive_directory_iterator(synthesis_netlist_path)) {
            _file_in_dir_[netlist.path().string()] = std::filesystem::last_write_time(netlist);
        }
    }

    void start_monitoring(const std::function<void (std::string, std::string, FileStatus)> &action) {
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
                    return;
                }
                auto current_file_last_write_time = std::filesystem::last_write_time(netlist);
                if(!contains(netlist.path().string())) {
                    _file_in_dir_[netlist.path().string()] = current_file_last_write_time;
                    action(netlist.path().string(),_current_stage_, FileStatus::netlist_generated);
                    if (netlist.path().string()==_current_stage_){
                        running_ = false;
                    }
                }
            }
        }
    }
private:
    std::unordered_map<std::string, std::filesystem::file_time_type> _file_in_dir_;
    bool running_ = true;

    // Check if "_file_in_dir_" contains a given key
    bool contains(const std::string &key) {
        auto el = _file_in_dir_.find(key);
        return el != _file_in_dir_.end();
    }
};