/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */
#include "kernel/celltypes.h"
#include "backends/rtlil/rtlil_backend.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/yosys.h"
#include "kernel/mem.h"
#include "kernel/ffinit.h"
#include "kernel/ff.h"
#include "include/abc.h"
#include <iostream>
#include <fstream>
#include <regex>
#include <string>

#ifdef PRODUCTION_BUILD
#include "License_manager.hpp"
#endif

int DSP_COUNTER;
USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define XSTR(val) #val
#define STR(val) XSTR(val)

#ifndef PASS_NAME
#define PASS_NAME synth_rs
#endif

#define GENESIS_DIR genesis
#define GENESIS_2_DIR genesis2
#define GENESIS_3_DIR genesis3
#define SEC_MODELS_DIR sec_models
#define COMMON_DIR common
#define SIM_LIB_FILE cells_sim.v
#define BLACKBOX_SIM_LIB_FILE cell_sim_blackbox.v
#define SIM_LIB_CARRY_FILE CARRY.v
#define LLATCHES_SIM_FILE llatches_sim.v
#define DSP_SIM_LIB_FILE dsp_sim.v
#define BRAMS_SIM_LIB_FILE brams_sim.v
#define BRAMS_SIM_NEW_LIB_FILE1 bram_map_rs.v
#define BRAMS_SIM_NEW_LIB_FILE2 TDP_RAM36K.v
#define FFS_MAP_FILE ffs_map.v
#define DFFRE_SIM_FILE DFFRE.v
#define DFFNRE_SIM_FILE DFFNRE.v
#define LUT1_SIM_FILE LUT1.v
#define LUT2_SIM_FILE LUT2.v
#define LUT3_SIM_FILE LUT3.v
#define LUT4_SIM_FILE LUT4.v
#define LUT5_SIM_FILE LUT5.v
#define LUT6_SIM_FILE LUT6.v

#define SEC_SIM_CELLS SEC_MODELS/simcells.v
#define SEC_SIM_LIB SEC_MODELS/simlib.v
#define SEC_GENESIS3 SEC_MODELS/genesis3.v
#define SEC_DSP_MAP SEC_MODELS/dsp_map.v
#define SEC_DSP_FINAL_MAP SEC_MODELS/dsp_final_map.v
#define SEC_MODELS_BLIF SEC_MODELS/models.blif

#define CLK_BUF_SIM_FILE CLK_BUF.v
#define I_BUF_SIM_FILE I_BUF.v
#define O_BUF_SIM_FILE O_BUF.v
#define LUT_FINAL_MAP_FILE lut_map.v
#define DSP_38_MAP_FILE dsp38_map.v
#define DSP_38_SIM_FILE DSP38.v
#define DSP19X2_MAP_FILE dsp19x2_map.v
#define DSP19X2_SIM_FILE DSP19X2.v
#define ARITH_MAP_FILE arith_map.v
#define DSP_MAP_FILE dsp_map.v
#define DSP_FINAL_MAP_FILE dsp_final_map.v
#define ALL_ARITH_MAP_FILE all_arith_map.v
#define BRAM_TXT brams.txt
#define BRAM_LIB brams_new.txt
#define BRAM_LIB_SWAP brams_new_swap.txt
#define BRAM_ASYNC_TXT brams_async.txt
#define BRAM_MAP_NEW_VERSION_FILE brams_map_new_version.v // New version techmap files for TDP36K
#define BRAM_FINAL_MAP_NEW_VERSION_FILE brams_final_map_new_version.v // New version techmap files for TDP36K
#define BRAM_MAP_FILE brams_map.v
#define BRAM_MAP_NEW_FILE brams_map_new.v
#define BRAM_FINAL_MAP_FILE brams_final_map.v
#define BRAM_FINAL_MAP_NEW_FILE brams_final_map_new.v
#define IO_cells_FILE io_cells_map1.v
#define IO_CELLs_final_map io_cell_final_map.v
#define GET_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)
#define GET_FILE_PATH_RS_FPGA_SIM(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/FPGA_PRIMITIVES_MODELS/sim_models/verilog/" STR(file)
#define GET_FILE_PATH_RS_FPGA_SIM_BLACKBOX(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/FPGA_PRIMITIVES_MODELS/blackbox_models/" STR(file)
#define GET_TECHMAP_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)
#define BRAM_WIDTH_36 36
#define BRAM_WIDTH_18 18
#define BRAM_WIDTH_9 9
#define BRAM_WIDTH_4 4
#define BRAM_WIDTH_2 2
#define BRAM_WIDTH_1 1

#define DSP_MIN_WIDTH_A 4
#define DSP_MIN_WIDTH_B 4

#define BRAM_first_byte_parity_bit 8
#define BRAM_second_byte_parity_bit 17
#define BRAM_third_byte_parity_bit 26
#define BRAM_fourth_byte_parity_bit 35
#define BRAM_data_bits 32
#define BRAM_MAX_ADDRESS_FOR_36_WIDTH 1024
#define BRAM_MAX_ADDRESS_FOR_18_WIDTH 2048

#define VERSION_MAJOR 0 // 0 - beta 
// 0 - initial version 
// 1 - dff inference 
// 2 - carry inference
// 3 - dsp inference
// 4 - bram inference
#define VERSION_MINOR 4
#define VERSION_PATCH 218

enum Strategy {
    AREA,
    DELAY,
    MIXED
};

enum EffortLevel {
    HIGH,
    MEDIUM,
    LOW
};

enum Technologies {
    GENERIC,   
    GENESIS,
    GENESIS_2,
    GENESIS_3
};

enum CarryMode {
    AUTO,
    ALL,
    NO
};

enum Encoding {
    BINARY,
    ONEHOT
};

enum ClockEnableStrategy {
    EARLY,
    LATE
};

struct SynthRapidSiliconPass : public ScriptPass {

    SynthRapidSiliconPass() : ScriptPass(STR(PASS_NAME), "Synthesis for RapidSilicon FPGAs") {}

    void help() override
    {
        log("\n");
        log("   %s [options]\n", STR(PASS_NAME));
        log("This command runs synthesis for RapidSilicon FPGAs\n");
        log("\n");
        log("    -top <module>\n");
        log("        Use the specified module as top module\n");
        log("\n");
        log("    -tech <technology>\n");
        log("        Run synthesis for the specified RapidSilicon architecture and \n");
        log("        generate the synthesis netlist for the specified technology.\n");
        log("        Supported values:\n");
        log("        - generic  : generic\n");
        log("        - genesis  : Gemini target architecture.\n");
        log("        - genesis2 : Gemini_2 target architecture.\n");
        log("        - genesis3 : Gemini_3 target architecture.\n");
        log("        By default 'generic' technology is used.\n");
        log("\n");
        log("    -blif <file>\n");
        log("        Write the design to the specified BLIF file. writing of an output file\n");
        log("        is omitted if this parameter is not specified.\n");
        log("\n");
        log("    -verilog <file>\n");
        log("        Write the design to the specified verilog file. writing of an output file\n");
        log("        is omitted if this parameter is not specified.\n");
        log("\n");
        log("    -vhdl <file>\n");
        log("        Write the design to the specified VHDL file.\n");
        log("\n");
        log("    -goal <strategy>\n");
        log("        Run synthesis and generate netlist with the specified strategy\n");
        log("        Supported values:\n");
        log("        - area  : minimize resource utilization\n");
        log("        - delay : expect better Frequencies in general without respect to\n");
        log("                  specific clock domains\n");
        log("        - mixed : good compromise between 'area' and 'delay'\n");
        log("        By default 'mixed' strategy is used.\n");
        log("\n");
        log("    -effort <level>\n");
        log("        Run synthesis with specified optimization level\n");
        log("        Supported values:\n");
        log("        - high   : high\n");
        log("        - medium : medium\n");
        log("        - low    : low\n");
        log("        By default 'high' level is used.\n");
        log("\n");
        log("    -fast\n");
        log("        Used to speed up synthesis flow\n");
        log("        Disabled by default.\n");
        log("\n");
        log("    -no_sat\n");
        log("        Disable SAT solver.\n");
        log("\n");
        log("    -no_flatten\n");
        log("        Do not flatten design to preserve hierarchy.\n");
        log("        Disabled, design is flattened by default.\n");
        log("\n");
        log("    -no_iobuf\n");
        log("        Do not adds IO and CLK Buffers.\n");
        log("        Disabled, IO-Buffers are added by default.\n");
        log("\n");
        log("    -preserve_ip\n");
        log("        It preserves the encrypted IP instance during synthesis.\n");
        log("        Disabled, do not preserve the encrypted IP instance by default.\n");
        log("\n");
        log("    -de\n");
        log("        Use Design Explorer for logic optimiztion and LUT mapping.\n");
        log("        Disabled by default.\n");
        log("\n");
        log("    -de_max_threads <value>\n");
        log("        Maximum number of threads in DE.\n");
        log("        Supported values: 2 to 64.\n");
        log("        By default '-1' (automatic)\n");
        log("\n");
#ifdef DEV_BUILD
        log("    -abc <script>\n");
        log("        Use a specific ABC script instead of the embedded one.\n");
        log("\n");
#endif
        log("    -cec\n");
        log("        Use internal equivalence checking (ABC based) during optimization\n");
        log("        and dump Verilog after key phases.\n");
        log("        Disabled by default.\n");
        log("\n");
        log("    -sec\n");
        log("        Call sequential ABC formal verification flow using 'dsec'.\n");
        log("        Disabled by default.\n");
        log("\n");
        log("    -carry <sub-mode>\n");
        log("        Infer Carry cells when possible.\n");
        log("        Supported values:\n");
        log("        - all      : Infer all the carries.\n");
        log("        - auto     : Infer carries based on internal heuristics.\n");
        log("        - no       : Do not infer any carries.\n");
        log("        By default 'auto' mode is used.\n");
        log("\n");
        log("    -max_carry_length <num>\n");
        log("        Specify the maximum length of carry chain.\n");
        log("        Specify a value >= 1, which should not\n");
        log("        exceed the available carry lenght on the target device. \n");
        log("        The flag should be used with -max_device_carry_length. \n");
        log("        By default synthesis tool will not limit carry chain length. \n");
        log("\n");
        log("    -max_device_carry_length <num>\n");
        log("        Specify the number of available carry resources for the target device.\n");
        log("\n");
#ifdef DEV_BUILD
        log("    -sdffr\n");
        log("        Infer synchroneous set/reset DFFs when possible.\n");
        log("        By default synchroneous set/reset DFFs are not infered.\n");
        log("\n");
        log("    -max_lut <num>\n");
        log("        Specify the max number of LUTs allowed in the final synthesized netlist. \n");
        log("        Synthesized netlist will be produced but synthesis will error out right after\n");
        log("        if netlist LUTs number exceeds -max_lut value.\n");
        log("        By default synthesis tool will not consider -max_lut if not specified. \n");
        log("\n");
        log("    -max_reg <num>\n");
        log("        Specify the max number of DFFs allowed in the final synthesized netlist. \n");
        log("        Synthesized netlist will be produced but synthesis will error out right after\n");
        log("        if netlist DFFs number exceeds -max_reg value.\n");
        log("        By default synthesis tool will not consider -max_reg if not specified. \n");
        log("\n");
#endif
        log("    -no_dsp\n");
        log("        By default use DSP blocks in output netlist.\n");
        log("        Do not use DSP blocks to implement multipliers and associated logic\n");
        log("\n");
        log("    -max_device_dsp <num>\n");
        log("        Specify the number of available DSP resources for the target device.\n");
        log("\n");
        log("    -max_dsp <num>\n");
        log("        Specify the maximum number of DSP to add\n");
        log("        to the design during synthesis. Specify a value >= 1, which should not\n");
        log("        exceed the available DSP count on the target device. \n");
        log("        The flag should be used with -max_device_dsp. \n");
        log("        By default synthesis tool will not limit DSP count. \n");
        log("\n");
#ifdef DEV_BUILD
        log("    -use_dsp_cfg_params\n");
        log("        By default use DSP blocks with configuration bits available at module ports.\n");
        log("        Specifying this forces usage of DSP block with configuration bits available as module parameters\n");
        log("\n");
#endif
        log("    -no_bram\n");
        log("        By default use Block RAM in output netlist.\n");
        log("        Specifying this switch turns it off.\n");
        log("\n");
        log("    -max_device_ios <num>\n");
        log("        Specify the number of available package pin resources for the target device.\n");
        log("\n");
        log("    -max_device_bram <num>\n");
        log("        Specify the number of available Block RAM resources for the targe device.\n");
        log("\n");
        log("    -max_bram <num>\n");
        log("        Specify the maximum number of Block RAM to add\n");
        log("        to the design during synthesis. Specify a value >= 1, which should not\n");
        log("        exceed the available BRAM count on the target device. \n");
        log("        The flag should be used with -max_device_bram. \n");
        log("        By default synthesis tool will not limit Block RAM count. \n");
        log("\n");
        log("    -no_simplify\n");
        log("        By default call simplify.\n");
        log("        Specifying this switch turns it off.\n");
        log("\n");
        log("    -no_libmap\n");
        log("        By default call memory_libmap for Block RAM mapping.\n");
        log("        Specifying this switch turns it to memory_bram.\n");
        log("\n");
        log("    -new_tdp36k\n");
        log("        By default OLD Block RAM mapping will run.\n");
        log("        Specifying this switch turns it to new bram mapping primitives.\n");
        log("\n");
        log("    -new_dsp19x2\n");
        log("        By default new DSP19X2 primitve is off.\n");
        log("        Specifying this switch turns on DSP19X2 primitive mapping.\n");
        log("\n");
        log("    -keep_tribuf\n");
        log("        By default translate TBUF into logic.\n");
        log("        Specify this to keep TBUF primitives.\n");
        log("\n");
        log("    -fsm_encoding <encoding>\n");
        log("        Supported values:\n");
        log("        - binary : compact encoding using minimum of registers to cover the N states\n");
        log("                   (n registers such that 2^(n-1) < N < 2^n).\n");
        log("        - onehot : one hot encoding . N registers for N states,\n");
        log("                   each register at 1 representing one state.\n");
        log("        By default 'binary' is used, when 'goal' is area, otherwise 'onehot' is used.\n");
        log("\n");
        log("    -clock_enable_strategy <strategy>\n");
        log("        Run synthesis with specified extraction strategy for FFs with clock enable.\n");
        log("        Supported values:\n");
        log("        - early\n");
        log("        - late\n");
        log("        By default 'early' is used.\n");
        log("\n");
        log("\n");
    }

    string top_opt; 
    Technologies tech; 
    string blif_file; 
    string verilog_file;
    string vhdl_file;
    Strategy goal;
    Encoding fsm_encoding;
    EffortLevel effort;
    string abc_script;
    bool cec;
    bool sec;
    bool new_tdp36k;
    bool new_dsp19x2;
    bool nodsp;
    bool nobram;
    bool de;
    bool fast;
    bool no_sat;
    bool no_flatten;
    bool no_iobuf;
    CarryMode infer_carry;
    bool sdffr;
    bool nosimplify;
    bool keep_tribuf;
    bool nolibmap;
    bool preserve_ip;
    int de_max_threads;
    int max_lut;
    int max_reg;
    int max_bram;
    int max_carry_length;
    int max_dsp;
    int max_device_ios;
    RTLIL::Design *_design;
    string nosdff_str;
    ClockEnableStrategy clke_strategy;
    string use_dsp_cfg_params;

    // dsec formal verification
    //
    int sec_counter = 0;
    string previousBlifName;


    // For Ports properties extraction
    //
    std::set<std::string> pp_clocks;
    std::set<std::string> pp_asyncSet;
    std::set<std::string> pp_asyncReset;
    std::set<std::string> pp_syncSet;
    std::set<std::string> pp_syncReset;
    std::set<std::string> pp_clkEnable;
    std::set<std::string> pp_activeHigh;
    std::set<std::string> pp_activeLow;
    std::set<std::string> pp_fake;

    void clear_flags() override
    {
        top_opt = "-auto-top";
        tech = Technologies::GENERIC;
        blif_file = "";
        verilog_file = "";
        vhdl_file = "";
        goal = Strategy::MIXED;
        fsm_encoding = Encoding::BINARY;
        effort = EffortLevel::HIGH;
        abc_script = "";
        cec = false;
        sec = false;
        fast = false;
        no_sat = false;
        no_flatten = false;
        no_iobuf= false;
        nobram = false;
        new_tdp36k = false;
        new_dsp19x2 =false;
        max_device_ios=-1;
        max_lut = -1;
        max_reg = -1;
        max_bram = -1;
        max_carry_length = -1;
        max_dsp = -1;
        DSP_COUNTER = 0;
        nodsp = false;
        nosimplify = false;
        keep_tribuf = false;
        de = false;
        de_max_threads = -1;
        infer_carry = CarryMode::AUTO;
        sdffr = false;
        nolibmap = false;
        nosdff_str = " -nosdff";
        clke_strategy = ClockEnableStrategy::EARLY;
        use_dsp_cfg_params = "";
        preserve_ip = false;
    }

    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
#ifdef PRODUCTION_BUILD
        License_Manager license(License_Manager::LicensedProductName::YOSYS_RS_PLUGIN);
#endif
        string run_from; 
        string run_to;
        string tech_str;
        string goal_str;
        string encoding_str;
        string effort_str;
        string carry_str;
        string clke_strategy_str;
        string gen3_model;
        clear_flags();
        int max_device_bram = -1;
        int max_device_dsp = -1;
        int max_device_carry_length = -1;
        _design = design;

        size_t argidx;
        for (argidx = 1; argidx < args.size(); argidx++) {
            if (args[argidx] == "-top" && argidx + 1 < args.size()) {
                top_opt = "-top " + args[++argidx];
                continue;
            }
            if (args[argidx] == "-tech" && argidx + 1 < args.size()) {
                tech_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-blif" && argidx + 1 < args.size()) {
                blif_file = args[++argidx];
                continue;
            }
            if (args[argidx] == "-verilog" && argidx + 1 < args.size()) {
                verilog_file = args[++argidx];
                continue;
            }
            if (args[argidx] == "-vhdl" && argidx + 1 < args.size()) {
                vhdl_file = args[++argidx];
                continue;
            }
            if (args[argidx] == "-goal" && argidx + 1 < args.size()) {
                goal_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-no_flatten") {
                no_flatten = true;
                continue;
            }
            if (args[argidx] == "-fsm_encoding" && argidx + 1 < args.size()) {
                encoding_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-effort" && argidx + 1 < args.size()) {
                effort_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-fast") {
                fast = true;
                continue;
            }
            if (args[argidx] == "-no_sat") {
                no_sat = true;
                continue;
            }
            if (args[argidx] == "-no_iobuf") {
				no_iobuf = true;
				continue;
			}
            if (args[argidx] == "-new_tdp36k") {
				new_tdp36k = true;
				continue;
			}
            if (args[argidx] == "-new_dsp19x2") {
				new_dsp19x2 = true;
				continue;
			}
#ifdef DEV_BUILD
            if (args[argidx] == "-abc" && argidx + 1 < args.size()) {
                abc_script = args[++argidx];
                continue;
            }
#endif
            if (args[argidx] == "-cec") {
                cec = true;
                continue;
            }
            if (args[argidx] == "-sec") {
                sec = true;
                continue;
            }
            if (args[argidx] == "-carry" && argidx + 1 < args.size()) {
                carry_str = args[++argidx];
                continue;
            }
#ifdef DEV_BUILD
            if (args[argidx] == "-sdffr") {
                sdffr = true;
                nosdff_str = "";
                continue;
            }
#endif
            if (args[argidx] == "-no_dsp") {
                nodsp = true;
                continue;
            }
            if (args[argidx] == "-max_dsp" && argidx + 1 < args.size()) {
                max_dsp = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_device_dsp" && argidx + 1 < args.size()) {
                max_device_dsp = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_device_ios" && argidx + 1 < args.size()) {
                max_device_ios = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_carry_length" && argidx + 1 < args.size()) {
                max_carry_length = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_device_carry_length" && argidx + 1 < args.size()) {
                max_device_carry_length = stoi(args[++argidx]);
                continue;
            }
#ifdef DEV_BUILD
            if (args[argidx] == "-use_dsp_cfg_params") {
                use_dsp_cfg_params = " -use_dsp_cfg_params";
                continue;
            }
#endif
            if (args[argidx] == "-no_bram") {
                nobram = true;
                continue;
            }
            if (args[argidx] == "-max_lut" && argidx + 1 < args.size()) {
                max_lut = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_reg" && argidx + 1 < args.size()) {
                max_reg = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_bram" && argidx + 1 < args.size()) {
                max_bram = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-max_device_bram" && argidx + 1 < args.size()) {
                max_device_bram = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-de") {
                de = true;
                continue;
            }
            if (args[argidx] == "-no_simplify") {
                nosimplify = true;
                continue;
            }
            if (args[argidx] == "-no_libmap") {
                nolibmap = true;
                continue;
            }
            if (args[argidx] == "-keep_tribuf") {
                keep_tribuf = true;
                continue;
            }
            if (args[argidx] == "-de_max_threads" && argidx + 1 < args.size()) {
                de_max_threads = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-clock_enable_strategy" && argidx + 1 < args.size()) {
                clke_strategy_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-preserve_ip") {
                preserve_ip = true;
                continue;
            }
            break;
        }
        extra_args(args, argidx, design);

        if (max_device_bram == -1 && max_bram != -1) {
                log_cmd_error("Invalid use of max_bram flag. Please see help.\n");
        } else if (max_bram > max_device_bram){
                log_cmd_error("Invalid value of max_bram is specified. The available BRAMs are %d.\n", max_device_bram);
        } else if (max_bram == -1){
            max_bram = max_device_bram;
        }

        if (max_device_dsp == -1 && max_dsp != -1) {
                log_cmd_error("Invalid use of max_dsp flag. Please see help.\n");
        } else if (max_dsp > max_device_dsp){
                log_cmd_error("Invalid value of max_dsp is specified. The available DSPs are %d.\n", max_device_dsp);
        } else if (max_dsp == -1){
            max_dsp = max_device_dsp; 
        }

        if (max_device_carry_length == -1 && max_carry_length != -1) {
                log_cmd_error("Invalid use of max_carry_length flag. Please see help.\n");
        } else if (max_carry_length > max_device_carry_length){
                log_cmd_error("Invalid value of max_carry_length is specified. The available carry length is %d.\n", max_device_carry_length);
        } else if (max_carry_length == -1){
            max_carry_length = max_device_carry_length;
        }

        if (!design->full_selection())
            log_cmd_error("This command only operates on fully selected designs!\n");

        if (tech_str == "generic")
            tech = Technologies::GENERIC;
        else if (tech_str == "genesis"){
            tech = Technologies::GENESIS;
        }
        else if (tech_str == "genesis2") {
            tech = Technologies::GENESIS_2;
            sdffr = true;
            nosdff_str = "";
            // no_cfp_params mode for Genesis2
            use_dsp_cfg_params = "";
        }
        else if (tech_str == "genesis3") {
            tech = Technologies::GENESIS_3;
            // No synchronous set/reset for Genesis 3
            // no_cfp_params mode for Genesis3
            use_dsp_cfg_params = "";
        }
        else if (tech_str != "")
            log_cmd_error("Invalid tech specified: '%s'\n", tech_str.c_str());

        //Cheking gen3_model and sending it to LIBMAP via scratchpad
        if (new_tdp36k && (tech == Technologies::GENESIS_3)){
            gen3_model="NEW";
            design->scratchpad_set_string("synth_rs.tech_rs", gen3_model); // Adding scratchpad to track technology
        }
        else{
            gen3_model="OLD";
            design->scratchpad_set_string("synth_rs.tech_rs", gen3_model); // Adding scratchpad to track technology
        }

        if (goal_str == "area")
            goal = Strategy::AREA;
        else if (goal_str == "delay")
            goal = Strategy::DELAY;
        else if (goal_str == "mixed")
            goal = Strategy::MIXED;
        else if (goal_str != "")
            log_cmd_error("Invalid goal specified: '%s'\n", goal_str.c_str());

        if (encoding_str == "binary")
            fsm_encoding = Encoding::BINARY;
        else if (encoding_str == "onehot")
            fsm_encoding = Encoding::ONEHOT;
        else if (encoding_str != "")
            log_cmd_error("Invalid fsm_encoding specified: '%s'\n", encoding_str.c_str());
        else if (goal_str == "area")
            fsm_encoding = Encoding::BINARY;
        else
            fsm_encoding = Encoding::ONEHOT;

        if (effort_str == "high")
            effort = EffortLevel::HIGH;
        else if (effort_str == "medium")
            effort = EffortLevel::MEDIUM;
        else if (effort_str == "low")
            effort = EffortLevel::LOW;
        else if (effort_str != "")
            log_cmd_error("Invalid effort specified: '%s'\n", effort_str.c_str());

        if (carry_str == "auto")
            infer_carry = CarryMode::AUTO;
        else if (carry_str == "all")
            infer_carry = CarryMode::ALL;
        else if (carry_str == "no")
            infer_carry = CarryMode::NO;
        else if (carry_str != "")
            log_cmd_error("Invalid carry sub-mode specified: '%s'\n", carry_str.c_str());

        if (de_max_threads < 2 && de_max_threads > 64) {
            log_cmd_error("Invalid max number of threads for DE is specified: '%i'\n", de_max_threads);
        }

        if (clke_strategy_str == "early")
            clke_strategy = ClockEnableStrategy::EARLY;
        else if (clke_strategy_str == "late")
            clke_strategy = ClockEnableStrategy::LATE;
        else if (clke_strategy_str != "")
            log_cmd_error("Invalid clock enable extraction strategy specified: '%s'\n", clke_strategy_str.c_str());

        // For Jul 22 release required to enable DE.
        //
        if (!de) {
            log_cmd_error("This version of synth_rs works only with DE enabled.\n"
                    "Please provide '-de' option to enable DE.");
        }


        log_header(design, "Executing synth_rs pass: v%d.%d.%d\n", 
            VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
        log_push();

        if(fast && effort == EffortLevel::LOW)
            log_warning("\"-effort low\" and \"-fast\" options are set.");

        run_script(design, run_from, run_to);

        log_pop();
    }

    void read_SEC_models() {

        std::string simcells = GET_FILE_PATH(GENESIS_3_DIR, SEC_SIM_CELLS);
        std::string simlib = GET_FILE_PATH(GENESIS_3_DIR, SEC_SIM_LIB);
        std::string genesis3 = GET_FILE_PATH(GENESIS_3_DIR, SEC_GENESIS3);
        std::string dspmap = GET_FILE_PATH(GENESIS_3_DIR, SEC_DSP_MAP);
        std::string dspfinalmap = GET_FILE_PATH(GENESIS_3_DIR, SEC_DSP_FINAL_MAP);

        run(stringf("read_verilog -sv %s", simcells.c_str()));
        run(stringf("read_verilog -sv %s", simlib.c_str()));
        run(stringf("read_verilog -sv %s", genesis3.c_str()));
        run(stringf("read_verilog -sv %s", dspmap.c_str()));
        run(stringf("read_verilog -sv %s", dspfinalmap.c_str()));
    }

    void appendBlifModels(string blifName) {

        //const std::string blif_file_path = GET_FILE_PATH(GENESIS_3_DIR, SEC_MODELS_BLIF);
        const std::string blif_file_path = "./MODELS/models.blif";

        std::ifstream blif_file(blif_file_path);
        if(!blif_file.is_open()){
            std::cout<< "Error opening source BLIF file" << std::endl;
        }

        std::string line;
        std::fstream gen_blif(blifName, std::ios::app);

        if(!gen_blif.is_open()){
            std::cout<< "Error opening source BLIF file" << std::endl;
        }
        while (std::getline(blif_file, line)){
            gen_blif << line <<std::endl;
        }
    }

    bool designIsSequential() {

       for (auto cell : _design->top_module()->cells()) {

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

    void sec_check(string checkName, bool verify) {
        
        if (!sec) {
          return;
        }

        char name[528];

        sec_counter++;

        sprintf(name, "%03d_%s", sec_counter, checkName.c_str());

        string blifName = "b" + string(name) + ".blif";
        string verilogName = "v" + string(name) + ".v";
        string resName = "r" + string(name) + ".res";
 
        run("design -save original");

        run("opt_clean -purge");

        run(stringf("hierarchy -check %s", top_opt.c_str()));

        Module* topModule = _design->top_module();

        const char* topName = topModule->name.c_str();
        topName++; // skip the escape 

        run(stringf("write_verilog -selected -noexpr -nodec %s", verilogName.c_str()));

        bool isSequential = designIsSequential();

        run("design -reset");

        read_SEC_models();

        // Read the previously dumped design. This mechanism helps to succeed on 'blob_merge'
        // otherwise if we work directly on the 'design' 'dsec' returns "NOT equivalent" for 
        // some reasons.
        //
        run(stringf("read_verilog -sv %s", verilogName.c_str()));

        run(stringf("hierarchy -top %s", topName));

        run("flatten");

        run(stringf("hierarchy -top %s", topName));
        
        run("proc");
        run("opt_expr");
        run("opt_clean -purge");

        // Transform the network so that the blif dumped is easier to process for 'dsec'
        //
        // run("abc -script prepare_for_dsec.scr");

        run(stringf("write_blif %s", blifName.c_str()));

        appendBlifModels(blifName);

        run("design -load original");

        // If there was a previous step then 'stat' the previous design cells
        //
        if (sec_counter > 1) {

          run("design -save current");

          // Load previous step to show the 'stat'
          //
          run("design -load previous");

          log("\n =======================\n");
          log("     Previous step:\n");
          log(" =======================\n");

          run("stat");

          run("design -load current");
        }

        log(" =======================\n");
        log("     Current step:\n");
        log(" =======================\n");

        run("stat");
        
        // If there was a previous step then perform Formal Verification between 
        // previous and current steps
        //
        if (sec_counter > 1) {

            std::string abc_script = "abc.scr";

            string abc_exe_dir = proc_self_dirname() + "abc";

            log("Comparing : %s <--> %s (%s)\n", previousBlifName.c_str(), blifName.c_str(),
                resName.c_str());

            std::string command = abc_exe_dir + " -f abc.scr > " + resName;

            // Show the last two lines of the 'dsec' output showing if FV either : 
            //
            //   1/ succeeded : "Networks are equivalent."
            //   2/ failed : "Networks are NOT equivalent."
            //   3/ unknown : UNDECIDABLE
            //   4/ error : error in reading (ex: missing cell)
            //
            command += " ; tail -n 2 " + resName;

            std::string command2 = "";

            if (isSequential) {
              command2 += "dsec ";
            } else {
              command2 += "cec ";
            }
            command2 += previousBlifName +" " + blifName +"; quit;" ;

            std::ofstream out(abc_script);

            if (out.is_open()){

                out<<command2;
                out.close();
            }

            log("\n===============================================================================\n");

            if (!verify) {

               log("Formal Verification skipped\n");

            } else {

               if (isSequential) {
                  log("DSEC : \n");
               } else {
                  log("CEC : \n");
               }
   
               // Call ABC which calls command "dsec" underneath
               //
               int fail = system(command.c_str());

               if (fail) {
                 log_error("Command %s failed !\n", command.c_str());
               }
            }

            log("===============================================================================\n");

            getchar();
        }

        previousBlifName =  blifName;
        
        run("design -save previous");
    }

    
    void step(string msg)
    {
        log("STEP : %s\n", msg.c_str());
        getchar();
    }

    int getNumberOfInstances() {
        return (_design->top_module()->cells_.size());
    }

    // Assume no carry chains with loops which is always the case
    //
    int getCarryChainLength(Cell* cell, dict<RTLIL::SigSpec, Cell*>& co2cell, 
                            dict<Cell*, RTLIL::SigSpec>& cell2ci, int l) {

       // cell is a carry adder. If it has no 'ci' net then return right away
       //
       if (!cell2ci.count(cell)) {
         return l;
       }

       SigSpec ciSignal = cell2ci[cell];

       // If the ci signal is not the carry out of another carry cell then return
       // right away.
       //
       if (!co2cell.count(ciSignal)) {
         return l;
       }

       // Compute the length recursively from the "nextCarryCell"
       //
       Cell* nextCarryCell = co2cell[ciSignal];

       return (getCarryChainLength(nextCarryCell, co2cell, cell2ci, l+1));
    }

    void reportCarryChains() {

       dict<RTLIL::SigSpec, Cell*> ci2cell; // from the 'ci' net gives the corresponding carry adder cell
       dict<RTLIL::SigSpec, Cell*> co2cell; // from the 'co' net gives the corresponding carry adder cell
       dict<Cell*, RTLIL::SigSpec> cell2ci; // from the carry cell gives its corresponding 'ci' net

       // store the carry adders wich are the heads of a carry chain
       //
       vector<Cell*> carry_chain_head_cells; 

       int nbCarryAdders = 0;

       for (auto cell : _design->top_module()->cells()) {

           //log("Cell = %s\n", (cell->type).c_str());

           if(cell->type != RTLIL::escape_id("CARRY")) {
             continue;
           }

           nbCarryAdders++;

           bool noCo = true;

           for (auto &conn : cell->connections()) {

               IdString portName = conn.first;
               RTLIL::SigSpec actual = conn.second;

               //log("     Port = %s\n", (portName).c_str());

               if (portName == RTLIL::escape_id("CIN")) {
                 ci2cell[actual] = cell;
                 cell2ci[cell] = actual;
                 continue;
               }

               if (portName == RTLIL::escape_id("COUT")) {
                 noCo = false;
                 co2cell[actual] = cell;
                 continue;
               }
           }

           // If carry adder has no "co" port then it is a carry chain head cell
           //
           if (noCo) {
             carry_chain_head_cells.push_back(cell);
           }
       }

       vector<RTLIL::SigSpec> carry_chain_head_co2cell; 

       for (auto &co_signal : co2cell) {

          // If 'co_signal" corresponds to a ci signal then it cannot be a top head CO
          // signal of a carry chain
          //
          RTLIL::SigSpec signal = co_signal.first;

          if (ci2cell.count(signal)) { // co signal is also a ci signal
            continue;
          }

          // this co signal does not drive any carry cell so it is a carry chain head cell.
          // get its associated cell and add it.
          Cell* cell = co_signal.second;

          carry_chain_head_cells.push_back(cell);
       }

#if 0
       log ("NB carry = %d\n", nbCarryAdders);
       log ("NB CI signals = %lu\n", ci2cell.size());
       log ("NB CO signals = %lu\n", co2cell.size());
       log ("NB CC heads = %lu\n", carry_chain_head_cells.size());
#endif

       dict<int /* ccarry chain length */, int /* number of arry chains with that length */> carry_chains_stat;

       for (auto &headCarryCell : carry_chain_head_cells) {

         // Get the length of the chain starting from head cell "headCarryCell"
         //
         int length = getCarryChainLength (headCarryCell, co2cell, cell2ci, 1);

         //log ("Length = %d\n", length);

         // Group chains of same length with same counter
         //
         if (!carry_chains_stat.count(length)) {
           carry_chains_stat[length] = 1; // first occurence case
          } else {
           carry_chains_stat[length] += 1;
         }
       }

       log ("   Number of CARRY ADDERs:       %5d\n", nbCarryAdders);

       if (carry_chains_stat.size() == 0) {
         return;
       }

       log ("   Number of CARRY CHAINs:       %5d (", (int)carry_chain_head_cells.size());

       bool first = true;
       for (auto &stat : carry_chains_stat) {
          if (!first) {
            log(", ");
          }
          log("%dx%d", stat.second, stat.first);
          first = false;
       }

       log (")\n");
    }

    int getNumberOfLUTx() {

       int nb = 0;

       for (auto cell : _design->top_module()->cells()) {
          if (cell->type.in(ID(LUT1), ID(LUT2), ID(LUT3), ID(LUT4), ID(LUT5), ID(LUT6))) {
            nb++;
          }
       }

       return nb;
    }

    // Specific to GENESIS3 by checking GENESI3 DFF names (dffre, dffnre)
    //
    int getNumberOfREGs() {

       int nb = 0;

       for (auto cell : _design->top_module()->cells()) {
          if (cell->type.in(ID(DFFRE), ID(DFFNRE))) {
            nb++;
          }
       }

       return nb;
    }

    int getNumberOfGenericREGs() {

       int nb = 0;

       for (auto cell : _design->top_module()->cells()) {

          if (!RTLIL::builtin_ff_cell_types().count(cell->type))
              continue;

          nb++;
       }

       return nb;
    }

    int getNumberOfLogic() {

       int nb = 0;

       for (auto cell : _design->top_module()->cells()) {
          if (cell->type.in(ID($and), ID($_AND_), ID($_NAND_), ID($or), ID($_OR_),
                            ID($_NOR_), ID($xor), ID($xnor), ID($_XOR_), ID($_XNOR_),
                            ID($_ANDNOT_), ID($_ORNOT_))) {
            nb += 2;
          }
          if (cell->type.in(ID($not), ID($_NOT_))) {
            nb += 1;
          }
          if (cell->type.in(ID($_MUX_), ID($mux))) {
            nb += 3;
          }
       }

       return nb;
    }

    void run_opt(int nodffe, int sat, int nosdff, int share, int max_iter, int no_sdff_temp) {

        string nodffe_str = "";
        string sat_str = "";

        if (nodffe) {
           nodffe_str = " -nodffe ";
        }

        if (sat) {
           sat_str = " -sat ";
        }

        run("opt_expr");
        run("opt_merge -nomux");

        int iteration = 0;

        while (1) {

            iteration++;

            int nbInstBefore = getNumberOfInstances();

            run("opt_muxtree");                                                                        
            run("opt_reduce");
            run("opt_merge");
            if (share) {
               run("opt_share");
            }
            if (nosdff) {
               if (sat) {
                  run("opt_dff -nosdff " + nodffe_str);
               }
               run("opt_dff -nosdff " + nodffe_str + sat_str);
            } else {
                if (no_sdff_temp){
                    if (sat) {
                      run("opt_dff "  + nodffe_str);
                    }
                    run("opt_dff "  + nodffe_str + sat_str);
                } else {
                    if (sat) {
                      run("opt_dff " + nosdff_str + nodffe_str);
                    }
                    run("opt_dff " + nosdff_str + nodffe_str + sat_str);
                }
            }
            run("opt_clean");
            run("opt_expr");

            int nbInstAfter = getNumberOfInstances();

            if (nbInstAfter == nbInstBefore) {
                break;
            }

            if (iteration == max_iter) {
                break;
            }

#if 0
            if ((nbInstAfter >= 80000) && (iteration >= 4)) {
                break;
            }
#endif

        }

        _design->optimize();
        _design->sort();
        _design->check();

        log("\nRUN-OPT ITERATIONS DONE : %d\n", iteration);
    }

    // Wrapper on 'run_opt' to better control way of using SAT mode. In non-SAT mode we call 
    // 'run_opt" as in regular mode.
    // In SAT mode we try to interleave non-SAT calls with 1 single SAT call in a general loop.
    // SAT call will create few constants that will be propagated through fast non-SAT mode.
    // On 'rsnoc" (EDA-1041) non-SAT mode takes 3 seconds and SAT mode can take up to 2 hours.
    // (Thierry)
    //
    void top_run_opt(int nodffe, int sat, int nosdff, int share, int max_iter, int no_sdff_temp) {

      if (!sat) {
         run_opt(nodffe, sat, nosdff, share, max_iter, no_sdff_temp);
         return;
      }

      while (max_iter--) {

         int nbInstBefore = getNumberOfInstances();

         run_opt(nodffe, 0 /* NO SAT */, nosdff, share, 12 /* iteration */, no_sdff_temp);

         // Note : only 1 iteration in SAT mode
         //
         run_opt(nodffe, 1 /* SAT */, nosdff, share, 1 /* iteration */, no_sdff_temp);

         int nbInstAfter = getNumberOfInstances();

         if (nbInstAfter == nbInstBefore) {
           break;
         }
      }
    }

    void map_luts(EffortLevel effort_lvl) {
        static int index = 1;
        if (abc_script != "")
            run("abc -script " + abc_script);
        else {
            std::string effortStr = "";
            std::string abcCommands = "";
            std::string scriptName = "abc_tmp_" + std::to_string(index) + ".scr";
            string tmp_file = get_shared_tmp_dirname() + "/" + scriptName;
            std::ofstream out(tmp_file);
            std::string in_blif_file = "in_" + std::to_string(index) + ".blif";
            std::string out_blif_file = "out_" + std::to_string(index) + ".blif";

            if (cec)
                out << "write_blif " + in_blif_file + ";";

            switch(effort_lvl) {
                case EffortLevel::HIGH: {
                    if (de)
                        effortStr = "-1";
                    break;
                }
                case EffortLevel::MEDIUM:
                case EffortLevel::LOW: {
                    if (de)
                        effortStr = "1"; // Some initial value
                    break;
                }
            } 

            if (fast) {
                //effortStr = "0"; // tell DE to not iterate
                effortStr = "3"; // iterate a couple of times in fast mode
            }

            switch(goal) {
                case Strategy::AREA: {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "area");
                    /* Disable static ABC script support for Jul 22 release.
                     *
                    else
                        abcCommands = abc_base6_a21;
                    */
                    break;
                }
                case Strategy::DELAY: {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "delay");
                    /* else
                        out << abc_base6_d1; // Delay optimized abc script. */
                    break;
                }
                case Strategy::MIXED: {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "mixed");
                    /* else
                        out << abc_base6_m1; // Delay and area mixed optimized abc script. */
                    break;
                }
            }
            if (de) {
                abcCommands = std::regex_replace(abcCommands, std::regex("DEPTH"), effortStr);
                abcCommands = std::regex_replace(abcCommands, std::regex("TMP_PATH"), 
                                                 get_shared_tmp_dirname());
                abcCommands = std::regex_replace(abcCommands, std::regex("THREAD_NUMBER"), std::to_string(de_max_threads));
            }
            out << abcCommands;

            if (cec) {
                out << "write_blif " + out_blif_file + ";";
                // cec command is not called, so as not to impact on runtime.
                // out << "cec " + in_blif_file + " " + out_blif_file;
            }
            out.close();

            run("abc -script " + tmp_file);
            if (remove(tmp_file.c_str()) != 0)
                log("Error deleting file: %s", tmp_file.c_str());
        }

        if (!fast)
            top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);

        if (cec) {
            run("write_verilog -noattr -nohex after_lut_map" + std::to_string(index) + ".v");
        }
        sec_check("after_lut_map", true);

        index++;
    }

    void preSimplify() 
    {
        if (tech != Technologies::GENERIC) {
            run("stat");
            switch (tech) {
                case Technologies::GENESIS: {
                    if (sdffr) {run("dfflegalize -cell $_SDFF_???_ 0 t:$_SDFFCE_*");}
                        break;
                    }
               case Technologies::GENESIS_2: {
                        run("dfflegalize -cell $_SDFF_???_ 0 -cell $_SDFFE_????_ 0 t:$_SDFFCE_*");
                        break;
                    }
               case Technologies::GENESIS_3: {
                       // run("dfflegalize -cell $_DLATCH_?_ 0 t:$_DFFSR_*_ "); //0 t:$_SDFF_*_"); // 0 t:$_DFFSR_*");
                        break;
                    }
               case Technologies::GENERIC: {
                        break;
                    }
                }
        }

        // Do not extract DFFE before simplify : it may have been done earlier
        //
        top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 0, 12, 0);

        if (!no_sat) {
          top_run_opt(1 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 0, 10, 0);
        }

        run("stat");
    }

    void postSimplify() 
    {
        top_run_opt(0 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);

        if (!no_sat) {
          top_run_opt(0 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 4, 0);
        }
    }

// return 1 if the design has at least one DFF with Clock enable
// 0 otherwise.
//
int designWithDFFce()
{
    for (auto &mod : _design->selected_modules()) {

       SigMap sigmap(mod);

       FfInitVals initvals(&sigmap, mod);

       for (auto cell : mod->selected_cells()) {

           if (!RTLIL::builtin_ff_cell_types().count(cell->type)) {
              continue;
           }

           FfData ff(&initvals, cell);

           if (!ff.has_clk) {
              continue;
           }

           if (ff.has_ce) {
             return 1;
           }
       }
    }

    return 0;
}


// Check size of current design to eventually drive Synthesis flow
//
bool isHugeDesign(int nbRegs, int nbCells)
{
   if (nbRegs >= 50000) {
     return true;
   }

   if (nbCells >= 400000) {
     return true;
   }

   return false;
}

// Perform different ABC -dff optimization strategies according to "dfl" heuristice number
//
void abcDffOpt(int unmap_dff_ce, int n, int dfl)
{
    log("\nABC-DFF iteration : %d\n", n);

    switch (dfl) {

       case 2 : run("abc -dff -keepff -dfl 2");   // WARNING: "abc -dff" is very time consuming !!!
                                                  // Use "-keepff" to preserve DFF output wire name
                break;
       case 0 : run("abc -dff -keepff -dfl 0");   // WARNING: "abc -dff" is very time consuming !!!
                                                  // Use "-keepff" to preserve DFF output wire name
                break;
       default : run("abc -dff -keepff -dfl 1");   // WARNING: "abc -dff" is very time consuming !!!
                                                   // Use "-keepff" to preserve DFF output wire name
                break;
    }

    if (!unmap_dff_ce) {

       top_run_opt(0 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 2, 0);

    } else {
            
      run("opt_dff -nosdff -nodffe");
      run("opt_expr");
      run("opt_clean");

      run("opt_dff -nosdff -nodffe");
      run("opt_expr");
      run("opt_clean");

      run("opt_dff -nosdff");
      run("opt_expr");
      run("opt_clean");

      run("dffunmap -ce-only");
    }

    if (cec) {
        run("write_verilog -noattr -nohex after_abc-dff" + std::to_string(n) + ".v");
    }
    sec_check("after_lut_map", true);

}


    // Perform a small loop of successive "abc -dff" calls.  
    // This "simplify" pass may have some big QoR impact on this list of designs:
    //     - wrapper_io_reg_max 
    //     - wrapper_io_reg_tc1 
    //     - wrapper_multi_enc_decx2x4
    //     - keymgr 
    //     - kmac 
    //     - alu4 
    //     - s38417
    //
    void simplify(int unmap_dff_ce, int &dfl) 
    {

        dfl = 0; // will return "dfl" best mode info to the caller (0 -> no value yet)

        int nbcells = getNumberOfInstances();
        int nbGenericREGs = getNumberOfGenericREGs();

        log("   Number of Generic REGs:          %d\n", nbGenericREGs);

        //run("design -save design_before_abc_dff");

        if (isHugeDesign (nbGenericREGs, nbcells)) {

          abcDffOpt(unmap_dff_ce, 1 /* step */, 0 /* dfl */); // fast version

        } else {

          abcDffOpt(unmap_dff_ce, 1 /* step */, 1 /* dfl */);
          abcDffOpt(unmap_dff_ce, 2 /* step */, 1 /* dfl */);
        }
        
        // Save this first simplify solution (with default "dfl")
        //
        run("design -push-copy");

        int nbcells1 = getNumberOfInstances();
        int nbGenericREGs1 = getNumberOfGenericREGs();
        int nbOfLogic1 = getNumberOfLogic();

        if (isHugeDesign (nbGenericREGs1, nbcells1)) {

          abcDffOpt(unmap_dff_ce, 2 /* step */, 0 /* dfl */); // fast version
        } else {

          abcDffOpt(unmap_dff_ce, 3 /* step */, 2 /* dfl */);
          abcDffOpt(unmap_dff_ce, 4 /* step */, 2 /* dfl */);
        }

        int nbcells2 = getNumberOfInstances();
        int nbGenericREGs2 = getNumberOfGenericREGs();
        int nbOfLogic2 = getNumberOfLogic();

        float thresh_logic = 0.92;
        float thresh_dff = 0.98;

        if (0) {   
           log("****************************\n");
           log(" NB cells DFL1 : %d\n", nbcells1);
           log(" NB REGs DFL1  : %d\n", nbGenericREGs1);
           log(" NB LOGs DFL1  : %d\n\n", nbOfLogic1);
           log(" NB cells DFL2 : %d\n", nbcells2);
           log(" NB REGs DFL2  : %d\n", nbGenericREGs2);
           log(" NB LOGs DFL2  : %d\n", nbOfLogic2);
           log("****************************\n");
        }

        if ((nbOfLogic2 <= thresh_logic * nbOfLogic1) ||
            (nbGenericREGs2 <= thresh_dff * nbGenericREGs1)) {

           dfl = 2;

           log("select with DFL2 synthesis (thresh-logic=%f, thresh_dff=%f)\n", thresh_logic, thresh_dff);

           run("design -save dfl");
           run("design -pop");
           run("design -load dfl");

        } else {

           dfl = 1;

          log("select with DFL1 synthesis (thresh_logic=%f, thresh_dff=%f)\n", thresh_logic, thresh_dff);

          run("design -pop");
        }

        run("opt_ffinv");
    }

    void transform(int bmuxmap)
    {
        if (bmuxmap) { // we can map the "$bmux" (otherwise they may be translated
                       // during call to "memory" through "memory_bmux2rom" and we can
                       // screw up the ROM inference: ex "wrapper_KeyExapantion").
                       //
            run("bmuxmap");
        }
        run("demuxmap");
        run("clean_zerowidth");
        _design->sort();
    }
    void add_out_reg(){
        std::vector <SigChunk> port_chunk;
        std::vector<Cell *> add_cells;
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                if(cell->type == RTLIL::escape_id("$add")){
                    add_cells.push_back(cell);
                }
            }
        }

        SigMap sigmap(_design->top_module());
        FfInitVals initvals(&sigmap, _design->top_module());
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                std::string cell_type_str = cell->type.str();
                
                if(cell_type_str == RTLIL::escape_id("$mul")){
                    
                    auto REGOUT = (cell->getParam(ID::REG_OUT));
                    if(REGOUT[0] == RTLIL::S1){

                        FfData ff(module, &initvals, NEW_ID);

                        ff.width = cell->getParam(ID::Y_WIDTH).as_int();
                        auto CLK_PORT = (cell->getParam(ID::DSP_CLK)).decode_string();
                        auto RST_PORT = (cell->getParam(ID::DSP_RST)).decode_string();

                        SigSpec sig_q 		= module->addWire(NEW_ID,ff.width);
                        for (auto wire : module->wires()){
                            if (wire->name==CLK_PORT.c_str()){
                                ff.has_clk = true;
                                ff.sig_clk = wire;
                                ff.pol_clk = REGOUT[4];
                            }
                            if (wire->name == RST_PORT.c_str()){
                                if (REGOUT[1]){
                                    ff.has_arst = true;
                                    ff.sig_arst = wire;
                                    ff.pol_arst = REGOUT[3];
                                    ff.val_arst = Const(0,ff.width);
                                }
                                if(REGOUT[2]){
                                    ff.has_srst = true;
                                    ff.sig_srst = wire;
                                    ff.pol_srst = REGOUT[3];
                                    ff.val_srst = Const(0,ff.width);
                                }
                            }
                        }
                        
                        ff.has_ce = false;
                        ff.has_sr = false;
                        ff.has_aload  = false;
                        ff.has_gclk = false;
                        int size_chunk = 0 ;
                        RTLIL::IdString chunk_id;
                        RTLIL::SigSpec Chunk_sig;
                        for (auto &cell_ : add_cells) {
                            for (auto &conn_ : cell_->connections()) {
                                if (!conn_.second.is_chunk()){
                                    std::vector<SigChunk> chunks_ = sigmap(conn_.second);
                                    size_chunk = GetSize(conn_.second);
                                    for (auto &chunk_ : chunks_){
                                        if (chunk_.wire != nullptr){
                                            if (cell->getPort(ID::Y) == chunk_){
                                                port_chunk = chunks_;
                                                chunk_id = conn_.first;
                                                Chunk_sig = conn_.second;
                                                break;
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        
                        SigSpec new_sig_s = module->addWire(NEW_ID, size_chunk);
                        int chunk_id_ = 0;
                        for (auto &chunk : port_chunk){

                            if(SigSpec(chunk) == cell->getPort(ID::Y)){
                                if (chunk_id_ ==0 )
                                    new_sig_s = sig_q;
                                else
                                    new_sig_s.append(sig_q);
                            }
                            else{if (chunk_id_ ==0 )
                                    new_sig_s = chunk;
                                else
                                    new_sig_s.append(chunk);
                            }
                        chunk_id_ = chunk_id_ + 1;                                            
                            
                        }
                        for (auto &cell_ : add_cells) {
                            if (chunk_id != ""){
                                if (cell_->getPort(chunk_id) == Chunk_sig){
                                    cell_->unsetPort(chunk_id);
                                    cell_->setPort(chunk_id,new_sig_s);
                                }
                            }
                        }
                        
                        port_chunk.clear();
                        ff.sig_d = cell->getPort(ID::Y);
                        ff.sig_q = sig_q;
                        ff.val_init = Const(0,ff.width);
                        ff.emit();
                    }
                }
                if(cell_type_str == RTLIL::escape_id("RS_DSP") || cell_type_str == RTLIL::escape_id("RS_DSPX2")){
                    RTLIL::Const MODE_BITS_ = cell->getParam(RTLIL::escape_id("MODE_BITS"));
                    if (MODE_BITS_[1] == RTLIL::S0 || MODE_BITS_[80] == RTLIL::S0){
                        cell->unsetParam(ID::DSP_CLK);
                        cell->unsetParam(ID::DSP_RST);
                        cell->unsetParam(ID::DSP_RST_POL);
                    }
                }
            }
        }
    }
    void check_mult_regout(){
        std::vector<Cell *> DFF_used_cells;
        std::vector<Cell *> MULT_used_cells; 
        std::vector<Cell *> MULT_DFF_used_cells;
        SigMap sigmap(_design->top_module());
        FfInitVals initvals(&sigmap, _design->top_module());
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                
                if (RTLIL::builtin_ff_cell_types().count(cell->type)) {
                    //adding all DFF cells of design
                    DFF_used_cells.push_back(cell);
                    continue;
                }
                if(cell->type == RTLIL::escape_id("$mul")){
                    MULT_used_cells.push_back(cell);
                    continue;
                }
            }
        }
        for (auto &mult : MULT_used_cells){
            if (mult->getPort(ID::A).size() >= DSP_MIN_WIDTH_A && mult->getPort(ID::B).size()>=DSP_MIN_WIDTH_B){
                int x = 0;

                for (auto &_dff_ :  DFF_used_cells){
                    FfData ff(&initvals, _dff_);
                    bool ignore_dsp = false;
                    if (sigmap(ff.sig_d) == sigmap(mult->getPort(ID::Y))){
                        if ((ff.has_ce || ff.has_srst || ff.has_sr || ff.has_aload || ff.has_gclk || !ff.has_clk) && tech != Technologies::GENESIS) {
                            if (ff.has_srst){
                                std::stringstream buf;
                                for (auto &it : _dff_->attributes) {
                                    RTLIL_BACKEND::dump_const(buf, it.second);
                                }
                                log_warning("The synchronous register element Generic DFF %s (type: %s) cannot be merged in RS_DSP due to architectural limitations. Please address this issue in the RTL at line %s\n",log_id(ff.name),log_id(ff.cell->type),buf.str().c_str());
                            }
                            ignore_dsp = true;
                        }
                        if (!ignore_dsp){
                            _design->DFF_cells.push_back(_dff_);
                            mult->setParam(RTLIL::escape_id("REG_OUT"), RTLIL::Const(1));
                            RTLIL::Const REGOUT = mult->getParam(RTLIL::escape_id("REG_OUT"));
                            RTLIL::Const reset_pol = mult->getParam(RTLIL::escape_id("DSP_RST_POL"));
                            string clk_name = log_signal(ff.sig_clk);
                            string rst_name = "";
                            // bool rst_pol = true;
                            if(ff.has_arst){
                                rst_name = log_signal(ff.sig_arst);
                                mult->setParam(RTLIL::escape_id("DSP_RST_POL"), RTLIL::Const(ff.pol_arst));
                                REGOUT[1] = RTLIL::S1;
                                REGOUT[3] = RTLIL::State(ff.pol_arst);
                            }
                            if(ff.has_srst){
                                rst_name = log_signal(ff.sig_srst);
                                mult->setParam(RTLIL::escape_id("DSP_RST_POL"), RTLIL::Const(ff.pol_srst));
                                REGOUT[2] = RTLIL::S1;
                                REGOUT[3] = RTLIL::State(ff.pol_srst);
                            }
                            
                            Const clk_paramValue;
                            clk_paramValue = Const(clk_name);
                            mult->setParam(ID::DSP_CLK, clk_name);

                            Const rst_paramValue;
                            rst_paramValue = Const(rst_name);
                            mult->setParam(ID::DSP_RST, rst_name);

                            REGOUT[4] = RTLIL::State(ff.pol_clk);
                            mult->setParam(RTLIL::escape_id("REG_OUT"), REGOUT);

                            mult->setPort(ID::Y, ff.sig_q);
                            DFF_used_cells.erase(DFF_used_cells.begin()+x);
                            ff.remove();
                            break;
                        }
                    }
                    x = x+1;
                }
                
            }
        }
    }
    void processDsp(bool cec){
        struct DspParams {
            size_t a_maxwidth;
            size_t b_maxwidth;
            size_t a_minwidth;
            size_t b_minwidth;
            std::string type;
        };
        /* 
            We start from technology mapping of RTL operator that can be mapped to RS_DSP2.* on smallest DSP to biggest one. 
            The idea is that if there is a perfect fit we want to assign the smallest DSP to the RTL operator.
        */
        std::vector<DspParams> dsp_rules_loop1;
        std::string dsp_map_file;
        switch (tech) {
            case Technologies::GENESIS: {
                dsp_rules_loop1.push_back({10, 9, 4, 4, "$__RS_MUL10X9"});
                dsp_rules_loop1.push_back({20, 18, 11, 10, "$__RS_MUL20X18"});
                dsp_map_file = "+/mul2dsp_check_maxwidth.v";
                break;
            }
            // Genesis2 technology doesn't support fractured mode for DSPs
            case Technologies::GENESIS_2: {
                dsp_rules_loop1.push_back({20, 18, 4, 4, "$__RS_MUL20X18"});
                dsp_map_file = "+/mul2dsp.v";
                break;
            }
            // Genesis3 technology doesn't support fractured mode for DSPs
            case Technologies::GENESIS_3: {
                if (new_dsp19x2){
                    dsp_rules_loop1.push_back({10, 9, 4, 4, "$__RS_MUL10X9"});
                    dsp_rules_loop1.push_back({20, 18, 11, 10, "$__RS_MUL20X18"});
                }
                else
                    dsp_rules_loop1.push_back({20, 18, 4, 4, "$__RS_MUL20X18"});
            
                // Run DSP19X2/DSP38 and map base on max width
                if (new_dsp19x2)
                    dsp_map_file = "+/mul2dsp_check_maxwidth.v";
                else
                    // Run DSP38 only 
                    dsp_map_file = "+/mul2dsp.v";
                break;
            }
            case Technologies::GENERIC: {
                break;
            }
        }
        switch (tech) {
            case Technologies::GENESIS: 
            case Technologies::GENESIS_3: 
            case Technologies::GENESIS_2: {
                for (const auto &rule : dsp_rules_loop1) {
                    run(stringf("techmap -map %s "
                                " -D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                                "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                                "-D DSP_NAME=%s %s",
                                dsp_map_file.c_str(), rule.a_maxwidth, 
                                rule.b_maxwidth, rule.a_minwidth, 
                                rule.b_minwidth, rule.type.c_str(), max_dsp != -1 ? "a:valid_map" : ""));
                    run("stat");
                    if (cec)
                        run("write_verilog -noattr -nohex after_dsp_map1_" + std::to_string(rule.a_maxwidth) + ".v");

                    run("chtype -set $mul t:$__soft_mul");
                }

                // Genesis2 technology doesn't support fractured mode for DSPs, so no need for second iteration.
                // Genesis3 technology doesn't support fractured mode for DSPs, so no need for second iteration.
                if (!new_dsp19x2){
                    if ((tech != Technologies::GENESIS_2) && 
                        (tech != Technologies::GENESIS_3)) {
                        /* 
                        In loop2, We start from technology mapping of RTL operator that can be mapped to RS_DSP2.* on biggest DSP to smallest one. 
                        The idea is that if a RTL operator that does not fully satisfies the "dsp_rules_loop1", it will be mapped on DSP in 2nd loop.
                        */
                        const std::vector<DspParams> dsp_rules_loop2 = {
                            {20, 18, 11, 10, "$__RS_MUL20X18"},
                            {10, 9, 4, 4, "$__RS_MUL10X9"},
                        };
                        for (const auto &rule : dsp_rules_loop2) {
                            if (max_dsp != -1)
                                run(stringf("techmap -map +/mul2dsp.v "
                                            "-D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                                            "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                                            "-D DSP_NAME=%s a:valid_map",
                                            rule.a_maxwidth, rule.b_maxwidth, rule.a_minwidth, rule.b_minwidth, rule.type.c_str()));
                            else
                                run(stringf("techmap -map +/mul2dsp.v "
                                            "-D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                                            "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                                            "-D DSP_NAME=%s",
                                            rule.a_maxwidth, rule.b_maxwidth, rule.a_minwidth, rule.b_minwidth, rule.type.c_str()));

                            if (cec)
                                run("write_verilog -noattr -nohex after_dsp_map2_" + std::to_string(rule.a_maxwidth) + ".v");

                            run("chtype -set $mul t:$__soft_mul");
                        }
                    }
                }
                else
                {   // Genesis3 technology support fractured mode for DSPs, so need for second iteration.
                    if ((tech != Technologies::GENESIS_2)) {
                        /* 
                        In loop2, We start from technology mapping of RTL operator that can be mapped to RS_DSP2.* on biggest DSP to smallest one. 
                        The idea is that if a RTL operator that does not fully satisfies the "dsp_rules_loop1", it will be mapped on DSP in 2nd loop.
                        */
                        const std::vector<DspParams> dsp_rules_loop2 = {
                            {20, 18, 11, 10, "$__RS_MUL20X18"},
                            {10, 9, 4, 4, "$__RS_MUL10X9"},
                        };
                        for (const auto &rule : dsp_rules_loop2) {
                            if (max_dsp != -1)
                                run(stringf("techmap -map +/mul2dsp.v "
                                            "-D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                                            "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                                            "-D DSP_NAME=%s a:valid_map",
                                            rule.a_maxwidth, rule.b_maxwidth, rule.a_minwidth, rule.b_minwidth, rule.type.c_str()));
                            else
                                run(stringf("techmap -map +/mul2dsp.v "
                                            "-D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                                            "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                                            "-D DSP_NAME=%s",
                                            rule.a_maxwidth, rule.b_maxwidth, rule.a_minwidth, rule.b_minwidth, rule.type.c_str()));

                            if (cec)
                                run("write_verilog -noattr -nohex after_dsp_map2_" + std::to_string(rule.a_maxwidth) + ".v");

                            run("chtype -set $mul t:$__soft_mul");
                        }
                    }
                }
                break;
            }
            case Technologies::GENERIC: {
                break;
            }
        }
    }

    void identifyMemsWithSwappedReadPorts() {
        for (auto module : _design->selected_modules()) {
            auto memCells = Mem::get_selected_memories(module);
            for (auto mem : memCells) {
                if (!mem.get_bool_attribute(RTLIL::escape_id("dff_merge")))
                    continue;
                std::set<SigSpec> clocks;
                for (int i = 0; i < GetSize(mem.wr_ports); i++) {
                    auto &wport = mem.wr_ports[i];
                    clocks.insert(wport.clk);
                }
                for (int i = 0; i < GetSize(mem.rd_ports); i++) {
                    auto &rport = mem.rd_ports[i];
                    clocks.insert(rport.clk);
                }
                if (1 == clocks.size()) {
                    mem.cell->set_bool_attribute(RTLIL::escape_id("read_swapped"));
                    log_debug("Swapped port memory identfied!");
                }
            }
        }
    }
void Set_INIT_PlacementWithNoParity_mode(Cell* cell,RTLIL::Const mode) {
    
    RTLIL::Const tmp_init;
    std::vector<RTLIL::State> init_value1; 
    std::vector<RTLIL::State> init_parity_value1;

    if ((cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_TDP")) || (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_SDP"))){
        RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
        switch (mode.as_int()) {
            case 9:
            case 18:{
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_18_WIDTH; ++i) {
                        for (int j = 0; j <16; ++j)
                            init_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                        for (int k = 16; k < BRAM_WIDTH_18; k++)
                                    init_parity_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + k]);
                    }
                break;
            }
            case 36:{
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_36_WIDTH; ++i) {
                        for (int j = 0; j <32; ++j)
                            init_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + j]);
                        for (int k = 32; k < BRAM_WIDTH_36; k++)
                            init_parity_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + k]);
                    }
                break;
            }
            default: {
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_36_WIDTH; ++i) {
                        for (int j = 0; j <32; ++j)
                            init_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + j]);
                        for (int k = 32; k < BRAM_WIDTH_36; k++)
                            init_parity_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + k]);
                    }
                break;
            }
        }
    }
    else if ((cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_TDP")) || (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_SDP"))){
        RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
        switch (mode.as_int()) {
            case 9:
            case 18:{
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_18_WIDTH; ++i) {
                        for (int j = 0; j <16; ++j)
                            init_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                        for (int k = 16; k < BRAM_WIDTH_18; k++)
                            init_parity_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + k]);
                    }
                break;
            }
            default: {
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_18_WIDTH; ++i) {
                        for (int j = 0; j <16; ++j)
                            init_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                        for (int k = 16; k < BRAM_WIDTH_18; k++)
                            init_parity_value1.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + k]);
                    }
                break;
            }
        }
    }
    cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));
    cell->setParam(RTLIL::escape_id("INIT_PARITY"), RTLIL::Const(init_parity_value1));
}


    bool SetParityTDPmode(Cell* cell) {
        bool set_parity {false};

        /*Checking byte-write condition for write Ports*/
        if ((cell->hasParam(RTLIL::escape_id("PORT_B_Parity")) && cell->getParam(RTLIL::escape_id("PORT_B_Parity")) == State::S1) ||
            (cell->hasParam(RTLIL::escape_id("PORT_D_Parity")) && cell->getParam(RTLIL::escape_id("PORT_D_Parity")) == State::S1))
            set_parity =true;
        /*Checking RAM condition with two write Ports*/
        else if ((cell->hasParam(RTLIL::escape_id("PORT_D_DATA_WIDTH"))) && (cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")) != State::S0)
             && (cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")) != State::S0)) {

            set_parity = (get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_B_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")))) &&
            get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_D_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")))));
            if (!set_parity) {
                //Symmetric RAM INIT Condition without parity bits
                if (cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")) == cell->getParam(RTLIL::escape_id("PORT_D_WIDTH"))){
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")));  
                }
            }
        }
        /*Checking RAM condition with single write Port*/
        else if (!(cell->hasParam(RTLIL::escape_id("PORT_D_DATA_WIDTH"))) && (cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")) != State::S0)
            && (cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")) != State::S0)) {

            cell->setParam(stringf("\\PORT_D_DATA_WIDTH"), cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")));
            set_parity = (get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_B_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")))) &&
            get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_D_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")))));
            if (!set_parity) {
                //Symmetric RAM INIT Condition without parity bits
                if (cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")) == cell->getParam(RTLIL::escape_id("PORT_D_WIDTH"))){
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")));  
                }
            }
        }
        /*Checking ROM condition with only readports*/
        else if ((cell->hasParam(RTLIL::escape_id("PORT_D_DATA_WIDTH"))) && (cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")) == State::S0)
            && (cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")) == State::S0)) {

            set_parity = (get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_C_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_C_DATA_WIDTH")))) &&
            get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_A_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_A_DATA_WIDTH")))));
            if (!set_parity) {
                //Symmetric ROM INIT Condition without parity bits
                if (cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")) == cell->getParam(RTLIL::escape_id("PORT_C_WIDTH"))){
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")));  
                }
            }
        }
        else
        {
            set_parity = (get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_B_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")))) &&
            get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_D_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")))));
        }
        return set_parity;
    }

    bool SetParitySDPmode(Cell* cell) {
        bool set_parity {false};
        /*Checking byte-write condition for write Port*/
        if ((cell->hasParam(RTLIL::escape_id("PORT_B_Parity")) && cell->getParam(RTLIL::escape_id("PORT_B_Parity")) == State::S1))
            set_parity =true;
        /*Checking RAM condition*/
        else if ((cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH")) != State::S0)){
            set_parity = get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_B_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_B_DATA_WIDTH"))) );
            if (!set_parity) {
                //Symmetric RAM INIT Condition without parity bits
                if (cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")) == cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")))
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")));
                //Asymmetric RAM INIT Condition without parity bits take the min width
                else if (cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")) < cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")))
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")));
                else
                    Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_B_WIDTH")));
            }
        }
        /*ROM condition with only readport*/
        else{
            set_parity = get_parity_36_mode((cell->getParam(RTLIL::escape_id("PORT_A_WIDTH"))),(cell->getParam(RTLIL::escape_id("PORT_A_DATA_WIDTH"))) );
            if (!set_parity)
                Set_INIT_PlacementWithNoParity_mode(cell,cell->getParam(RTLIL::escape_id("PORT_A_WIDTH")));
        }
        return set_parity;
    }

    bool get_parity_36_mode(RTLIL::Const port_width, RTLIL::Const port_data_width) {
        bool set_parity;
        if (port_width == BRAM_WIDTH_1) {
            set_parity = true;
        }
        else if (port_width == BRAM_WIDTH_2) {
            set_parity = true;
        }
        else if (port_width == BRAM_WIDTH_4) {
            set_parity = true;
        }
        else if (  port_width == BRAM_WIDTH_9) {
            set_parity = true;
        }
        else if ( (port_width == BRAM_WIDTH_18) && (port_data_width == BRAM_WIDTH_18)) {
            set_parity = true;
        }
        else if ((port_width == BRAM_WIDTH_36) && (port_data_width == 27)) {
            set_parity = true;
        }
        else if ( (port_width == BRAM_WIDTH_36) && (port_data_width == BRAM_WIDTH_36)) {
            set_parity = true;
        }
        else 
            set_parity = false;

        return set_parity;
    }
    /*  To check whether we have a missing param for TDP CASE, if yes then assign default value.
        This condition occurs when we have two write ports and a single read port for TDP.
        To avoid error this is needed so that we can easily merge two 18TDP RAMs for new FPGA_PRIMITIVES_MODELS.
    */
    void CHECK_PARAM(){
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                if (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_TDP") ||
                    (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_TDP"))){
                        if (!(cell->hasParam(RTLIL::escape_id("PORT_C_DATA_WIDTH"))))
                            cell->setParam(stringf("\\PORT_C_DATA_WIDTH"), cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")));
                }
            }
        }
    }
    void Set_SDPBram_InitValues(){
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                //For  $__RS_FACTOR_BRAM36_SDP
                if (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_SDP"))
                {
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1;
                    std::vector<RTLIL::State> init_parity_value1;
                    std::vector<RTLIL::State> init_temp;

                    if (SetParitySDPmode(cell)){
                        for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_36_WIDTH; ++i) {
                            for (int j = 0; j <BRAM_WIDTH_36; ++j)
                                init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + j]);
                            // Separating the data and parity bits
                            for (int m = 0; m < BRAM_first_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // Data bits [7:0]
                            init_parity_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // Data bits [16:9]
                            init_parity_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                            for (int m = 18; m < BRAM_third_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // Data bits [25:18]
                            init_parity_value1.push_back(init_temp[BRAM_third_byte_parity_bit]);
                            for (int m = 27; m < BRAM_fourth_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // Data bits [27:34]
                            init_parity_value1.push_back(init_temp[BRAM_fourth_byte_parity_bit]);
                            init_temp.clear();
                        }
                        cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));
                        cell->setParam(RTLIL::escape_id("INIT_PARITY"), RTLIL::Const(init_parity_value1));
                    }
                }
               
                /// For  $__RS_FACTOR_BRAM18_SDP
                else if ((cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_SDP"))) 
                {
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1;
                    std::vector<RTLIL::State> init_parity_value1;
                    std::vector<RTLIL::State> init_temp;

                    if (SetParitySDPmode(cell)){
                        for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_36_WIDTH; ++i) {
                            for (int j = 0; j <BRAM_WIDTH_18; ++j)
                                init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                            // Separating the data and parity bits
                            for (int m = 0; m < BRAM_first_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// Data bits [7:0]
                            init_parity_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// Data bits [16:9]
                            init_parity_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                            init_temp.clear();
                        }
                        cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));
                        cell->setParam(RTLIL::escape_id("INIT_PARITY"), RTLIL::Const(init_parity_value1));
                    }
                }   
            }
        }
    }

    void Set_TDPBram_InitValues(){
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                 //For  $__RS_FACTOR_BRAM36_TDP 
                if (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_TDP")){
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1; 
                    std::vector<RTLIL::State> init_parity_value1;
                    std::vector<RTLIL::State> init_temp;
                    if (SetParityTDPmode(cell)){
                        for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_36_WIDTH; ++i) {
                            for (int j = 0; j <BRAM_WIDTH_36; ++j)
                                init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_36 + j]);
                            // Separating the data and parity bits    
                            for (int m = 0; m < BRAM_first_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // data bits[7:0]
                            init_parity_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]); // data bits[16:9]
                            init_parity_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                            for (int m = 18; m < BRAM_third_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// data bits[25:18]
                            init_parity_value1.push_back(init_temp[BRAM_third_byte_parity_bit]);
                            for (int m = 27; m < BRAM_fourth_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// data bits[34:27]
                            init_parity_value1.push_back(init_temp[BRAM_fourth_byte_parity_bit]);
                            init_temp.clear();
                        }
                        cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1)); // Assigning data bits
                        cell->setParam(RTLIL::escape_id("INIT_PARITY"), RTLIL::Const(init_parity_value1)); //Assigning parity bits
                    }
                }
                /// For  $__RS_FACTOR_BRAM18_TDP
                else if ((cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_TDP"))) 
                {
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1;
                    std::vector<RTLIL::State> init_parity_value1;
                    std::vector<RTLIL::State> init_temp;
                    if (SetParityTDPmode(cell)){
                        for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_18_WIDTH; ++i) {
                            for (int j = 0; j <BRAM_WIDTH_18; ++j)
                                init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                            // Separating the data and parity bits
                            for (int m = 0; m < BRAM_first_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// Data bits[7:0]
                            init_parity_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);// Data bits[16:9]
                            init_parity_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                            init_temp.clear();
                        }
                        cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));// Assigning data bits
                        cell->setParam(RTLIL::escape_id("INIT_PARITY"), RTLIL::Const(init_parity_value1));//Assigning parity bits
                    }
                }
                CHECK_PARAM();
            }
        }
    }
    // BRAM INIT mapping scheme for (old version of genesis3), genesis2 and genesis techlogies 
    void SET_GEN2_InitValues(){
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                //For $__RS_FACTOR_BRAM36_TDP and $__RS_FACTOR_BRAM36_SDP
                if (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_TDP") ||
                    (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_SDP")))
                {
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1;
                    std::vector<RTLIL::State> init_value2;
                    std::vector<RTLIL::State> init_temp;
                    std::vector<RTLIL::State> init_temp2;
                    for (int i = 0; i < BRAM_MAX_ADDRESS_FOR_18_WIDTH; ++i) {
                        if (i % 2 == 0){
                            for (int j = 0; j <BRAM_WIDTH_18; ++j)
                                init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                            for (int k = 0; k < BRAM_first_byte_parity_bit; k++)
                                init_value1.push_back(init_temp[k]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value1.push_back(init_temp[m]);
                            init_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);//placed at location [16]
                            init_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                            init_temp.clear();
                        }
                        else
                        {
                            for (int j = 0; j <BRAM_WIDTH_18; ++j)
                                init_temp2.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                            for (int k = 0; k < BRAM_first_byte_parity_bit; k++)
                                init_value2.push_back(init_temp2[k]);
                            for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                                init_value2.push_back(init_temp2[m]);
                            init_value2.push_back(init_temp2[BRAM_first_byte_parity_bit]);//placed at location [16]
                            init_value2.push_back(init_temp2[BRAM_second_byte_parity_bit]);
                            init_temp2.clear();
                        }
                    }
                    init_value1.insert(std::end(init_value1), std::begin(init_value2), std::end(init_value2));
                    cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));
                }
                /// For 18/9/4/2/1 bit modes in case of $__RS_FACTOR_BRAM18_TDP and $__RS_FACTOR_BRAM18_SDP
                else if ((cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_TDP")) ||
                        (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_SDP"))) 
                {
                    RTLIL::Const tmp_init = cell->getParam(RTLIL::escape_id("INIT"));
                    std::vector<RTLIL::State> init_value1;
                    std::vector<RTLIL::State> init_temp;
                    int width_size = BRAM_MAX_ADDRESS_FOR_36_WIDTH;
                    for (int i = 0; i < width_size; ++i) {
                        for (int j = 0; j <BRAM_WIDTH_18; ++j)
                            init_temp.push_back(tmp_init.bits[i*BRAM_WIDTH_18 + j]);
                        for (int k = 0; k < BRAM_first_byte_parity_bit; k++)
                            init_value1.push_back(init_temp[k]);
                        for (int m = 9; m < BRAM_second_byte_parity_bit; m++) 
                            init_value1.push_back(init_temp[m]);
                        init_value1.push_back(init_temp[BRAM_first_byte_parity_bit]);//placed at location [16]
                        init_value1.push_back(init_temp[BRAM_second_byte_parity_bit]);
                        init_temp.clear();
                    }
                    cell->setParam(RTLIL::escape_id("INIT"), RTLIL::Const(init_value1));
                }
            }
        }
    }
    /* Lia: When data width is greater than 18 bits reading is performed from 
     * two 18K RAMs, so we need to split Init bits to 2x18 bit pairs, first half
     * will go to the first 18K RAM and the second half to the second 18k RAM.
     */
    void correctBramInitValues() {
        switch (tech) {
            case Technologies::GENESIS:
            case Technologies::GENESIS_2:{
                SET_GEN2_InitValues();
                break;
            }
        case Technologies::GENESIS_3: {
                /*
                 Based on new RS_TDP Bram primitves(TDP_RAM36K & TDP_RAM18KX2) bram initialization 
                 is handled such that data and parity bits are separated and assigned to INIT and 
                 INIT_PARITY parameters respectively.
                */
                if (new_tdp36k && (tech == Technologies::GENESIS_3)){
                    Set_TDPBram_InitValues(); // set TDP BRAM
                    Set_SDPBram_InitValues(); // set SDP BRAM
                }
                else
                    SET_GEN2_InitValues(); 
                break;
            }
        case Technologies::GENERIC: {
                break;
            }
        }
    }

    std::string get_bram_mapping_file1(){
        std::string bramMapFile = "";
        return bramMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_MAP_NEW_VERSION_FILE);
    }

    std::string get_bram_mapping_file2(){
        std::string bramMapFile = "";
        return bramMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_FINAL_MAP_NEW_VERSION_FILE);
    }
    //Suppose to map on new TDP36K BRAM primitive 
    void run_new_version_of_tdp36K_mapping(){

        std::string bramTxtSwap = GET_FILE_PATH(GENESIS_3_DIR, BRAM_LIB_SWAP);
        std::string bramTxt = "";
        std::string bramAsyncTxt = "";
        std::string bramMapFile = "";
        std::string bramFinalMapFile = "";
        if(nolibmap) {
            bramTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_TXT);
            bramAsyncTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_ASYNC_TXT);
            bramMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_MAP_FILE);
            bramFinalMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_FINAL_MAP_FILE);
            run("memory_bram -rules" + bramTxt);
            if (areMemCellsLeft()) {
                run("memory_bram -rules" + bramAsyncTxt);
            }
            run("rs_bram_split -tech genesis");
            run("techmap -autoproc -map" + bramMapFile);
            run("techmap -map" + bramFinalMapFile);
            
        } else {
                bramTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_LIB);
                bramMapFile = get_bram_mapping_file1();
                bramFinalMapFile = get_bram_mapping_file2();
                run("memory_libmap -lib" + bramTxtSwap + " -tech genesis3" +" -limit " + std::to_string(max_bram) + " a:read_swapped");
                run("memory_libmap -lib" + bramTxt + " -tech genesis3" +" -limit " + std::to_string(max_bram));
                correctBramInitValues();
                run("rs_bram_split -new_mapping -tech genesis3");
                run("techmap -autoproc -map" + bramMapFile);
                run("techmap -map" + bramFinalMapFile);
        }
    }


    void mapBrams() {
        std::string bramTxt = "";
        std::string bramTxtSwap = "";
        std::string bramAsyncTxt = "";
        std::string bramMapFile = "";
        std::string bramFinalMapFile = "";

        switch (tech) {
            case Technologies::GENESIS: {
                if(nolibmap) {
                    bramTxt = GET_FILE_PATH(GENESIS_DIR, BRAM_TXT);
                    bramAsyncTxt = GET_FILE_PATH(GENESIS_DIR, BRAM_ASYNC_TXT);
                    bramMapFile = GET_FILE_PATH(GENESIS_DIR, BRAM_MAP_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_DIR, BRAM_FINAL_MAP_FILE);
                } else {
                    bramTxt = GET_FILE_PATH(GENESIS_DIR, BRAM_LIB);
                    bramMapFile = GET_FILE_PATH(GENESIS_DIR, BRAM_MAP_NEW_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_DIR, BRAM_FINAL_MAP_NEW_FILE);
                }
                break;
            }
            case Technologies::GENESIS_2: {
                bramTxtSwap = GET_FILE_PATH(GENESIS_2_DIR, BRAM_LIB_SWAP);
                if(nolibmap) {
                    bramTxt = GET_FILE_PATH(GENESIS_2_DIR, BRAM_TXT);
                    bramAsyncTxt = GET_FILE_PATH(GENESIS_2_DIR, BRAM_ASYNC_TXT);
                    bramMapFile = GET_FILE_PATH(GENESIS_2_DIR, BRAM_MAP_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_2_DIR, BRAM_FINAL_MAP_FILE);
                } else {
                    bramTxt = GET_FILE_PATH(GENESIS_2_DIR, BRAM_LIB);
                    bramMapFile = GET_FILE_PATH(GENESIS_2_DIR, BRAM_MAP_NEW_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_2_DIR, BRAM_FINAL_MAP_NEW_FILE);
                }
                break;
            }
            case Technologies::GENESIS_3: {
                bramTxtSwap = GET_FILE_PATH(GENESIS_3_DIR, BRAM_LIB_SWAP);
                if(nolibmap) {
                    bramTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_TXT);
                    bramAsyncTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_ASYNC_TXT);
                    bramMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_MAP_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_FINAL_MAP_FILE);
                } else {
                    bramTxt = GET_FILE_PATH(GENESIS_3_DIR, BRAM_LIB);
                    bramMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_MAP_NEW_FILE);
                    bramFinalMapFile = GET_FILE_PATH(GENESIS_3_DIR, BRAM_FINAL_MAP_NEW_FILE);
                }
                break;
            }

            case Technologies::GENERIC: {
                break;
            }
        }
        switch (tech) {
            case Technologies::GENESIS:
            case Technologies::GENESIS_3:
            case Technologies::GENESIS_2: {
                    /* Aram: Disabled as it's not supported
                     *run("rs_bram_asymmetric");
                     */
                    if (nolibmap) {
                        run("memory_bram -rules" + bramTxt);
                        if (areMemCellsLeft()) {
                            run("memory_bram -rules" + bramAsyncTxt);
                        }
                        run("rs_bram_split -tech genesis");
                        run("techmap -autoproc -map" + bramMapFile);
                        run("techmap -map" + bramFinalMapFile);
                    }
                    else {
                        /* Aram: Yosys swaps read ports for the single clock TDP
                         * memories when the address is registered. The first call
                         * to memory_libmap is for these memeories. We counter swap
                         * port mappings to get correct connections for the read ports.
                         */
                        if (tech != Technologies::GENESIS)
                            run("memory_libmap -lib" + bramTxtSwap + " -tech genesis" +" -limit " + std::to_string(max_bram) + " a:read_swapped");
                        run("memory_libmap -lib" + bramTxt + " -tech genesis" +" -limit " + std::to_string(max_bram));
                        correctBramInitValues();
                        run("rs_bram_split -new_mapping -tech genesis");
                        run("techmap -autoproc -map" + bramMapFile);
                        run("techmap -map" + bramFinalMapFile);
                    }
                    if (cec)
                        run("write_verilog -noattr -nohex after_bram_map.v");
                break;
            }
            case Technologies::GENERIC: {
                break;
            }
        }
    }

    void postProcessBrams() {
        if (areMemCellsLeft()) {
            if (nobram) {
                log("\n"); // Skip line to make the warning more focused.
                log_warning("Forcing to use BRAMs.\n");
                //If (-new_tdp36 flag is given then it will run new mapping for Gensis3 primitves)
                if (new_tdp36k && (tech == Technologies::GENESIS_3)){
                    run_new_version_of_tdp36K_mapping();
                }
                //old mapping for Gensis3 primitves runs
                else{
                    mapBrams();
                }
                
                if (areMemCellsLeft()) {
                    reportUnmappedRams();
                }
            }
            else {
                reportUnmappedRams();
            }
        }
    }

    bool areMemCellsLeft() {
        for (auto module : _design->selected_modules()) {
            auto memCells = Mem::get_selected_memories(module);
            if (memCells.size())
                return true;
        }
        return false;
    }

    void reportUnmappedRams() {
        std::stringstream msg;
        msg << "Failed to map RAM(s) on technology specific BRAM.\n";
        for (auto module : _design->selected_modules()) {
            auto memCells = Mem::get_selected_memories(module);
            for (auto mem : memCells) {
                msg << "  Signal: " << mem.memid.str().substr(1) << ", ";
                msg << "Src: " << mem.get_src_attribute().c_str() << "\n";
            }
        }
        msg << "NOTE: Please review MEMORY_BRAM pass logs for details.\n";
        log("\n"); // Skip line to make the error more focused.
        log_error("%s\n", msg.str().c_str());
    }


    //check if internal 3 states exist
    // This is for Gemini 


    void check_internal_3states(){
        int tri_nError =0;
        int tri_max =20;
        for (auto cell : _design->top_module()->cells()){
            if(cell->type.in(ID($tribuf), ID($_TBUF_),ID($assert))){

                std::string inst_names= log_id(cell->name);
                std::regex pattern1("\\$tribuf_conflict\\$");
                std::regex pattern2("\\$\\d+$");
                std::regex pattern3(".*\\$");
                std::string out = std::regex_replace(inst_names,pattern1,"");
                out = std::regex_replace(out,pattern2,"");
                out = std::regex_replace(out,pattern3,"");
                
                if(tri_nError < tri_max){
                    log_warning("Does not support internal 3-states.Please change the RTL at %s. \n", out.c_str());
                }
                else if (tri_nError == tri_max){
                    log_warning("..\n");
                }
                tri_nError++;
            }
        }
        if(tri_nError){
            log_error("Cannot map %d internal 3-states Abort Synthesis  \n",tri_nError);
        }
    }

    // Check if DLATCH has been found.
    // This is specific for Genesis3 since it does not support DLATCH   
    //
    void check_DLATCH(){
        int nError =0;
        int maxDL= 20;
        for (auto cell : _design->top_module()->cells()){
            if (!RTLIL::builtin_ff_cell_types().count(cell->type))
            continue;

            if (cell->type.in(
#if 0
                            ID($_DLATCH_N_),
                            ID($_DLATCH_P_),
                            ID($_DLATCH_NN0_),
                            ID($_DLATCH_NN1_),
                            ID($_DLATCH_NP0_),
                            ID($_DLATCH_NP1_),
                            ID($_DLATCH_PN0_),
                            ID($_DLATCH_PN1_),
                            ID($_DLATCH_PP0_),
                            ID($_DLATCH_PP1_),
#endif
                            ID($_DLATCHSR_NNN_),
                            ID($_DLATCHSR_NNP_),
                            ID($_DLATCHSR_NPN_),
                            ID($_DLATCHSR_NPP_),
                            ID($_DLATCHSR_PNN_),
                            ID($_DLATCHSR_PNP_),
                            ID($_DLATCHSR_PPN_),
                            ID($_DLATCHSR_PPP_))){
                                string instName = log_id(cell->name);
                                std::stringstream buf;
                                for (auto &it : cell->attributes) {
                                    RTLIL_BACKEND::dump_const(buf, it.second);
                                }
                                if(nError < maxDL){
                                    log_warning("Generic DLATCH '%s' (type %s) is not supported by the architecture. Please rewrite the RTL at %s to avoid a LATCH behavior.\n", instName.c_str(),log_id(cell->type),buf.str().c_str());
                                }
                                else if (nError == maxDL){
                                    log_warning("..\n");
                                }
                            nError++;
                            }
        }
        if(nError){
            log_error("Cannot map %d Generic DLATCH. Abort Synthesis \n",nError);
        }
    }



    // Make sure we do not have DFFs with async. SR. Report if any and abort at the end.
    // This is specific for Genesis3 since it does not support DFFs with async. SR.
    //
    void check_DFFSR() 
    {
       SigMap sigmap(_design->top_module());
       FfInitVals initvals(&sigmap, _design->top_module());
       int nbErrors = 0;
       int maxPrintOut = 20; // Print out the first 'maxPrintOut' DFF with async. SR

       for (auto cell : _design->top_module()->cells()) {

          if (!RTLIL::builtin_ff_cell_types().count(cell->type))
              continue;

          FfData ff(&initvals, cell);

          if (ff.has_sr) {

              string instName = log_id(ff.name);
              std::stringstream buf;
              for (auto &it : cell->attributes) {
                    RTLIL_BACKEND::dump_const(buf, it.second);
                }
              if (nbErrors < maxPrintOut) {

                 log_warning("Synchronous register element Generic DFF '%s' (type %s) describes both asynchrnous set and reset function and not supported by the architecture. Please update the RTL at %s to either change the description to synchronous set/reset or a static 0 or 1 value.\n", instName.c_str(),log_id(ff.cell->type),buf.str().c_str());

              } else if (nbErrors == maxPrintOut) {
                log_warning("...\n");
              }

              nbErrors++;
          }
       }

       if (nbErrors) {
          log_error("Cannot map %d Generic DFFs. Abort Synthesis.\n", nbErrors);
       }
    }

static std::string id(RTLIL::IdString internal_id)
{
        const char *str = internal_id.c_str();
        return std::string(str);
}

static void dump_const(const RTLIL::Const &data, int width = -1, int offset = 0, bool no_decimal = false, bool escape_comment = false)
{
        bool set_signed = (data.flags & RTLIL::CONST_FLAG_SIGNED) != 0;
        if (width < 0)
                width = data.bits.size() - offset;
        if (width == 0) {
                log("{0{1'b0}}");
                return;
        }
#if 0
        if (nostr)
                goto dump_hex;
#endif
        if ((data.flags & RTLIL::CONST_FLAG_STRING) == 0 || width != (int)data.bits.size()) {
                if (width == 32 && !no_decimal && 1) {
                        int32_t val = 0;
                        for (int i = offset+width-1; i >= offset; i--) {
                                log_assert(i < (int)data.bits.size());
                                if (data.bits[i] != State::S0 && data.bits[i] != State::S1)
                                        goto dump_hex;
                                if (data.bits[i] == State::S1)
                                        val |= 1 << (i - offset);
                        }
                        if (1)
                                log("%d", val);
                        else if (set_signed && val < 0)
                                log("-32'sd%u", -val);
                        else
                                log("32'%sd%u", set_signed ? "s" : "", val);
                } else {
        dump_hex:
                        if (1)
                                goto dump_bin;
                        vector<char> bin_digits, hex_digits;
                        for (int i = offset; i < offset+width; i++) {
                                log_assert(i < (int)data.bits.size());
                                switch (data.bits[i]) {
                                case State::S0: bin_digits.push_back('0'); break;
                                case State::S1: bin_digits.push_back('1'); break;
                                case RTLIL::Sx: bin_digits.push_back('x'); break;
                                case RTLIL::Sz: bin_digits.push_back('z'); break;
                                case RTLIL::Sa: bin_digits.push_back('?'); break;
                                case RTLIL::Sm: log_error("Found marker state in final netlist.");
                                }
                        }
                        if (GetSize(bin_digits) == 0)
                                goto dump_bin;
                        while (GetSize(bin_digits) % 4 != 0)
                                if (bin_digits.back() == '1')
                                        bin_digits.push_back('0');
                                else
                                        bin_digits.push_back(bin_digits.back());
                        for (int i = 0; i < GetSize(bin_digits); i += 4)
                        {
                                char bit_3 = bin_digits[i+3];
                                char bit_2 = bin_digits[i+2];
                                char bit_1 = bin_digits[i+1];
                                char bit_0 = bin_digits[i+0];
                                if (bit_3 == 'x' || bit_2 == 'x' || bit_1 == 'x' || bit_0 == 'x') {
                                        if (bit_3 != 'x' || bit_2 != 'x' || bit_1 != 'x' || bit_0 != 'x')
                                                goto dump_bin;
                                        hex_digits.push_back('x');
                                        continue;
                                }
                                if (bit_3 == 'z' || bit_2 == 'z' || bit_1 == 'z' || bit_0 == 'z') {
                                        if (bit_3 != 'z' || bit_2 != 'z' || bit_1 != 'z' || bit_0 != 'z')
                                                goto dump_bin;
                                        hex_digits.push_back('z');
                                        continue;
                                }
                                if (bit_3 == '?' || bit_2 == '?' || bit_1 == '?' || bit_0 == '?') {
                                        if (bit_3 != '?' || bit_2 != '?' || bit_1 != '?' || bit_0 != '?')
                                                goto dump_bin;
                                        hex_digits.push_back('?');
                                        continue;
                                }
                                int val = 8*(bit_3 - '0') + 4*(bit_2 - '0') + 2*(bit_1 - '0') + (bit_0 - '0');
                                hex_digits.push_back(val < 10 ? '0' + val : 'a' + val - 10);
                        }
                        log("%d'%sh", width, set_signed ? "s" : "");
                        for (int i = GetSize(hex_digits)-1; i >= 0; i--)
                                log(hex_digits[i]);
                }
                if (0) {
        dump_bin:
                        log("%d'%sb", width, set_signed ? "s" : "");
                        if (width == 0)
                                log("0");
                        for (int i = offset+width-1; i >= offset; i--) {
                                log_assert(i < (int)data.bits.size());
                                switch (data.bits[i]) {
                                case State::S0: log("0"); break;
                                case State::S1: log("1"); break;
                                case RTLIL::Sx: log("x"); break;
                                case RTLIL::Sz: log("z"); break;
                                case RTLIL::Sa: log("?"); break;
                                case RTLIL::Sm: log_error("Found marker state in final netlist.");
                                }
                        }
                }
        } else {
                if ((data.flags & RTLIL::CONST_FLAG_REAL) == 0)
                        log("\"");
                std::string str = data.decode_string();
                for (size_t i = 0; i < str.size(); i++) {
                        if (str[i] == '\n')
                                log("\\n");
                        else if (str[i] == '\t')
                                log("\\t");
                        else if (str[i] < 32)
                                log("\\%03o", str[i]);
                        else if (str[i] == '"')
                                log("\\\"");
                        else if (str[i] == '\\')
                                log("\\\\");
                        else if (str[i] == '/' && escape_comment && i > 0 && str[i-1] == '*')
                                log("\\/");
                        else
                                log(str[i]);
                }
                if ((data.flags & RTLIL::CONST_FLAG_REAL) == 0)
                        log("\"");
        }
}

static void dump_sigchunk(const RTLIL::SigChunk &chunk, bool no_decimal = false)
{
    if (chunk.wire == NULL) {
        dump_const(chunk.data, chunk.width, chunk.offset, no_decimal);
        return;
    }

    if (chunk.width == chunk.wire->width && chunk.offset == 0) {

        log("%s", id(chunk.wire->name).c_str());

    } else if (chunk.width == 1) {

        if (chunk.wire->upto)
            log("%s[%d]", id(chunk.wire->name).c_str(),
                (chunk.wire->width - chunk.offset - 1) + chunk.wire->start_offset);
        else
            log("%s[%d]", id(chunk.wire->name).c_str(), chunk.offset + chunk.wire->start_offset);

    } else {

        if (chunk.wire->upto)
             log("%s[%d:%d]", id(chunk.wire->name).c_str(),
                 (chunk.wire->width - (chunk.offset + chunk.width - 1) - 1) + chunk.wire->start_offset,
                 (chunk.wire->width - chunk.offset - 1) + chunk.wire->start_offset);
        else
             log("%s[%d:%d]", id(chunk.wire->name).c_str(),
                 (chunk.offset + chunk.width - 1) + chunk.wire->start_offset,
                 chunk.offset + chunk.wire->start_offset);
    }
}

static void show_sig(const RTLIL::SigSpec &sig)
{
        if (GetSize(sig) == 0) {
           log("{0{1'b0}}");
           return;
        }

        if (sig.is_chunk()) {

            dump_sigchunk(sig.as_chunk());

        } else {

            log("{ ");

            for (auto it = sig.chunks().rbegin(); it != sig.chunks().rend(); ++it) {

                 if (it != sig.chunks().rbegin())
                    log(", ");

                 dump_sigchunk(*it, true);
            }
            log(" }");
        }
}
 
    void dumpSig(std::ofstream &json_file, const RTLIL::SigSpec &sig)
    {
        const RTLIL::SigChunk chunk = sig.as_chunk();

        const char* name = "\\";

        if (chunk.width == chunk.wire->width && chunk.offset == 0) {
          name = id(chunk.wire->name).c_str();
        }
        // any name is prefixed with '\' so we need to remove it
        name++;

        json_file << "\"";
        json_file << name;
        json_file << "\"";
    }

    std::string* sigName(const RTLIL::SigSpec &sig)
    {
        const RTLIL::SigChunk chunk = sig.as_chunk();

        const char* name = "\\";

        if (chunk.width == chunk.wire->width && chunk.offset == 0) {
          name = id(chunk.wire->name).c_str();
        }
        // any name is prefixed with '\' so we need to remove it
        name++;

        std::string* sName = new std::string;
        *sName = std::string(name);

        return sName;
    }

    int checkCell(Cell* cell, const string cellName, 
                  const string& port1, std::set<std::string>& pp_group1, std::set<std::string>& pp_activeValue1,
                  const string& port2, std::set<std::string>& pp_group2, std::set<std::string>& pp_activeValue2)
    {
      if (cell->type != RTLIL::escape_id(cellName)) {
        return 0;
      }

      for (auto &conn : cell->connections()) {

          IdString portName = conn.first;
          RTLIL::SigSpec actual = conn.second;

          if (portName == RTLIL::escape_id(port1)) {
             std::string* actualName = sigName(actual);
             pp_group1.insert(*actualName);
             pp_activeValue1.insert(*actualName);
             continue;
          }

          if (portName == RTLIL::escape_id(port2)) {
             std::string* actualName = sigName(actual);
             pp_group2.insert(*actualName);
             pp_activeValue2.insert(*actualName);
             continue;
          }
      }

      return 1;
    }

    void writePortProperties(string jsonFileName)
    {
        run("design -save original");

        run("splitnets -ports");

        run(stringf("hierarchy -check %s", top_opt.c_str()));

        Module* topModule = _design->top_module();

        const char* topName = topModule->name.c_str();
        topName++; // skip the escape 


        log("\nDumping port properties into '%s' file.\n\n", jsonFileName.c_str());

        // Now dump the extracted port properties info into a json file
        //
        bool firstLine = true;

        std::ofstream json_file(jsonFileName);

        json_file << "{\n";

        json_file << "  \"top\" : \"";
        json_file << topName;
        json_file << "\",\n";

        json_file << "  \"ports\" : [\n";

        for (auto wire : _design->top_module()->wires()) {

           if (!wire->port_input && !wire->port_output) {
             continue;
           }

           RTLIL::SigSpec io = wire;

           if (firstLine) {
             firstLine = false;
           } else {
             json_file << ",\n";
           }

           json_file << "     {\n";

           json_file << "        \"name\": ";

           dumpSig(json_file, io);

           std::string* ioName = sigName(io);

           json_file << ",\n";

           if (wire->port_input) {
             json_file << "        \"direction\": \"input\"";
           } else {
             json_file << "        \"direction\": \"output\"";
           }

           if (pp_clocks.count(*ioName)) {
             json_file << ",\n        \"clock\": ";

             if (pp_activeHigh.count(*ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(*ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_asyncReset.count(*ioName)) {
             json_file << ",\n        \"async_reset\": ";
             if (pp_activeHigh.count(*ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(*ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_asyncSet.count(*ioName)) {
             json_file << ",\n        \"async_set\": ";
             if (pp_activeHigh.count(*ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(*ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_syncReset.count(*ioName)) {
             json_file << ",\n        \"sync_reset\": ";
             if (pp_activeHigh.count(*ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(*ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_syncSet.count(*ioName)) {
             json_file << ",\n        \"sync_set\": ";
             if (pp_activeHigh.count(*ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(*ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else {
               json_file << "\n";
           }

           json_file << "     }";
        }

        json_file << "\n   ]\n";
        json_file << "}\n";

        json_file.close();

        run("design -load original");

    }

    // EDA-2594 requirement : 
    //
    // Dump a JSON file storing top level ports properties like :
    //
    //    - direction : input/output
    //    - clocked : no or active low or high
    //    - async set/reset : no or set or reset. Active low or high
    //    - sync set/reset : no or set or reset. Active low or high
    //
    // Example :
    // 
    //  {
    //    "ports" : [
    //       {
    //          "name": "a",
    //          "direction": "input"
    //       },
    //       {
    //          "name": "b",
    //          "direction": "input"
    //       },
    //       {
    //          "name": "c",
    //          "direction": "output"
    //       },
    //       {
    //          "name": "clk",
    //          "direction": "input",
    //          "clock": "active_high"
    //       },
    //       {
    //          "name": "enable",
    //          "direction": "input"
    //       },
    //       {
    //          "name": "reset",
    //          "direction": "input",
    //          "sync_reset": "active_high"
    //       }
    //     ]
    //  }
    //
    void collectPortProperties()
    {

        run("design -save original");

        run("splitnets -ports");

        // visit all the cells of the design an store info.
        //

        for (auto cell : _design->top_module()->cells()) {
#if 0
           log("Cell = %s\n", (cell->type).c_str());
#endif

           if (cell->type == RTLIL::escape_id("$lut")) {
              continue;
           }

           // Case of DFF without any set/reset
           //
           if ((cell->type == RTLIL::escape_id("$dff")) ||
               (cell->type == RTLIL::escape_id("$dffe"))) {

              RTLIL::Const clk_pol = cell->getParam(RTLIL::escape_id("CLK_POLARITY"));
 
              RTLIL::SigSpec clk = cell->getPort(ID::CLK);

              std::string* clkName = sigName(clk);

              // Clock
              //
              pp_clocks.insert(*clkName);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(*clkName);
              } else {
                pp_activeHigh.insert(*clkName);
              }

              continue;
           }


           // Case of DFF with synchronous set/reset
           //
           if ((cell->type == RTLIL::escape_id("$sdff")) ||
               (cell->type == RTLIL::escape_id("$sdffe"))) {

              RTLIL::Const clk_pol = cell->getParam(RTLIL::escape_id("CLK_POLARITY"));
              RTLIL::Const srst_pol = cell->getParam(RTLIL::escape_id("SRST_POLARITY"));
              RTLIL::Const srst_val = cell->getParam(RTLIL::escape_id("SRST_VALUE"));
 
              RTLIL::SigSpec clk = cell->getPort(ID::CLK);
              std::string* clkName = sigName(clk);

              RTLIL::SigSpec srst = cell->getPort(ID::SRST);
              std::string* srstName = sigName(srst);

              // Clock
              //
              pp_clocks.insert(*clkName);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(*clkName);
              } else {
                pp_activeHigh.insert(*clkName);
              }

              bool srst_active_low = RTLIL::const_eq(srst_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (srst_active_low) { 
                  pp_activeLow.insert(*srstName);
              } else { 
                  pp_activeHigh.insert(*srstName);
              }

              bool srst_is_reset = RTLIL::const_eq(srst_val, RTLIL::Const(0), false, false, 1).as_bool();

              if (srst_is_reset) { 
                  pp_syncReset.insert(*srstName);
              } else {
                  pp_syncSet.insert(*srstName);
              }

              continue;
           }

           // Case of DFF with asynchronous set/reset
           //
           if ((cell->type == RTLIL::escape_id("$adff")) ||
               (cell->type == RTLIL::escape_id("$adffe"))) {

              RTLIL::Const clk_pol = cell->getParam(RTLIL::escape_id("CLK_POLARITY"));
              RTLIL::Const arst_pol = cell->getParam(RTLIL::escape_id("ARST_POLARITY"));
              RTLIL::Const arst_val = cell->getParam(RTLIL::escape_id("ARST_VALUE"));
 
              RTLIL::SigSpec clk = cell->getPort(ID::CLK);
              std::string* clkName = sigName(clk);

              RTLIL::SigSpec arst = cell->getPort(ID::ARST);
              std::string* arstName = sigName(arst);

              // Clock
              //
              pp_clocks.insert(*clkName);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(*clkName);
              } else {
                pp_activeHigh.insert(*clkName);
              }

              bool arst_active_low = RTLIL::const_eq(arst_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (arst_active_low) { 
                  pp_activeLow.insert(*arstName);
              } else { 
                  pp_activeHigh.insert(*arstName);
              }

              bool arst_is_reset = RTLIL::const_eq(arst_val, RTLIL::Const(0), false, false, 1).as_bool();

              if (arst_is_reset) { 
                  pp_asyncReset.insert(*arstName);
              } else {
                  pp_asyncSet.insert(*arstName);
              }

              continue;
           }

           if (checkCell(cell, "DFFRE", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }

           if (checkCell(cell, "DFFNRE", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }

           // Check simple DFF with no set/reset (but eventually with clock Enable 'E')
           //
           if (checkCell(cell, "$_DFF_P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "", pp_fake, pp_fake)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PP_", 
                         "C", pp_clocks, pp_activeHigh,
                         "", pp_fake, pp_fake)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PN_", 
                         "C", pp_clocks, pp_activeHigh,
                         "", pp_fake, pp_fake)) {
              continue;
           }

           if (checkCell(cell, "$_DFF_N_", 
                         "C", pp_clocks, pp_activeLow,
                         "", pp_fake, pp_fake)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NP_", 
                         "C", pp_clocks, pp_activeLow,
                         "", pp_fake, pp_fake)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NN_", 
                         "C", pp_clocks, pp_activeLow,
                         "", pp_fake, pp_fake)) {
              continue;
           }

           // Process DFF with only asynchromous set/reset
           //
           // Check DFF with negative clock and async set/reset
           //
           if (checkCell(cell, "$_DFF_NP0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_NP1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_NN0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_NN1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }

           // Check DFF with positive clock and async set/reset
           //
           if (checkCell(cell, "$_DFF_PP0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_PP1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_PN0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFF_PN1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }

           // Check DFF with positive clock with clock enable and async. set/reset
           //
           if (checkCell(cell, "$_DFFE_PN0P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PN0N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PP0P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PN0N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PN1P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PN1N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PP1P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_PP1N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }

           // Check DFF with negative clock with clock enable and async. set/reset
           //
           if (checkCell(cell, "$_DFFE_NN0P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NN0N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NP0P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NN0N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NN1P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NN1N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NP1P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_DFFE_NP1N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_asyncSet, pp_activeHigh)) {
              continue;
           }


           // Process DFF with only synchromous set/reset
           //
           // Check DFF with negative clock and async set/reset
           //
           if (checkCell(cell, "$_SDFF_NP0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_NP1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_NN0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_NN1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }

           // Check DFF with positive clock and sync set/reset
           //
           if (checkCell(cell, "$_SDFF_PP0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_PP1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_PN0_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFF_PN1_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }

           // Check DFF with positive clock with clock enable and sync. set/reset
           //
           if (checkCell(cell, "$_SDFFE_PN0P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PN0N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PP0P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PN0N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PN1P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PN1N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PP1P_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_PP1N_", 
                         "C", pp_clocks, pp_activeHigh,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }

           // Check DFF with negative clock with clock enable and sync. set/reset
           //
           if (checkCell(cell, "$_SDFFE_NN0P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NN0N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NP0P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NN0N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncReset, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NN1P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NN1N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeLow)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NP1P_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }
           if (checkCell(cell, "$_SDFFE_NP1N_", 
                         "C", pp_clocks, pp_activeLow,
                         "R", pp_syncSet, pp_activeHigh)) {
              continue;
           }


           // Processed DSP38 if clocked
           //
           if (checkCell(cell, "DSP38", 
                         "CLK", pp_clocks, pp_activeHigh,
                         "RESET", pp_asyncReset, pp_activeHigh)) {
              continue;
           }

           // Process BRAM
           //
           if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;
                std::string* actualName = sigName(actual);

                if ((portName == RTLIL::escape_id("CLK_A")) || 
                    (portName == RTLIL::escape_id("CLK_B"))) {

                  pp_clocks.insert(*actualName);
                  pp_activeHigh.insert(*actualName);
                  continue;
                }
             }
             continue;
           }

           if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;
                std::string* actualName = sigName(actual);

                if ((portName == RTLIL::escape_id("CLK_A1")) ||
                    (portName == RTLIL::escape_id("CLK_A2")) ||
                    (portName == RTLIL::escape_id("CLK_B1")) ||
                    (portName == RTLIL::escape_id("CLK_B2"))) {

                  pp_clocks.insert(*actualName);
                  pp_activeHigh.insert(*actualName);
                  continue;
                }
             }
             continue;
           }

           if (cell->type == RTLIL::escape_id("RS_TDP36K")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;
                std::string* actualName = sigName(actual);

                if ((portName == RTLIL::escape_id("CLK_A1")) ||
                    (portName == RTLIL::escape_id("CLK_A2")) ||
                    (portName == RTLIL::escape_id("CLK_B1")) ||
                    (portName == RTLIL::escape_id("CLK_B2"))) {

                  pp_clocks.insert(*actualName);
                  pp_activeHigh.insert(*actualName);
                  continue;
                }
             }
             continue;
           }

        }

        run("design -load original");
    }


    void script() override
    {
        string readArgs;

        if (preserve_ip){
            RTLIL::IdString protectId("$rs_protected");
            for (auto &module : _design->selected_modules()) {
                if (module->get_bool_attribute(protectId)) {
                    run(stringf("blackbox %s", module->name.c_str()));
                    _design->unset_protcted_rtl();
                }
            }
        }

        if (check_label("begin") && tech != Technologies::GENERIC) {
            switch (tech) {
                case Technologies::GENESIS: {
                    readArgs = GET_FILE_PATH(GENESIS_DIR, SIM_LIB_FILE) 
                                GET_FILE_PATH(GENESIS_DIR, DSP_SIM_LIB_FILE);
                    break;
                }    
                case Technologies::GENESIS_2: {
                    readArgs = GET_FILE_PATH(GENESIS_2_DIR, SIM_LIB_FILE) 
                                GET_FILE_PATH(GENESIS_2_DIR, DSP_SIM_LIB_FILE) 
                                GET_FILE_PATH(GENESIS_2_DIR, BRAMS_SIM_LIB_FILE);
                    break;
                }    
                case Technologies::GENESIS_3: {
                    readArgs = GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, SIM_LIB_CARRY_FILE) 
                                GET_FILE_PATH(GENESIS_3_DIR, LLATCHES_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, DFFRE_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, DFFNRE_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT1_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT2_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT3_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT4_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT5_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, LUT6_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, CLK_BUF_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, O_BUF_SIM_FILE)
                                GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, DSP_38_SIM_FILE)
                                GET_FILE_PATH(GENESIS_3_DIR, BRAMS_SIM_NEW_LIB_FILE1)
                                GET_FILE_PATH(GENESIS_3_DIR, BRAMS_SIM_LIB_FILE);
                    break;
                }    
                // Just to make compiler happy
                case Technologies::GENERIC: {
                    break;
                }    
            }
            run("read_verilog -lib -specify -nomem2reg" GET_FILE_PATH(COMMON_DIR, SIM_LIB_FILE) + readArgs);
        }

        if (check_label("prepare")) {
            run(stringf("hierarchy -check %s", top_opt.c_str()));
            run("proc");
            
            // Collect ports properties
            //
            collectPortProperties();

            if (cec) {
                run("write_verilog -noattr -nohex after_proc.v");
            }
            sec_check("after_proc", true);

            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

            if (!no_flatten) {
              run("flatten");
            }

            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

#if 1
            // New tri-state handling (Thierry)
            //
            if (cec) {
               run("write_verilog -noexpr -noattr -nohex before_tribuf.v");
            }
            sec_check("before_tribuf", true);

            /*Added to support OBUFT  if keep_tribuf flag is given*/
            if(keep_tribuf) { //non defualt mode :we keep TRIBUF

                run("tribuf -logic");
                no_iobuf = false;
                log_warning("Ignored -no_iobuf because -keep_tribuf is used.\n");

            }else { // defualt mode : we replace TRIBUF by plain logic
                // specific Rapid Silicon merge with -rs_merge option
                //
                run("tribuf -rs_merge");

                if (cec) {
                   run("write_verilog -noexpr -noattr -nohex after_tribuf_merge_noexpr.v");
                   run("write_verilog -noattr -nohex after_tribuf_merge.v");
                }
                sec_check("after_tribuf_merge", true);

                // specific Rapid Silicon logic with -rs_logic option
                //
                run("tribuf -rs_logic -formal"); // fix EDA-1536 : add -formal to process tristate on IOs
            }
                if (cec) {
                   run("write_verilog -noexpr -noattr -nohex after_tribuf_logic.v");
                }
                sec_check("after_tribuf_logic", true);
            
#else
            // Old tri-state handling
            //
            if (keep_tribuf)
                run("tribuf -logic");
            else
                run("tribuf -logic -formal");
            
            check_internal_3states();
#endif

            run("deminout");
            run("opt_expr");
            run("opt_clean");

            if (cec) {
                run("write_verilog -noattr -nohex after_opt_clean1.v");
            }
            sec_check("after_opt_clean1", true);

            run("check");

            run("stat");

            top_run_opt(1 /* nodffe  */, 0 /* sat */, 1 /* force nosdff */, 1, 12, 0);

            if (fsm_encoding == Encoding::BINARY)
                run("fsm -encoding binary");
            else
                run("fsm -encoding one-hot");

            if (cec) {
                run("write_verilog -noattr -nohex after_fsm.v");
            }
            sec_check("after_fsm", true);

            run("wreduce -keepdc");
            run("peepopt");
            run("opt_clean");

            if (fast)
                run("opt -fast");
            else if (1 && (clke_strategy == ClockEnableStrategy::EARLY)) {
                top_run_opt(0 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 1);
                if (!no_sat) {
                  top_run_opt(0 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 1, 1);
                }
            } else {
                top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 1);
                if (!no_sat) {
                  top_run_opt(1 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 1, 1);
                }
            }

            run("wreduce -keepdc");
            run("peepopt");
            run("opt_clean");

            if (cec) {
                run("write_verilog -noattr -nohex after_opt_clean2.v");
            }
            sec_check("after_opt_clean2", true);
        }

        transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

        // Extract Port properties like CLK, RST, ASYN, SYNC, ACTIVE_LOW, ... before any : 
        //     1. "dffunmap -srs-only" pass that may remove synchronous set/reset.
        //     2. DFF legalization pass. Indeed this DFF legalization pass may remove SYNC 
        //     set/reset logic when library DFFs do not have any set/reset pins.
        //
        collectPortProperties();

        if (check_label("coarse")) {
            if(!nodsp){
                std::string dspMapFile;
                std::string dspFinalMapFile;
                std::string dsp38MapFile;
                std::string dsp19x2MapFile;
                std::string genesis2;
                std::string genesis3;

                switch (tech) {
                    case Technologies::GENESIS: {
                        dspMapFile = GET_FILE_PATH(GENESIS_DIR, DSP_MAP_FILE);
                        dspFinalMapFile = GET_FILE_PATH(GENESIS_DIR, DSP_FINAL_MAP_FILE);
                        break;
                    }
                    case Technologies::GENESIS_2: {
                        dspMapFile = GET_FILE_PATH(GENESIS_2_DIR, DSP_MAP_FILE);
                        dspFinalMapFile = GET_FILE_PATH(GENESIS_2_DIR, DSP_FINAL_MAP_FILE);
                        genesis2 = " -genesis2";
                        break;
                    }
                    case Technologies::GENESIS_3: {
                        dspMapFile = GET_FILE_PATH(GENESIS_3_DIR, DSP_MAP_FILE);
                        dspFinalMapFile = GET_FILE_PATH(GENESIS_3_DIR, DSP_FINAL_MAP_FILE);
                        dsp38MapFile = GET_FILE_PATH(GENESIS_3_DIR, DSP_38_MAP_FILE);
                        dsp19x2MapFile = GET_FILE_PATH(GENESIS_3_DIR, DSP19X2_MAP_FILE);
                        genesis3 = " -genesis3";
                        break;
                    }
                    case Technologies::GENERIC: {
                        break;
                    }
                }
                switch (tech) {
                    case Technologies::GENESIS:
                    case Technologies::GENESIS_2: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        run("wreduce t:$mul");
                        run("rs_dsp_macc" + use_dsp_cfg_params + genesis2 + " -max_dsp " + std::to_string(max_dsp));
                        if (max_dsp != -1){
                            for(auto& modules : _design->selected_modules()){
                                for(auto& cells : modules->selected_cells()){
                                    if(cells->type == RTLIL::escape_id("$mul")){
                                        if(DSP_COUNTER < max_dsp){
                                            cells->set_bool_attribute(RTLIL::escape_id("valid_map"));
                                        }
                                        ++DSP_COUNTER;
                                    }
                                }
                            }
                        }

                        // Check if mult output is connected with Registers output
                        if (tech == Technologies::GENESIS_2)
                            check_mult_regout();

                        processDsp(cec);
                        if (use_dsp_cfg_params.empty())
                            run("techmap -map " + dspMapFile + " -D USE_DSP_CFG_PARAMS=0");
                        else
                            run("techmap -map " + dspMapFile + " -D USE_DSP_CFG_PARAMS=1");
                            
                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map3.v");
                        }
                        sec_check("after_dsp_map3", true);

                        // Fractuated mode has been disabled for Genesis2
                        // Fractuated mode has been disabled for Genesis3
                        //
                        if ((tech != Technologies::GENESIS_2) &&
                            (tech != Technologies::GENESIS_3)) {

                            run("rs_dsp_simd");
                        }
                        run("techmap -map " + dspFinalMapFile);

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map4.v");
                        }
                        sec_check("after_dsp_map4", true);

                        if (tech == Technologies::GENESIS)
                            run("rs-pack-dsp-regs -genesis");
                        else   
                            run("rs-pack-dsp-regs");

                        // add register at the remaining decomposed small multiplier that are not packed in DSP cells
                        if(tech == Technologies::GENESIS_2)
                            add_out_reg();

                        if (tech == Technologies::GENESIS)
                            run("rs_dsp_io_regs");
                        else
                            run("rs_dsp_io_regs -tech genesis2");

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map5.v");
                        }
                        sec_check("after_dsp_map5", true);

                        break;
                    }

                    case Technologies::GENESIS_3: {
#ifdef DEV_BUILD
                        run("stat");
#endif                  
                        if (new_dsp19x2) // RUN based on DSP19x2 mapping
                            run("rs-dsp-multadd -genesis3 -new_dsp19x2");
                        else 
                            run("rs-dsp-multadd -genesis3");
                        run("wreduce t:$mul");
                        if (!new_dsp19x2)
                            run("rs_dsp_macc" + use_dsp_cfg_params + genesis3 + " -max_dsp " + std::to_string(max_dsp));
                        else // RUN based on DSP19x2 mapping
                            run("rs_dsp_macc" + use_dsp_cfg_params + genesis3 + " -new_dsp19x2" + " -max_dsp " + std::to_string(max_dsp));
                        if (max_dsp != -1)
                            for(auto& modules : _design->selected_modules()){
                                for(auto& cells : modules->selected_cells()){
                                    if(cells->type == RTLIL::escape_id("$mul")){
                                        if(DSP_COUNTER < max_dsp){
                                            cells->set_bool_attribute(RTLIL::escape_id("valid_map"));
                                        }
                                        ++DSP_COUNTER;
                                    }
                                }
                            }

                        // Check if mult output is connected with Registers output  
                        if (tech == Technologies::GENESIS_3)
                            check_mult_regout();
                        processDsp(cec);

                        if (use_dsp_cfg_params.empty())
                            run("techmap -map " + dspMapFile + " -D USE_DSP_CFG_PARAMS=0");
                        else
                            run("techmap -map " + dspMapFile + " -D USE_DSP_CFG_PARAMS=1");
                            
                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map3.v");
                        }
                        sec_check("after_dsp_map3", true);

                        // Fractuated mode has been enabled for Genesis3
                        if (tech == Technologies::GENESIS_3  && new_dsp19x2)
                            run("rs_dsp_simd -tech genesis3");

                        run("techmap -map " + dspFinalMapFile); // For RS_DSP mapping
                        // Convert RS_DSP3_cfg_param to RS_DSP2X for DSP19x2 mapping
                        if (new_dsp19x2)
                            run("techmap -map " + dsp19x2MapFile); 

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map4.v");
                        }
                        sec_check("after_dsp_map4", true);

                        run("rs-pack-dsp-regs -genesis3");

                        // add register at the remaining decomposed small multiplier that are not packed in DSP cells
                        if (tech == Technologies::GENESIS_3)
                            add_out_reg();
                        run("rs_dsp_io_regs -tech genesis3");

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map5.v");
                        }
                        sec_check("after_dsp_map5", true);

#if 1
                        //run("stat");
                        run("techmap -map " + dsp38MapFile);
                        if (new_dsp19x2)
                            run("techmap -map " + dsp19x2MapFile);
                        run("stat");
#endif
                        break;
                    }

                    case Technologies::GENERIC: {
                        break;
                    }
                }
            }

            run("alumacc");

            if (cec) {
                run("write_verilog -noattr -nohex after_alumacc.v");
            }
            sec_check("after_alumacc", true);

            if (!fast) {
                top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);
            }

#ifdef DEV_BUILD
            run("stat");
#endif
            run("memory -nomap");
#ifdef DEV_BUILD
            run("stat");
#endif
            run("muxpack");

            run("opt_clean");

            if (cec) {
                run("write_verilog -noattr -nohex after_opt_clean3.v");
            }
            sec_check("after_opt_clean3", true);
        }

        if (!nobram){
            identifyMemsWithSwappedReadPorts();
            //If (-new_tdp36 flag is given then it will run new mapping for Gensis3 primitves)
            if (new_tdp36k && (tech == Technologies::GENESIS_3)){
                run_new_version_of_tdp36K_mapping();
            }
            //else old mapping for Gensis3 primitves runs
            else{
                mapBrams();
            }
        }

        // In Genesis3 we do not support DFF with sync set/reset so we need to unmap them. We do this
        // right after "mapBrams" because it may screw up Map inference if we dissolve the sync set/reset
        // logic before.
        // This is also the place where we noticed the minimum QoR diff on the Golden suite (Thierry).
        //
        if (tech == GENESIS_3) {
          run("dffunmap -srst-only");
          top_run_opt(0 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);
        }

        run("pmuxtree");

        run("muxpack");

        run("memory_map");

        postProcessBrams();

        if (check_label("map_gates")) {
            std::string arithMapFile;
            std::string allArithMapFile;
            switch (tech) {
                case Technologies::GENESIS: {
                    arithMapFile = GET_FILE_PATH(GENESIS_DIR, ARITH_MAP_FILE);
                    allArithMapFile = GET_FILE_PATH(GENESIS_DIR, ALL_ARITH_MAP_FILE);
                    break;    
                }    
                case Technologies::GENESIS_2: {
                    arithMapFile = GET_FILE_PATH(GENESIS_2_DIR, ARITH_MAP_FILE);
                    allArithMapFile = GET_FILE_PATH(GENESIS_2_DIR, ALL_ARITH_MAP_FILE);
                    break;
                }    
                case Technologies::GENESIS_3: {
                    arithMapFile = GET_FILE_PATH(GENESIS_3_DIR, ARITH_MAP_FILE);
                    allArithMapFile = GET_FILE_PATH(GENESIS_3_DIR, ALL_ARITH_MAP_FILE);
                    break;
                }    
                case Technologies::GENERIC: {
                    break;
                }    
            }
            switch (tech) {
                case Technologies::GENESIS:
                case Technologies::GENESIS_2: {
#ifdef DEV_BUILD
                    run("stat");
#endif
                    switch (infer_carry) {
                        case CarryMode::AUTO: {
                            run("techmap -map +/techmap.v -map" + arithMapFile);
                            break;
                        }
                        case CarryMode::ALL: {
                            run("techmap -map +/techmap.v -map" + allArithMapFile);
                            break;
                        }
                        case CarryMode::NO: {
                            run("techmap");
                            break;
                        }
                    }
#ifdef DEV_BUILD
                    run("stat");
#endif
                    break;    
                }    
                case Technologies::GENESIS_3: {
                    switch (infer_carry) {
                        case CarryMode::AUTO: {
                            run(stringf("techmap -map +/techmap.v -map %s -D MAX_CARRY_CHAIN=%u", arithMapFile.c_str(), max_carry_length));
                            break;
                        }
                        case CarryMode::ALL: {
                            run(stringf("techmap -map +/techmap.v -map %s -D MAX_CARRY_CHAIN=%u", allArithMapFile.c_str(), max_carry_length));
                            break;
                        }
                        case CarryMode::NO: {
                            run("techmap");
                            break;
                        }
                    }
                    run("stat");
                            break;
                }
                case Technologies::GENERIC: {
                    run("techmap");
                    break;
                }    
            }

            if (cec) {
                run("write_verilog -noattr -nohex after_tech_map.v");
            }
            sec_check("after_tech_map", false);

            if (!fast) {
                top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);
            }

            run("opt_expr -full");

            if (cec) {
                run("write_verilog -noattr -nohex after_opt-fast-full.v");
            }
            sec_check("after_opt-fast-full", true);
        }

#if 1
        string techMapArgs = " -map +/techmap.v";
        run("techmap " + techMapArgs);
#endif

        if (fast) {
            // commenting : 
            //run("opt -fast");
#if 1
            // control loop in fast mode because "opt -fast" can still iterate a lot
            //
            for (int i = 0; i < 2; i++) { // 2 iterations seems a good trade-off

                int nbInstBefore = getNumberOfInstances();

                run("opt_expr");
                run("opt_merge");
                run("opt_dff");
                run("opt_clean");

                int nbInstAfter = getNumberOfInstances();

                if (nbInstAfter == nbInstBefore) { // early break if apparently no change
                    break;
                }
            }
#endif
        } else {
            // Perform a small loop of successive "abc -dff" calls.  
            // This simplify pass may have some big QoR impact on this list of designs:
            //     - wrapper_io_reg_max 
            //     - wrapper_io_reg_tc1 
            //     - wrapper_multi_enc_decx2x4
            //     - keymgr 
            //     - kmac 
            //     - alu4 
            //     - s38417
            //
            if (!nosimplify) {
                if (cec) {
                    run("write_verilog -noattr -nohex before_simplify.v");
                }
                sec_check("before_simplify", true);

                int dfl = 0;

                preSimplify();

                // Explore two strategies :
                //     - one with FF with clock enables
                //     - the other with no clock enables
                // Perform this sequentially (as multi-thread would not work
                // here) and pick up the best on rough criterion.
                //

                // First save the original design
                //
                run("design -save original");

                // Simplify wit clock enables if any
                //
                simplify(0 /* unmap_dff_ce */, dfl);
                run("design -push-copy");

                int nbcells_strategy1 = getNumberOfInstances();
                int nbGenericREGs1 = getNumberOfGenericREGs();
                int nbOfLogic1 = getNumberOfLogic();

                int hasDFFce = designWithDFFce();

                // if design has any DFF with clock enable explore also
                // solution by dissolving clock enables
                //
                if (hasDFFce &&
                    !isHugeDesign (nbGenericREGs1, nbcells_strategy1)) {

                  // re-start from original design
                  //
                  run("design -load original");

                  // Simplify without clock enables
                  //
                  int with_no_ce_dfl = 0;
                  simplify(1 /* unmap_dff_ce */, with_no_ce_dfl);
                  run("design -save unmap_dff_ce");

                  int nbcells_strategy2 = getNumberOfInstances();
                  int nbGenericREGs2 = getNumberOfGenericREGs();
                  int nbOfLogic2 = getNumberOfLogic();

                  if (0) {   
                     log("****************************\n");
                     log(" NB cells keep CE   : %d\n", nbcells_strategy1);
                     log(" NB REGs keep CE    : %d\n", nbGenericREGs1);
                     log(" NB LOGs keep CE    : %d\n\n", nbOfLogic1);
                     log(" NB cells remove CE : %d\n", nbcells_strategy2);
                     log(" NB REGs remove CE  : %d\n", nbGenericREGs2);
                     log(" NB LOGs remove CE  : %d\n", nbOfLogic2);
                     log("****************************\n");
  
                     //getchar();
                  }

                  // Pick up second strategy only if :
                  //      - total number of logic cells increase is limited .
                  //      - OR there is a nice DFF reduction number.
                  //
                  float thresh_logic = 0.92;
                  float thresh_dff = 0.98;

                  if ((nbOfLogic2 * thresh_logic <= nbOfLogic1) ||
                      (nbGenericREGs2 <= thresh_dff * nbGenericREGs1)) {

                     dfl = with_no_ce_dfl;

                     log("select CE remove strategy (thresh_logic=%f, thresh_dff=%f, dfl=%d)\n",
                         thresh_logic, thresh_dff, dfl);

                     run("design -save unmap_dff_ce");
                     run("design -pop");
                     run("design -load unmap_dff_ce");

                  } else {

                     log("select CE keep strategy (thresh_logic=%f, thresh_dff=%f, dfl=%d)\n",
                         thresh_logic, thresh_dff, dfl);

                     run("design -pop");
                  }
                }

                postSimplify();

                if (cec) {
                    run("write_verilog -noattr -nohex after_simplify.v");
                }
                sec_check("after_simplify", true);
            }
        }

        transform(1 /* bmuxmap*/); // we can map $bmux now because
                                   // "memory" has been called

        if (check_label("map_luts") && effort != EffortLevel::LOW && !fast) {

            map_luts(effort);

            if (!nosimplify)
                run("opt_ffinv"); // help for "trial1" to gain further luts

            top_run_opt(1 /* nodffe */, 1 /* sat */, 1 /* force nosdff */, 1, 2, 0);

        }
        
        if (check_label("map_ffs")) {
            if (tech != Technologies::GENERIC) {

                string techMapArgs = " -map +/techmap.v -map";
                switch (tech) {
                    case Technologies::GENESIS: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        run("shregmap -minlen 8 -maxlen 20 -clkpol pos");
                        if (sdffr) {
                            run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_DFFSR_???_ 0 -cell $_DFFSRE_????_ 0 -cell $_DLATCHSR_PPP_ 0"
                                " -cell $_SDFF_???_ 0"
                               );
                        } else {
                            run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_DFFSR_???_ 0 -cell $_DFFSRE_????_ 0 -cell $_DLATCHSR_PPP_ 0"
                               );
                        }

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dfflegalize.v");
                        }
                        sec_check("after_dfflegalize", true);

#ifdef DEV_BUILD
                        run("stat");
#endif
                        techMapArgs += GET_FILE_PATH(GENESIS_DIR, FFS_MAP_FILE);
                        break;    
                    }    

                    case Technologies::GENESIS_2: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        // TODO: run("shregmap -minlen 8 -maxlen 20");
                        run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFFE_??_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_SDFF_???_ 0 -cell $_SDFFE_????_ 0"
                                " -cell $_DLATCH_?_ 0 -cell $_DLATCH_???_ 0"
                           );

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dfflegalize.v");
                        }
                        sec_check("after_dfflegalize", true);

#ifdef DEV_BUILD
                        run("stat");
#endif
                        techMapArgs += GET_FILE_PATH(GENESIS_2_DIR, FFS_MAP_FILE);
                        break;
                    }

                    case Technologies::GENESIS_3: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        check_DLATCH (); // Make sure that design does not have Latches since DLATCH 
                                         // support has not been added to genesis3 architecture.
                                         // Error out if it is the case. 
                        // TODO: run("shregmap -minlen 8 -maxlen 20");
                         run(
                               "dfflegalize -cell $_DFF_?_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                               " -cell $_DFFSR_???_ 0 -cell $_DFFSRE_????_ 0 -cell $_DLATCH_?_ 0 -cell $_DLATCH_???_ 0"
                            );
                        run("rs_dffsr_conv");
                        if (cec) {
                            run("write_verilog -noattr -nohex after_dfflegalize.v");
                        }
                        sec_check("after_dfflegalize", true);

#ifdef DEV_BUILD
                        run("stat");
#endif
                                       
                        check_DFFSR(); // make sure we do not have any Generic DFFs with async. SR.
                                       // Error out if it is the case. 

                                       
                        techMapArgs += GET_FILE_PATH(GENESIS_3_DIR, FFS_MAP_FILE);
                        break;
                    }
                    // Just to make compiler happy
                    case Technologies::GENERIC: {
                        break;
                    }    
                }
                run("techmap " + techMapArgs);

                if (cec) {
                    run("write_verilog -noattr -nohex after_techmap_ff_map.v");
                }
                sec_check("after_techmap_ff_map", true);
            }
            run("opt_expr -mux_undef");
            run("simplemap");
            run("opt_expr");
            run("opt_merge");
            run("opt_dff -nodffe -nosdff");
            run("opt_clean");

            if (cec) {
                run("write_verilog -noattr -nohex after_opt_clean4.v");
            }
            sec_check("after_opt_clean4", true);

            if (!fast)
                top_run_opt(1 /* nodffe */, 0 /* sat */, 1 /* force nosdff */, 1, 12, 0);
        }

        // Map left over cells like $mux (EDA-1441)
        //
        run("techmap");

        if (check_label("map_luts_2")) {
            if(fast) 
                map_luts(EffortLevel::LOW);
            else
                map_luts(EffortLevel::HIGH);
        }

        if (check_label("check")) {
            run("hierarchy -check");
        }

        if (check_label("finalize")) {
            run("opt_clean -purge");
        }

        // In genesis3 eventually replace and expanse LLatch primitives if any in 
        // the final netlist.
        //
        if (tech == Technologies::GENESIS_3) {
#if 0    //Removing latch conversion to $lut for EDA-1773
           run("stat");

           run("read_verilog " GET_FILE_PATH(GENESIS_3_DIR, LLATCHES_SIM_FILE));

           run("flatten");

           // remove the dangling LLatch primitives.
           //
           run("opt_clean -purge");
#endif
           string readIOArgs;
           readIOArgs=GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_cells_FILE)
                      GET_FILE_PATH_RS_FPGA_SIM_BLACKBOX(GENESIS_3_DIR,BLACKBOX_SIM_LIB_FILE);
           
           if (!no_iobuf){
                run("read_verilog -sv -lib "+readIOArgs);
                run("clkbufmap -buf rs__CLK_BUF O:I");
                run("techmap -map " GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_CELLs_final_map));// TECHMAP CELLS
                //EDA-2629: Remove dangling wires after CLK_BUF
                run("opt_clean");
                run("iopadmap -bits -inpad rs__I_BUF O:I -outpad rs__O_BUF I:O -toutpad rs__O_BUFT T:I:O -limit "+ std::to_string(max_device_ios));
                run("techmap -map " GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_CELLs_final_map));// TECHMAP CELLS

           }

           run("stat");
#if 1
           string techMaplutArgs = GET_TECHMAP_FILE_PATH(GENESIS_3_DIR, LUT_FINAL_MAP_FILE);// LUTx Mapping
           run("techmap -map" + techMaplutArgs);
#endif
        run("opt_clean");
        }

        if (check_label("blif")) {
            if (!blif_file.empty()) {
                run(stringf("write_blif %s", blif_file.c_str()));
            }
        }

        if (check_label("verilog")) {
            if (!verilog_file.empty()) {
                run("write_verilog -noattr -nohex " + verilog_file);
            }
        }

        if (check_label("vhdl")) {
            if (!vhdl_file.empty()) {
                run("write_vhdl " + vhdl_file);
            }
        }

        sec_check("final_netlist", true);

        run("stat");

        // Note that numbers extractions are specific to GENESIS3
        //
        int nbLUTx = getNumberOfLUTx();
        int nbREGs = getNumberOfREGs();

        log("   Number of LUTs:               %5d\n", nbLUTx);
        log("   Number of REGs:               %5d\n", nbREGs);

        reportCarryChains();

        writePortProperties("port_info.json");

        if ((max_lut != -1) && (nbLUTx > max_lut)) {
          log("\n");
          log_cmd_error("Final netlist LUTs number [%d] exceeds '-max_lut' specified value [%d].\n", nbLUTx, max_lut);
        }

        if ((max_reg != -1) && (nbREGs > max_reg)) {
          log("\n");
          log_cmd_error("Final netlist DFFs number [%d] exceeds '-max_reg' specified value [%d].\n", nbREGs, max_reg);
        }
    }

} SynthRapidSiliconPass;

PRIVATE_NAMESPACE_END
