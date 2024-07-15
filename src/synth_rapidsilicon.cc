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
#include <strings.h>
#include <chrono>


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
#define SEC_MODELS_DIR SEC_MODEL
#define COMMON_DIR common
#define SIM_LIB_FILE cells_sim.v
#define BLACKBOX_SIM_LIB_FILE cell_sim_blackbox.v
#define BLACKBOX_SIM_LIB_OFAB_FILE cell_ofab_sim_blackbox.v
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
#define SEC_CARRY SEC_MODELS/CARRY.v
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
#define GEN3_TECHMAP gen3_techmap.v
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

enum SECMode {
    ON_STEP,
    ON,
    OFF
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
        log("    -legalize_ram_clk_ports \n");
        log("        Connect unconnected TDP Ram clock ports with associated clock.\n");
        log("\n");
        log("    -post_cleanup <0|1|2>\n");
        log("        Performs a post synthesis netlist cleanup. '0' value means post cleanup is OFF. '1' means post cleanup is ON and '2' is ON in debug mode.\n");
        log("\n");
        log("    -new_iobuf_map <0|1|2>\n");
        log("        Performs a new approach to map IO buffers. '0' value means mapping is OFF. '1' means new mapping is ON and '2' is ON in debug mode.\n");
        log("\n");
        log("    -iofab_map <0|1|2>\n");
        log("        Performs mapping of I_FAB/O_FAB cells to drive netlist editor. '0' value means mapping is OFF. '1' means mapping is ON and '2' is ON in debug mode.\n");
        log("\n");
        log("    -cec\n");
        log("        Use internal equivalence checking (ABC based) during optimization\n");
        log("        and dump Verilog after key phases.\n");
        log("        Disabled by default.\n");
        log("\n");
        log("    -sec\n");
        log("        Call sequential ABC formal verification flow using 'dsec'.\n");
        log("        - on_step  : SEC is called and stopts after each incremental FV comparison.\n");
        log("        - on       : SEC is called but never stops.\n");
        log("        - off      : SEC is not called.\n");
        log("        By default 'off' mode is used.\n");
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


    dict<RTLIL::SigSpec, std::set<Cell*>*> in_2_cell;
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
    int post_cleanup;
    int new_iobuf_map;
    int iofab_map;
    bool legalize_ram_clk_ports;
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
    SECMode sec_mode;
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

    int cec_counter = 0;

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

    // Special cells
    //
    dict<std::string, pair<int, int>> pp_memories;

    // Alias between same signals (for I_BUF/CLK_BUF)
    //
    dict<std::string, std::string> pp_alias;

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
        post_cleanup= 0;
        new_iobuf_map= 0;
        iofab_map= 0;
        legalize_ram_clk_ports= false;
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
        sec_mode = SECMode::OFF;
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
        string sec_str;
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
            if (args[argidx] == "-sec" && argidx + 1 < args.size()) {
                sec_str = args[++argidx];
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
            if (args[argidx] == "-legalize_ram_clk_ports") {
                legalize_ram_clk_ports = true;
                continue;
            }
            if (args[argidx] == "-de_max_threads" && argidx + 1 < args.size()) {
                de_max_threads = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-post_cleanup" && argidx + 1 < args.size()) {
                post_cleanup = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-new_iobuf_map" && argidx + 1 < args.size()) {
                new_iobuf_map = stoi(args[++argidx]);
                continue;
            }
            if (args[argidx] == "-iofab_map" && argidx + 1 < args.size()) {
                iofab_map = stoi(args[++argidx]);
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

        if (sec_str == "on_step")
            sec_mode = SECMode::ON_STEP;
        else if (sec_str == "on")
            sec_mode = SECMode::ON;
        else if (sec_str == "off")
            sec_mode = SECMode::OFF;

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
        if (post_cleanup < 0 && post_cleanup > 2) {
            log_cmd_error("Invalid post cleanup value: '%i'\n", post_cleanup);
        }
        if (new_iobuf_map < 0 && new_iobuf_map > 2) {
            log_cmd_error("Invalid new iobuf map value: '%i'\n", new_iobuf_map);
        }
        if (iofab_map < 0 && iofab_map > 2) {
            log_cmd_error("Invalid iofab map value: '%i'\n", iofab_map);
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
        std::string carry = GET_FILE_PATH(GENESIS_3_DIR, SEC_CARRY);
        std::string genesis3 = GET_FILE_PATH(GENESIS_3_DIR, SEC_GENESIS3);
        std::string dspmap = GET_FILE_PATH(GENESIS_3_DIR, SEC_DSP_MAP);
        std::string dspfinalmap = GET_FILE_PATH(GENESIS_3_DIR, SEC_DSP_FINAL_MAP);

        run(stringf("read_verilog -sv %s", simcells.c_str()));
        run(stringf("read_verilog -sv %s", simlib.c_str()));
        run(stringf("read_verilog -sv %s", carry.c_str()));
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

    // Performs Formal Verification between design in current memory (called "original") 
    // and "previous" design saved as "previous".
    //


    void remove_print_cell(){
        for(auto& modules : _design->selected_modules()){
            for(auto& cell : modules->selected_cells()){
                if (cell->type == RTLIL::escape_id("$print")){
                    log("Deleting Cell = %s\n",log_id(cell->type));
                    modules->remove(cell);
                }
            }
        }
    }

    void sec_check(string checkName, bool verify, bool elaborate_cells) {
        
        if (sec_mode == SECMode::OFF) {
          return;
        }
        run(stringf("rs-sec -genesis3 -stage %s -verify %d -gen_net %d",checkName.c_str(),verify,elaborate_cells));
        if (sec_mode == SECMode::ON_STEP) {
          getchar();
        }
    }

    void cec_check(string checkName) {
        
        if (!cec) {
          return;
        }

        char name[1024];

        cec_counter++;

        sprintf(name, "%03d_%s", cec_counter, checkName.c_str());

        string verilogName = "cec_" + string(name) + ".v";
 
        // Dump a verilog image of the current design in memory
        //
        run(stringf("write_verilog -selected -noexpr -nodec %s", verilogName.c_str()));

    }

    void sec_report() {
        
        if (sec_mode == SECMode::OFF) {
          return;
        }

        log("=================================================================================\n");
        log("SEC REPORT: \n");
        log("\n");

        log("Nb FV Comparisons (Nb res files) : ");
        std::string command = "ls -l *.res | wc -l";
        int fail = system(command.c_str());
        if (fail) {
           log_error("Command %s failed !\n", command.c_str());
        }
        log("\n");

        // report NB equivalences
        //
        command = "grep 'Networks are equivalent.' *.res | wc -l";
        log("Nb EQUIVALENT FV comparisons : ");
        fail = system(command.c_str());
        if (fail) {
           log_error("Command %s failed !\n", command.c_str());
        }
        log("\n");

        // report NB NOT equivalences
        //
        command = "grep 'NOT EQUIVALENT' *.res | wc -l";
        log("Nb NOT EQUIVALENT FV comparisons : ");
        fail = system(command.c_str());
        if (0 && fail) {
           log_error("Command %s failed !\n", command.c_str());
        }
        log("\n");
        command = "grep 'NOT EQUIVALENT' *.res";
        fail = system(command.c_str());
        if (0 && fail) {
           log_error("Command %s failed !\n", command.c_str());
        }

        // report NB UNDECIDABLE equivalences
        //
        command = "grep 'UNDECID' *.res | wc -l";
        log("Nb UNDECIDABLE FV comparisons : ");
        fail = system(command.c_str());
        if (0 && fail) {
           log_error("Command %s failed !\n", command.c_str());
        }
        log("\n");
        command = "grep 'UNDECID' *.res";
        fail = system(command.c_str());
        if (0 && fail) {
           log_error("Command %s failed !\n", command.c_str());
        }

        log("=================================================================================\n");
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

    bool isSimpleSig(RTLIL::SigSpec lhs) {

        return (lhs.chunks().size() <= 1);
    }

    // Split up complex LHS into simple ones
    //
    void makeSimpleLHS() {

      std::vector<RTLIL::SigSig> newConnections;

      for (auto it = _design->top_module()->connections().begin(); 
           it != _design->top_module()->connections().end(); ++it) {

          RTLIL::SigSpec lhs = it->first;
          RTLIL::SigSpec rhs = it->second;

#if 0
          if (!isSimpleSig(lhs)) {
            log("TRANSFORM: assign ");
            show_sig(lhs);
            log(" = ");
            show_sig(rhs);
            log("\n");
          }
#endif

          int offset = 0;

          for (auto &chunk : lhs.chunks()) {

#if 0
              if (!isSimpleSig(lhs)) {
                log("       assign ");
                show_sig(chunk);
                log(" = ");
                show_sig(rhs.extract(offset, GetSize(chunk)));
                log("\n");
              }
#endif

              RTLIL::SigSig newConn = std::make_pair((SigSpec)chunk, 
                                            rhs.extract(offset, GetSize(chunk)));
   
              offset += GetSize(chunk);
     
              newConnections.push_back(newConn);
          }
      }

      _design->top_module()->connections_.clear();

      for (auto &conn : newConnections) {

          RTLIL::SigSpec lhs = conn.first;
          RTLIL::SigSpec rhs = conn.second;

          _design->top_module()->connect(lhs, rhs);
      }

#if 0
      run("write_verilog -noexpr make_simple_lhs.v");
#endif
    }

    void split2bits() {

        log("Split to bits ... \n");

        // we need to split busses in ihe netlist to make sure the forward and backward
        // traversals will work correctly. Indeed when we have mixed up of single bit 
        // signals (ex: s[5]) and busses (ex: s[6:4]) it is extremely difficult to 
        // handle some clean traversals. By having a single bit to single bit
        // correspondance the traversals will behave correctly
        //
        run("splitnets"); // do not split ports !

        // Use "write_verilog -simple_lhs" to deal with complex LHS. It is costly
        // in term of runtime so it would be better to fix it in "sig2sig" and avoid
        // to call this part of the code.
        // For '\LU32PEEng' we waste 150 seconds in this code and only 3 seconds to 
        // extract clock domains. Fixing it in "sig2sig" will then reduce to 3 seconds
        // the total extraction.

        //#define USE_WRITE_VERILOG_SIMPLE_LHS

        #ifdef USE_WRITE_VERILOG_SIMPLE_LHS

            // "-simple-lhs" to have single bits lhs assignments 
            //
            run("write_verilog -noexpr -simple-lhs post_cleanup.v");
            run("design -reset");

            string readArgs = GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, SIM_LIB_CARRY_FILE) 
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
                                        GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, I_BUF_SIM_FILE)
                                        GET_FILE_PATH_RS_FPGA_SIM(GENESIS_3_DIR, DSP_38_SIM_FILE)
                                        GET_FILE_PATH(GENESIS_3_DIR, BRAMS_SIM_NEW_LIB_FILE1)
                                        GET_FILE_PATH(GENESIS_3_DIR, BRAMS_SIM_LIB_FILE);
            run("read_verilog -lib -specify -nomem2reg" GET_FILE_PATH(COMMON_DIR, SIM_LIB_FILE) + readArgs);

            run("read_verilog post_cleanup.v");

        #else

            makeSimpleLHS();

        #endif

    }

    void disposeSig2Cells(dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanout,
                          dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanin) {

      for (auto elt : sig2CellsInFanout){
         delete(elt.second);
      }
      for (auto elt : sig2CellsInFanin){
         delete(elt.second);
      }
    }

    void disposeSig2Sig(dict<RTLIL::SigSpec, std::set<RTLIL::SigSpec>*>& rhsSig2LhsSig) {

      for (auto elt : rhsSig2LhsSig){
         delete(elt.second);
      }
    }


    // Look at all the top module cells and build up the 'sig2CellsInFanout' and
    // 'sig2CellsInFanin' dictionaries.
    // 'sig2CellsInFanout' : sig to cells it is driving
    // 'sig2CellsInFanin' : sig to cells it is driving from
    //
    void sig2cells (dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanout,
                    dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanin) {

        int nbCells = 0;
        int nbInputs = 0;
        int nbOutputs = 0;

        log("Building Sig2cells ... ");

        auto startTime = std::chrono::high_resolution_clock::now();

        for (auto cell : _design->top_module()->cells()) {

            nbCells++;

            for (auto &conn : cell->connections()) {

                IdString portName = conn.first;
                RTLIL::SigSpec actual = conn.second;
                std::set<Cell*>* newSet;

                // For each input port of the cell stores its corresponding actual sig net 
                // that drives this cell through this port.
                // So for each sig net we have the corresponding set of cells it is driving.
                //
                if (cell->input(portName)) {

                    nbInputs++;

                    if (!actual.is_chunk()) {

                      for (auto it = actual.chunks().rbegin(); 
                              it != actual.chunks().rend(); ++it) {

                          RTLIL::SigSpec sub_actual = *it;

                          if (sig2CellsInFanout.count(sub_actual)) {

                              newSet = sig2CellsInFanout[sub_actual];

                          } else {

                              newSet = new std::set<Cell*>;
                              sig2CellsInFanout[sub_actual] = newSet;
                          }
  
                          newSet->insert(cell);
  
                      } // end for 

                    } else {

    #if 0
                      if (1 || (cell->name == "_091_")) {
                        log("Processing input %s of cell %s\n", portName.c_str(), 
                            (cell->name).c_str());
                        show_sig(actual);
                        log("\n");
                      }
    #endif

                      if (sig2CellsInFanout.count(actual)) {

                        newSet = sig2CellsInFanout[actual];

                      } else {

                        newSet = new std::set<Cell*>;
                        sig2CellsInFanout[actual] = newSet;
                      }

                      newSet->insert(cell);
                    }

                } else { // Cell output port case :
                         // For each output port of the cell stores its corresponding 
                         // actual sig net that is driven by this cell through this 
                         // output port.
                         // So for each sig net we have the corresponding set of cells 
                         // that drives it.
                         // Theoritically this set has only 1 Cell. If it has multiple 
                         // cells then this means this sig net is multiply driven 
                         // (which is not good !).

                    // we need to make sure that we have a real direction info
                    // on the portName otherwise the obs cleanup can be wrong.
                    // (cause : may be the cell model has not been read).
                    //
                    if (!cell->output(portName)) {
                       log_warning ("sig2cells : cannot find direction of port '%s' with Cell '%s' (%s)\n", (portName).c_str(), (cell->name).c_str(), (cell->type).c_str());
                       continue;
                    }

                    nbOutputs++;

                    if (!actual.is_chunk()) {

                      for (auto it = actual.chunks().rbegin(); 
                              it != actual.chunks().rend(); ++it) {

                          RTLIL::SigSpec sub_actual = *it;

                          if (sig2CellsInFanin.count(sub_actual)) {

                              newSet = sig2CellsInFanin[sub_actual];

                          } else {

                              newSet = new std::set<Cell*>;
                              sig2CellsInFanin[sub_actual] = newSet;
                          }
  
                          newSet->insert(cell);
  
                      } // end for 

                    } else {

                      if (sig2CellsInFanin.count(actual)) { // should not happen ! Multiply driven case

                        newSet = sig2CellsInFanin[actual];

                      } else {

                        newSet = new std::set<Cell*>;
                        sig2CellsInFanin[actual] = newSet;
                      }

                      newSet->insert(cell);
                    }
                }
            }
        }       

        #if 0
            log("Processed %d cells\n", nbCells);
            log("Processed %d inputs\n", nbInputs);
            log("Processed %d outputs\n", nbOutputs);
        #endif

        auto endTime = std::chrono::high_resolution_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(endTime - startTime);

        float totalTime = elapsed.count() * 1e-9;

        log(" [%.2f sec.]\n", totalTime);
    }

    int sigIsConstant(RTLIL::SigSpec sig) {

       if (sig.is_chunk()) {
           if ((sig.as_chunk()).wire == NULL) {
              return 1;
           }
       }

       return 0;
    }


    // Process the internal assignment of the form : assign lhs = rhs;
    //
    // Handle case where LHS is complex and is a concat of several signals like
    //
    // assign {lhsSig1, lhsSig2, lhsSig3, lhsSig4} = {rhsSig1, rhsSig2, rhsSig3, rhsSig4}.
    //
    // We will translate it into :
    //    assign lhsSig1 = rhsSig1;
    //    assign lhsSig2 = rhsSig2;
    //    assign lhsSig3 = rhsSig3;
    //    assign lhsSig4 = rhsSig4;
    //
    // Handle also case where we have constants in the RHS like :
    //
    // assign {lhsSig1, lhsSig2, lhsSig3, lhsSig4} = {2'b00, rhsSig3, rhsSig4}.
    //
    // We need to look at the constant width to make sure that there is a one to one
    // correspondance between the lhsSig_i and rhsSig_i (called sub actuals).
    // In this case we will generate only assignments for "lhsSig3", "lhsSig4" like : 
    //
    //    assign lhsSig3 = rhsSig3;
    //    assign lhsSig4 = rhsSig4;
    //
    // The RHS constant assignments are not usefull for traversals.
    //
    void sig2sig(dict<RTLIL::SigSpec, std::set<RTLIL::SigSpec>*>& rhsSig2LhsSig,
                 dict<RTLIL::SigSpec, RTLIL::SigSpec>& lhsSig2rhsSig)
    {
        log("Building Sig2sig ...   ");

        auto startTime = std::chrono::high_resolution_clock::now();

        for (auto it = _design->top_module()->connections().begin(); 
            it != _design->top_module()->connections().end(); ++it) {

            RTLIL::SigSpec lhs = it->first;
            RTLIL::SigSpec rhs = it->second;

            if (sigIsConstant(rhs)) {
            continue;
            }

    #if 0
            log("ASSIGN ");
            show_sig(lhs);
            log(" = ");
            show_sig(rhs);
            log("\n\n");
    #endif

            if (!lhs.is_chunk()) { // if the assign is an assignment of bus/slice

              int misMatchCase = 0;

              // This case needs to be handled. It is generally when we have a constant
              // on several bits on RHS. If the constant is for instance 6'b000000 it counts 
              // for 1 (element) instead of 6 (bits). So we would need to split the constant
              // as well.
              //
              if (lhs.chunks().size() != rhs.chunks().size()) {

                misMatchCase = 1;

                auto rit = rhs.chunks().rbegin();
        
                long unsigned rhsSize = 0;

                // Check if size mismatch is due to constant slices on the RHS
                //
                while (rit != rhs.chunks().rend()) {

                    RTLIL::SigSpec sub_rhs = *rit;

                    if (sigIsConstant(sub_rhs)) {

                       rhsSize += (sub_rhs.as_chunk()).width;

                    } else {

                       rhsSize++;
                    }

                    rit++;
                }

                if (lhs.chunks().size() != rhsSize) {

                   log("ERROR: Assignment with LHS and RHS of different sizes (%ld vs %ld)\n",
                       lhs.chunks().size(), rhsSize);

                   log("         assign ");
                   show_sig(lhs);
                   log(" = ");
                   show_sig(rhs);
                   log("\n");
                   log_error("\n");

                   // There is a true mismatch : we would need to investigate this case if this happens
                   continue;
                }

    #if 0
                log("         assign ");
                show_sig(lhs);
                log(" = ");
                show_sig(rhs);
                log("\n");

                log("Computed LHS and RHS exact sizes : %ld vs %ld\n", lhs.chunks().size(), rhsSize);
                getchar();
    #endif
              }

              // Lhs and Rhs have exactly the same size !
              //
              auto lit = lhs.chunks().rbegin();
              auto rit = rhs.chunks().rbegin();
        
              // RHS should have always less (misMatchCase) or equal sub actuals than LHS so 
              // we check iteration exit on RHS.
              //
              while (rit != rhs.chunks().rend()) {

                RTLIL::SigSpec sub_lhs = *lit;
                RTLIL::SigSpec sub_rhs = *rit;

                std::set<RTLIL::SigSpec>* fanout;

                // If the 'sub_rhs" is a constant pass over it and iterate on the 'lhs' 
                // the "constant width" number of time.
                //
                if (sigIsConstant(sub_rhs)) {

                    int constSize = (sub_rhs.as_chunk()).width;

                    while (constSize--) {
                       lit++;
                    }
                    rit++;

                    continue;
                }

                if (rhsSig2LhsSig.count(sub_rhs) == 0) {

                    fanout = new std::set<RTLIL::SigSpec>;
                    rhsSig2LhsSig[sub_rhs] = fanout;
                }

                fanout = rhsSig2LhsSig[sub_rhs];
            
                fanout->insert(sub_lhs); // add 'sub_lhs' in the fanout of 'sub_rhs'.

                lhsSig2rhsSig[sub_lhs] = sub_rhs; // 'sub_lhs" has only one 'sub_rhs'

                if (misMatchCase) {
    #if 0
                    log("SUB_ASSIGN ");
                    show_sig(sub_lhs);
                    log(" = ");
                    show_sig(sub_rhs);
                    log("\n\n");
                    getchar();
    #endif
                }

                lit++;
                rit++;
              }

            } else { 

              std::set<RTLIL::SigSpec>* fanout;

              if (rhsSig2LhsSig.count(rhs) == 0) {

                fanout = new std::set<RTLIL::SigSpec>;
                rhsSig2LhsSig[rhs] = fanout;
              }

              fanout = rhsSig2LhsSig[rhs];
            
              fanout->insert(lhs); // add 'lhs' in the fanout of 'rhs'.
                
              lhsSig2rhsSig[lhs] = rhs; // 'lhs" has only one 'rhs'
            }
        }

        auto endTime = std::chrono::high_resolution_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(endTime - startTime);

        float totalTime = elapsed.count() * 1e-9;

        log(" [%.2f sec.]\n", totalTime);
    }

    // Recursive backward traversal going through the transitive fanin of signal 'sig'.
    //
    void backCleanRec(RTLIL::SigSpec& sig,
                          dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanin,
                          dict<RTLIL::SigSpec, RTLIL::SigSpec>& lhsSig2RhsSig,
                          std::set<Cell*> &visitedCells,
                          std::set<RTLIL::SigSpec> &visitedSigSpec) {


        if (sigIsConstant(sig)) {
           return;
        }

        // return if already visited
        //
        if (visitedSigSpec.count(sig)) {
           return;
        }

        visitedSigSpec.insert(sig);

    #if 0
        log("Backward Visit ");
        show_sig(sig);
        log("\n");
    #endif

        int nbDrivers = 0;

        // If some cells are driving this 'sig' then go through them.
        //
        if (sig2CellsInFanin.count(sig)) {

            // Get the cells that are driving this 'sig'
            //
            std::set<Cell*>* sigFanin = sig2CellsInFanin[sig];

            // For all the cells driving this 'sig' process them.
            //
            // **WARNING ** : theoritically we should have only 1 driver cell, not more !
            // otherwise this "sig" is multi-driven
            //
            for (std::set<Cell*>::iterator it = sigFanin->begin(); it != sigFanin->end(); it++) {

               Cell* cell = *it;

               if (visitedCells.count(cell)) {
                  continue;
               }

               visitedCells.insert(cell);

               nbDrivers++;

               // We traverse the cell and continue recursivity through its input ports
               //
               for (auto &conn : cell->connections()) {

                   IdString portName = conn.first;
                   RTLIL::SigSpec actual = conn.second;
            
                   if (cell->input(portName)) {

                      // Beware : the 'actual' can be a single signal or a concat of several
                      // signals.
                      //
                      if (!actual.is_chunk()) { // if the 'actual' is a concat of sub actuals then
                                                // propagate backward on each sub actual.

                        for (auto it = actual.chunks().rbegin(); 
                            it != actual.chunks().rend(); ++it) {
   
                            RTLIL::SigSpec sub_actual = *it;

                            backCleanRec(sub_actual, sig2CellsInFanin, lhsSig2RhsSig, 
                                             visitedCells, visitedSigSpec); 
                        }

                      } else { // otherwise propagate backward on the single actual

                            backCleanRec(actual, sig2CellsInFanin, lhsSig2RhsSig, 
                                             visitedCells, visitedSigSpec); 
                      }
                   }
               } // end of processing all the cell connections

            } // end of processing all the cells driving 'sig'

        } // end of case where 'sig' is driven by some cells

        // Now handle case where 'sig' is driven by assigns : assign sig = rhs
        //
        if (lhsSig2RhsSig.count(sig)) {

           RTLIL::SigSpec rhs = lhsSig2RhsSig[sig];

           backCleanRec(rhs, sig2CellsInFanin, lhsSig2RhsSig,
                        visitedCells, visitedSigSpec);

           nbDrivers++;
        }

        // Complain if 'sig' is multi-driven
        //
        if (nbDrivers > 1) {

          RTLIL::Wire *wire = sig[0].wire;
          std::string sig_name = wire->name.str();
          log_warning("Signal '%s' has multiple drivers !\n", sig_name.c_str());
        }
    }

    // Peform a backward traversal from the top module primary outputs and store
    // all the visited cells and signals.
    // Remove the non visited cells and signals as they are not observable from
    // the primary outputs.
    //
    void backClean(dict<RTLIL::SigSpec, std::set<Cell*>*>& sig2CellsInFanin,
                   dict<RTLIL::SigSpec, RTLIL::SigSpec>& lhsSig2RhsSig) {

        std::set<Cell*> visitedCells;
        std::set<RTLIL::SigSpec> visitedSigSpec;

        auto startTime = std::chrono::high_resolution_clock::now();

        // Look at all signals driven by cells and which correspond to
        // Primary outputs : start backward traversal from them.
        //
        for (auto elt : sig2CellsInFanin){

           RTLIL::SigSpec po = elt.first;

           RTLIL::Wire *w = po[0].wire;

           if (!w->port_id) { // port_id <> 0 means it is an output
             continue;
           }

           if (post_cleanup == 2) {
             log("Starts from cell PO : ");
             show_sig(po);
             log("\n");
           }

           backCleanRec(po, sig2CellsInFanin, lhsSig2RhsSig, 
                        visitedCells, visitedSigSpec);
        }
        
        // Look at all signals driven by assigns and which correspond to
        // Primary outputs : start backward traversal from them.
        //
        for (auto elt : lhsSig2RhsSig){

           RTLIL::SigSpec po = elt.first;

           RTLIL::Wire *w = po[0].wire;

           if (!w->port_id) { // port_id <> 0 means it is an output
             continue;
           }

           if (post_cleanup == 2) {
             log("Starts from assign PO : ");
             show_sig(po);
             log("\n");
           }

           backCleanRec(po, sig2CellsInFanin, lhsSig2RhsSig, 
                        visitedCells, visitedSigSpec);
        }

        auto endTime = std::chrono::high_resolution_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(endTime - startTime);

        float totalTime = elapsed.count() * 1e-9;

        log("Backward clean up ...  ");
        log(" [%.2f sec.]\n", totalTime);

        // Keep specific cells/signals even if they do not drive primary outputs
        //
        for (auto cell : _design->top_module()->cells()) {

           if(cell->type == RTLIL::escape_id("I_BUF")) {

              visitedCells.insert(cell); 
              RTLIL::SigSpec out = cell->getPort(ID::O);
              visitedSigSpec.insert(out);
              continue;
           }

           if(cell->type == RTLIL::escape_id("CLK_BUF")) {

              visitedCells.insert(cell); 
              RTLIL::SigSpec out = cell->getPort(ID::O);
              visitedSigSpec.insert(out);
              continue;
           }
        }


        log("Before cleanup :\n");
        run("stat");

#if 1
        // Remove unsused connections/ unused assigns. They are the ones
        // with unsued LHS
        //
        pool<RTLIL::SigSig> newConnections;
        int nbConnectionsToRemove = 0;

        for (auto it = _design->top_module()->connections().begin(); 
            it != _design->top_module()->connections().end(); ++it) {

            RTLIL::SigSpec lhs = it->first;

            if (visitedSigSpec.count(lhs)) {
              newConnections.insert(*it);
              continue;
            }

            nbConnectionsToRemove++;
        }

        _design->top_module()->connections_.clear();

        for (auto conn : newConnections) {
            _design->top_module()->connect(conn);
            //_design->top_module()->connections_.push_back(conn);
        }
#endif

        // remove unused wires
        //
        pool<RTLIL::Wire*> wiresToRemove;

        for (auto wire : _design->top_module()->wires()) {

           RTLIL::SigSpec sig = wire;

           if (visitedSigSpec.count(sig)) {
              continue;
           }

#if 0
           log_warning("Not observable Signal : ");
           show_sig(sig);
           log("\n");
#endif

           RTLIL::Wire *w = sig[0].wire;

           // Do not remove ports
           //
           if (w->port_id) {
              continue;
           }

           if (post_cleanup == 2) {
             std::string sig_name = w->name.str();
             log("OBS_CLEAN: remove wire '%s'\n", sig_name.c_str());
           }

           wiresToRemove.insert(w);
        }

        log(" --------------------------\n");
        log("   Removed assigns : %d\n", nbConnectionsToRemove);

        _design->top_module()->remove(wiresToRemove);

        log("   Removed wires   : %lu\n", wiresToRemove.size());

        // remove unused cells
        //
        std::set<Cell*> cellsToRemove;

        for (auto cell : _design->top_module()->cells()) {

          if (visitedCells.count(cell)) {
            continue;
          }

          cellsToRemove.insert(cell);
        }

        log("   Removed cells   : %lu\n", cellsToRemove.size());
        log(" --------------------------\n");

        for (auto cell : cellsToRemove) {

          if (post_cleanup == 2) {

            RTLIL::IdString cellType = cell->type;

            log("Removing cell '%s (%s)'\n", id(cell->name).c_str(),
                 cellType.c_str());
          }

          _design->top_module()->remove(cell);
        }

        log("After cleanup :\n");
        run("stat");
    }

    // This functions will do a from-PO "observability" clean-up, e.g. any object not 
    // contributing in the top module Primary Outputs functionality will be 
    // removed.
    // NOTE: this pass will transform also the current design as it will bit 
    // split it and transform complex LHS assigns into simple LHS assigns.
    //
    void obs_clean() {

        //run("design -save before_post_cleanup");

        log("\n==========================\n");
        log("Post Design clean up ... \n\n");

        auto startTime = std::chrono::high_resolution_clock::now();

        // we need to split busses in the netlist to make sure the forward and backward
        // traversals will work correctly. Indeed when we have mixed up of single bit 
        // signals (ex: s[5]) and busses (ex: s[6:4]) it is extremely difficult to 
        // handle some clean traversals. By having a single bit to single bit
        // correspondance the traversals will behave correctly
        //
        split2bits();

        auto endTime = std::chrono::high_resolution_clock::now();
        auto elapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(endTime - startTime);

        float totalTime = elapsed.count() * 1e-9;

        log("\nSplit into bits ...    ");
        log(" [%.2f sec.]\n", totalTime);

        dict<RTLIL::SigSpec, std::set<Cell*>*> sig2CellsInFanout;
        dict<RTLIL::SigSpec, std::set<Cell*>*> sig2CellsInFanin;

        // Building connections dictionaries
        //
        // On cells connections
        //
        sig2cells(sig2CellsInFanout, sig2CellsInFanin);

        dict<RTLIL::SigSpec, std::set<RTLIL::SigSpec>*> rhsSig2LhsSig;
        dict<RTLIL::SigSpec, RTLIL::SigSpec> lhsSig2RhsSig;

        // on simple assignments (assign lhs = rhs)
        //
        sig2sig(rhsSig2LhsSig, lhsSig2RhsSig);

        if (post_cleanup == 2) { // for debug
          run("write_verilog -noexpr -simple-lhs -org-name before_obs_clean.v");
          run("write_blif before_obs_clean.blif");
        }

        // Perform the real clean up by doing a backward traversal from the POs.
        //
        backClean(sig2CellsInFanin, lhsSig2RhsSig);

        if (post_cleanup == 2) { // for debug
          run("write_verilog -noexpr -simple-lhs -org-name after_obs_clean.v");
          run("write_blif after_obs_clean.blif");
        }

        // Dispose objects created with 'new' when building the dictionaries
        //
        disposeSig2Cells(sig2CellsInFanout, sig2CellsInFanin);
        disposeSig2Sig(rhsSig2LhsSig);

        auto fendTime = std::chrono::high_resolution_clock::now();
        auto felapsed = std::chrono::duration_cast<std::chrono::nanoseconds>(fendTime - startTime);

        float ftotalTime = felapsed.count() * 1e-9;

        log("\nTotal time for 'obs_clean' ...   \n");
        log(" [%.2f sec.]\n", ftotalTime);
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

    void map_luts(EffortLevel effort_lvl, const std::string step) {
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
            run("write_verilog -noexpr -nohex after_lut_map" + std::to_string(index) + ".v");
        }
        sec_check(step, true, false);
        
        //run(stringf("rs-sec -genesis3 -stage after_lut_map%d -verify 1 -gen_net 0",index));

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
void abcDffOpt(int unmap_dff_ce, int n, int dfl, const string step)
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

    sec_check(step, true, true);

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

          abcDffOpt(unmap_dff_ce, 1 /* step */, 0 /* dfl */, "after_dffOpt_step1_dfl0"); // fast version

        } else {

          abcDffOpt(unmap_dff_ce, 1 /* step */, 1 /* dfl */, "after_dffOpt_step1_dfl1");
          abcDffOpt(unmap_dff_ce, 2 /* step */, 1 /* dfl */, "after_dffOpt_step2_dfl1");
        }
        
        // Save this first simplify solution (with default "dfl")
        //
        run("design -push-copy");

        int nbcells1 = getNumberOfInstances();
        int nbGenericREGs1 = getNumberOfGenericREGs();
        int nbOfLogic1 = getNumberOfLogic();

        if (isHugeDesign (nbGenericREGs1, nbcells1)) {

          abcDffOpt(unmap_dff_ce, 2 /* step */, 0 /* dfl */, "after_dffOpt_step2_dfl0"); // fast version
        } else {

          abcDffOpt(unmap_dff_ce, 3 /* step */, 2 /* dfl */, "after_dffOpt_step3_dfl2");
          abcDffOpt(unmap_dff_ce, 4 /* step */, 2 /* dfl */, "after_dffOpt_step4_dfl2");
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
    void CHECK_PARAM(std::set<Cell*> BRAM_cells){
        for (auto &cell : BRAM_cells) {
            if (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM36_TDP") ||
                (cell->type == RTLIL::escape_id("$__RS_FACTOR_BRAM18_TDP"))){
                    if (!(cell->hasParam(RTLIL::escape_id("PORT_C_DATA_WIDTH"))))
                        cell->setParam(stringf("\\PORT_C_DATA_WIDTH"), cell->getParam(RTLIL::escape_id("PORT_D_DATA_WIDTH")));
            }
        }
    }
    void Set_SDPBram_InitValues(std::set<Cell*> BRAM_cells){
        for (auto &cell : BRAM_cells) {
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

    void Set_TDPBram_InitValues(std::set<Cell*> BRAM_cells){
        for (auto &cell : BRAM_cells) {
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
            CHECK_PARAM(BRAM_cells);
        }
    }
    // BRAM INIT mapping scheme for (old version of genesis3), genesis2 and genesis techlogies 
    void SET_GEN2_InitValues(std::set<Cell*> BRAM_cells){
        for (auto &cell : BRAM_cells) {
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
    /* Lia: When data width is greater than 18 bits reading is performed from 
     * two 18K RAMs, so we need to split Init bits to 2x18 bit pairs, first half
     * will go to the first 18K RAM and the second half to the second 18k RAM.
     */
    void correctBramInitValues() {
        //Getting all the BRAM cells
        std::set<Cell*> BRAM_cells;
        std::set<RTLIL::IdString> available_ram_cells = {"$__RS_FACTOR_BRAM18_SDP","$__RS_FACTOR_BRAM18_TDP","$__RS_FACTOR_BRAM36_SDP","$__RS_FACTOR_BRAM36_TDP"};
        for (auto &module : _design->selected_modules()) {
            for (auto &cell : module->selected_cells()) {
                if(!available_ram_cells.count(cell->type))
                   continue;
                BRAM_cells.insert(cell); 
            }
        }
        switch (tech) {
            case Technologies::GENESIS:
            case Technologies::GENESIS_2:{
                SET_GEN2_InitValues(BRAM_cells);
                break;
            }
        case Technologies::GENESIS_3: {
                /*
                 Based on new RS_TDP Bram primitves(TDP_RAM36K & TDP_RAM18KX2) bram initialization 
                 is handled such that data and parity bits are separated and assigned to INIT and 
                 INIT_PARITY parameters respectively.
                */
                if (new_tdp36k && (tech == Technologies::GENESIS_3)){
                    Set_TDPBram_InitValues(BRAM_cells); // set TDP BRAM
                    Set_SDPBram_InitValues(BRAM_cells); // set SDP BRAM
                }
                else
                    SET_GEN2_InitValues(BRAM_cells); 
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

    // Add error message when clock signal is used in expression EDA-2953
    void illegal_clk_connection(){
        for (auto cell : _design->top_module()->cells()){
            if (RTLIL::builtin_ff_cell_types().count(cell->type)){
                for (auto conn : cell->connections()){
                    if (conn.first == ID::CLK || conn.first == ID::C){
                        if (conn.second == cell->getPort(ID::D)){
                            std::stringstream buf;
                            for (auto &it : cell->attributes) {
                                RTLIL_BACKEND::dump_const(buf, it.second);
                            }
                            log_error("Use of clock signal '%s' in the expression is not supported %s\n", log_signal(cell->getPort(ID::CLK)),buf.str().c_str());
                        }
                    }
                }
            }
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
 
    std::string getSigNameSource(std::string &sig)
    {
      if (pp_alias.count(sig) == 0) {
        return sig;
      }

      return (getSigNameSource(pp_alias[sig]));
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

    bool sigName(const RTLIL::SigSpec &sig, std::string& name)
    {
        if (!sig.is_chunk()) {
           return false;
        }

        const RTLIL::SigChunk chunk = sig.as_chunk();

        if (chunk.wire == NULL) {
           return false;
        }

        if (chunk.width == chunk.wire->width && chunk.offset == 0) {
          name = (chunk.wire->name).substr(1);
        } else {
          name = "";
        }

        name = getSigNameSource(name);

        return true;
    }

    int checkCell(Cell* cell, const string cellName, 
                  const string& port1, 
                  std::set<std::string>& pp_group1, std::set<std::string>& pp_activeValue1,
                  const string& port2, 
                  std::set<std::string>& pp_group2, std::set<std::string>& pp_activeValue2)
    {
      if (cell->type != RTLIL::escape_id(cellName)) {
        return 0;
      }

      std::string name;

      for (auto &conn : cell->connections()) {

          IdString portName = conn.first;
          RTLIL::SigSpec actual = conn.second;

          if (portName == RTLIL::escape_id(port1)) {
             if (sigName(actual, name)) {
               pp_group1.insert(name);
               pp_activeValue1.insert(name);
             }
             continue;
          }

          if (portName == RTLIL::escape_id(port2)) {
             if (sigName(actual, name)) {
               pp_group2.insert(name);
               pp_activeValue2.insert(name);
             }
             continue;
          }
      }

      return 1;
    }

    void writeNetlistInfo(string jsonFileName)
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

           std::string ioName;
           if (!sigName(io, ioName)) {
             continue;
           }

           json_file << ",\n";

           if (wire->port_input) {
             if (wire->port_output) {
               json_file << "        \"direction\": \"inout\"";
             } else {
               json_file << "        \"direction\": \"input\"";
             }
           } else {
             json_file << "        \"direction\": \"output\"";
           }

           if (pp_clocks.count(ioName)) {
             json_file << ",\n        \"clock\": ";

             if (pp_activeHigh.count(ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_asyncReset.count(ioName)) {
             json_file << ",\n        \"async_reset\": ";
             if (pp_activeHigh.count(ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_asyncSet.count(ioName)) {
             json_file << ",\n        \"async_set\": ";
             if (pp_activeHigh.count(ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_syncReset.count(ioName)) {
             json_file << ",\n        \"sync_reset\": ";
             if (pp_activeHigh.count(ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else if (pp_syncSet.count(ioName)) {
             json_file << ",\n        \"sync_set\": ";
             if (pp_activeHigh.count(ioName)) {
               json_file << "\"active_high\"\n";
             }
             else if (pp_activeLow.count(ioName)) {
               json_file << "\"active_low\"\n";
             }
           }
           else {
               json_file << "\n";
           }

           json_file << "     }";
        }

        if (pp_memories.size()) {

           json_file << "\n   ],\n";

           dict<std::string, pair<int, int>>::iterator it;

           json_file << "  \"memories\" : [\n";

           firstLine = true;

           for (it = pp_memories.begin(); it != pp_memories.end(); ++it) {

             if (firstLine) {
               firstLine = false;
             } else {
               json_file << ",\n";
             }

             json_file << "     {\n";
             std::string name = it->first;
             pair<int, int> wd = it->second;

             json_file << "        \"name\" : \"" << name.substr(1) << "\",\n";
             json_file << "        \"width\" : \"" << wd.first << "\",\n";
             json_file << "        \"depth\" : \"" << wd.second << "\"\n";
             json_file << "     }";
           }

           json_file << "\n   ]\n";

        } else {
           json_file << "\n   ]\n";
        }

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

        std::string nameIn;
        std::string nameOut;

        // process first alias names situations
        // introduced by I_BUF/CLK_BUF presence
        //
        for (auto cell : _design->top_module()->cells()) {

           if ((cell->type == RTLIL::escape_id("I_BUF")) ||
               (cell->type == RTLIL::escape_id("CLK_BUF"))) {

              RTLIL::SigSpec in = cell->getPort(ID::I);

              if (!sigName(in, nameIn)) {
                continue;
              }

              RTLIL::SigSpec out = cell->getPort(ID::O);

              if (!sigName(out, nameOut)) {
                continue;
              }

              // Avoid infinite recursivity
              //
              if (nameIn != nameOut) {

                pp_alias[nameOut] = nameIn;
              }

              continue;
           }

        }

        std::string name;

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

              if (!sigName(clk, name)) {
                continue;
              }

              // Clock
              //
              pp_clocks.insert(name);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(name);
              } else {
                pp_activeHigh.insert(name);
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
              std::string clkName;

              if (!sigName(clk, clkName)) {
                continue;
              }

              RTLIL::SigSpec srst = cell->getPort(ID::SRST);

              if (!sigName(srst, name)) {
                continue;
              }

              // Clock
              //
              pp_clocks.insert(clkName);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(clkName);
              } else {
                pp_activeHigh.insert(clkName);
              }

              bool srst_active_low = RTLIL::const_eq(srst_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (srst_active_low) { 
                  pp_activeLow.insert(name);
              } else { 
                  pp_activeHigh.insert(name);
              }

              bool srst_is_reset = RTLIL::const_eq(srst_val, RTLIL::Const(0), false, false, 1).as_bool();

              if (srst_is_reset) { 
                  pp_syncReset.insert(name);
              } else {
                  pp_syncSet.insert(name);
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
              std::string clkName;

              if (!sigName(clk, clkName)) {
                continue;
              }
              RTLIL::SigSpec arst = cell->getPort(ID::ARST);

              if (!sigName(arst, name)) {
                continue;
              }

              // Clock
              //
              pp_clocks.insert(clkName);

              bool clk_neg_edge = RTLIL::const_eq(clk_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (clk_neg_edge) {
                pp_activeLow.insert(clkName);
              } else {
                pp_activeHigh.insert(clkName);
              }

              bool arst_active_low = RTLIL::const_eq(arst_pol, RTLIL::Const(0), false, false, 1).as_bool();

              if (arst_active_low) { 
                  pp_activeLow.insert(name);
              } else { 
                  pp_activeHigh.insert(name);
              }

              bool arst_is_reset = RTLIL::const_eq(arst_val, RTLIL::Const(0), false, false, 1).as_bool();

              if (arst_is_reset) { 
                  pp_asyncReset.insert(name);
              } else {
                  pp_asyncSet.insert(name);
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

           if (checkCell(cell, "DSP19X2", 
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

                if (!sigName(actual, name)) {
                  continue;
                }
                if ((portName == RTLIL::escape_id("CLK_A")) || 
                    (portName == RTLIL::escape_id("CLK_B"))) {

                  pp_clocks.insert(name);
                  pp_activeHigh.insert(name);
                  continue;
                }
             }

             continue;
           }

           if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;

                if (!sigName(actual, name)) {
                  continue;
                }

                if ((portName == RTLIL::escape_id("CLK_A1")) ||
                    (portName == RTLIL::escape_id("CLK_A2")) ||
                    (portName == RTLIL::escape_id("CLK_B1")) ||
                    (portName == RTLIL::escape_id("CLK_B2"))) {

                  pp_clocks.insert(name);
                  pp_activeHigh.insert(name);
                  continue;
                }
             }

             continue;
           }

           if (cell->type == RTLIL::escape_id("RS_TDP36K")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;

                if (!sigName(actual, name)) {
                  continue;
                }

                if ((portName == RTLIL::escape_id("CLK_A1")) ||
                    (portName == RTLIL::escape_id("CLK_A2")) ||
                    (portName == RTLIL::escape_id("CLK_B1")) ||
                    (portName == RTLIL::escape_id("CLK_B2"))) {

                  pp_clocks.insert(name);
                  pp_activeHigh.insert(name);
                  continue;
                }
             }
             continue;
           }

           if (cell->type == RTLIL::escape_id("FIFO36K")) {

             for (auto &conn : cell->connections()) {

                IdString portName = conn.first;

                RTLIL::SigSpec actual = conn.second;

                if (!sigName(actual, name)) {
                  continue;
                }

                if ((portName == RTLIL::escape_id("WR_CLK")) ||
                    (portName == RTLIL::escape_id("RD_CLK"))) {

                  pp_clocks.insert(name);
                  pp_activeHigh.insert(name);
                  continue;
                }

                if (portName == RTLIL::escape_id("RESET")) {

                  pp_syncReset.insert(name);
                  pp_activeHigh.insert(name);
                  continue;
                }
             }
             continue;
           }

        }

        run("design -load original");
    }

    void collectMemProperties()
    {
	for (auto &mem : Mem::get_all_memories(_design->top_module())) {

	   std::string mem_id = id(mem.memid);

           int width = mem.width;
           int depth = mem.size;

           pp_memories[mem_id] = std::make_pair(width, depth);
        }
    }

    bool illegal_port_connection(std::set<Cell*>* set_cells){
        bool generic_cell = false;
        bool i_buf = false;
        for (std::set<Cell*>::iterator it = set_cells->begin(); 
            it != set_cells->end(); it++) {
            Cell* cell = *it;
            if (cell->type == RTLIL::escape_id("I_BUF"))
                i_buf = true;
            else
                generic_cell = true;

            if (i_buf && generic_cell) return true;
        }
        return false;
    }

    void get_port_cell_relation (){
        for (auto &module : _design->selected_modules()) {
            for (auto wire : module->wires()){
                if (!wire->port_input) continue;
                SigSpec sig_port = wire;
                for (auto &cell : module->selected_cells()) {
                    for (auto &conn : cell->connections()) {
                        std::set<Cell*>* newSet;
                        if (!conn.second.is_chunk()){
                            std::vector<SigChunk> chunks_ = conn.second;
                            for (auto &chunk_ : chunks_){
                                SigSpec ChunkP  = chunk_;
                                if (sig_port == ChunkP){
                                    if (in_2_cell.count(sig_port)) { 
                                        newSet = in_2_cell[sig_port];
                                    } else {
                                        newSet = new std::set<Cell*>;
                                        in_2_cell[sig_port] = newSet;
                                    }
                                    newSet->insert(cell);
                                    continue;
                                }
                                // wire chunk with size greater 1
                                for (auto  Pbit : ChunkP){
                                    if (Pbit  == sig_port){
                                        if (in_2_cell.count(sig_port)) { 
                                            newSet = in_2_cell[sig_port];
                                        } else {
                                            newSet = new std::set<Cell*>;
                                            in_2_cell[sig_port] = newSet;
                                        }
                                        newSet->insert(cell);
                                    }
                                }
                            }
                        }
                        else{
                            if (sig_port == conn.second){
                                if (in_2_cell.count(sig_port)) { 
                                    newSet = in_2_cell[sig_port];
                                } else {
                                    newSet = new std::set<Cell*>;
                                    in_2_cell[sig_port] = newSet;
                                }
                                newSet->insert(cell);
                                continue;
                            }
                            // wire chunk with size greater 1
                            for (auto  Pbit : conn.second){
                                if (Pbit  == sig_port){
                                    if (in_2_cell.count(sig_port)) {
                                        newSet = in_2_cell[sig_port];
                                    } else {
                                        newSet = new std::set<Cell*>;
                                        in_2_cell[sig_port] = newSet;
                                    }
                                    newSet->insert(cell);
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    // Make sure that all OBUFT are correctly connected after calling
    // 'iopadmap'. Any undriven OBUFT or any dangling OBUFT is illegal
    // and we error out.
    //
    void check_OBUFT_Connections() {

       for (auto &module : _design->selected_modules()) {

          for(auto& cell : module->selected_cells()) {

             if(cell->type != RTLIL::escape_id("rs__O_BUFT")){
               continue;
             }

             int found_O = false;
             int found_I = false;

             for (auto &conn : cell->connections()) {

                 IdString portName = conn.first;

                 if (portName == RTLIL::escape_id("I")) {
                    found_I = true;
                 }
                 if (portName == RTLIL::escape_id("O")) {
                    found_O = true;
                 }
             }

             if (!found_O) {
                log_error("Dangling OBUFT (may be due to 'inout' port declaration or 'z' not handled (use -keep_tribuf)) \n");
             }

             if (!found_I) {
                log_error("Undriven OBUFT error connection \n");
             }
          }
       }
    }

    void checkPortConnections() {

       run("design -save original");
       run("splitnets -ports");
       get_port_cell_relation();

       bool error_count_illegal_port_conn = false;

       for (auto &module : _design->selected_modules()) {
           for (auto wire : module->wires()){
              SigSpec sig_port = wire;
              if (!wire->port_input) continue;
              if (in_2_cell.count(sig_port)){
                std::set<Cell*>* set_cells = in_2_cell[sig_port];
                if (illegal_port_connection(set_cells)){
                  error_count_illegal_port_conn=true;
                  log("ERROR: Illegal port connection: Input port %s connected to an input buffer and other components\n",log_signal(sig_port));
                }
              }
           }
        }
        if (error_count_illegal_port_conn)
            log_error("Terminating Synthesis for design %s due to previous errors\n",_design->top_module()->name.c_str());

        run("design -load original");
    }

    void legalize_tdp_ram_clock_ports(Cell* cell)
    {
      if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {
    
         bool found_CLK1 = false;
         bool found_CLK2 = false;
         RTLIL::SigSpec clk1;
         RTLIL::SigSpec clk2;

         // Look for clocks first in TDP
         //
         for (auto &conn : cell->connections()) {

            IdString portName = conn.first;
            RTLIL::SigSpec actual = conn.second;

            if (portName == RTLIL::escape_id("CLK_A1")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK1 = true;
                clk1 = actual;
              }
              continue;
            }
            if (portName == RTLIL::escape_id("CLK_B1")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK1 = true;
                clk1 = actual;
              }
              continue;
            }
            if (portName == RTLIL::escape_id("CLK_A2")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK2 = true;
                clk2 = actual;
              }
              continue;
            }
            if (portName == RTLIL::escape_id("CLK_B2")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK2 = true;
                clk2 = actual;
              }
              continue;
            }
         }

         if (!found_CLK1 && !found_CLK2) {
           log_error("cell '%s' has no associated clock\n", (cell->name).c_str());
         }

         // Reconnect clock ports if they are unconnected
         //
         for (auto &conn : cell->connections()) {

            IdString portName = conn.first;
            RTLIL::SigSpec actual = conn.second;

            if (portName == RTLIL::escape_id("CLK_A1")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 if (found_CLK1) {
                   cell->setPort(portName, clk1);
                 } else {
                   cell->setPort(portName, clk2);
                 }
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
            if (portName == RTLIL::escape_id("CLK_B1")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 if (found_CLK1) {
                   cell->setPort(portName, clk1);
                 } else {
                   cell->setPort(portName, clk2);
                 }
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
            if (portName == RTLIL::escape_id("CLK_A2")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 if (found_CLK2) {
                   cell->setPort(portName, clk2);
                 } else {
                   cell->setPort(portName, clk1);
                 }
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
            if (portName == RTLIL::escape_id("CLK_B2")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 if (found_CLK2) {
                   cell->setPort(portName, clk2);
                 } else {
                   cell->setPort(portName, clk1);
                 }
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
         }

         return;
      }

      if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {
    
         bool found_CLK = false;
         RTLIL::SigSpec clk;

         // Look for clocks first in TDP
         //
         for (auto &conn : cell->connections()) {

            IdString portName = conn.first;
            RTLIL::SigSpec actual = conn.second;

            if (portName == RTLIL::escape_id("CLK_A")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK = true;
                clk = actual;
              }
              continue;
            }
            if (portName == RTLIL::escape_id("CLK_B")) {
              if ((actual.is_chunk() && (actual.as_chunk()).wire != NULL)) {
                found_CLK = true;
                clk = actual;
              }
              continue;
            }
         }

         if (!found_CLK) {
           log_error("cell '%s' has no associated clock\n", (cell->name).c_str());
         }

         // Reconnect clock ports if they are unconnected
         //
         for (auto &conn : cell->connections()) {

            IdString portName = conn.first;
            RTLIL::SigSpec actual = conn.second;

            if (portName == RTLIL::escape_id("CLK_A")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 cell->setPort(portName, clk);
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
            if (portName == RTLIL::escape_id("CLK_B")) {
               // If port not connected
               //
               if ((actual.is_chunk() && (actual.as_chunk()).wire == NULL)) {
                 cell->setPort(portName, clk);
                 log_warning("Reconnect TDP_RAM clock port '%s' with '", portName.c_str());
                 show_sig(conn.second);
                 log("' for cell '%s'\n", (cell->name).c_str());
               }
               continue;
            }
         }

         return;
      }

    }

    void check_blackbox_param(){
	    std::set<RTLIL::IdString> primitive_names = {
		/* genesis3 blackbox primitives*/
		"\\I_BUF_DS","\\O_BUFT_DS","\\O_SERDES", "\\I_SERDES","\\BOOT_CLOCK","\\O_DELAY","\\O_SERDES_CLK","\\PLL",
        "\\SOC_FPGA_TEMPERATURE"};

        for (auto &module : _design->selected_modules()) {
           for(auto& cell : module->selected_cells()){
                if (!primitive_names.count(cell->type))
                continue;
                //PLL Default Paramters
                if (cell->type == RTLIL::escape_id("PLL")){

                    if (!cell->hasParam(RTLIL::escape_id("DEV_FAMILY")))
                        cell->setParam(RTLIL::escape_id("DEV_FAMILY"), stringf("VIRGO"));

                    if (!cell->hasParam(RTLIL::escape_id("PLL_DIV")))
                        cell->setParam(RTLIL::escape_id("PLL_DIV"), RTLIL::Const(1));

                    if (!cell->hasParam(RTLIL::escape_id("PLL_MULT")))
                        cell->setParam(RTLIL::escape_id("PLL_MULT"), RTLIL::Const(16));

                    if (!cell->hasParam(RTLIL::escape_id("PLL_POST_DIV")))
                        cell->setParam(RTLIL::escape_id("PLL_POST_DIV"), RTLIL::Const(17));

                    if (!cell->hasParam(RTLIL::escape_id("PLL_MULT_FRAC")))
                        cell->setParam(RTLIL::escape_id("PLL_MULT_FRAC"), RTLIL::Const(0));

                    if (!cell->hasParam(RTLIL::escape_id("DIVIDE_CLK_IN_BY_2")))
                        cell->setParam(RTLIL::escape_id("DIVIDE_CLK_IN_BY_2"), stringf("FALSE"));
                }
                //O_SERDES_CLK Default Paramters
                if (cell->type == RTLIL::escape_id("O_SERDES_CLK")){

                    if (!cell->hasParam(RTLIL::escape_id("DATA_RATE")))
                        cell->setParam(RTLIL::escape_id("DATA_RATE"), stringf("SDR"));

                    if (!cell->hasParam(RTLIL::escape_id("CLOCK_PHASE")))
                        cell->setParam(RTLIL::escape_id("CLOCK_PHASE"), RTLIL::Const(0));
                }
                //O_DELAY Default Paramters
                if (cell->type == RTLIL::escape_id("O_DELAY")){

                    if (!cell->hasParam(RTLIL::escape_id("DELAY")))
                        cell->setParam(RTLIL::escape_id("DELAY"), RTLIL::Const(0));
                }

                if (cell->type == RTLIL::escape_id("BOOT_CLOCK")){

                    if (!cell->hasParam(RTLIL::escape_id("PERIOD")))
                        cell->setParam(RTLIL::escape_id("PERIOD"), RTLIL::Const(25));
                }
                //I_SERDES Default Paramters
                if (cell->type == RTLIL::escape_id("I_SERDES")){

                    if (!cell->hasParam(RTLIL::escape_id("DATA_RATE")))
                        cell->setParam(RTLIL::escape_id("DATA_RATE"), stringf("SDR"));

                    if (!cell->hasParam(RTLIL::escape_id("WIDTH")))
                        cell->setParam(RTLIL::escape_id("WIDTH"), RTLIL::Const(4));

                    if (!cell->hasParam(RTLIL::escape_id("DPA_MODE")))
                        cell->setParam(RTLIL::escape_id("DPA_MODE"), stringf("NONE"));
                }
                //O_SERDES Default Paramters
                if (cell->type == RTLIL::escape_id("O_SERDES")){

                    if (!cell->hasParam(RTLIL::escape_id("DATA_RATE")))
                        cell->setParam(RTLIL::escape_id("DATA_RATE"), stringf("SDR"));

                    if (!cell->hasParam(RTLIL::escape_id("WIDTH")))
                        cell->setParam(RTLIL::escape_id("WIDTH"), RTLIL::Const(4));
                }
                //O_BUFT_DS Default Paramters
                if (cell->type == RTLIL::escape_id("O_BUFT_DS")){

                    if (!cell->hasParam(RTLIL::escape_id("WEAK_KEEPER")))
                        cell->setParam(RTLIL::escape_id("WEAK_KEEPER"), stringf("NONE"));
                }

                if (cell->type == RTLIL::escape_id("I_BUF_DS")){

                    if (!cell->hasParam(RTLIL::escape_id("WEAK_KEEPER")))
                        cell->setParam(RTLIL::escape_id("WEAK_KEEPER"), stringf("NONE"));
                }

                if (cell->type == RTLIL::escape_id("SOC_FPGA_TEMPERATURE")){

                    if (!cell->hasParam(RTLIL::escape_id("INITIAL_TEMPERATURE")))
                        cell->setParam(RTLIL::escape_id("INITIAL_TEMPERATURE"), RTLIL::Const(25));

                    if (!cell->hasParam(RTLIL::escape_id("TEMPERATURE_FILE")))
                        cell->setParam(RTLIL::escape_id("TEMPERATURE_FILE"), stringf(" "));
                }
           }
        }
    }

    void legalize_all_tdp_ram_clock_ports()
    {
       for (auto &module : _design->selected_modules()) {

           for(auto& cell : module->selected_cells()){

              if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {
                legalize_tdp_ram_clock_ports(cell);
                continue;
              }

              if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {
                legalize_tdp_ram_clock_ports(cell);
                continue;
              }

           }
       }

    }

    void collect_pll(RTLIL::Module* module, pool<RTLIL::Cell*>& pll_cells)
    {
       for (auto cell : module->cells()) {
           if (cell->type == RTLIL::escape_id("PLL")) {
             pll_cells.insert(cell);
           }
       }
    }

    void collect_ibuf(RTLIL::Module* module, pool<RTLIL::Cell*>& ibuf_cells)
    {
       for (auto cell : module->cells()) {
           if (cell->type == RTLIL::escape_id("rs__I_BUF")) {
             ibuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("I_BUF")) {
             ibuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("I_BUF_DS")) {
             ibuf_cells.insert(cell);
           }
       }
    }

    void collect_obuf(RTLIL::Module* module, pool<RTLIL::Cell*>& obuf_cells)
    {
       for (auto cell : module->cells()) {
           if (cell->type == RTLIL::escape_id("rs__O_BUF")) {
             obuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("O_BUF")) {
             obuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("O_BUF_DS")) {
             obuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("O_BUFT")) {
             obuf_cells.insert(cell);
           }
           if (cell->type == RTLIL::escape_id("O_BUFT_DS")) {
             obuf_cells.insert(cell);
           }
       }
    }

    bool is_input_ibuf(pool<RTLIL::Cell*>& ibuf_cells, RTLIL::Wire* w)
    {

       for (auto cell : ibuf_cells) {

           if (cell->type == RTLIL::escape_id("I_BUF")) {

             SigSpec input = cell->getPort(ID::I);
             RTLIL::Wire *iw = input[0].wire;

             if (w->name == iw->name) {
                return true;
             }
             continue;
           }
           if (cell->type == RTLIL::escape_id("I_BUF_DS")) {

             SigSpec input = cell->getPort(RTLIL::escape_id("I_P"));
             RTLIL::Wire* iw = input[0].wire;

             if (w->name == iw->name) {
                return true;
             }

             input = cell->getPort(RTLIL::escape_id("I_N"));
             iw = input[0].wire;

             if (w->name == iw->name) {
                return true;
             }
             continue;
          }
       }

       return false;
    }

    bool is_output_ibuf(pool<RTLIL::Cell*>& ibuf_cells, RTLIL::Wire* w)
    {

       for (auto cell : ibuf_cells) {

           SigSpec output = cell->getPort(ID::O);
           RTLIL::Wire *iw = output[0].wire;

           if (w->name == iw->name) {
              return true;
           }
       }

       return false;
    }

    bool is_output_pll(pool<RTLIL::Cell*>& ibuf_cells, RTLIL::Wire* w)
    {

       for (auto cell : ibuf_cells) {

          for (auto &conn : cell->connections()) {

               IdString portName = conn.first;
               RTLIL::SigSpec actual = conn.second;

               if (portName == RTLIL::escape_id("CLK_OUT")) {

                   RTLIL::Wire *iw = actual[0].wire;

                   if (w->name == iw->name) {
                      return true;
                   }
                   continue;
               }
               if (portName == RTLIL::escape_id("CLK_OUT_DIV2")) {

                   RTLIL::Wire *iw = actual[0].wire;

                   if (w->name == iw->name) {
                      return true;
                   }
                   continue;
               }
               if (portName == RTLIL::escape_id("CLK_OUT_DIV3")) {

                   RTLIL::Wire *iw = actual[0].wire;

                   if (w->name == iw->name) {
                      return true;
                   }
                   continue;
               }
               if (portName == RTLIL::escape_id("CLK_OUT_DIV4")) {

                   RTLIL::Wire *iw = actual[0].wire;

                   if (w->name == iw->name) {
                      return true;
                   }
                   continue;
               }
           }
       }

       return false;
    }


    bool is_output_obuf(pool<RTLIL::Cell*>& obuf_cells, RTLIL::Wire* w)
    {

       for (auto cell : obuf_cells) {

           if ((cell->type == RTLIL::escape_id("O_BUF")) ||
               (cell->type == RTLIL::escape_id("O_BUFT"))) {

             SigSpec output = cell->getPort(ID::O);
             RTLIL::Wire *ow = output[0].wire;

             if (w->name == ow->name) {
                return true;
             }
             continue;
           }

           if ((cell->type == RTLIL::escape_id("O_BUF_DS")) ||
               (cell->type == RTLIL::escape_id("O_BUFT_DS"))) {

             SigSpec output = cell->getPort(RTLIL::escape_id("O_N"));
             RTLIL::Wire* ow = output[0].wire;

             if (w->name == ow->name) {
                return true;
             }

             output = cell->getPort(RTLIL::escape_id("O_P"));
             ow = output[0].wire;

             if (w->name == ow->name) {
                return true;
             }

             continue;
           }
       }

       return false;
    }

    // For any O_BUFT that is driven by a I_BUF through its port 'O' 
    // we need to change the corresponding actual of 'O' and replace it
    // by the input of the I_BUF.
    //
    void rewire_obuft()
    {
       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_rewire_obuft.v");
       }

       for (auto &module : _design->selected_modules()) {

         dict<RTLIL::SigSpec, RTLIL::SigSpec> sig2sig;

         for (auto cell : module->cells()) {

            if (cell->type != RTLIL::escape_id("I_BUF")) {
               continue;
            }
            RTLIL::SigSpec out = cell->getPort(ID::O);
            RTLIL::SigSpec in = cell->getPort(ID::I);

            sig2sig[out] = in; // for the I_BUF output get its input
         }

         for (auto cell : module->cells()) {

            if (cell->type != RTLIL::escape_id("O_BUFT")) {
               continue;
            }

            RTLIL::SigSpec out = cell->getPort(ID::O);

            // If the actual output of the O_BUFT is an output of an
            // I_BUF.
            //
            if (sig2sig.find(out) != sig2sig.end()) {

               cell->unsetPort(ID::O);

               RTLIL::SigSpec in = sig2sig[out];

               RTLIL::Wire *iw = in[0].wire;

               cell->setPort(ID::O, iw);
              
            }
         }
       } // for all the modules

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_rewire_obuft.v");
       }
    }

    // Map the $TBUF cells into OBUFT equivalent.
    //
    void map_obuft(RTLIL::Module* top_module)
    {
       log(" *****************************\n");
       log("   Mapping Tri-state Buffers\n");
       log(" *****************************\n");

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_map_obuft.v");
       }

       vector<RTLIL::Cell*> tbufCells;

       for (auto cell : top_module->cells()) {

           if (cell->type != RTLIL::escape_id("$_TBUF_")) {
              continue;
           }

           tbufCells.push_back(cell);
       }

       for (auto cell : tbufCells) {

          log_assert(cell->type == RTLIL::escape_id("$_TBUF_"));

          RTLIL::IdString newName = top_module->uniquify(stringf("$o_buft_%s", 
                                                  log_id(cell->name)));

          RTLIL::Cell* newcell = top_module->addCell(newName, "\\O_BUFT");

          newcell->set_bool_attribute(ID::keep);

          for (auto &conn : cell->connections()) {

               IdString portName = conn.first;
               RTLIL::SigSpec actual = conn.second;

               if (portName == RTLIL::escape_id("A")) {

                  newcell->setPort(ID::I, actual);

                 continue;
               }
               if (portName == RTLIL::escape_id("E")) {

                  newcell->setPort(ID::T, actual);

                 continue;
               }
               if (portName == RTLIL::escape_id("Y")) {

                  newcell->setPort(ID::O, actual);

                 continue;
               }
               log_assert(0);
          }
       }

       // remove the original $TBUF cells
       //
       for (auto cell : tbufCells) {
            top_module->remove(cell);
       }

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_map_obuft.v");
       }
    }

    // Remove I_BUF and O_BUF and replace by assigns
    // This is usefull for instance when we start from a bad implementation
    // of I_BUF/O_Buf like in test case : 
    // 'Validation/RTL_testcases/RS_Primitive_example_designs/primitive_example_design_1'
    // where I_BUF is user instantiated on a PI but sometime the PI is
    // used directly in the logic instead of using the I_BUF output
    // So this allows to restart from a clean sheet.
    // WARNING; we may need to handle case where 'keep' attribute is on
    // the I_BUF/O_BUF so that we cannot remove them.
    //
    void remove_io_buffers(RTLIL::Module* top_module)
    {
       log(" *********************************\n");
       log("   Removing Input/Output Buffers\n");
       log(" *********************************\n");

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_remove_io_buffers.v");
       }

       vector<RTLIL::Cell*> ibufCells;
       vector<RTLIL::Cell*> obufCells;

       for (auto cell : top_module->cells()) {

           if (cell->type == RTLIL::escape_id("I_BUF")) {
              ibufCells.push_back(cell);
              continue;
           }

           if (cell->type == RTLIL::escape_id("O_BUF")) {
              obufCells.push_back(cell);
              continue;
           }

       }

       std::vector<RTLIL::SigSig> newConnections;

       for (auto conn : top_module->connections()) {
          newConnections.push_back(conn);
       }

       for (auto cell : ibufCells) {

          log_assert(cell->type == RTLIL::escape_id("I_BUF"));

          RTLIL::SigSpec input = cell->getPort(ID::I);
          RTLIL::SigSpec output = cell->getPort(ID::O);

          RTLIL::SigSig newConnection = make_pair(output, input);

          newConnections.push_back(newConnection);
       }

       for (auto cell : obufCells) {

          log_assert(cell->type == RTLIL::escape_id("O_BUF"));

          RTLIL::SigSpec input = cell->getPort(ID::I);
          RTLIL::SigSpec output = cell->getPort(ID::O);

          RTLIL::SigSig newConnection = make_pair(output, input);

          newConnections.push_back(newConnection);
       }

       top_module->new_connections(newConnections);

       for (auto cell : ibufCells) {
            top_module->remove(cell);
       }

       for (auto cell : obufCells) {
            top_module->remove(cell);
       }

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_remove_io_buffers.v");
       }
    }

    void ofab_insert_NS_rules(RTLIL::Module* top_module, RTLIL::Cell* cell,
                              string portName, string fabPortName, RTLIL::SigSpec& actual)
    {

       if (iofab_map == 2) {
          log("     - Inserting O_FAB on cell '%s' (%s) on NS input port '%s'\n", (cell->name).c_str(),
              (cell->type).c_str(), portName.c_str());
       }

       if (!actual.is_chunk()) {

          RTLIL::SigSpec new_sig;

          // This is an append of sub signals
          //
          for (auto it = actual.chunks().rbegin(); it != actual.chunks().rend(); ++it) {

             RTLIL::SigSpec sub_actual = *it;

             RTLIL::Wire *wire = sub_actual[0].wire;

             if (fabPortName =="") {
               fabPortName = "ofab";
             }

             // Make sure the wire is 1 bit size
             //
             if (GetSize(wire) != 1) {
               log_error("insert O_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                         (wire->name).c_str(), GetSize(wire));
             }

             RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                             log_id(wire)));

             RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

             RTLIL::Cell *new_cell = top_module->addCell(
                                     top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                        log_id(wire->name))), RTLIL::escape_id("O_FAB"));

             new_cell->set_bool_attribute(ID::keep);
  
             new_cell->setPort(ID::I, RTLIL::SigSpec(wire));

             RTLIL::SigSpec new_sigI = RTLIL::SigSpec(new_wire);

             new_cell->setPort(ID::O, new_sigI);

             // Build the new append
             //
             new_sig.append(new_sigI);

          }

          RTLIL::IdString idPortName = RTLIL::escape_id(portName);

          cell->unsetPort(idPortName);

          cell->setPort(idPortName, new_sig);

       } else {

         RTLIL::Wire *wire = actual[0].wire;

         if (fabPortName =="") {
           fabPortName = "ofab";
         }

         // Make sure the wire is 1 bit size
         //
         if (GetSize(wire) != 1) {
           log_error("insert O_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                     (wire->name).c_str(), GetSize(wire));
         }

         RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                         log_id(wire)));

         RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

         RTLIL::Cell *new_cell = top_module->addCell(
                                 top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                    log_id(wire->name))), RTLIL::escape_id("O_FAB"));

         new_cell->set_bool_attribute(ID::keep);
  
         new_cell->setPort(ID::I, RTLIL::SigSpec(wire));
         new_cell->setPort(ID::O, RTLIL::SigSpec(new_wire));

         RTLIL::IdString idPortName = RTLIL::escape_id(portName);

         cell->unsetPort(idPortName);

         cell->setPort(idPortName, new_wire);
      }
    }

    void ifab_insert_NS_rules(RTLIL::Module* top_module, RTLIL::Cell* cell,
                              string portName, string fabPortName, RTLIL::SigSpec& actual)
    {
       if (iofab_map == 2) {
          log("     - Inserting I_FAB on cell '%s' (%s) on NS output port '%s'\n", (cell->name).c_str(),
              (cell->type).c_str(), portName.c_str());
       }

       if (!actual.is_chunk()) {

          RTLIL::SigSpec new_sig;

          // This is an append of sub signals
          //
          for (auto it = actual.chunks().rbegin(); it != actual.chunks().rend(); ++it) {

             RTLIL::SigSpec sub_actual = *it;

             RTLIL::Wire *wire = sub_actual[0].wire;

             if (fabPortName =="") {
               fabPortName = "ifab";
             }

             // Make sure the wire is 1 bit size
             //
             if (GetSize(wire) != 1) {
               log_error("insert I_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                         (wire->name).c_str(), GetSize(wire));
             }

             RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                             log_id(wire)));

             RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

             RTLIL::Cell *new_cell = top_module->addCell(
                                     top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                        log_id(wire->name))), RTLIL::escape_id("I_FAB"));

             new_cell->set_bool_attribute(ID::keep);

             new_cell->setPort(ID::O, RTLIL::SigSpec(wire));

             RTLIL::SigSpec new_sigI = RTLIL::SigSpec(new_wire);

             new_cell->setPort(ID::I, new_sigI);

             // Build the new append
             //
             new_sig.append(new_sigI);
          }

          RTLIL::IdString idPortName = RTLIL::escape_id(portName);

          cell->unsetPort(idPortName);

          cell->setPort(idPortName, new_sig);

       } else {

          RTLIL::Wire *wire = actual[0].wire;

          if (fabPortName =="") {
            fabPortName = "ifab";
          }

          // Make sure the wire is 1 bit size
          //
          if (GetSize(wire) != 1) {
            log_error("insert I_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                      (wire->name).c_str(), GetSize(wire));
          }

          RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                          log_id(wire)));

          RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

          RTLIL::Cell *new_cell = top_module->addCell(
                                  top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                     log_id(wire->name))), RTLIL::escape_id("I_FAB"));

          new_cell->set_bool_attribute(ID::keep);

          new_cell->setPort(ID::O, RTLIL::SigSpec(wire));
          new_cell->setPort(ID::I, RTLIL::SigSpec(new_wire));

          RTLIL::IdString idPortName = RTLIL::escape_id(portName);

          cell->unsetPort(idPortName);

          cell->setPort(idPortName, new_wire);
       }
    }


    // Insert a I_FAB or O_FAB at the port of name 'portName' of 'cell' if
    // possible. For instance we do not insert anything if the port is driven 
    // by a constant. We are in the Non Shared(NS) case which means that 
    // we systematically create a I_FAB or O_FAB.
    //
    void insert_iofab_NS_rules(RTLIL::Module* top_module, RTLIL::Cell* cell,
                               string portName, string fabPortName)
    {
       int found = 0;
       int insertable = 0;
       RTLIL::SigSpec actual;

       // Look for the Port 
       //
       for (auto &conn : cell->connections()) {

          IdString cellPortName = conn.first;
          actual = conn.second;

          if (cellPortName == RTLIL::escape_id(portName)) {

            found = 1;

            // We cannot insert on a constant wire
            //
            if (actual.has_const()) {
              return;
            }
            insertable = 1;
            break;
          }
       }

       if (!found) {
         log_warning("Could not find port '%s' to insert I_FAB/O_FAB on cell of type '%s'\n",
                     portName.c_str(), (cell->type).c_str());
         return;
       }

       if (!insertable) {
         log_warning("Nothing to insert at port '%s' for cell '%s' of type '%s (probably constant actual)'\n",
                     portName.c_str(), (cell->name).c_str(), (cell->type).c_str());
         return;
       }

       // For a primitive cell port input we need to insert a O_FAB in order to
       // bring the logic driving this port from the fabric.
       //
       if (cell->input(RTLIL::escape_id(portName))) {

          ofab_insert_NS_rules(top_module, cell, portName, fabPortName, actual);

          return;
       }

       // For a primitive cell port output we need to insert a I_FAB in order to
       // bring the logic into the fabric.
       //
       if (cell->output(RTLIL::escape_id(portName))) {

          ifab_insert_NS_rules(top_module, cell, portName, fabPortName, actual);

          return;
       }

       log_warning("Could not insert I_FAB/O_FAB cell on port '%s' of cell type '%s' because port direction is unknown\n", portName.c_str(), (cell->type).c_str());

    }

    // We are in SHARED mode. Insert one unique O_FAB for the sub group of cells 'sub_cells' 
    // at port of name 'portName'.
    //
    void insert_ofab_sub_cells (RTLIL::Module* top_module, vector<RTLIL::Cell*>* sub_cells, 
                               string portName, string fabPortName, RTLIL::SigSpec& actual) 
    {
       log("     - Inserting O_FAB on SHARED input port '%s' for cells\n", portName.c_str());

       for (auto cell : *sub_cells) {
         log("             '%s'\n", (cell->name).c_str());
       }

       if (!actual.is_chunk()) {

          for (auto it = actual.chunks().rbegin(); it != actual.chunks().rend(); ++it) {

             RTLIL::SigSpec sub_actual = *it;

             RTLIL::Wire *wire = sub_actual[0].wire;

             if (fabPortName =="") {
               fabPortName = "ofab";
             }

             // Make sure the wire is 1 bit size
             //
             if (GetSize(wire) != 1) {
               log_error("insert O_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                        (wire->name).c_str(), GetSize(wire));
             }

             RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                             log_id(wire)));

             RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

             RTLIL::Cell *new_cell = top_module->addCell(
                                     top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                        log_id(wire->name))), RTLIL::escape_id("O_FAB"));

             new_cell->set_bool_attribute(ID::keep);

             new_cell->setPort(ID::I, RTLIL::SigSpec(wire));
             new_cell->setPort(ID::O, RTLIL::SigSpec(new_wire));

             RTLIL::IdString idPortName = RTLIL::escape_id(portName);

             // rewire the sub group of cells
             //
             for (auto cell : *sub_cells) {

               cell->unsetPort(idPortName);

               cell->setPort(idPortName, new_wire);
             }
          }

       } else {

         RTLIL::Wire *wire = actual[0].wire;

         if (fabPortName =="") {
           fabPortName = "ofab";
         }

         // Make sure the wire is 1 bit size
         //
         if (GetSize(wire) != 1) {
           log_error("insert O_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                     (wire->name).c_str(), GetSize(wire));
         }

         RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                         log_id(wire)));

         RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

         RTLIL::Cell *new_cell = top_module->addCell(
                                 top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                    log_id(wire->name))), RTLIL::escape_id("O_FAB"));

         new_cell->set_bool_attribute(ID::keep);

         new_cell->setPort(ID::I, RTLIL::SigSpec(wire));
         new_cell->setPort(ID::O, RTLIL::SigSpec(new_wire));

         RTLIL::IdString idPortName = RTLIL::escape_id(portName);

         // rewire the sub group of cells
         //
         for (auto cell : *sub_cells) {

           cell->unsetPort(idPortName);

           cell->setPort(idPortName, new_wire);
         }
      }
    }
    
    // We are in SHARED mode. Insert one unique I_FAB for the sub group of cells 'sub_cells' 
    // at port of name 'portName'.
    //
    void insert_ifab_sub_cells (RTLIL::Module* top_module, vector<RTLIL::Cell*>* sub_cells, 
                               string portName, string fabPortName, RTLIL::SigSpec& actual) 
    {
       
       log("     - Inserting I_FAB on SHARED output port '%s' for cells\n", portName.c_str());

       for (auto cell : *sub_cells) {
         log("             '%s'\n", (cell->name).c_str());
       }

       if (!actual.is_chunk()) {

          for (auto it = actual.chunks().rbegin(); it != actual.chunks().rend(); ++it) {

             RTLIL::SigSpec sub_actual = *it;

             RTLIL::Wire *wire = sub_actual[0].wire;

             if (fabPortName =="") {
               fabPortName = "ifab";
             }

             // Make sure the wire is 1 bit size
             //
             if (GetSize(wire) != 1) {
               log_error("insert I_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                         (wire->name).c_str(), GetSize(wire));
             }

             RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                             log_id(wire)));

             RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

             RTLIL::Cell *new_cell = top_module->addCell(
                                        top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                        log_id(wire->name))), RTLIL::escape_id("I_FAB"));

             new_cell->set_bool_attribute(ID::keep);

             new_cell->setPort(ID::O, RTLIL::SigSpec(wire));
             new_cell->setPort(ID::I, RTLIL::SigSpec(new_wire));

             RTLIL::IdString idPortName = RTLIL::escape_id(portName);

             // rewire the sub group of cells
             //
             for (auto cell : *sub_cells) {

               cell->unsetPort(idPortName);
   
               cell->setPort(idPortName, new_wire);
             }
          }

       } else {

          RTLIL::Wire *wire = actual[0].wire;

          if (fabPortName =="") {
            fabPortName = "ifab";
          }

          // Make sure the wire is 1 bit size
          //
          if (GetSize(wire) != 1) {
            log_error("insert I_FAB procedure expects '%s' to be a 1 bit signal (size = %d).\n",
                      (wire->name).c_str(), GetSize(wire));
          }

          RTLIL::IdString new_name = top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                                          log_id(wire)));

          RTLIL::Wire *new_wire = top_module->addWire(new_name, wire); 

          RTLIL::Cell *new_cell = top_module->addCell(
                                     top_module->uniquify(stringf("$%s_%s", fabPortName.c_str(), 
                                     log_id(wire->name))), RTLIL::escape_id("I_FAB"));

          new_cell->set_bool_attribute(ID::keep);

          new_cell->setPort(ID::O, RTLIL::SigSpec(wire));
          new_cell->setPort(ID::I, RTLIL::SigSpec(new_wire));

          RTLIL::IdString idPortName = RTLIL::escape_id(portName);

          // rewire the sub group of cells
          //
          for (auto cell : *sub_cells) {

            cell->unsetPort(idPortName);
   
            cell->setPort(idPortName, new_wire);
          }
       }
    }

    // Insert a I_FAB or O_FAB at the port of name 'portName' for a group of cells if
    // possible. For instance we do not insert anything if the port is driven 
    // by a constant. We are in the Shared (S) case which means that we insert 
    // a unique I_FAB or O_FAB for sub-group of cells that have in common the same 
    // actual associated to a port of name 'portName'.
    //
    void insert_iofab_S_rules(RTLIL::Module* top_module, vector<RTLIL::Cell*>* cells, 
                              string portName, string fabPortName)
    {

       dict<RTLIL::SigSpec, vector<RTLIL::Cell*>*> sig2cells;

       int found = 0;

       int direction = 0; // 0 -> unknown, 1 -> input, 2 -> output

       RTLIL::Cell* last_cell;

       if (cells->size() == 0) {
          return;
       }

       // group cells having the same actual on portName
       //
       for (auto cell : *cells) {

          last_cell = cell;

          if (cell->input(RTLIL::escape_id(portName))) {
            direction = 1;
          }

          if (cell->output(RTLIL::escape_id(portName))) {
            direction = 2;
          }

          // Look for the Port 'portname'
          //
          for (auto &conn : cell->connections()) {

            IdString cellPortName = conn.first;
            RTLIL::SigSpec actual = conn.second;

            if (cellPortName == RTLIL::escape_id(portName)) {

              found = 1;

              // We cannot insert on a constant wire
              //
              if (actual.has_const()) {
                break;
              }

              if (sig2cells.count(actual) == 0) {
                sig2cells[actual] = new vector<RTLIL::Cell*>;
              }

              sig2cells[actual]->push_back(cell);

              break;
            }
          }
       }

       if (!found) {
         log_warning("Could not find port '%s' to insert I_FAB/O_FAB on cell of type '%s'\n",
                     portName.c_str(), (last_cell->type).c_str());
         return;
       }

       if (!direction) {
         log_warning("Could not insert I_FAB/O_FAB cell on port '%s' of cell type '%s' because port direction is unknown\n", portName.c_str(), (last_cell->type).c_str());
         return;
       }

       // Insert only one I_FAB/O_FAB for the sub group of cells
       //
       for (auto group : sig2cells) {

          RTLIL::SigSpec actual = group.first;

          vector<RTLIL::Cell*>* sub_cells = group.second;

          if (direction == 1) { // if primitive port direction is input -> insert a O_FAB

            insert_ofab_sub_cells (top_module, sub_cells, portName, fabPortName, actual); 

          } else { // if primitive port direction is output -> insert a I_FAB

            insert_ifab_sub_cells (top_module, sub_cells, portName, fabPortName, actual); 
          }
       }

    }


    // Creates for each primary input an associated 'rs__I_BUF' cell that will
    // be tech mapped later.
    // We use a trick so that the PI physical wire will be renamed into the name
    // of the wire at the output of the 'rs__I_BUF'. This avoid to visit all the logic
    // to replace the original PI by the output of the new 'rs__I_BUF'. So we spare
    // run time and extra code development. On the other hand we need to create a new PI, 
    // exactly the same as the original PI, and declare it as the new PI. We will 
    // then connect this new PI to the input of the 'rs__I_BUF' buffer and the renamed 
    // original PI at the output of 'rs__I_BUF' buffer.
    //
    void insert_input_buffers(RTLIL::Module* top_module)
    {
new_iobuf_map = 2;

       log(" ***************************\n");
       log("   Inserting Input Buffers\n");
       log(" ***************************\n");

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_input_buffers.v");
       }

       pool<RTLIL::Cell*> ibuf_cells;

       collect_ibuf(top_module, ibuf_cells);

       std::vector<RTLIL::Wire*> piw2ibuf;

       // Collect primary Inputs wires (piw) that have no associated I_BUF/I_BUF_DS
       //
       for (auto wire : top_module->wires()) {

            // Here we can process both input and inout because in both cases
            // we have to infer a I_BUF
            //
            if (!wire->port_input) {
               continue;
            }

            log_assert(wire->port_input); // either input or inout

            if (is_input_ibuf(ibuf_cells, wire)) {
              log("INFO: port '%s' has an associated I_BUF\n", (wire->name).c_str());
              continue;
            }

            log("WARNING: port '%s' has no associated I_BUF\n", (wire->name).c_str());

            piw2ibuf.push_back(wire);
       } 

       pool<RTLIL::Cell*> newCells;
       dict<RTLIL::IdString, RTLIL::IdString> name2name;
       dict<RTLIL::Wire*, RTLIL::Wire*> wire2wire;

       // Create I_BUF for these primary inputs without already associated I_BUF
       //
       for (auto wire : piw2ibuf) {

             RTLIL::IdString orgName = wire->name;

             RTLIL::IdString newName = top_module->uniquify(stringf("$ibuf_%s", log_id(wire)));

             name2name[newName] = orgName;

             // The original Primary input is renamed as the IBUF wire output
             //
             top_module->rename(wire, newName);

             // The new created wire will become the new Primary input
             //
             RTLIL::Wire *new_wire = top_module->addWire(orgName, wire); 

             wire2wire[wire] = new_wire;

             // Wire which was a port becomes a regular wire, it is no more a PI.
             //
             wire->port_input = 0;
             wire->port_output = 0;
             wire->port_id = 0;

             // new_wire becomes the new PI.
             //
             // work directly on the primary input/inout wire if its with is 1
             //
             if (GetSize(new_wire) == 1) {

               RTLIL::Cell *cell = top_module->addCell(
                                    top_module->uniquify(stringf("$ibuf$%s.%s", 
                                     log_id(top_module->name), log_id(wire->name))),
                                     RTLIL::escape_id("rs__I_BUF"));

               cell->set_bool_attribute(ID::keep);

               cell->setPort(ID::I, RTLIL::SigSpec(new_wire));
               cell->setPort(ID::O, RTLIL::SigSpec(wire));

             } else {

                // If primary input/inout wire width > 1 then bit split it
                //
                for (int i = 0; i< wire->width; i++) {

                  RTLIL::Cell *cell = top_module->addCell(
                                       top_module->uniquify(stringf("$ibuf$%s.%s", 
                                         log_id(top_module->name), log_id(wire->name))),
                                         RTLIL::escape_id("rs__I_BUF"));

                  cell->set_bool_attribute(ID::keep);

                  RTLIL::SigSpec new_sig = RTLIL::SigSpec(new_wire, i, 1);
                  RTLIL::SigSpec sig = RTLIL::SigSpec(wire, i, 1);

                  cell->setPort(ID::I, new_sig);
                  cell->setPort(ID::O, sig);

                }
             }
  
       }

       // rebuild the port interface
       //
       top_module->fixup_ports();

       // Now make sure that there is not a single primary input which is used
       // directly. case :
       // 'Validation/RTL_testcases/RS_Primitive_example_designs/primitive_example_design_1'
       //

       // Build the map table for all I_BUF input to I_BUF output
       //
       dict<RTLIL::Wire*, RTLIL::Wire*> in2out_ibuf;

       for (auto cell : top_module->cells()) {

           if (cell->type == RTLIL::escape_id("I_BUF")) {

              RTLIL::SigSpec input = cell->getPort(ID::I);
              RTLIL::SigSpec output = cell->getPort(ID::O);

              if (input.has_const()) {
                 continue;
              }

              RTLIL::Wire *win = input[0].wire;
              RTLIL::Wire *wout = output[0].wire;

              in2out_ibuf[win] = wout;
           }
       }

       // Look at all the cells connected wires and replace them if
       // they correspond to direct primary inputs
       //
       for (auto cell : top_module->cells()) {

          if ((cell->type == RTLIL::escape_id("I_BUF")) ||
              (cell->type == RTLIL::escape_id("I_BUF_DS"))) {
            continue;
          }

	  dict<RTLIL::IdString, RTLIL::SigSpec> connections;

          // Collect/duplicate the good cell connections
          //
          for (auto &conn : cell->connections()) {

             RTLIL::SigSpec actual = conn.second;

             if (actual.has_const()) {
                 continue;
             }
             connections[conn.first] = actual;
          }

          // and eventually replace
          //
          for (auto conn : connections) {

             IdString portName = conn.first;

             RTLIL::SigSpec actual = conn.second;

             RTLIL::Wire *wi = actual[0].wire;

             // If we find a direct primary input occurence replace it
             // by its corresponding output I_BUF
             //
             if (in2out_ibuf.count(wi)) {

                RTLIL::Wire *wo = in2out_ibuf[wi];

                cell->unsetPort(portName);

                cell->setPort(portName, wo);

                log_warning("Replacing direct input '%s' by I_BUF output '%s' in cell '%s (%s)'\n",
                            (wi->name).c_str(), (wo->name).c_str(), (cell->name).c_str(),
                            (cell->type).c_str());
             }
          }
       }

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_input_buffers.v");
       }
    }

    // Creates for each primary output an associated 'rs__O_BUF' cell that will
    // be tech mapped later.
    // We use a trick so that the PO physical wire will be renamed into the name
    // of the wire at the input of the 'rs__O_BUF'. This avoid to visit all the logic
    // to replace the original PO by the input of the new 'rs__O_BUF'. So we spare
    // run time and extra code development. On the other hand we need to create a new PO, 
    // exactly the same as the original PO, and declare it as the new PO. We will 
    // then connect this new PO to the output of the 'rs__O_BUF' buffer and the renamed 
    // original PO at the input of 'rs__O_BUF' buffer.
    //
    void insert_output_buffers(RTLIL::Module* top_module)
    {
       log(" *****************************\n");
       log("   Inserting Output Buffers\n");
       log(" *****************************\n");

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_output_buffers.v");
       }

       pool<RTLIL::Cell*> obuf_cells;

       collect_obuf(top_module, obuf_cells);

       std::vector<RTLIL::Wire*> w2obuf;

       for (auto wire : top_module->wires()) {

            // do not consider inout, only pure output !
            //
            if (!wire->port_output || wire->port_input) {
               continue;
            }

            if (is_output_obuf(obuf_cells, wire)) {
              log("INFO: OUTPUT port '%s' has an associated O_BUF\n", (wire->name).c_str());
              continue;
            }

            log("WARNING: OUTPUT port '%s' has no associated O_BUF\n", (wire->name).c_str());

            w2obuf.push_back(wire);
       } 

       pool<RTLIL::Cell*> newCells;
       dict<RTLIL::IdString, RTLIL::IdString> name2name;
       dict<RTLIL::Wire*, RTLIL::Wire*> wire2wire;

       for (auto wire : w2obuf) {

             RTLIL::IdString orgName = wire->name;

             RTLIL::IdString newName = top_module->uniquify(stringf("$obuf_%s", log_id(wire)));

             name2name[newName] = orgName;

             // we rename the original PO
             //
             top_module->rename(wire, newName);

             // We create a new PO with the original PO name.
             //
             RTLIL::Wire *new_wire = top_module->addWire(orgName, wire); 

             wire2wire[wire] = new_wire;

             // The old PO becomes a regular wire.
             //
             wire->port_input = 0;
             wire->port_output = 0;
             wire->port_id = 0;

             // new_wire becomes the new PO
             //
             // work directly on the primary output wire if its with is 1
             //
             if (GetSize(new_wire) == 1) {

               RTLIL::Cell *cell = top_module->addCell(
                                    top_module->uniquify(stringf("$obuf$%s.%s", 
                                     log_id(top_module->name), log_id(wire->name))),
                                     RTLIL::escape_id("rs__O_BUF"));

               cell->set_bool_attribute(ID::keep);

               cell->setPort(ID::O, RTLIL::SigSpec(new_wire));
               cell->setPort(ID::I, RTLIL::SigSpec(wire));

             } else {

                // If primary output wire width > 1 then bit split it
                //
                for (int i = 0; i< wire->width; i++) {
                   RTLIL::Cell *cell = top_module->addCell(
                                         top_module->uniquify(stringf("$obuf$%s.%s", 
                                          log_id(top_module->name), log_id(wire->name))),
                                          RTLIL::escape_id("rs__O_BUF"));

                   cell->set_bool_attribute(ID::keep);

                   RTLIL::SigSpec new_sig = RTLIL::SigSpec(new_wire, i, 1);
                   RTLIL::SigSpec sig = RTLIL::SigSpec(wire, i, 1);

                   cell->setPort(ID::O, new_sig);
                   cell->setPort(ID::I, sig);
                }
             }
       }

       // rebuild the port interface
       //
       top_module->fixup_ports();

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_output_buffers.v");
       }
    }

    // Collect all the SigSpec that drive any clock port of a sequential cell.
    // For such a given SigSpec, stores the vector of the sequential cells
    // driven by this SigSpec.
    //
    void collect_clock_domains(RTLIL::Module* module, 
                               dict<RTLIL::SigSpec, vector<RTLIL::Cell*>*>& clock_domain)
    {
       for (auto cell : module->cells()) {

           if ((cell->type == RTLIL::escape_id("DFFRE")) ||
               (cell->type == RTLIL::escape_id("DFFNRE"))) {

              RTLIL::SigSpec actual = cell->getPort(ID::C);

              if (actual.has_const()) {
                 continue;
              }

              if (clock_domain.find(actual) == clock_domain.end()) {
                clock_domain[actual] = new vector<RTLIL::Cell*>;
              }
              clock_domain[actual]->push_back(cell);
              continue;
           }

           if ((cell->type == RTLIL::escape_id("I_DELAY")) ||
               (cell->type == RTLIL::escape_id("O_DELAY"))) {

              RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("CLK_IN"));

              if (actual.has_const()) {
                 continue;
              }

              if (clock_domain.find(actual) == clock_domain.end()) {
                clock_domain[actual] = new vector<RTLIL::Cell*>;
              }
              clock_domain[actual]->push_back(cell);
              continue;
           }

           if ((cell->type == RTLIL::escape_id("I_DDR")) ||
               (cell->type == RTLIL::escape_id("O_DDR"))) {

              RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("C"));

              if (actual.has_const()) {
                 continue;
              }

              if (clock_domain.find(actual) == clock_domain.end()) {
                clock_domain[actual] = new vector<RTLIL::Cell*>;
              }
              clock_domain[actual]->push_back(cell);
              continue;
           }

           if ((cell->type == RTLIL::escape_id("I_SERDES")) ||
               (cell->type == RTLIL::escape_id("O_SERDES"))) {

              RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("CLK_IN"));

              if (actual.has_const()) {
                 continue;
              }

              if (clock_domain.find(actual) == clock_domain.end()) {
                clock_domain[actual] = new vector<RTLIL::Cell*>;
              }
              clock_domain[actual]->push_back(cell);
              continue;
           }

           if ((cell->type == RTLIL::escape_id("DSP19X2")) ||
               (cell->type == RTLIL::escape_id("DSP38"))) {

              for (auto &conn : cell->connections()) {

                  IdString portName = conn.first;
                  RTLIL::SigSpec actual = conn.second;

                  if (actual.has_const()) {
                     continue;
                  }

                  if (portName == RTLIL::escape_id("CLK")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }
              }
              continue;
           }

           if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {

              for (auto &conn : cell->connections()) {

                  IdString portName = conn.first;
                  RTLIL::SigSpec actual = conn.second;

                  if (actual.has_const()) {
                     continue;
                  }

                  if (portName == RTLIL::escape_id("CLK_A1")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }

                  if (portName == RTLIL::escape_id("CLK_A2")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }

                  if (portName == RTLIL::escape_id("CLK_B1")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }

                  if (portName == RTLIL::escape_id("CLK_B2")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }
              }
              continue;
           }

           if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {

              for (auto &conn : cell->connections()) {

                  IdString portName = conn.first;
                  RTLIL::SigSpec actual = conn.second;

                  if (actual.has_const()) {
                     continue;
                  }

                  if (portName == RTLIL::escape_id("CLK_A")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }

                  if (portName == RTLIL::escape_id("CLK_B")) {

                    if (clock_domain.find(actual) == clock_domain.end()) {
                      clock_domain[actual] = new vector<RTLIL::Cell*>;
                    }
                    clock_domain[actual]->push_back(cell);
                  }
              }
              continue;
           }
       }
    }

    // We either insert CLK_BUF or FCLK_BUF on clocks signals that drive 
    // sequential cells.
    //
    // ASSUMPTION: the IBUF insertions should be done before calling 
    // this function because it will tell whether we need to 
    // infer a CLK_BUF or a FCLK_BUF.
    //
    void insert_clk_buffers(RTLIL::Module* top_module)
    {
       log(" ***************************\n");
       log("   Inserting Clock Buffers\n");
       log(" ***************************\n");

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex before_clk_buffers.v");
       }

       dict<RTLIL::SigSpec, vector<RTLIL::Cell*>*> clock_domains;

       // Collect the clocks driving the sequential cells of the
       // top module. Sequential cells are DFFRE, DFFNRE, DSP with clock port
       // and TDP_RAM.
       // We insert a CLK_BUF/FCLK_BUF only in front of these cells and not
       // in front of the other cells (comb. cells) in case clocks drive them.
       //
       collect_clock_domains(top_module, clock_domains);

       pool<RTLIL::Cell*> ibuf_cells;

       // Collect the IBUF to decide later if we need to infer CLK_BUF (driven
       // by IBUF) or FCLK_BUF (not driven by IBUF).
       //
       collect_ibuf(top_module, ibuf_cells);

       pool<RTLIL::Cell*> pll_cells;

       collect_pll(top_module, pll_cells);

       for (auto cd : clock_domains) {

            bool is_FCLK_BUF = false;

            RTLIL::SigSpec clk = cd.first;
            RTLIL::Wire *w = clk[0].wire;

            // We do not insert CLK_BUF in front of 'w' if 'w' is the output of
            // a PLL clock port.
            //
            if (is_output_pll(pll_cells, w)) {
              continue;
            }

            if (is_output_ibuf(ibuf_cells, w)) {

              log("INFO: inserting CLK_BUF before '");
              show_sig(clk);
              log("'\n");

            } else {

              is_FCLK_BUF = true;

              log("INFO: inserting FCLK_BUF before '");
              show_sig(clk);
              log("'\n");
            }

            RTLIL::IdString newName = top_module->uniquify(stringf(
                                       (is_FCLK_BUF ? "$fclk_buf_%s" : "$clk_buf_%s"), 
                                       log_id(w)));

            RTLIL::Wire *newWire = top_module->addWire(newName, w); 

            // Create the clock buf for the sequential clock domain : it can
            // be either a CLK_BUF or FCLK_BUF
            //
            RTLIL::Cell *clk_buf = top_module->addCell(
                                   top_module->uniquify(stringf("$clkbuf$%s.%s", 
                                     log_id(top_module->name), log_id(w->name))),
                                     (is_FCLK_BUF ? RTLIL::escape_id("FCLK_BUF") : 
                                      RTLIL::escape_id("CLK_BUF")));

            clk_buf->set_bool_attribute(ID::keep);

            clk_buf->setPort(ID::I, RTLIL::SigSpec(w));
            clk_buf->setPort(ID::O, RTLIL::SigSpec(newWire));

            // vector of sequential cells with 'clk' driving one of their
            // port
            //
            vector<RTLIL::Cell*>* scells = cd.second;

            // Now we rewire the clock port of the cells in the clock domain
            // by the output of the new CLK_BUF/FCLK_BUF
            //
            for (auto cell : *scells) {

                if ((cell->type == RTLIL::escape_id("DFFRE")) ||
                    (cell->type == RTLIL::escape_id("DFFNRE"))) {

                   RTLIL::SigSpec actual = cell->getPort(ID::C);

                   if (actual == clk) {

                      cell->unsetPort(ID::C);

                      cell->setPort(ID::C, newWire);
                   }

                   continue;
                }

                if ((cell->type == RTLIL::escape_id("DSP19X2")) ||
                    (cell->type == RTLIL::escape_id("DSP38"))) {

                   for (auto &conn : cell->connections()) {

                      IdString portName = conn.first;
                      RTLIL::SigSpec actual = conn.second;

                      if (portName == RTLIL::escape_id("CLK")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }

                   }
                   continue;
                }

                if (cell->type == RTLIL::escape_id("TDP_RAM18KX2")) {

                   for (auto &conn : cell->connections()) {

                      IdString portName = conn.first;
                      RTLIL::SigSpec actual = conn.second;

                      if (portName == RTLIL::escape_id("CLK_A1")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }
                      if (portName == RTLIL::escape_id("CLK_B1")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }
                      if (portName == RTLIL::escape_id("CLK_A2")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }
                      if (portName == RTLIL::escape_id("CLK_B2")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }

                   }
                   continue;
                }

                if (cell->type == RTLIL::escape_id("TDP_RAM36K")) {

                   for (auto &conn : cell->connections()) {

                      IdString portName = conn.first;
                      RTLIL::SigSpec actual = conn.second;

                      if (portName == RTLIL::escape_id("CLK_A")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }

                      if (portName == RTLIL::escape_id("CLK_B")) {

                        if (actual == clk) {

                           cell->unsetPort(portName);

                           cell->setPort(portName, newWire);
                        }
                      }

                   }
                   continue;
                }

                if ((cell->type == RTLIL::escape_id("I_DELAY")) ||
                    (cell->type == RTLIL::escape_id("O_DELAY"))) { 

                   RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("CLK_IN"));

                   if (actual == clk) {

                      cell->unsetPort(RTLIL::escape_id("CLK_IN"));

                      cell->setPort(RTLIL::escape_id("CLK_IN"), newWire);
                   }

                   continue;
                }

                if ((cell->type == RTLIL::escape_id("I_DDR")) ||
                    (cell->type == RTLIL::escape_id("O_DDR"))) { 

                   RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("C"));

                   if (actual == clk) {

                      cell->unsetPort(RTLIL::escape_id("C"));

                      cell->setPort(RTLIL::escape_id("C"), newWire);
                   }

                   continue;
                }

                if ((cell->type == RTLIL::escape_id("I_SERDES")) ||
                    (cell->type == RTLIL::escape_id("O_SERDES"))) { 

                   RTLIL::SigSpec actual = cell->getPort(RTLIL::escape_id("CLK_IN"));

                   if (actual == clk) {

                      cell->unsetPort(RTLIL::escape_id("CLK_IN"));

                      cell->setPort(RTLIL::escape_id("CLK_IN"), newWire);
                   }

                   continue;
                }


            } // for all the cells of the clock domain

       } // for all the clock domains

       if (new_iobuf_map == 2) {
         run("write_verilog -org-name -noattr -noexpr -nohex after_clk_buffers.v");
       }
    }

    // New iobuf map version
    // This works only with a flattened design and we deal with the top module
    //
    void map_iobuf() {

        if (new_iobuf_map == 2) {
           run("write_verilog -org-name -noattr -noexpr -nohex before_map_iobuf.v");
        }

        RTLIL::Module* top_module = _design->top_module();


        // Remove I_BUF and O_BUF and replace by assigns
        // This is usefull for instance when we start from a bad implementation
        // of I_BUF/O_Buf like in test case : 
        // 'Validation/RTL_testcases/RS_Primitive_example_designs/primitive_example_design_1'
        // where I_BUF is user instantiated on a PI but sometime the PI is
        // used directly in the logic instead of using the I_BUF output
        // So this allows to restart from a clean sheet.
        // WARNING; we may need to handle case where 'keep' attribute is on
        // the I_BUF/O_BUF so that we cannot remove them.
        //
#if 0
        remove_io_buffers(top_module);

        // Bypass the assigns by replacing LHs by RHS. Assigns will be
        // dangling but it is ok as they will be removed later.
        //
        run("opt_clean");
#endif

        // We need to respect the ordering of BUF insertions input buffers first,
        // then clock buffers, then output buffers then O_BUFT tristate buffers.
        //
        insert_input_buffers(top_module);

        // Map CLK_BUF and FCLK_BUF only for sequential cells
        //
        insert_clk_buffers(top_module);

        insert_output_buffers(top_module);

        map_obuft(top_module);

        // Bypass the assigns by replacing LHs by RHS
        //
        run("opt_clean");

        if (new_iobuf_map == 2) {
           run("write_verilog -org-name -noattr -noexpr -nohex after_map_iobuf.v");
        }
    }

    void register_rule(string cellName, string portName, string fabPortName, int shared, 
                       dict<RTLIL::IdString, vector<std::tuple<string, string, int>>*>& rules)
    {

        if (rules.find(RTLIL::escape_id(cellName)) == rules.end()) {
          rules[RTLIL::escape_id(cellName)] = new vector<std::tuple<string, string, int>>;
        }

        rules[RTLIL::escape_id(cellName)]->push_back(make_tuple(portName, fabPortName, shared));
    } 

    void show_all_rules(dict<RTLIL::IdString,
                                vector<std::tuple<string, string, int>>*>& all_rules)
    {

       log("\n");
       log(" ==================================================================================\n");
       log("   Primitive            Control Port               Fabric control name     Shared \n");
       log(" ==================================================================================\n");

       for (auto rule : all_rules) {

         IdString primitive = rule.first;

         vector<std::tuple<string, string, int>>* spec = rule.second;

         for (auto line : *spec) {
           log("   %-16s     %-22s     %-22s  %c \n", primitive.c_str(),
                 (std::get<0>(line)).c_str(), (std::get<1>(line)).c_str(), 
                 (std::get<2>(line) ? 'S' : '-'));
         }
       }

       log(" ==================================================================================\n");
       log("\n");
    }

    void specify_all_rules(dict<RTLIL::IdString, 
                                vector<std::tuple<string, string, int>>*>& all_rules) 
    {
       if (iofab_map == 2) {
         log("Getting the rules ...\n");
       }

       register_rule("I_BUF", "EN", "f2g_in_en_A", 0 /* not shared */, all_rules);
       register_rule("I_BUF_DS", "EN", "f2g_in_en_A", 0, all_rules);

       register_rule("O_BUFT", "T", "f2g_tx_oe_A", 0, all_rules);
       register_rule("O_BUFT_DS", "T", "f2g_tx_oe_A", 0, all_rules);

#if 0
       // SHARED version
       //
       register_rule("I_DELAY", "DLY_LOAD", "f2g_trx_dly_ld", 1 /* shared */, all_rules);
       register_rule("I_DELAY", "DLY_ADJ", "f2g_trx_dly_adj", 1, all_rules);
       register_rule("I_DELAY", "DLY_INCDEC", "f2g_trx_dly_inc", 1, all_rules);
       register_rule("I_DELAY", "DLY_TAP_VALUE", "f2g_trx_dly_tap", 1, all_rules);
#else
       // Non SHARED version
       //
       register_rule("I_DELAY", "DLY_LOAD", "f2g_trx_dly_ld", 0 /* not shared */, all_rules);
       register_rule("I_DELAY", "DLY_ADJ", "f2g_trx_dly_adj", 0, all_rules);
       register_rule("I_DELAY", "DLY_INCDEC", "f2g_trx_dly_inc", 0, all_rules);
       register_rule("I_DELAY", "DLY_TAP_VALUE", "f2g_trx_dly_tap", 0, all_rules);
#endif

       register_rule("I_DDR", "R", "f2g_trx_reset_n_A", 0, all_rules);
       register_rule("I_DDR", "E", "", 0, all_rules);

       register_rule("O_DDR", "R", "f2g_trx_reset_n_A", 0, all_rules);
       register_rule("O_DDR", "E", "", 0, all_rules);

       register_rule("I_SERDES", "RST", "f2g_trx_reset_n_A", 0, all_rules);
       register_rule("I_SERDES", "BITSLIP_ADJ", "", 0, all_rules);
       register_rule("I_SERDES", "EN", "", 0, all_rules);
       register_rule("I_SERDES", "DATA_VALID", "g2f_rx_dvalid_A", 0, all_rules);
       register_rule("I_SERDES", "DPA_LOCK", "", 0, all_rules);
       register_rule("I_SERDES", "DPA_ERROR", "", 0, all_rules);
       register_rule("I_SERDES", "PLL_LOCK", "", 0, all_rules);

       register_rule("O_SERDES", "RST", "f2g_trx_reset_n_A", 0, all_rules);
       register_rule("O_SERDES", "DATA_VALID", "f2g_trx_dvalid_A", 0, all_rules);
       register_rule("O_SERDES", "OE_IN", "", 0, all_rules);
       register_rule("O_SERDES", "OE_OUT", "", 0, all_rules);
       register_rule("O_SERDES", "CHANNEL_BOND_SYNC_IN", "", 0, all_rules);
       register_rule("O_SERDES", "CHANNEL_BOND_SYNC_OUT", "", 0, all_rules);
       register_rule("O_SERDES", "PLL_LOCK", "", 0, all_rules);

       register_rule("O_SERDES_CLK", "CLK_EN", "", 0, all_rules);
       register_rule("O_SERDES_CLK", "PLL_EN", "", 0, all_rules);

       register_rule("PLL", "PLL_EN", "", 0, all_rules);
       register_rule("PLL", "LOCK", "", 0, all_rules);

    }

    void apply_rules(RTLIL::Module* top_module,
                     RTLIL::IdString cellName, vector<RTLIL::Cell*>* cells, 
                     vector<std::tuple<string, string, int>>* rules)
    {
        vector<std::tuple<string, string, int>> NSrules;
        vector<std::tuple<string, string, int>> Srules;

        // Split the rules into the Shared rules and the non-shared ones
        //
        for (auto rule : *rules) {

           if (std::get<2>(rule) == 1) {

             Srules.push_back(rule);

           } else {

             NSrules.push_back(rule);
           }
        }

        // Process the non share port rules first
        //
        for (auto rule : NSrules) {
           string portName = std::get<0>(rule);
           string fabPortName = std::get<1>(rule);

           if (iofab_map == 2) {
             log("  o Apply NS rule on '%s', port = '%s', fabPort = '%s'\n",
                 cellName.c_str(), portName.c_str(), fabPortName.c_str());
           }

           for (auto cell : *cells) {
              insert_iofab_NS_rules(top_module, cell, portName, fabPortName);
           }
        }

        // Process the share port rules at last
        //
        for (auto rule : Srules) {
           string portName = std::get<0>(rule);
           string fabPortName = std::get<1>(rule);

           if (iofab_map == 2) {
             log("  o Apply S rule on '%s', port = '%s', fabPort = '%s'\n",
                 cellName.c_str(), portName.c_str(), fabPortName.c_str());
           }

           insert_iofab_S_rules(top_module, cells, portName, fabPortName);
        }

    }

    // Insert I_FAB/O_FAB "fake" cells to add extra port inputs/outputs to the fabric through
    // netlist editing.
    //
    // Works only for : 
    //     - flattened design
    //     - bit splitted design
    //
    void map_iofab() {

        log("\nInserting I_FAB/O_FAB cells ...\n\n");

        if (iofab_map == 2) {
           run("write_verilog -org-name -noattr -noexpr -nohex before_iofab_map.v");
        }

        RTLIL::Module* top_module = _design->top_module();

        dict<RTLIL::IdString, vector<std::tuple<string, string, int>>*> all_rules; 

        // get all the rules for O_FAB and I_FAB insertions.
        //
        specify_all_rules(all_rules); 

        if (iofab_map == 2) {
          show_all_rules(all_rules);
        }

        // group cells by their type (I_BUF, I_DDR, O_DDR, ...)
        //
        dict<RTLIL::IdString, vector<RTLIL::Cell*>*> cells_to_process;

        if (iofab_map == 2) {
           log("Getting the cells ...\n");
        }

        for (auto cell : top_module->cells()) {

           // Ignore the cell if not involved by a rule
           //
           if (!all_rules.count(cell->type)) {
              continue;
           }

           if (!cells_to_process.count(cell->type)) {
              cells_to_process[cell->type] = new vector<Cell*>;
           }

           (cells_to_process[cell->type])->push_back(cell);
            
        }

        // Process each type of cells one by one
        //
        for (auto group : cells_to_process) {

           RTLIL::IdString cellName = group.first;

           vector<RTLIL::Cell*>* cells = group.second;

           vector<std::tuple<string, string, int>>* rules = all_rules[cellName];

           if (iofab_map == 2) {
             log("\nCell type to process '%s' (Nb Cells=%ld):\n", cellName.c_str(), 
                 cells->size());
           }

           apply_rules(top_module, cellName, cells, rules);
        }

        // Dispose all obects
        //
        for (auto group : all_rules) {
          delete (group.second);
        }

        for (auto group : cells_to_process) {
          delete (group.second);
        }

        if (iofab_map == 2) {
           run("write_verilog -org-name -noattr -noexpr -nohex after_iofab_map.v");
        }

        log("\nInserting I_FAB/O_FAB cells done.\n\n");
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

            // Show the first design resources stat before
            // starting anything.
            //
            run("design -save original");
            run("flatten");
            log("\n# -------------------- \n");
            log("#  Design entry stats  \n");
            log("# -------------------- \n");
            run("stat");
            run("design -load original");
            
            // Collect ports properties
            //
            collectPortProperties();

            if (cec) {
                run("write_verilog -noattr -nohex after_proc.v");
            }
            sec_check("after_proc", true, true); 
            
            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

            if (!no_flatten) {
              run("flatten");
            }

            remove_print_cell();
            illegal_clk_connection();

            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

#if 1
            // New tri-state handling (Thierry)
            //
            if (cec) {
               run("write_verilog -noexpr -noattr -nohex before_tribuf.v");
            }
            sec_check("before_tribuf", true, true);
            
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
                sec_check("after_tribuf_merge", true, true);
                
                // specific Rapid Silicon logic with -rs_logic option
                //
                run("tribuf -rs_logic -formal"); // fix EDA-1536 : add -formal to process tristate on IOs
            }
                if (cec) {
                   run("write_verilog -noexpr -noattr -nohex after_tribuf_logic.v");
                }
                sec_check("after_tribuf_logic", true, true);
                
            
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

            collectMemProperties();

            if (cec) {
                run("write_verilog -noattr -nohex after_opt_clean1.v");
            }
            sec_check("after_opt_clean1", true, true);
            

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
            sec_check("after_fsm", true, true);
            

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
            sec_check("after_opt_clean2", true, true);
            
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
                        sec_check("after_dsp_map3", true, true);
                        
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
                        sec_check("after_dsp_map4", true, true);
                        
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
                        sec_check("after_dsp_map5", true, true);
                        

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
                        sec_check("after_dsp_map3", true, true);
                        

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
                        sec_check("after_dsp_map4", true, true);
                       

                        run("rs-pack-dsp-regs -genesis3");

                        // add register at the remaining decomposed small multiplier that are not packed in DSP cells
                        if (tech == Technologies::GENESIS_3)
                            add_out_reg();
                        run("rs_dsp_io_regs -tech genesis3");

                        if (cec) {
                            run("write_verilog -noattr -nohex after_dsp_map5.v");
                        }
                        sec_check("after_dsp_map5", true, true);
                        

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
            sec_check("after_alumacc", true, true);
            

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
            sec_check("after_opt_clean3", true,true);
            
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
                run("write_verilog -noexpr -noattr -nohex after_tech_map.v");
            }
            //sec_check("after_tech_map", false);
            sec_check("after_tech_map", true, true);
            
            
            if (!fast) {
                top_run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 12, 0);
            }

            run("opt_expr -full");

            if (cec) {
                run("write_verilog -noexpr -noattr -nohex after_opt-fast-full.v");
            }
            sec_check("after_opt-fast-full", true, true);
            
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
                sec_check("before_simplify", true, true);
                

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
                sec_check("after_simplify", true, true);
                
            }
        }

        transform(1 /* bmuxmap*/); // we can map $bmux now because
                                   // "memory" has been called

        collectPortProperties();

        if (check_label("map_luts") && effort != EffortLevel::LOW && !fast) {

            map_luts(effort, "after_map_lut_1");

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
                        sec_check("after_dfflegalize", false, false);
                        

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
                        sec_check("after_dfflegalize", false, false);
                        

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
                        sec_check("after_dfflegalize", false, false);
                        

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
                sec_check("after_techmap_ff_map", true,false);
               
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
            sec_check("after_opt_clean4", true,false);
            
            if (!fast)
                top_run_opt(1 /* nodffe */, 0 /* sat */, 1 /* force nosdff */, 1, 12, 0);
        }

        // Map left over cells like $mux (EDA-1441)
        //
        run("techmap");

        if (check_label("map_luts_2")) {
            if(fast) 
                map_luts(EffortLevel::LOW, "after_map_lut_2");
            else
                map_luts(EffortLevel::HIGH, "after_map_lut_2");
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
           

           // New iobuf mapping flow taking care of tricky situations that could not
           // be handled with the regular Yosys 'iopadmap' command especially on 'inout'
           // with tristates.
           // We can also customize the flow more easily since we have full conrol of
           // our source code. (Thierry, Rapid Silicon)
           //
           if (new_iobuf_map) {

                // Everything is there : mapping I_BUF, CLK_BUF/FCLK_BUF, O_BUF and
                // O_BUFT.
                //
                map_iobuf();

                run("read_verilog -sv -lib "+readIOArgs);

                run("techmap -map " GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_CELLs_final_map));

                if (new_iobuf_map == 2) {
                  run("write_verilog -org-name -noattr -noexpr -nohex after_techmap_io_cells_final_map.v");
                }
                
                //EDA-2629: Remove dangling wires after CLK_BUF
                //
                run("opt_clean");

                if (new_iobuf_map == 2) {
                  run("write_verilog -org-name -noattr -noexpr -nohex after_new_iobuf_map_opt_clean.v");
                }

           } else if (!new_iobuf_map && !no_iobuf){

                run("read_verilog -sv -lib "+readIOArgs);
                run("clkbufmap -buf rs__CLK_BUF O:I");
                run("techmap -map " GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_CELLs_final_map));// TECHMAP CELLS
                //EDA-2629: Remove dangling wires after CLK_BUF
                run("opt_clean");

                cec_check("before_iopadmap");

                // Fix EDA-2887 : handle tri-state where output is declared as 'inout'
                //
                run("iopadmap -bits -inpad rs__I_BUF O:I -outpad rs__O_BUF I:O -toutpad rs__O_BUFT T:I:O -tinoutpad rs__O_BUFT T:O:I -limit "+ std::to_string(max_device_ios));

                cec_check("after_iopadmap");

                check_OBUFT_Connections();

                run("techmap -map " GET_TECHMAP_FILE_PATH(GENESIS_3_DIR,IO_CELLs_final_map));// TECHMAP CELLS

                cec_check("after_iopadmap_techmap");

                run("opt_clean");

                cec_check("after_iopadmap_techmap_opt_clean");
                
                checkPortConnections();
           }

           run("stat");
#if 1
           string techMaplutArgs = GET_TECHMAP_FILE_PATH(GENESIS_3_DIR, LUT_FINAL_MAP_FILE);// LUTx Mapping
           run("techmap -map" + techMaplutArgs);
#endif

           check_blackbox_param();
          
           if (legalize_ram_clk_ports) {
             legalize_all_tdp_ram_clock_ports();
           }
        }

        run("opt_clean");

        run("stat");

        if (new_iobuf_map) {
          rewire_obuft();
        }

        // Eventually performs post synthesis clean up
        //
        if (post_cleanup){
          obs_clean();
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

        //sec_check("final_netlist", true, true);
        
        writeNetlistInfo("netlist_info.json");

        // Insert I_FAB/O_FAB "fake" cells to add extra port inputs/outputs to the fabric through
        // netlist editing.
        //
        if (iofab_map) {
          map_iofab();
        }

        run("stat");

        // Note that numbers extractions are specific to GENESIS3
        //
        int nbLUTx = getNumberOfLUTx();
        int nbREGs = getNumberOfREGs();

        log("   Number of LUTs:               %5d\n", nbLUTx);
        log("   Number of REGs:               %5d\n", nbREGs);

        reportCarryChains();

        if ((max_lut != -1) && (nbLUTx > max_lut)) {
          log("\n");
          log_error("Final netlist LUTs number [%d] exceeds '-max_lut' specified value [%d].\n", nbLUTx, max_lut);
        }

        if ((max_reg != -1) && (nbREGs > max_reg)) {
          log("\n");
          log_error("Final netlist DFFs number [%d] exceeds '-max_reg' specified value [%d].\n", nbREGs, max_reg);
        }

        sec_report();

        log("\n# -------------------- \n");
        log("# Core Synthesis done \n");
        log("# -------------------- \n");
    }

} SynthRapidSiliconPass;

PRIVATE_NAMESPACE_END
