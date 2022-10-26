/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */
#include "kernel/celltypes.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/yosys.h"
#include "kernel/mem.h"
#include "include/abc.h"
#include <iostream>
#include <fstream>
#include <regex>

#ifdef PRODUCTION_BUILD
#include "License_manager.hpp"
#endif

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define XSTR(val) #val
#define STR(val) XSTR(val)

#ifndef PASS_NAME
#define PASS_NAME synth_rs
#endif

#define GENESIS_DIR genesis
#define GENESIS_2_DIR genesis2
#define COMMON_DIR common
#define SIM_LIB_FILE cells_sim.v
#define DSP_SIM_LIB_FILE dsp_sim.v
#define FFS_MAP_FILE ffs_map.v
#define ARITH_MAP_FILE arith_map.v
#define DSP_MAP_FILE dsp_map.v
#define DSP_FINAL_MAP_FILE dsp_final_map.v
#define ALL_ARITH_MAP_FILE all_arith_map.v
#define BRAM_TXT brams.txt
#define BRAM_ASYNC_TXT brams_async.txt
#define BRAM_MAP_FILE brams_map.v
#define BRAM_FINAL_MAP_FILE brams_final_map.v
#define GET_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)

#define VERSION_MAJOR 0 // 0 - beta 
// 0 - initial version 
// 1 - dff inference 
// 2 - carry inference
// 3 - dsp inference
// 4 - bram inference
#define VERSION_MINOR 4
#define VERSION_PATCH 82

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
    GENESIS_2
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
        log("    -carry <sub-mode>\n");
        log("        Infer Carry cells when possible.\n");
        log("        Supported values:\n");
        log("        - all      : Infer all the carries.\n");
        log("        - auto     : Infer carries based on internal heuristics.\n");
        log("        - no       : Do not infer any carries.\n");
        log("        By default 'auto' mode is used.\n");
        log("\n");
#ifdef DEV_BUILD
        log("    -sdffr\n");
        log("        Infer synchroneous set/reset DFFs when possible.\n");
        log("        By default synchroneous set/reset DFFs are not infered.\n");
        log("\n");
#endif
        log("    -no_dsp\n");
        log("        By default use DSP blocks in output netlist.\n");
        log("        Do not use DSP blocks to implement multipliers and associated logic\n");
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
        log("    -no_simplify\n");
        log("        By default call simplify.\n");
        log("        Specifying this switch turns it off.\n");
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
    Strategy goal;
    Encoding fsm_encoding;
    EffortLevel effort;
    string abc_script;
    bool cec;
    bool nodsp;
    bool nobram;
    bool de;
    bool fast;
    CarryMode infer_carry;
    bool sdffr;
    bool nosimplify;
    bool keep_tribuf;
    int de_max_threads;
    RTLIL::Design *_design;
    string nosdff_str;
    ClockEnableStrategy clke_strategy;
    string use_dsp_cfg_params;

    void clear_flags() override
    {
        top_opt = "-auto-top";
        tech = Technologies::GENERIC;
        blif_file = "";
        verilog_file = "";
        goal = Strategy::MIXED;
        fsm_encoding = Encoding::BINARY;
        effort = EffortLevel::HIGH;
        abc_script = "";
        cec = false;
        fast = false;
        nobram = false;
        nodsp = false;
        nosimplify = false;
        keep_tribuf = false;
        de = false;
        de_max_threads = -1;
        infer_carry = CarryMode::AUTO;
        sdffr = false;
        nosdff_str = " -nosdff";
        clke_strategy = ClockEnableStrategy::EARLY;
        use_dsp_cfg_params = "";
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
        clear_flags();

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
            if (args[argidx] == "-goal" && argidx + 1 < args.size()) {
                goal_str = args[++argidx];
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
            if (args[argidx] == "-de") {
                de = true;
                continue;
            }
            if (args[argidx] == "-no_simplify") {
                nosimplify = true;
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

            break;
        }
        extra_args(args, argidx, design);

        if (!design->full_selection())
            log_cmd_error("This command only operates on fully selected designs!\n");

        if (tech_str == "generic")
            tech = Technologies::GENERIC;
        else if (tech_str == "genesis")
            tech = Technologies::GENESIS;
        else if (tech_str == "genesis2")
            tech = Technologies::GENESIS_2;
        else if (tech_str != "")
            log_cmd_error("Invalid tech specified: '%s'\n", tech_str.c_str());

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

    void step(string msg)
    {
        log("STEP : %s\n", msg.c_str());
        getchar();
    }

    int getNumberOfInstances() {
        return (_design->top_module()->cells_.size());
    }

    void run_opt(int nodffe, int sat, int nosdff, int share, int max_iter) {

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
               run("opt_dff -nosdff " + nodffe_str + sat_str);
            } else {
               run("opt_dff " + nosdff_str + nodffe_str + sat_str);
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

            if ((nbInstAfter >= 80000) && (iteration >= 4)) {
                break;
            }

        }

        _design->optimize();
        _design->sort();
        _design->check();

        log("MAX OPT ITERATION = %d\n", iteration);
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
            std::string in_eqn_file = "in_" + std::to_string(index) + ".eqn";
            std::string out_eqn_file = "out_" + std::to_string(index) + ".eqn";

            if (cec)
                out << "write_eqn " + in_eqn_file + ";";

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
                out << "write_eqn " + out_eqn_file + ";";
		// cec command is not called, so as not to impact on runtime.
	        // out << "cec " + in_eqn_file + " " + out_eqn_file;
            }
            out.close();

            run("abc -script " + tmp_file);
            if (remove(tmp_file.c_str()) != 0)
                log("Error deleting file: %s", tmp_file.c_str());
        }

        if (!fast)
            run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 4);

        if (cec)
            run("write_verilog -noattr -nohex after_lut_map" + std::to_string(index) + ".v");

        index++;
    }

    // Perform a small loop of successive "abc -dff" calls.  
    // This "simplify" pass may have some big QoR impact on this list of designs:
    // 	- wrapper_io_reg_max 
    // 	- wrapper_io_reg_tc1 
    // 	- wrapper_multi_enc_decx2x4
    // 	- keymgr 
    // 	- kmac 
    // 	- alu4 
    // 	- s38417
    //
    void simplify() 
    {
        // Do not extract DFFE before simplify : it may have been done earlier
        //
        run_opt(1 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 0, 10);

        for (int n=1; n <= 4; n++) { // perform 4 calls as a good trade-off QoR / runtime

            run("abc -dff");   // WARNING: "abc -dff" is very time consuming !!!

            if (cec)
                run("write_verilog -noattr -nohex after_abc-dff" + std::to_string(n) + ".v");
        }
        run("opt_ffinv");

        run_opt(0 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 4);
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
        const std::vector<DspParams> dsp_rules_loop1 = {
            {10, 9, 4, 4, "$__RS_MUL10X9"},
            {20, 18, 11, 10, "$__RS_MUL20X18"},
        };
        for (const auto &rule : dsp_rules_loop1) {
            run(stringf("techmap -map +/mul2dsp_check_maxwidth.v "
                        " -D DSP_A_MAXWIDTH=%zu -D DSP_B_MAXWIDTH=%zu "
                        "-D DSP_A_MINWIDTH=%zu -D DSP_B_MINWIDTH=%zu "
                        "-D DSP_NAME=%s",
                        rule.a_maxwidth, rule.b_maxwidth, rule.a_minwidth, rule.b_minwidth, rule.type.c_str()));
            run("stat");

            if (cec)
                run("write_verilog -noattr -nohex after_dsp_map1_" + std::to_string(rule.a_maxwidth) + ".v");

            run("chtype -set $mul t:$__soft_mul");
        }

        /* 
            In loop2, We start from technology mapping of RTL operator that can be mapped to RS_DSP2.* on biggest DSP to smallest one. 
            The idea is that if a RTL operator that does not fully satisfies the "dsp_rules_loop1", it will be mapped on DSP in 2nd loop.
        */
        const std::vector<DspParams> dsp_rules_loop2 = {
            {20, 18, 11, 10, "$__RS_MUL20X18"},
            {10, 9, 4, 4, "$__RS_MUL10X9"},
        };
        for (const auto &rule : dsp_rules_loop2) {
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

    void mapBrams() {
        switch (tech) {
            case Technologies::GENESIS: {
                run("rs_bram_asymmetric");
                run("memory_bram -rules" GET_FILE_PATH(GENESIS_DIR, BRAM_TXT));
                if (areMemCellsLeft()) {
                    run("memory_bram -rules" GET_FILE_PATH(GENESIS_DIR, BRAM_ASYNC_TXT));
                }
                run("rs_bram_split");
                run("techmap -autoproc -map" GET_FILE_PATH(GENESIS_DIR, BRAM_MAP_FILE));
                run("techmap -map" GET_FILE_PATH(GENESIS_DIR, BRAM_FINAL_MAP_FILE));

                if (cec)
                    run("write_verilog -noattr -nohex after_bram_map.v");
                break;
            }
            case GENESIS_2: {
                // TODO: Add BRAM inference.
                log_warning("BRAM inference is not yet implemented for Genesis_2 technology.");
                break;
            }
            case GENERIC: {
                break;
            }
        }
    }

    void postProcessBrams() {
        if (areMemCellsLeft()) {
            if (nobram) {
                log("\n"); // Skip line to make the warning more focused.
                log_warning("Forcing to use BRAMs.\n");
                mapBrams();
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

    void script() override
    {
        if (check_label("begin") && tech != Technologies::GENERIC) {
            string readArgs;
            switch (tech) {
                case Technologies::GENESIS: {
                    readArgs = GET_FILE_PATH(GENESIS_DIR, SIM_LIB_FILE) GET_FILE_PATH(GENESIS_DIR, DSP_SIM_LIB_FILE);
                    break;
                }    
                case Technologies::GENESIS_2: {
                    readArgs = GET_FILE_PATH(GENESIS_2_DIR, SIM_LIB_FILE);
                    //readArgs = GET_FILE_PATH(GENESIS_2_DIR, SIM_LIB_FILE) GET_FILE_PATH(GENESIS_2_DIR, DSP_SIM_LIB_FILE);
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

            if (cec)
                run("write_verilog -noattr -nohex after_proc.v");

            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

            run("flatten");

            transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

            if (keep_tribuf)
                run("tribuf -logic");
            else
                run("tribuf -logic -formal");

            run("deminout");
            run("opt_expr");
            run("opt_clean");

            if (cec)
                run("write_verilog -noattr -nohex after_opt_clean1.v");

            run("check");
            run_opt(1 /* nodffe  */, 0 /* sat */, 1 /* force nosdff */, 1, 4);

            if (fsm_encoding == Encoding::BINARY)
                run("fsm -encoding binary");
            else
                run("fsm -encoding one-hot");

            if (cec)
                run("write_verilog -noattr -nohex after_fsm.v");

            if (fast)
                run("opt -fast");
            else if (clke_strategy == ClockEnableStrategy::EARLY) {
                run_opt(0 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 4);
            } else {
                run_opt(1 /* nodffe */, 1 /* sat */, 0 /* force nosdff */, 1, 4);
            }

            run("wreduce -keepdc");
            run("peepopt");
            run("opt_clean");

            if (cec)
                run("write_verilog -noattr -nohex after_opt_clean2.v");
        }

        transform(nobram /* bmuxmap */); // no "$bmux" mapping in bram state

        if (check_label("coarse")) {
            if(!nodsp){
                switch (tech) {
                    case GENESIS: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        run("wreduce t:$mul");
                        run("rs_dsp_macc" + use_dsp_cfg_params);
                        processDsp(cec);
                        

                        if (use_dsp_cfg_params.empty())
                            run("techmap -map " GET_FILE_PATH(GENESIS_DIR, DSP_MAP_FILE) 
                                    " -D USE_DSP_CFG_PARAMS=0");
                        else
                            run("techmap -map " GET_FILE_PATH(GENESIS_DIR, DSP_MAP_FILE) 
                                    " -D USE_DSP_CFG_PARAMS=1");
                            
                        if (cec)
                            run("write_verilog -noattr -nohex after_dsp_map3.v");

                        run("rs_dsp_simd");
                        run("techmap -map " GET_FILE_PATH(GENESIS_DIR, DSP_FINAL_MAP_FILE));

                        if (cec)
                            run("write_verilog -noattr -nohex after_dsp_map4.v");
                        run("opt_clean");
                        run("rs_pack_dsp_regs");
                        run("opt_clean");
                        
                        run("rs_dsp_io_regs");

                        if (cec)
                            run("write_verilog -noattr -nohex after_dsp_map5.v");

                        break;
                    }
                    case GENESIS_2: {
                        // TODO: Add DSP inference
                        log_warning("DSP inference is not yet implemented for Genesis_2 technology.");
                        break;
                    }
                    case GENERIC: {
                        break;
                    }
                }
            }

            run("alumacc");

            if (cec)
                run("write_verilog -noattr -nohex after_alumacc.v");

            if (!fast) {
                run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 4);
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

            if (cec)
                run("write_verilog -noattr -nohex after_opt_clean3.v");
        }

        if (!nobram){
            mapBrams();
        }

        run("pmuxtree");

        run("muxpack");

        run("memory_map");

        postProcessBrams();

        if (check_label("map_gates")) {
            switch (tech) {
                case GENESIS: {
#ifdef DEV_BUILD
                    run("stat");
#endif
                    switch (infer_carry) {
                        case CarryMode::AUTO: {
                            run("techmap -map +/techmap.v -map" GET_FILE_PATH(GENESIS_DIR, ARITH_MAP_FILE));
                            break;
                        }
                        case CarryMode::ALL: {
                            run("techmap -map +/techmap.v -map" GET_FILE_PATH(GENESIS_DIR, ALL_ARITH_MAP_FILE));
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
                case GENESIS_2: {
                    // TODO: Add Carry inference
                    log_warning("Carry inference is not yet implemented for Genesis_2 technology.");
                    run("techmap");
                    break;
                }    
                // Just to make compiler happy
                case Technologies::GENERIC: {
                    run("techmap");
                    break;
                }    
            }

            if (cec)
                run("write_verilog -noattr -nohex after_carry_map.v");

            if (!fast) {
                run_opt(1 /* nodffe */, 0 /* sat */, 0 /* force nosdff */, 1, 4);

                run("opt_expr -full");
            }

            if (cec)
                run("write_verilog -noattr -nohex after_opt-fast-full.v");
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
            // 	- wrapper_io_reg_max 
            // 	- wrapper_io_reg_tc1 
            // 	- wrapper_multi_enc_decx2x4
            // 	- keymgr 
            // 	- kmac 
            // 	- alu4 
            // 	- s38417
            //
            if (!nosimplify) {
                if (cec)
                    run("write_verilog -noattr -nohex before_simplify.v");

                simplify();

                if (cec)
                    run("write_verilog -noattr -nohex after_simplify.v");
            }
        }

        transform(1 /* bmuxmap*/); // we can map $bmux now because
                                   // "memory" has been called

        if (check_label("map_luts") && effort != EffortLevel::LOW && !fast) {

            map_luts(effort);

            if (!nosimplify)
                run("opt_ffinv"); // help for "trial1" to gain further luts
        }
        
        if (check_label("map_ffs")) {
            if (tech != Technologies::GENERIC) {

                string techMapArgs = " -map +/techmap.v -map";
                switch (tech) {
                    case GENESIS: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        run("shregmap -minlen 8 -maxlen 20");
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

                        if (cec)
                            run("write_verilog -noattr -nohex after_dfflegalize.v");

#ifdef DEV_BUILD
                        run("stat");
#endif
                        techMapArgs += GET_FILE_PATH(GENESIS_DIR, FFS_MAP_FILE);
                        break;    
                    }    
                    case GENESIS_2: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        // TODO: run("shregmap -minlen 8 -maxlen 20");
                        run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFFE_??_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_SDFF_???_ 0 -cell $_SDFFE_????_ 0"
                                " -cell $_DLATCH_?_ 0 -cell $_DLATCH_???_ 0"
                           );

                        if (cec)
                            run("write_verilog -noattr -nohex after_dfflegalize.v");

#ifdef DEV_BUILD
                        run("stat");
#endif
                        techMapArgs += GET_FILE_PATH(GENESIS_2_DIR, FFS_MAP_FILE);
                        break;
                    }
                    // Just to make compiler happy
                    case Technologies::GENERIC: {
                        break;
                    }    
                }
                run("techmap " + techMapArgs);

                if (cec)
                    run("write_verilog -noattr -nohex after_techmap_ff_map.v");
            }
            run("opt_expr -mux_undef");
            run("simplemap");
            run("opt_expr");
            run("opt_merge");
            run("opt_dff -nodffe -nosdff");
            run("opt_clean");
            

            if (cec)
                run("write_verilog -noattr -nohex after_opt_clean4.v");

            if (!fast)
                run_opt(1 /* nodffe */, 0 /* sat */, 1 /* force nosdff */, 1, 4);
        }

        if (check_label("map_luts_2")) {
            if(fast) 
                map_luts(EffortLevel::LOW);
            else
                map_luts(EffortLevel::HIGH);
        }

        if (check_label("check")) {
            run("hierarchy -check");
            run("stat");
        }

        if (check_label("finalize")) {
            run("opt_clean -purge");
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
    }

} SynthRapidSiliconPass;

PRIVATE_NAMESPACE_END
