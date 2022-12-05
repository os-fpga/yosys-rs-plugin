
#include <iostream>
#include <vector>
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
#include "test.h"
#include <filesystem>

#define READ   0
namespace fs = std::filesystem;
mutex mtx;
using namespace std;


struct hdl_args{
    string hdl_type;
    string ref_container;
    string imp_container;
    string hdl_sett;
    string hdl_footer;
    string file_sep;
    vector<string>golden;
    vector<string>revised;
    string stage;
    string top;
};




struct fm_setting{
    bool name_matching;
    bool reg_merg;
    bool reg_init;
    string init;
};

string FV_TOOL = "";

string onespin_exe(string cmd, string stage, bool &onespin_lic_fail){

    char buffer[256];
    bool lic_captured = false;
    string result = "", str_buff="";
    smatch lic_match,lic_match1;
    regex _lic_pass_("(.*Loading.*'RTL2RTL'?)");
    regex _lic_fail_("(.*Error:.*Cannot.*get.*license?)");

    string command  = "onespin_sh "+cmd;
    command.append(" 2>&1");

    cout<<"PID: "<<getpid()<<endl;
    
    pid_t child_id;
    cout<<"Child ID:" <<child_id<<endl;
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) {
        return "popen failed!";
    }
    else{
        while (!feof(pipe)) {
            if (fgets(buffer, 256, pipe) != NULL){
                result.append(buffer);
                cout<<buffer;
            }
            if (!onespin_lic_fail){
                str_buff = buffer;
                regex_search(str_buff, lic_match, _lic_fail_);
                regex_search(str_buff, lic_match1, _lic_pass_);
                if(lic_match[1].str().length()>0){
                    std::cerr<<"Cannot get the license for Onespin"<<endl;
                    onespin_lic_fail=true;
                }
                else if(lic_match1[1].str().length()>0){
                    std::cout<<"Succeeded to get the Onepsin License"<<endl;
                    onespin_lic_fail=false;
                    if (!lic_captured){
                        onespin_lic++;
                        lic_captured=true;
                    }
                }
            }
        }
    }
    
    ofstream pipe_out;
    pipe_out.open(stage+".log", ios::out);
    pipe_out<<result<<endl;
    if (lic_captured)
        onespin_lic--;
   pclose(pipe);
   
   return result;
}

string fm_exe(string cmd, string stage, bool &fm_lic_fail){
    char buffer[256];
    bool lic_captured =false;
    
    string result = "", str_buff="";
    smatch lic_match,lic_match1,fv_pass, fv_fail;
    regex _lic_pass_("(.*Loading.*db?)");
    regex _lic_fail_("(.*Error:.*All.*'Formality'.*licenses.*use?)");
    regex _fv_succeeded_ ("(.*Verification.*SUCCEEDED.*?)");
    regex _fv_failed_ ("(.*Verification.*FAILED.*?)");
    ofstream pipe_out;

    pipe_out.open(stage+"_"+FV_TOOL+".log", ios::app);

    string command  = "fm_shell -f "+cmd;
    command.append(" 2>&1");

    cout<<"PID: "<<getpid()<<endl;
    
    pid_t child_id;
    cout<<"Child ID:" <<child_id<<endl;
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
                }
                else if(lic_match1[1].str().length()>0){
                    std::cout<<"Succeeded to get the Formality License "<<stage<<endl;
                    fm_lic_fail=false;
                    if (!lic_captured){
                        formality_lic++;
                        lic_captured=true;
                    }
                }
            }
        }
    }
    

   pclose(pipe);
   pipe_out.close();
   // check for Formal Verification Status
   regex_search(result, fv_pass, _fv_succeeded_);
   regex_search(result, fv_fail, _fv_failed_);
   if(fv_pass[1].str().length()>0){
        std::cerr<<"Verification Succeeded for "<<stage<<endl;
    }
    else if(fv_fail[1].str().length()>0){
        std::cout<<"Verification Failed for "<<stage<<endl;
    }
    else{
        std::cout<<"Verification Results not found for "<<stage<<endl;
    }
    // Release the formal verification tool license
    if (lic_captured){
        formality_lic--;
    }

    cout<<"fm_lic in exe "<<formality_lic<<endl;
   return result;
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
    
    if (FV_TOOL=="fm"){
        fm_guid(fv_script);
    }
    else if (FV_TOOL=="onespin"){
        sett_onespin(fv_script);
    }
    else if(FV_TOOL=="conformal"){
        cerr<<"[ERROR] Cadence Conformal is not part of Yosys synthesis verification"<<endl;
        // throw unkown_tool();
    }
    else{
        cerr<<"[ERROR] Unknown formal tool selected for verification"<<endl;
        // throw unkown_tool();
    }
    // fv_script<<"load_settings ec_fpga_rtl\n";

}

void get_rtl(fs::path ys_script, vector<string> &rtl_files){
   if (fs::exists(ys_script)){
      ifstream inp;
      string line;
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
                     istringstream ss(line);
                     string word{};
                     regex str2("("+mode+"?)");
                     while (ss >> word){
                        regex_search(word, match, str2);
                        if ((word !="verific") & !(match[1].str().length()>0) & (word != "\\"))  {
                           rtl_files.push_back(word);
                           cout<<"FILES: "<<word<<endl;
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
        if(FV_TOOL=="fm"){
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
        else if(FV_TOOL=="onespin"){
            cout<<"Generating TCL for Onespin"<<endl;
            hdlarg.hdl_type = "read_verilog ";
            hdlarg.ref_container = "-golden ";
            hdlarg.hdl_sett = "-pragma_ignore {}  -version sv2012 { \\\n";
            hdlarg.hdl_footer = "}\n";
            write_hdl(fv_script,hdlarg.golden,hdlarg); // Reading Golden Design
            hdlarg.ref_container   = "-revised ";
            write_hdl(fv_script,hdlarg.revised,hdlarg); // Reading Revised Design
        }
        else if(FV_TOOL=="conformal"){
            cerr<<"[ERROR] Cadence Conformal is not part of Yosys synthesis verification"<<endl;
            // throw unkown_tool();
        }
        else{
            cerr<<"[ERROR] Unknown formal tool selected for verification"<<endl;
            // throw unkown_tool();
        }
    }
    else if (regex_match (hdlarg.golden[0], regex("(.*.vhd)") ) | regex_match (hdlarg.golden[0], regex("(.*.vhdl)") )){
        if(FV_TOOL=="fm"){
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
        else if(FV_TOOL=="onespin"){
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
        else if(FV_TOOL=="conformal"){
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
    
    if (FV_TOOL=="fm")
        fv_script<<"\nmatch\n";
    else if (FV_TOOL=="onespin"){
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

void compare(std::ofstream& fv_script,struct hdl_args hdlarg){

    if (FV_TOOL=="fm"){
        fv_script<<"\nverify\nexit\n"; 
    }
    else if (FV_TOOL=="onespin"){
        fv_script<<"set_limit -command_real_time 3600\n compare\n"; 
        fv_script<<"\n\nsave_result_file "<<hdlarg.top<<"_"<<hdlarg.stage<<"_results.log\nexit -force";
    }
 
}

void gen_tcl(struct hdl_args hdlarg, std::string *tclout_path){
    std::ofstream fv_script;
    cout<<"TCL Path: "<<*tclout_path<<endl;
    struct fm_setting fm_set;
    fm_set.name_matching = true;
    fv_script.open(*tclout_path,ios::app);
    tool_settings(fv_script);
    hdl_proccessing(fv_script,hdlarg);
    if (FV_TOOL == "fm"){
        fm_design_setup(fv_script,fm_set);
    }
    else if (FV_TOOL=="onespin"){
        elaboration(fv_script,hdlarg);
        compile(fv_script);
    }
    mapping(fv_script, false);
    compare(fv_script,hdlarg);
    fv_script.close();
}

string exec_pipe(struct hdl_args hdlarg,string stage,string synth_dir_) {
    string result = "";
    bool onespin_lic_fail=false;
    bool fm_lic_fail=false;

    int lic_o=onespin_lic;
    int lic_f=formality_lic;
    string tclout_path_fm = "";
    string tclout_path_onespin = "";
    // if (FV_TOOL=="fm"){
    FV_TOOL="onespin";
    tclout_path_onespin = synth_dir_+stage+"_onespin.tcl";
    gen_tcl(hdlarg, &tclout_path_onespin);

    onespin_exe(tclout_path_onespin, stage, onespin_lic_fail);

    if (onespin_lic_fail){
        FV_TOOL="fm";
        tclout_path_fm = synth_dir_+stage+"_fm.tcl";
        gen_tcl(hdlarg, &tclout_path_fm);

        fm_exe(tclout_path_fm,  stage, fm_lic_fail);
    }
    if (fm_lic_fail){
        while (1){
            std::this_thread::sleep_for(std::chrono::seconds(3));
            cout<<"fm_lic "<<formality_lic<<" lic_f: " <<lic_f<<endl;
            if (onespin_lic<lic_o){
                onespin_exe(tclout_path_onespin, stage, onespin_lic_fail);
                cout<<"Break loop inside onespin"<<" Local Lic: "<<lic_o<< " Onespin Lic: "<<onespin_lic<<endl;
                lic_o = onespin_lic;
                break;
            }
            if (formality_lic<lic_f){
                fm_exe(tclout_path_fm,  stage, fm_lic_fail);
                cout<<"Break loop inside Formality"<<" Local Lic: "<<lic_f<< " Formality Lic: "<<formality_lic<<endl;
                lic_f = formality_lic;
                break;
            }

            if (formality_lic == 0 && onespin_lic ==0 && lic_o==0 && lic_f == 0) break;
        }
        
    }
    // }
    cout<<stage<<"License "<<fm_lic_fail<<endl;
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

    hdlarg.stage=*fvargs->stage1;
    if (*fvargs->stage1=="RTL")get_rtl(ys_script,hdlarg.golden);
    else{
        hdlarg.golden.push_back(synth_dir_+*fvargs->stage1+".v");
        hdlarg.golden.push_back(shared_dir+"rapidsilicon/sim_models.v");
    }
    hdlarg.revised.push_back(synth_dir_+*fvargs->stage2+".v");
    hdlarg.revised.push_back(shared_dir+"rapidsilicon/sim_models.v");
    
    // for (auto file: hdlarg.golden)cout<<"File Golden: "<<file<<endl;
    // for (auto file: hdlarg.revised)cout<<"File Revised: "<<file<<endl;
    istringstream ss(*fvargs->top_module);
    string word{};
    string top_mod{};
    while (ss>>word){
        top_mod=word;
    }
    hdlarg.top = top_mod;

    // cout<<"Top Module: "<<hdlarg.top<<endl;
    // cout<<"Stage1: "<<*fvargs->stage1<<endl<<"Stage2: "<<*fvargs->stage2<<endl;
    // cout<<"Synthesis Directory: "<<synth_dir_<<endl;
    // cout<<"Shared Directory: "<<shared_dir<<endl;
    
    mtx.unlock();

    string result = exec_pipe(hdlarg,*fvargs->stage2,synth_dir_);

    pthread_exit(NULL);
    return NULL;
}
