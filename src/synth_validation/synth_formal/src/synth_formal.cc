
#include <iostream>
#include <vector>
#include <map>
#include <tuple>
#include <fstream>
#include <string>
#include <regex>
#include <stdexcept>
#include <stdio.h>
#include <thread> 
#include <sys/wait.h>
#include <chrono>

#include <unistd.h>
#include <cstdlib>
#include <signal.h>
#include <mutex>
#include "synth_formal.h"
#include "../../synth_simulation/TBG.h"

#include <filesystem>

#define READ   0
namespace fs = std::filesystem;
mutex mtx;
using namespace std;

vector <string> fv_stages;
map <string, string> stage_status;

struct hdl_args{
    string hdl_type;
    string ref_container;
    string imp_container;
    string hdl_sett;
    string hdl_footer;
    string file_sep;
    vector<string>golden;
    vector<string>revised;

    string stage2;
    string stage;
    string top;
    string tool;
};




struct fm_setting{
    bool name_matching;
    bool reg_merg;
    bool reg_init;
    string init;
};

string TCL_TOOL = "";
 
map <string, tuple<string,string,string,string,string,string,int>> fv_results;

tuple<string,string,string,string,string,string,int> fv_results_tp;

int verif_stage = 0;
string onespin_exe(string cmd, string stage, bool &onespin_lic_fail, int &spent_time){

    char buffer[256];
    onespin_lic_fail = false;
    bool lic_captured = false;
    string result = "", str_buff="";
    smatch lic_match,lic_match1,fv_pass, fv_fail;
    regex _lic_pass_("(.*Loading.*'RTL2RTL'?)");
    regex _lic_fail_("(.*Error:.*Cannot.*get.*license?)");
    regex _fv_succeeded_ ("(.*designs.*are equivalent.*?)");
    regex _fv_failed_ ("(.*designs.*are not equivalent.*?)");

    string command  = "onespin_sh "+cmd;
    command.append(" 2>&1");

    // cout<<"PID: "<<getpid()<<endl;
    
    stage_status.insert({stage, ""});
    auto itr = stage_status.find(stage);

    // pid_t child_id;
    // cout<<"Child ID:" <<child_id<<endl;
    auto start = chrono::high_resolution_clock::now();
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) {
        return "popen failed!";
    }
    else{
        while (!feof(pipe)) {
            if (fgets(buffer, 256, pipe) != NULL){
                result.append(buffer);
                // cout<<buffer;
            }
            if (!onespin_lic_fail){
                str_buff = buffer;
                regex_search(str_buff, lic_match, _lic_fail_);
                regex_search(str_buff, lic_match1, _lic_pass_);
                if(lic_match[1].str().length()>0){
                    std::cerr<<"Cannot get the license for Onespin"<<endl;
                    onespin_lic_fail=true;
                    if (itr != stage_status.end()){
                        itr->second = "lic_check_fail";
                    }
                }
                else if(lic_match1[1].str().length()>0){
                    std::cout<<"Succeeded to get the Onepsin License"<<endl;
                    onespin_lic_fail=false;
                    if (!lic_captured){
                        if (itr != stage_status.end()){
                            itr->second = "busy";
                        }

                        lic_captured=true;
                    }
                }
            }
        }
    }
    
    ofstream pipe_out;
    pipe_out.open(stage+".log", ios::out);
    pipe_out.close(); 
    pipe_out.open(stage+".log", ios::app);
    pipe_out<<result<<endl;
    string fv_status;
    // check for Formal Verification Status
    regex_search(result, fv_pass, _fv_succeeded_);
    regex_search(result, fv_fail, _fv_failed_);
    if(fv_pass[1].str().length()>0){
        fv_status = "Verification Succeeded";
        std::cerr<<"Verification Succeeded for "<<stage<<endl;
    }
    else if(fv_fail[1].str().length()>0){
        fv_status = "Verification Failed";
        std::cout<<"Verification Failed for "<<stage<<endl;
    }
    else{
        fv_status = "N/A";
        std::cout<<"Verification Results not found for "<<stage<<endl;
    }

    if (lic_captured){  
        if (itr != stage_status.end()){
            itr->second = "done";
            auto stop = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::seconds>(stop - start);
            spent_time = duration.count();
        }
        cout<<"Staus Done:  "<<endl;
    }
   pclose(pipe);
   
   return fv_status;
}

string fm_exe(string cmd, string stage, bool &fm_lic_fail, int &spent_time){
    char buffer[256];
    bool lic_captured =false;
    fm_lic_fail = false;
    string result = "", str_buff="";
    smatch lic_match,lic_match1,fv_pass, fv_fail;
    regex _lic_pass_("(.*Loading.*db?)");
    regex _lic_fail_("(.*Error:.*All.*'Formality'.*licenses.*use?)");
    regex _fv_succeeded_ ("(.*Verification.*SUCCEEDED.*?)");
    regex _fv_failed_ ("(.*Verification.*FAILED.*?)");
    ofstream pipe_out;

    stage_status.insert({stage, ""});
    auto itr = stage_status.find(stage);
    pipe_out.open(stage+"_"+TCL_TOOL+".log", ios::out);
    pipe_out.close();
    pipe_out.open(stage+"_"+TCL_TOOL+".log", ios::app);

    string command  = "fm_shell -f "+cmd;
    command.append(" 2>&1");

    cout<<"PID: "<<getpid()<<endl;
    
    pid_t child_id;
    cout<<"Child ID:" <<child_id<<endl;
    auto start = chrono::high_resolution_clock::now();
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) {
        return "popen failed!";
    }
    else{
        while (!feof(pipe)) {
            if (fgets(buffer, 256, pipe) != NULL){
                result.append(buffer);
                // cout<<buffer;
                pipe_out<<buffer;
            }
            if (!fm_lic_fail){
                str_buff = buffer;
                regex_search(str_buff, lic_match, _lic_fail_);
                regex_search(str_buff, lic_match1, _lic_pass_);
                if(lic_match[1].str().length()>0){
                    std::cerr<<"Cannot get the license for Formality "<<stage<<endl;
                    fm_lic_fail=true;
                    if (itr != stage_status.end()){
                        itr->second = "lic_check_fail";
                    }
                }
                else if(lic_match1[1].str().length()>0){
                    std::cout<<"Succeeded to get the Formality License "<<stage<<endl;
                    fm_lic_fail=false;
                    if (!lic_captured){
                        if (itr != stage_status.end()){
                            itr->second = "busy";
                            
                        }
                        lic_captured=true;
                    }
                }
            }
        }
    }
    

   pclose(pipe);
   pipe_out.close();

   string fv_status;
   // check for Formal Verification Status
   regex_search(result, fv_pass, _fv_succeeded_);
   regex_search(result, fv_fail, _fv_failed_);
   if(fv_pass[1].str().length()>0){
        fv_status = "Verification Succeeded";
        std::cerr<<"Verification Succeeded for "<<stage<<endl;
    }
    else if(fv_fail[1].str().length()>0){
        fv_status = "Verification Failed";
        std::cout<<"Verification Failed for "<<stage<<endl;
    }
    else{
        fv_status = "N/A";
        std::cout<<"Verification Results not found for "<<stage<<endl;
    }
    // Release the formal verification tool license
    if (lic_captured){
        if (itr != stage_status.end()){
            itr->second = "done";
            auto stop = chrono::high_resolution_clock::now();
            auto duration = chrono::duration_cast<chrono::seconds>(stop - start);
            spent_time = duration.count();

        }
    }
   return fv_status;
}

void fm_guid(ofstream& fv_script){
    
    /******************** Synopsys Auto Setup ****************************
        Setting Auto setup will set following guidance commands for FV

        hdlin_ignore_embedded_configuration = true
        hdlin_ignore_full_case = false
        hdlin_ignore_parallel_case = false
        signature_analysis_allow_subset_match = false
        svf_ignore_unqualified_fsm_information = false (only changed when there are guide_fsm_reencoding commands in the sutomated setup file for verification (SVF))
        upf_assume_related_supply_default_primary = true
        upf_use_additional_db_attributes = true
        verification_set_undriven_signals = synthesis
        verification_verify_directly_undriven_output = false
        set_mismatch_message_filter -warn
        hdlin_enable_verilog_configurations_array_n_block = true
        svf_checkpoint_auto_setup_commands = all
        
    **********************************************************************/
    fv_script<<"set synopsys_auto_setup true\n";

    /******************Ignore Design Elaboration Warinings****************/
    fv_script<<"\nset_mismatch_message_filter -warn FMR_ELAB-116\n";
    fv_script<<"set_mismatch_message_filter -warn FMR_ELAB-147\n";
    fv_script<<"set_mismatch_message_filter -warn FMR_ELAB-149\n";

}

void sett_onespin(ofstream& fv_script){
    fv_script<<"load_settings ec_fpga_rtl\n";
}

void tool_settings(std::ofstream& fv_script){
    
    if (TCL_TOOL=="formality"){
        fm_guid(fv_script);
    }
    else if (TCL_TOOL=="onespin"){
        sett_onespin(fv_script);
    }
    else if(TCL_TOOL=="conformal"){
        cerr<<"[ERROR] Cadence Conformal is not part of Yosys synthesis verification"<<endl;
        // throw unkown_tool();
    }
    else{
        cerr<<"[ERROR] Unknown formal tool selected for verification"<<endl;
        // throw unkown_tool();
    }
    // fv_script<<"load_settings ec_fpga_rtl\n";

}

string get_rtl(fs::path ys_script, vector<string> &rtl_files){
   if (fs::exists(ys_script)){
      ifstream inp;
      string line;
      string verific_mode;
      smatch match;
      char comp = '\\';
      bool eseq =false;
      inp.open(ys_script);
      if(inp.is_open()){
         while(inp.good()){
            getline(inp,line); // get line one by one
            string hdl_mode[] = {"-vhdl",  "-vlog2k", "-vlog95", "-sv"}; // Supported languages
            if (!eseq){
               for (auto mode:hdl_mode){
                  regex _rstr("(verific.*"+mode+"?)");
                  regex_search(line, match, _rstr);
                  if(match[1].str().length()>0){
                    cout<<"Verific Mode "<<mode<<endl;
                    verific_mode=mode;
                     istringstream ss(line);
                     string word{};
                     regex str2("("+mode+"?)");
                     while (ss >> word){
                        regex_search(word, match, str2);
                        if ((word !="verific") & !(match[1].str().length()>0) & (word != "\\"))  {
                           rtl_files.push_back(word);
                        //    cout<<"FILES: "<<word<<endl;
                           if (*line.rbegin() == comp){
                              eseq=true;
                              break;
                           }
                        }
                     }
                     if (eseq)break;
                  }
               }
            }
            else{
               istringstream ss(line);
               string word{};
               while(ss>>word){
                  rtl_files.push_back(word);
               }
               if (*line.rbegin() != comp){
                  eseq=false;
               }
            }
         }
      }
     inp.close();
    return verific_mode;
   }
}

void write_hdl(std::ofstream& fv_script,vector<string>& file_path,struct hdl_args hdlarg){
    string hdl_header;
    string hdl_body = "";
    hdl_header = hdlarg.hdl_type+" "+hdlarg.ref_container+" "+hdlarg.hdl_sett;
    fv_script<<"\n"+hdl_header;
    for (auto i = file_path.begin(); i != file_path.end(); ++i) hdl_body =hdl_body + "\t" + *i + hdlarg.file_sep + " \\\n";
    if (!(hdlarg.file_sep.empty()))hdl_body.resize(hdl_body.size()-4);
    else hdl_body.resize(hdl_body.size()-2);
    fv_script<<hdl_body+"\n";
    fv_script<<hdlarg.hdl_footer; 
}

void hdl_proccessing(std::ofstream& fv_script,struct hdl_args hdlarg){
    // struct hdl_args hdlarg;

    if (regex_match (hdlarg.golden[0], regex("(.*..*vh)") ) | regex_match (hdlarg.golden[0], regex("(.*.v)") ) | regex_match (hdlarg.golden[0], regex("(.*.sv)") )){   
        if(TCL_TOOL=="formality"){
            hdlarg.hdl_type        = "read_sverilog ";
            hdlarg.ref_container   = "-container r ";
            hdlarg.hdl_sett        = "-libname WORK { \\\n";
            hdlarg.file_sep = ",";
            hdlarg.hdl_footer = "}\n";
            write_hdl(fv_script,hdlarg.golden,hdlarg); // Reading Golden Design
            fv_script<<"set_top r:/WORK/"+hdlarg.top+"\n";
            hdlarg.ref_container   = "-container i ";
            write_hdl(fv_script,hdlarg.revised,hdlarg); // Reading Revised Design
            fv_script<<"set_top i:/WORK/"+hdlarg.top+"\n";
        }
        else if(TCL_TOOL=="onespin"){
            cout<<"Generating TCL for Onespin"<<endl;
            hdlarg.hdl_type = "read_verilog ";
            hdlarg.ref_container = "-golden ";
            hdlarg.hdl_sett = "-pragma_ignore {}  -version sv2012 { \\\n";
            hdlarg.hdl_footer = "}\n";
            write_hdl(fv_script,hdlarg.golden,hdlarg); // Reading Golden Design
            hdlarg.ref_container   = "-revised ";
            write_hdl(fv_script,hdlarg.revised,hdlarg); // Reading Revised Design
        }
        else if(TCL_TOOL=="conformal"){
            cerr<<"[ERROR] Cadence Conformal is not part of Yosys synthesis verification"<<endl;
            // throw unkown_tool();
        }
        else{
            cerr<<"[ERROR] Unknown formal tool selected for verification"<<endl;
            // throw unkown_tool();
        }
    }
    else if (regex_match (hdlarg.golden[0], regex("(.*.vhd)") ) | regex_match (hdlarg.golden[0], regex("(.*.vhdl)") )){
        if(TCL_TOOL=="formality"){
            hdlarg.hdl_type        = "read_vhdl ";
            hdlarg.ref_container   = "-container r ";
            hdlarg.hdl_sett        = "-libname WORK { \\\n";
            hdlarg.file_sep = ",";
            hdlarg.hdl_footer = "}\n";
            write_hdl(fv_script,hdlarg.golden,hdlarg); // Reading Golden Design
            fv_script<<"set_top r:/WORK/"+hdlarg.top+"\n";
            hdlarg.hdl_type        = "read_sverilog ";
            hdlarg.ref_container   = "-container i ";
            write_hdl(fv_script,hdlarg.revised,hdlarg); // Reading Revised Design
            fv_script<<"set_top i:/WORK/"+hdlarg.top+"\n";
        }
        else if(TCL_TOOL=="onespin"){
            hdlarg.hdl_type     = "read_vhdl ";
            hdlarg.ref_container = "-golden ";
            hdlarg.hdl_sett = "-pragma_ignore {}  -version 2008 { \\\n";
            hdlarg.hdl_footer = "}\n";
            write_hdl(fv_script,hdlarg.golden,hdlarg); // Reading Golden Design
            hdlarg.hdl_type        = "read_verilog ";
            hdlarg.ref_container   = "-revised ";
            hdlarg.hdl_sett = "-pragma_ignore {}  -version sv2012 { \\\n"; 
            write_hdl(fv_script,hdlarg.revised,hdlarg); // Reading Revised Design
        }
        else if(TCL_TOOL=="conformal"){
            cerr<<"[ERROR] Cadence Conformal is not part of Yosys synthesis verification"<<endl;
            // throw unkown_tool();
        }
        else{
            cerr<<"[ERROR] Unknown formal tool selected for verification"<<endl;
            // throw unkown_tool();
        }
    }
}

void fm_design_setup(ofstream& fv_script, struct fm_setting fmset){
    /*
        "match":{
            "message_x_source_reporting": true,
            "name_match_based_on_nets": false,
            "name_match": "port"
        },
        "verify":{
            "verification_timeout_limit": "02:00:00",
            "verification_run_analyze_points": true,
            "verification_merge_duplicated_registers": true,
            "verification_failing_point_limit": 1000,
            "verification_assume_reg_init": "Liberal0",
            "verification_set_undriven_signals": 0

        }
    */
    if (fmset.name_matching){
        fv_script<<"\nset name_match_based_on_nets false\n";
        fv_script<<"set name_match port\n";
    }
    // fv_script<<"verification_timeout_limit "+timeout+"\n";
    if (fmset.reg_merg)fv_script<<"set verification_merge_duplicated_registers true\n";
    if (fmset.reg_init)fv_script<<"set verification_assume_reg_init "+fmset.init+"\n";
}

void elaboration (std::ofstream& fv_script,struct hdl_args hdlarg){
    if (regex_match (hdlarg.golden[0], regex("(.*..*vh)") ) | regex_match (hdlarg.golden[0], regex("(.*.v)") ) | regex_match (hdlarg.golden[0], regex("(.*.sv)") ))
        fv_script<<"\nset_elaborate_option -both -top {Verilog!work."<<hdlarg.top<<"}\n";
    else if (regex_match (hdlarg.golden[0], regex("(.*.vhd)") ) | regex_match (hdlarg.golden[0], regex("(.*.vhdl)") ))
        fv_script<<"\n\nset_elaborate_option -revised -top {Verilog!work."<<hdlarg.top<<"}\n";
    
    fv_script<<"\nelaborate -both\n";
}

void compile(std::ofstream& fv_script){
    fv_script<<"compile -both\n"; 
}

void mapping(std::ofstream& fv_script, bool extra_map){
    
    if (TCL_TOOL=="formality")
        fv_script<<"\nmatch\n";
    else if (TCL_TOOL=="onespin"){
        fv_script<<"set_mode ec\n";
        if (!extra_map){
            fv_script<<"map\n";
            fv_script<<"compute_initial_state\n";
            fv_script<<"compute_state_relations\n";

        }
        else{
            fv_script<<"\nmap -input -output -state -style quartus -nonameonly -no_phase -effort_phase {10} -port_complement_naming_style {BAR} -delimiters {,_.()[]<>/} -exclude {} -ignored_substrings {\\ { }} -fsm {} -nofsm {} -effort_fsm {-1} -reset {} -vif_file {} -vif_submodule_prefix {} -replace_regexp { {@.*@} {}}\n";   
        }

    }
}

void compare(std::ofstream& fv_script,struct hdl_args hdlarg,std::string *out_path_rs){

    if (TCL_TOOL=="formality"){
        fv_script<<"\nverify\nexit\n"; 
    }
    else if (TCL_TOOL=="onespin"){
        fv_script<<"set_limit -command_real_time 3600\n compare\n"; 
        fv_script<<"\n\nsave_result_file "<<hdlarg.top<<"_"<<hdlarg.stage2<<"_results.log\nexit -force";
    }
    
    if( remove( (*out_path_rs+hdlarg.top+"_"+hdlarg.stage2+"_results.log").c_str() ) != 0 )
    std::cout<<"Error deleting onespin result file"<<endl;
}

void gen_tcl(struct hdl_args hdlarg, std::string *tclout_path ,string *w_dir_){
    std::ofstream fv_script;
    cout<<"TCL Path: "<<*tclout_path<<endl;
    struct fm_setting fm_set;
    fm_set.name_matching = true;
    fv_script.open(*tclout_path,ios::out);
    fv_script.close(); // clear the already written data
    fv_script.open(*tclout_path,ios::app);
    tool_settings(fv_script);
    hdl_proccessing(fv_script,hdlarg);
    if (TCL_TOOL == "formality"){
        fm_design_setup(fv_script,fm_set);
    }
    else if (TCL_TOOL=="onespin"){
        elaboration(fv_script,hdlarg);
        compile(fv_script);
    }
    mapping(fv_script, false);
    compare(fv_script,hdlarg,w_dir_);
    fv_script.close();
}

string exec_pipe(struct hdl_args hdlarg,string tool,string stage,string key_stage, string synth_dir_) {
    string result = "";
    string _fv_tool_ = "";
    bool onespin_lic_fail=false;
    bool fm_lic_fail=false;
    int time_spent;
    string tclout_path_fm = "";
    string tclout_path_onespin = "";
  
    if (tool == "onespin" || tool== "both"){
        fv_stages.push_back(stage);
        TCL_TOOL = "onespin";
        tclout_path_onespin = synth_dir_+stage+"_onespin.tcl";
        gen_tcl(hdlarg, &tclout_path_onespin,&synth_dir_);
        result = onespin_exe(tclout_path_onespin, stage, onespin_lic_fail,time_spent);
        _fv_tool_ ="Onespin";

        if (stage_status[stage] == "lic_check_fail" && tool=="onespin"){
            int time_count = 0;
            while (1){
                std::this_thread::sleep_for(std::chrono::seconds(5));
                time_count = time_count +5;
                result = onespin_exe(tclout_path_onespin, stage, onespin_lic_fail,time_spent);
                _fv_tool_ ="Onespin";
                if (stage_status[stage] == "done" || time_count >= 900) {
                    break;
                }
            }
        }
    }
    if (tool=="formality" || (stage_status[stage] == "lic_check_fail" && tool == "both")){
        TCL_TOOL = "formality";
        tclout_path_fm = synth_dir_+stage+"_fm.tcl";
        gen_tcl(hdlarg, &tclout_path_fm,&synth_dir_);

        result = fm_exe(tclout_path_fm,  stage, fm_lic_fail,time_spent);
        _fv_tool_ = "Formality";
    }
    if (stage_status[stage] == "lic_check_fail" && tool != "onespin"){
        int time_count = 0;
        while (1){
            std::this_thread::sleep_for(std::chrono::seconds(5));
            time_count = time_count +5;
            if (tool == "both"){
                result = onespin_exe(tclout_path_onespin, stage, onespin_lic_fail,time_spent);
                _fv_tool_ ="Onespin";
                if (stage_status[stage] == "done" || time_count >= 900) {
                    break;
                }
            }
            result = fm_exe(tclout_path_fm,  stage, fm_lic_fail,time_spent);
            _fv_tool_ ="Formality";
            if (stage_status[stage] == "done" || time_count >= 900) {
                break;
            }
        }   
    }

    auto itr = fv_results.find(key_stage);
    if (itr != fv_results.end()){
        get<2>(itr->second) = result;
        get<3>(itr->second) = _fv_tool_;
        get<6>(itr->second) = time_spent;
        cout<<"Verification Results\n"<<key_stage<<"\t"<<get<0>(itr->second)<<" VS "<<get<1>(itr->second)<<"\t"<<get<2>(itr->second)<<"\t"<<get<3>(itr->second)<<"\t"<<time_spent<<endl;
    }
   return result ;
}

void *run_fv(void* flow) {
    mtx.lock();

    cout<<"Gen RTL"<<endl;
    struct fv_args *fvargs = (struct fv_args *)flow;
    string ref_net = *fvargs->ref_net;
    string shared_dir = *fvargs->shared_dir_path;
    int fV_timeout = *fvargs->fv_timeout;

    fs::path cwd_dir_ = fs::current_path();
    string synth_dir_ = (cwd_dir_.generic_string()+"/");

    fs::path ys_script=synth_dir_+"yosys.ys";
    struct hdl_args hdlarg;
    string rtl_files;
    vector<string> hdl_files;
    string cells_sim;
    hdlarg.stage=*fvargs->stage1;
    hdlarg.stage2=*fvargs->stage2;
    if (*fvargs->stage1=="RTL"){
        string verific_mode=get_rtl(ys_script,hdlarg.golden);
        for (auto files: hdlarg.golden) {
            if (regex_match (files, regex(".*.vh")) || regex_match (files, regex(".*.svh"))) hdl_files.push_back(files);
            
            if (verific_mode=="-sv") rtl_files+=" -sv "+files; //getting RTL files for verilator
            else
                rtl_files+=" -v "+files;
        }
        cells_sim =" -v "+shared_dir+"rapidsilicon/sim_models.v"; // getting simulation models for varilator
        cout<<"simulation model directory:"<<cells_sim<<endl;
    }
    else{
        hdlarg.golden.push_back(synth_dir_+*fvargs->stage1+".v");
        hdlarg.golden.push_back(shared_dir+"rapidsilicon/sim_models.v");
    }
    hdlarg.revised.push_back(synth_dir_+*fvargs->stage2+".v");
    hdlarg.revised.push_back(shared_dir+"rapidsilicon/sim_models.v");
    
    // hdlarg.tool == *fvargs->fv_tool;
    //cout<<"rtl_files :"<<rtl_files<<endl;

    istringstream ss(*fvargs->top_module);
    string word{};
    string top_mod{};
    while (ss>>word){
        top_mod=word;
    }
    hdlarg.top = top_mod;

    // cout << "FV TOOL = "<<hdlarg.tool<<endl;
     cout<<"Top Module: "<<top_mod<<endl;

    fv_results_tp = make_tuple(*fvargs->stage1,*fvargs->stage2,"N/A","N/A",synth_dir_,top_mod,0);
    verif_stage++;
    // fv_results_tp.clear();
    fv_results.insert(make_pair(("stage"+to_string(verif_stage)),fv_results_tp));
    mtx.unlock();
    // cout<<*fvargs->fv<<endl;
    if (*fvargs->fv == "formal"){
        string result = exec_pipe(hdlarg,*fvargs->fv_tool,*fvargs->stage2,"stage"+to_string(verif_stage),synth_dir_);
    }
    else if (*fvargs->fv == "simulation"){
        
        cout<<"Before generating testbench for synth_rs"<<endl;
        string directory_name("sim_dir");
        fs::remove_all(directory_name)?cout << "deleted sim_dir directory - " << directory_name << endl:cout << "delete_directory() failed" << endl;
        fs::create_directory(directory_name)?cout << "created sim_dir directory - " << directory_name << endl:cout << "create_directory() failed" << endl;
        fs::copy(synth_dir_+"/post_synthesis.v",synth_dir_+"sim_dir/post_synthesis.v");
        write_tb(synth_dir_,*fvargs->sim_clock_ports,*fvargs->sim_reset_ports,*fvargs->sim_reset_state,hdl_files);//writing testbench
        cout<<"Generating testbench for synth_rs"<<endl;
        launching_varilator(rtl_files,cells_sim,synth_dir_,top_mod); //launching verilator
        }
    pthread_exit(NULL);
    return NULL;
}
