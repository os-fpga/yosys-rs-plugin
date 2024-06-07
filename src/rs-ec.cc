// Copyright (C) 2022 RapidSilicon
//

#include "kernel/yosys.h"
#include "kernel/modtools.h"
#include "kernel/ffinit.h"
#include "kernel/ff.h"
#include <filesystem>

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN
namespace fs = std::filesystem;
#define MODE_BITS_OUTPUT_SELECT_WIDTH 3
#define GENESIS_3_DIR genesis3
#define XSTR(val) #val
#define STR(val) XSTR(val)
#define GET_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)
#define GET_FILE_PATH_SEC_MODEL(tech_dir,file) "/rapidsilicon/" STR(tech_dir) "/" STR(file)
#define SEC_SIM_CELLS SEC_MODELS/simcells.v
#define SEC_SIM_LIB SEC_MODELS/simlib.v
#define SEC_DFFRE_blif SEC_MODELS/DFFRE.blif

bool is_genesis3;
bool isSequential =false;
string current_stage;
string previous_state = "";
int sec_counter = 0;
string  mod_name = "";
int gen_net = 0;
dict<RTLIL::IdString, RTLIL::IdString> sbckt_name;
std::set<RTLIL::IdString> cell_mod_name;
struct RsSECWorker
{
    RTLIL::Module *m_module;
    SigMap m_sigmap;
    // string, int, int, int, bool
    FfInitVals m_initvals;
    RsSECWorker(RTLIL::Module *module) :
        m_module(module), m_sigmap(module), m_initvals(&m_sigmap, module) {}

    
    struct Entry {
        std::string type;
        RTLIL::IdString name;
        int inA;
        int inB;
        int outY;
        bool signed_opr;
        int inS;

        // Overload == operator to compare two Entry objects
        bool operator==(const Entry& other) const {
            return type == other.type && name == other.name && inA == other.inA && inB == other.inB && outY == other.outY && signed_opr == other.signed_opr && inS == other.inS;
        }
    };
    
    struct Entry_ff_sync {
        RTLIL::IdString type;
        RTLIL::IdString name;
        int inCLK;
        int inEN;
        int inSET;
        int inCLR;
        int inD;
        int outQ;
        int clk_polarity;
        int srst_polarity;
        int srst_value;
        // Overload == operator to compare two Entry objects
        bool operator==(const Entry_ff_sync& other) const {
            return type == other.type && name == other.name && inCLK == other.inCLK && inEN == other.inEN && inSET == other.inSET && \
            inCLR == other.inCLR && inD == other.inD && outQ == other.outQ && clk_polarity == other.clk_polarity &&\
            srst_polarity == other.srst_polarity && srst_value == other.srst_value;
        }
        
    };
    
    struct CompareEntry {
        bool operator()(const Entry& a, const Entry& b) const {
            if (a.type != b.type) return a.type < b.type;
            if (a.name != b.name) return a.name < b.name;
            if (a.inA != b.inA) return a.inA < b.inA;
            if (a.inB != b.inB) return a.inB < b.inB;
            if (a.outY != b.outY) return a.outY < b.outY;
            return a.signed_opr < b.signed_opr;
            if (a.inS != b.inS) return a.inS < b.inS;
        }
    };
    
    struct CompareEntry_ff_sync {
        bool operator()(const Entry_ff_sync& a, const Entry_ff_sync& b) const {
            if (a.type != b.type) return a.type < b.type;
            if (a.name != b.name) return a.name < b.name;
            if (a.inEN != b.inEN) return a.inEN < b.inEN;
            if (a.inSET != b.inSET) return a.inSET < b.inSET;
            if (a.inCLR != b.inCLR) return a.inCLR < b.inCLR;
            if (a.inD != b.inD) return a.inD < b.inD;
            if (a.outQ != b.outQ) return a.outQ < b.outQ;
            if (a.clk_polarity != b.clk_polarity) return a.clk_polarity < b.clk_polarity ;
            if (a.srst_polarity != b.srst_polarity) return a.srst_polarity < b.srst_polarity;
            if (a.srst_value != b.srst_value) return a.srst_value < b.srst_value;
            return a.inCLK < b.inCLK;
        }
    };
    
    void addEntry(std::vector<Entry>& entries, std::set<Entry, CompareEntry>& uniqueSet, const Entry& entry) {
        if (uniqueSet.find(entry) == uniqueSet.end()) {
            uniqueSet.insert(entry);
            entries.push_back(entry);
        }
    }
    
    void addEntry_ff_sync(std::vector<Entry_ff_sync>& entries, std::set<Entry_ff_sync, CompareEntry_ff_sync>& uniqueSet, const Entry_ff_sync& entry) {
        if (uniqueSet.find(entry) == uniqueSet.end()) {
            uniqueSet.insert(entry);
            entries.push_back(entry);
        }
    }
    
    void add_ff_sync (RTLIL::Design *design, const std::vector<Entry_ff_sync>& entries){
        for (auto entry : entries){
            if (entry.type.in(ID($ff), ID($dff), ID($dffe), ID($dffsr),ID($dffsre),ID($_DFF_P_),ID($_DFF_N_),ID($dff))){
                std::string cell_type_str = entry.type.str();
                RTLIL::IdString  mod_name = cell_type_str + "_" + std::to_string(entry.inCLK) + "_" + std::to_string(entry.inEN) + "_" + std::to_string(entry.inD)+"_"+std::to_string(entry.outQ);
                sbckt_name[entry.name] = mod_name;
                if (cell_mod_name.find(mod_name) != cell_mod_name.end()) {
                    continue;
                }
                design->addModule(mod_name);
                cell_mod_name.insert(mod_name);
                for (auto &module : design->selected_modules()) {
                    if (module->name == mod_name && entry.type== ID($dff)){
                        SigSpec CLK;
                        SigSpec D; 
                        SigSpec Q;  

                        CLK = module->addWire(RTLIL::escape_id("CLK"), entry.inCLK);
                        D   = module->addWire(RTLIL::escape_id("D"), entry.inD);
                        Q   = module->addWire(RTLIL::escape_id("Q"), entry.outQ);
                        for (auto wire : module->wires()){
                            if (wire->name == "\\CLK") {
                                wire->port_input = true;
                                wire->port_id=1;
                            }
                            if (wire->name == "\\D") {
                                wire->port_input = true;
                                wire->port_id=2;
                            }
                            if (wire->name == "\\Q") {
                                wire->port_output = true;
                                    wire->port_id=3;
                            }
                        }
                        module->ports.push_back(RTLIL::escape_id("CLK"));
                        module->ports.push_back(RTLIL::escape_id("D"));
                        module->ports.push_back(RTLIL::escape_id("Q"));
                        if (entry.type == "$dff")
                            module->addDff(mod_name, CLK, D, Q,true);
                    }
                    else if (module->name == mod_name && entry.type== ID($sdff)){
                        SigSpec CLK;
                        SigSpec SRST;
                        SigSpec D; 
                        SigSpec Q;  
                        bool clk_polarity= entry.clk_polarity;
                        bool srst_polarity = entry.srst_polarity;
                        CLK = module->addWire(RTLIL::escape_id("CLK"), entry.inCLK);
                        SRST = module->addWire(RTLIL::escape_id("SRST"), entry.inCLR);
                        D   = module->addWire(RTLIL::escape_id("D"), entry.inD);
                        Q   = module->addWire(RTLIL::escape_id("Q"), entry.outQ);
                        for (auto wire : module->wires()){
                            if (wire->name == "\\CLK") {
                                wire->port_input = true;
                                wire->port_id=1;
                            }
                            if (wire->name == "\\SRST") {
                                wire->port_input = true;
                                wire->port_id=2;
                            }
                            if (wire->name == "\\D") {
                                wire->port_input = true;
                                wire->port_id=3;
                            }

                            if (wire->name == "\\Q") {
                                wire->port_output = true;
                                    wire->port_id=4;
                            }
                        }
                        module->ports.push_back(RTLIL::escape_id("CLK"));
                        module->ports.push_back(RTLIL::escape_id("SRST"));
                        module->ports.push_back(RTLIL::escape_id("D"));
                        module->ports.push_back(RTLIL::escape_id("Q"));
                        module->addSdff(mod_name, CLK, SRST, D, Q,entry.srst_value,clk_polarity,srst_polarity);
                    }
                    else if (module->name == mod_name && (entry.type== ID($_DFF_P_) || entry.type== ID($_DFF_N_))){
                        SigSpec C;
                        SigSpec D; 
                        SigSpec Q;  

                        C = module->addWire(RTLIL::escape_id("C"), entry.inCLK);
                        D   = module->addWire(RTLIL::escape_id("D"), entry.inD);
                        Q   = module->addWire(RTLIL::escape_id("Q"), entry.outQ);
                        for (auto wire : module->wires()){
                            if (wire->name == "\\C") {
                                wire->port_input = true;
                                wire->port_id=1;
                            }
                            if (wire->name == "\\D") {
                                wire->port_input = true;
                                wire->port_id=2;
                            }
                            if (wire->name == "\\Q") {
                                wire->port_output = true;
                                    wire->port_id=3;
                            }
                        }
                        module->ports.push_back(RTLIL::escape_id("C"));
                        module->ports.push_back(RTLIL::escape_id("D"));
                        module->ports.push_back(RTLIL::escape_id("Q"));
                        if (entry.type == "$_DFF_P_")
                            module->addDffGate(mod_name, C, D, Q,true);
                        else
                            module->addDffGate(mod_name, C, D, Q,false);
                    }
                }
                Pass::call(design, stringf("hierarchy -top %s",mod_name.c_str()));

                Pass::call(design, "proc");
                Pass::call(design, "flatten");
                Pass::call(design, "opt_expr");
                Pass::call(design, "techmap");
                Pass::call(design, "opt_clean");
                Pass::call(design, stringf("write_blif %s.blif",mod_name.c_str()));
            }
        }
    }
    
    void add_A_B_Y_S (RTLIL::Design *design, const std::vector<Entry>& entries){
        for (auto entry : entries){
            RTLIL::IdString  mod_name =  entry.type+ "_" + std::to_string(entry.inA) + "_" + std::to_string(entry.inB) + "_" + std::to_string(entry.outY)+"_"+std::to_string(entry.inS);
            sbckt_name[entry.name] = mod_name;
            if (cell_mod_name.find(mod_name) != cell_mod_name.end()) {
                continue;
            }

            design->addModule(mod_name);
            
            cell_mod_name.insert(mod_name);
            for (auto &module : design->selected_modules()) {
                if (module->name == mod_name){
                    SigSpec A;
                    SigSpec B; 
                    SigSpec Y; 
                    SigSpec S; 


                    A = module->addWire(RTLIL::escape_id("A"), entry.inA);
                    if (entry.inB!=0)
                        B =  module->addWire(RTLIL::escape_id("B"), entry.inB);
                    else if (entry.inB ==0 && entry.type== "$mux"){
                        B =  module->addWire(RTLIL::escape_id("B"), entry.inA);
                    }

                    Y =  module->addWire(RTLIL::escape_id("Y"), entry.outY);
                    if (entry.inS!=0)
                        S =  module->addWire(RTLIL::escape_id("S"), entry.inS);
                    for (auto wire : module->wires()){
                        if (wire->name == "\\A") {
                            wire->port_input = true;
                            wire->port_id=1;
                        }
                        if (wire->name == "\\B") {
                            wire->port_input = true;
                            wire->port_id=2;
                        }
                        if (wire->name == "\\Y") {
                            wire->port_output = true;
                            if (entry.inB != 0)
                                wire->port_id=3;
                            else if(entry.inB == 0 && entry.type == "$mux")
                                wire->port_id=3;
                            else
                                wire->port_id=2;
                        }
                        if (wire->name == "\\S") {
                            wire->port_input = true;
                            wire->port_id=4;
                        }
                    }
                    module->ports.push_back(RTLIL::escape_id("A"));
                    if (entry.inB != 0)
                        module->ports.push_back(RTLIL::escape_id("B"));
                    else if(entry.inB == 0 && entry.type == "$mux")
                        module->ports.push_back(RTLIL::escape_id("B"));

                    module->ports.push_back(RTLIL::escape_id("Y"));
                    if (entry.inS != 0)
                        module->ports.push_back(RTLIL::escape_id("S"));

                    if (entry.type == "$add")
                        module->addAdd(mod_name, A, B, Y, false);
                    else if (entry.type == "$reduce_xor")
                        module->addReduceXor(mod_name, A, Y, false);
                    else if (entry.type == "$not")
                        module->addNot(mod_name, A, Y, false);
                    else if (entry.type == "$xor")
                        module->addXor(mod_name, A, B, Y, false);
                    else if (entry.type == "$and")
                        module->addAnd(mod_name, A, B, Y, false);
                    else if (entry.type == "$or")
                        module->addOr(mod_name, A, B, Y, false);
                    else if (entry.type == "$mux")
                        module->addMux(mod_name, A, B, S, Y);
                    else if (entry.type == "$shr")
                        module->addShr(mod_name, A, B, Y,false);
                }
            }
            Pass::call(design, stringf("hierarchy -top %s",mod_name.c_str()));

            Pass::call(design, "proc");
            Pass::call(design, "flatten");
            Pass::call(design, "opt_expr");
            Pass::call(design, "techmap");
            Pass::call(design, "opt_clean");
            
            Pass::call(design, stringf("write_blif %s.blif",mod_name.c_str()));
        }
    }

    void edit_design(RTLIL::Design *design, std::set<RTLIL::IdString>& blif_models){
        if (!gen_net)
            Pass::call(design, "design -save original");
        Pass::call(design,"opt_clean");
        
        for(auto& modules : design->selected_modules()){
            for (auto &cell : modules->selected_cells()) {
                for (auto name_mod : sbckt_name){
                    if (cell->name != name_mod.first) continue;

                    if (cell->type.in(ID($add),ID($xor),ID($and),ID($or),ID($shr),ID($reduce_xor),ID($not),ID($mux),ID($dff),ID($sdff),ID($_DFF_P_),ID($_DFF_N_))){
                        blif_models.insert(name_mod.second);
                        cell->type = name_mod.second;
                    }
                    if (cell->type == RTLIL::escape_id("\\DFFRE")){ 
                        blif_models.insert(cell->type);
                    }
                }
            }
        }
    }

    void create_blif_models(RTLIL::Design *design, std::set<RTLIL::IdString>& blif_models){
        char current_netlist_name[528];
        sprintf(current_netlist_name, "%03d_%s", sec_counter, current_stage.c_str());
        Pass::call(design, stringf("write_blif %s.blif",current_netlist_name));

        std::filesystem::path currentPath = std::filesystem::current_path();
        std::string currentPathStr = currentPath.string();
        string model_file_name,netlist_name;

        for (auto blif_model : blif_models){

            if(blif_model == RTLIL::escape_id("DFFRE")){
                std::string model_file_name = GET_FILE_PATH_SEC_MODEL(GENESIS_3_DIR, SEC_DFFRE_blif);
                string plugin_dir = proc_self_dirname() + "../share/yosys/";
                model_file_name = plugin_dir + model_file_name;
                std::ifstream inputFile(model_file_name);
                if (!inputFile.is_open()) 
                    log_error("Failed to open the input file %s\n",model_file_name.c_str());

                netlist_name = currentPathStr + "/" + current_netlist_name + ".blif";
                std::ofstream outputFile(netlist_name, std::ios::app);
                if (!outputFile.is_open()) 
                    log_error("Failed to open the output file %s\n",netlist_name.c_str());
            
                std::string line;
                while (std::getline(inputFile, line)) {
                    outputFile << line << std::endl;
                }

                inputFile.close();
                outputFile.close();

            }else {
                model_file_name = currentPathStr + "/" + log_id(blif_model) +".blif";
            
                std::ifstream inputFile(model_file_name);
                if (!inputFile.is_open()) 
                    log_error("Failed to open the input file %s\n",model_file_name.c_str());

                netlist_name = currentPathStr + "/" + current_netlist_name + ".blif";
                std::ofstream outputFile(netlist_name, std::ios::app);
                if (!outputFile.is_open()) 
                    log_error("Failed to open the output file %s\n",netlist_name.c_str());
            
                std::string line;
                while (std::getline(inputFile, line)) {
                    outputFile << line << std::endl;
                }

                std::filesystem::remove(model_file_name);
                inputFile.close();
                outputFile.close();
            }
                
        }
    }

    bool design_has_clk(RTLIL::Design *design) {

       for (auto cell : design->top_module()->cells()) {

           if (cell->type == RTLIL::escape_id("$dff")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("$dffe")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("$sdff")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("$sdffe")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("$adff")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("$adffe")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("RS_TDP36K")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("DFFRE")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("DFFRE1")) {
              return true;
           }
           if (cell->type == RTLIL::escape_id("DSP38")) {
              for (auto &conn : cell->connections()) {

                  IdString portName = conn.first;
                  RTLIL::SigSpec actual = conn.second;

                  if (portName == RTLIL::escape_id("CLK")) {
                     return true;
                  }
              }
           }

           RTLIL::IdString cellType = cell->type;
           const char* cName = cellType.c_str();
           string cellName = std::string(cName);

           if ((cellName.length() >= 5) &&
               (cellName.substr(0, 5) == "$_DFF")) { 
              return true;
           }

           if ((cellName.length() >= 6) &&
               (cellName.substr(0, 6) == "$_SDFF")) {  
              return true;
           }
       }

       return false;
    }

    void run_sec(bool Sequential){
        
        char current_netlist_name[528];
        char previous_netlist_name[528];
        char resName[528];
        sprintf(current_netlist_name, "%03d_%s.blif", sec_counter, current_stage.c_str());
        sprintf(previous_netlist_name, "%03d_%s.blif", (sec_counter-1), previous_state.c_str());
        sprintf(resName, "%03d_%s.res", (sec_counter), current_stage.c_str());
        string cmd;
        string abc_script = "abc.scr";
        if (Sequential){
            cmd = std::string("dsec ") + current_netlist_name + std::string(" ") +  previous_netlist_name +std::string("; quit;");
        }
        else{
            cmd = std::string("cec ") + current_netlist_name + std::string(" ") + previous_netlist_name +std::string("; quit;");
        }
        std::ofstream out(abc_script);
        if (out.is_open()){
            out<<cmd;
            out.close();
        }
        log("Comparing : \n\n");
        log("  %s <-> %s (%s)\n", previous_netlist_name, current_netlist_name,resName);
        log("\n=================================================================================\n");
        string abc_exe_dir = proc_self_dirname() + "abc";
        std::string command = abc_exe_dir + std::string(" -f abc.scr > ") + resName;
        command += std::string(" ; tail -n 2 ") + resName;
        
        if (Sequential) {
            log("DSEC : \n");
        } else {
            log("CEC : \n");
        }

        int fail = system(command.c_str());

        if (fail) {
            log_error("Command %s failed !\n", command.c_str());
        }
        log("\n=================================================================================\n");
    }

    void gen_netlist(RTLIL::Design *design){
        std::string simcells = GET_FILE_PATH(GENESIS_3_DIR, SEC_SIM_CELLS);
        std::string simlib = GET_FILE_PATH(GENESIS_3_DIR, SEC_SIM_LIB);
        
        Module* topModule = design->top_module();

        const char* topName = topModule->name.c_str();
        topName++;

        Pass::call(design, "write_verilog -selected -noexpr -nodec design.v");
        Pass::call(design, "design -reset");
        
        Pass::call(design, stringf("read_verilog -sv %s", simcells.c_str()));
        Pass::call(design, stringf("read_verilog -sv %s", simlib.c_str()));
        Pass::call(design, "read_verilog design.v");
        
        Pass::call(design, stringf("hierarchy -top %s",topName));
        Pass::call(design, "flatten");
        Pass::call(design, stringf("hierarchy -top %s",topName));

        Pass::call(design, "proc");
        Pass::call(design, "opt_expr");

        Pass::call(design, "opt_clean -purge");
        Pass::call(design, "design -save new_design");
    }

    void run_scr (RTLIL::Design *design) {
        cell_mod_name.clear();
        isSequential = design_has_clk(design);
        Pass::call(design, "design -save original");
        if (gen_net)
            gen_netlist(design);

        std::vector<Entry> entries;
        std::set<Entry, CompareEntry> uniqueSet;

        std::vector<Entry_ff_sync> entries_ff;
        std::set<Entry_ff_sync, CompareEntry_ff_sync> uniqueSet_ff;
        
        for (auto cell : design->top_module()->cells()) {
            if (cell->type.in(ID($add), ID($sub), ID($div), ID($mod), ID($divfloor), ID($modfloor), ID($pow), ID($mul),\
                ID($xor),ID($or),ID($or),ID($and),ID($nor),ID($nand))){
                addEntry(entries,uniqueSet,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::A)),GetSize(cell->getPort(ID::B)),GetSize(cell->getPort(ID::Y)),false,0});
            }
            if (cell->type.in(ID($reduce_xor),ID($not), ID($logic_not))){
                addEntry(entries,uniqueSet,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::A)), 0, GetSize(cell->getPort(ID::Y)), false,0});
            }
            if (cell->type.in(ID($mux))){
                addEntry(entries,uniqueSet,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::A)), GetSize(cell->getPort(ID::B)), GetSize(cell->getPort(ID::Y)), false, GetSize(cell->getPort(ID::S))});
            }
            if (cell->type.in(ID($shl), ID($shr), ID($sshl), ID($sshr))){
                addEntry(entries,uniqueSet,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::A)),GetSize(cell->getPort(ID::B)),GetSize(cell->getPort(ID::Y)),false,0});
            }
            if (cell->type.in(ID($dff))){
                addEntry_ff_sync(entries_ff,uniqueSet_ff,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::CLK)), 0, 0, 0,GetSize(cell->getPort(ID::D)), GetSize(cell->getPort(ID::Q)), false,false,0});
            }
            if (cell->type.in(ID($_DFF_P_),ID($_DFF_N_))){
                addEntry_ff_sync(entries_ff,uniqueSet_ff,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::C)), 0, 0, 0,GetSize(cell->getPort(ID::D)), GetSize(cell->getPort(ID::Q)),false, false, 0});
            }
            if (cell->type.in(ID($sdff))){
                addEntry_ff_sync(entries_ff,uniqueSet_ff,{log_id(cell->type), cell->name, GetSize(cell->getPort(ID::CLK)), 0, 0, GetSize(cell->getPort(ID::SRST)),GetSize(cell->getPort(ID::D)), GetSize(cell->getPort(ID::Q)),cell->getParam(ID::CLK_POLARITY).as_int(),cell->getParam(ID::SRST_POLARITY).as_int(),cell->getParam(ID::SRST_VALUE).as_int()});
            }
        }
        add_ff_sync(design,entries_ff);
       
        add_A_B_Y_S(design,entries);
    #if 1
        // Load previous step to show the 'stat'
        //
        if (sec_counter>1){
            Pass::call(design,"design -load previous");

          log("\n =======================\n");
          log("     Previous step:\n");
          log(" =======================\n");

        Pass::call(design,"stat");
        }
    #endif  

        if (gen_net){
            log(" =======================\n");
            log("     Current step:\n");
            log(" =======================\n");
            Pass::call(design, "design -load new_design");
            Pass::call(design,"stat");
        }
        else{
            log(" =======================\n");
            log("     Current step:\n");
            log(" =======================\n");
            Pass::call(design, "design -load original");
            Pass::call(design,"stat");
        }
        std::set<RTLIL::IdString> blif_models;

        // edit netlist subckt names according to cell (name, size)
        edit_design(design, blif_models);

        // append current netlist with subckt models
        create_blif_models(design, blif_models);
        
        if (current_stage != "" && previous_state != "")
            run_sec(isSequential);
        
        Pass::call(design, "design -load original");
        Pass::call(design,"design -save previous");
        previous_state = current_stage;
        #if 0
            getchar();
        #endif
    }
};

struct RsSecPass : public Pass {
    RsSecPass() : Pass("rs-sec", "run sequential equivalence check for netlist") { }
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    SEC [selection]\n");
        log("\n");
        log("    This pass verifies netlist(n) agaist netlist(n-1)\n");
        log("\n");
    }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *design) override
    {
        log_header(design, "Executing RS Equivalence Check.\n");
        size_t argidx;
        int verify = 0;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            if (a_Args[argidx] == "-genesis3")
                is_genesis3 = true;
            if (a_Args[argidx] == "-stage")
                current_stage = a_Args[++argidx];
            if (a_Args[argidx] == "-verify")
                verify = -stoi(a_Args[++argidx]);
            if (a_Args[argidx] == "-gen_net")
                gen_net = -stoi(a_Args[++argidx]);
           
        }
        
        extra_args(a_Args, argidx, design);
        
        sec_counter++;
        if (!verify)
            return;
            
        for (auto mod : design->selected_modules()) {
            RsSECWorker worker(mod);
            worker.run_scr(design);
        }
    }
} RsSecPass;

PRIVATE_NAMESPACE_END
