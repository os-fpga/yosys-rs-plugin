/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */
#include "kernel/celltypes.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "kernel/yosys.h"
#include "include/abc.h"
#include <iostream>
#include <fstream>
#include <regex>

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define XSTR(val) #val
#define STR(val) XSTR(val)

#ifndef PASS_NAME
#define PASS_NAME synth_rs
#endif

#define GENESIS_DIR genesis
#define COMMON_DIR common
#define SIM_LIB_FILE cells_sim.v
#define FFS_MAP_FILE ffs_map.v
#define ARITH_MAP_FILE arith_map.v
#define ALL_ARITH_MAP_FILE all_arith_map.v
#define GET_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)

#define VERSION_MAJOR 0 // 0 - beta 
#define VERSION_MINOR 2 // 0 - initial version, 1 - dff_inference, 2 - carry_inference
#define VERSION_PATCH 42

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
    GENESIS
};
enum CarryMode {
    NO_CONST,
    ALL,
    NO
};

enum Encoding {
    BINARY,
    ONEHOT
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
        log("    -de\n");
        log("        Use Design Explorer for logic optimiztion and LUT mapping.\n");
        log("        Disabled by default.\n");
        log("\n");
#ifdef DEV_BUILD
        log("    -abc <script>\n");
        log("        Use a specific ABC script instead of the embedded one.\n");
        log("\n");
        log("    -cec\n");
        log("        Use internal equivalence checking (ABC based) during optimization.\n");
        log("        Disabled by default.\n");
        log("\n");
#endif
        log("    -carry <sub-mode>\n");
        log("        Infer Carry cells when possible.\n");
        log("        Supported values:\n");
        log("        - all      : Infer all the carries.\n");
        log("        - no_const : Infer carries only with non const inputs.\n");
        log("        - no       : Do not infer any carries.\n");
        log("        By default 'no_const' mode is used.\n");
        log("\n");
        log("    -sdffr\n");
        log("        Infer synchroneous set/reset DFFs when possible.\n");
        log("        By default synchroneous set/reset DFFs are not infered.\n");
        log("\n");
        log("    -no_dsp\n");
        log("        By default use DSP blocks in output netlist.\n");
        log("        Do not use DSP blocks to implement multipliers and associated logic\n");
        log("\n");
        log("    -no_bram\n");
        log("        By default use Block RAM in output netlist.\n");
        log("        Specifying this switch turns it off.\n");
        log("\n");
        log("    -fsm_encoding <encoding>\n");
        log("        Supported values:\n");
        log("        - binary : compact encoding using minimum of registers to cover the N states\n");
        log("                   (n registers such that 2^(n-1) < N < 2^n).\n");
        log("        - onehot : one hot encoding . N registers for N states,\n");
        log("                   each register at 1 representing one state.\n");
        log("        By default 'binary' is used, when 'goal' is area, otherwise 'onehot' is used.\n");
        log("\n");
        log("\n");
        log("The following commands are executed by this synthesis command:\n");
        help_script();
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
    CarryMode infer_carry;
    bool sdffr;

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
        nobram = false;
        nodsp = false;
        de = false;
        infer_carry = CarryMode::NO_CONST;
        sdffr = false;
    }

    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
        string run_from; 
        string run_to;
        string tech_str;
        string goal_str;
        string encoding_str;
        string effort_str;
        string carry_str;
        clear_flags();

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
#ifdef DEV_BUILD
            if (args[argidx] == "-abc" && argidx + 1 < args.size()) {
                abc_script = args[++argidx];
                continue;
            }
            if (args[argidx] == "-cec") {
                cec = true;
                continue;
            }
#endif
            if (args[argidx] == "-carry" && argidx + 1 < args.size()) {
                carry_str = args[++argidx];
                continue;
            }
            if (args[argidx] == "-sdffr") {
                sdffr = true;
                continue;
            }
            if (args[argidx] == "-no_dsp") {
                nodsp = true;
                continue;
            }
            if (args[argidx] == "-no_bram") {
                nobram = true;
                continue;
            }
            if (args[argidx] == "-de") {
                de = true;
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

        if (carry_str == "no_const")
            infer_carry = CarryMode::NO_CONST;
        else if (carry_str == "all")
            infer_carry = CarryMode::ALL;
        else if (carry_str == "no")
            infer_carry = CarryMode::NO;
        else if (carry_str != "")
            log_cmd_error("Invalid carry sub-mode specified: '%s'\n", carry_str.c_str());


        log_header(design, "Executing synth_rs pass: v%d.%d.%d\n", 
            VERSION_MAJOR, VERSION_MINOR, VERSION_PATCH);
        log_push();

        run_script(design, run_from, run_to);

        log_pop();
    }

    void map_luts(EffortLevel effort_lvl) {
        static int index = 1;
        if (abc_script != "")
            run("abc -script " + abc_script);
        else {
            std::string effortStr = "";
            std::string abcCommands = "";
            std::string scriptName = "abc_tmp_" + std::to_string(index++) + ".scr";
            string tmp_file = get_shared_tmp_dirname() + "/" + scriptName;
            std::ofstream out(tmp_file);
            if (cec)
                out << "write_eqn in.eqn;";
            switch(effort_lvl) {
                case EffortLevel::HIGH:
                {
                    if (de)
                        effortStr = "-1";
                    break;
                }
                case EffortLevel::MEDIUM:
                case EffortLevel::LOW:
                {
                    if (de)
                        effortStr = "1"; // Some initial value
                    break;
                }
            } 
            switch(goal) {
                case Strategy::AREA:
                {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "area");
                    else
                        abcCommands = abc_base6_a21;
                    break;
                }
                case Strategy::DELAY:
                {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "delay");
                    /* else
                        out << abc_base6_d1; // Delay optimized abc script. */
                    break;
                }
                case Strategy::MIXED:
                {
                    if (de)
                        abcCommands = std::regex_replace(de_template, std::regex("TARGET"), "mixed");
                    /* else
                        out << abc_base6_m1; // Delay and area mixed optimized abc script. */
                    break;
                }
            }
            if (de) {
                abcCommands = std::regex_replace(abcCommands, std::regex("DEPTH"), effortStr);
                abcCommands = std::regex_replace(abcCommands, std::regex("TMP_PATH"), get_shared_tmp_dirname());
            }
            out << abcCommands;
            if (cec)
                out << "write_eqn out.eqn; cec in.eqn out.eqn";
            out.close();
            run("abc -script " + tmp_file);
            if (remove(tmp_file.c_str()) != 0)
                log("Error deleting file: %s", tmp_file.c_str());
        }
        run("opt");
    }

    void script() override
    {
        if (check_label("begin") && tech != Technologies::GENERIC) {
            string readArgs;
            switch (tech) {
                case Technologies::GENESIS: {
                    readArgs = GET_FILE_PATH(GENESIS_DIR, SIM_LIB_FILE);
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
            run("flatten");
            run("tribuf -logic");
            run("deminout");
            run("opt_expr");
            run("opt_clean");
            run("check");
            run("opt -nodffe -nosdff");

            if (fsm_encoding == Encoding::BINARY)
                run("fsm -encoding binary");
            else
                run("fsm -encoding one-hot");

            run("opt -sat");
            run("wreduce -keepdc");
            run("peepopt");
            run("pmuxtree");
            run("opt_clean");
        }

        if (check_label("coarse")) {
            run("alumacc");
            run("opt");
            run("memory -nomap");
            run("opt_clean");
        }

        if (check_label("map_gates")) {
            switch (tech) {
                case GENESIS: {
#ifdef DEV_BUILD
                    run("stat");
#endif
                    switch (infer_carry){
                        case CarryMode::NO_CONST: {
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
                // Just to make compiler happy
                case Technologies::GENERIC: {
                    run("techmap");
                    break;
                }    
            }
            run("opt");
            run("opt -fast -full");
            run("memory_map");
            run("opt -full");
        }

        run("abc -dff");

        if (check_label("map_luts") && effort != EffortLevel::LOW)
            map_luts(effort);

        if (check_label("map_ffs")) {
            if (tech != Technologies::GENERIC) {
                string techMapArgs = " -map +/techmap.v -map";
                switch (tech) {
                    case GENESIS: {
#ifdef DEV_BUILD
                        run("stat");
#endif
                        run("shregmap -minlen 8 -maxlen 20");
                        if (sdffr){
                            run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_DFFSR_???_ 0 -cell $_DFFSRE_????_ 0 -cell $_DLATCHSR_PPP_ 0"
                                " -cell $_SDFF_???_ 0"
                               );
                        }else{  
                            run(
                                "dfflegalize -cell $_DFF_?_ 0 -cell $_DFF_???_ 0 -cell $_DFFE_????_ 0"
                                " -cell $_DFFSR_???_ 0 -cell $_DFFSRE_????_ 0 -cell $_DLATCHSR_PPP_ 0"
                               );
                        }         
#ifdef DEV_BUILD
                        run("stat");
#endif
                        techMapArgs += GET_FILE_PATH(GENESIS_DIR, FFS_MAP_FILE);
                        break;    
                    }    
                    // Just to make compiler happy
                    case Technologies::GENERIC: {
                        break;
                    }    
                }
                run("techmap " + techMapArgs);
            }
            run("opt_expr -mux_undef");
            run("simplemap");
            run("opt_expr");
            run("opt_merge");
            run("opt_dff -nodffe -nosdff");
            run("opt_clean");
            run("opt -nodffe -nosdff");
        }

        if (check_label("map_luts_2"))
            map_luts(EffortLevel::HIGH);

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
