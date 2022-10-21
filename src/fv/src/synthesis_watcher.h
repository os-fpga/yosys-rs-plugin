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

    bool start_monitoring(const std::function<void (std::string, std::string, FileStatus)> &action);
private:
    std::unordered_map<std::string, std::filesystem::file_time_type> _file_in_dir_;
    bool running_ = true;

    // Check if "_file_in_dir_" contains a given key
    bool contains(const std::string &key);
};