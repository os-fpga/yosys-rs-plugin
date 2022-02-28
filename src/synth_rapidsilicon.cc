/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */
#include "kernel/celltypes.h"
#include "kernel/log.h"
#include "kernel/register.h"
#include "kernel/rtlil.h"
#include "include/abc.h"
#include <iostream>
#include <fstream>

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define XSTR(val) #val
#define STR(val) XSTR(val)

#ifndef PASS_NAME
#define PASS_NAME synth_rs
#endif

#define RS_K6N10_DIR rs_k6n10
#define COMMON_DIR common
#define SIM_LIB_FILE cells_sim.v
#define FFS_MAP_FILE ffs_map.v

#define GET_FILE_PATH(tech_dir,file) " +/rapidsilicon/" STR(tech_dir) "/" STR(file)

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
    RS_K6N10 
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
        log("        By default 'medium' level is used.\n");
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
        log("    -no_dsp\n");
        log("        By default use DSP blocks in output netlist.\n");
        log("        Do not use DSP blocks to implement multipliers and associated logic\n");
        log("\n");
        log("    -no_bram\n");
        log("        By default use Block RAM in output netlist.\n");
        log("        Specifying this switch turns it off.\n");
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
    EffortLevel effort;
    string abc_script;
    bool cec;
    bool nodsp;
    bool nobram;

    void clear_flags() override
    {
        top_opt = "-auto-top";
        tech = Technologies::GENERIC;
        blif_file = "";
        verilog_file = "";
        goal = Strategy::MIXED;
        effort = EffortLevel::MEDIUM;
        abc_script = "";
        cec = false;
        nobram = false;
        nodsp = false;
    }

    void execute(std::vector<std::string> args, RTLIL::Design *design) override
    {
        string run_from; 
        string run_to;
        string tech_str;
        string goal_str;
        string effort_str;
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
            if (args[argidx] == "-no_dsp") {
                nodsp = true;
                continue;
            }
            if (args[argidx] == "-no_bram") {
                nobram = true;
                continue;
            }

            break;
        }
        extra_args(args, argidx, design);

        if (!design->full_selection())
            log_cmd_error("This command only operates on fully selected designs!\n");

        if (tech_str == "generic")
            tech = Technologies::GENERIC;
        else if (tech_str == "rs_k6n10")
            tech = Technologies::RS_K6N10;
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

        if (effort_str == "high")
            effort = EffortLevel::HIGH;
        else if (effort_str == "medium")
            effort = EffortLevel::MEDIUM;
        else if (effort_str == "low")
            effort = EffortLevel::LOW;
        else if (effort_str != "")
            log_cmd_error("Invalid effort specified: '%s'\n", effort_str.c_str());

        log_header(design, "Executing synth_rs pass.\n");
        log_push();

        run_script(design, run_from, run_to);

        log_pop();
    }

    void script() override
    {
        if (check_label("begin") && tech != Technologies::GENERIC) {
            string readArgs;
            switch (tech) {
                case Technologies::RS_K6N10: {
                    readArgs = GET_FILE_PATH(RS_K6N10_DIR, SIM_LIB_FILE);
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
            run("opt_expr");
            run("opt_clean");
            run("check");
            run("deminout");
            run("opt -nodffe -nosdff");
            run("fsm");
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

        if (check_label("map_ffs")) {
            if (tech != Technologies::GENERIC) {
                string techMapArgs = " -map +/techmap.v -map";
                switch (tech) {
                    case RS_K6N10: {
                        run("dfflegalize -cell $_DFF_P_ 0 -cell $_DFF_PP?_ 0 -cell $_DFFE_PP?P_ 0 -cell $_DFFSR_PPP_ 0 -cell $_DFFSRE_PPPP_ 0 -cell $_DLATCHSR_PPP_ 0");
                        techMapArgs += GET_FILE_PATH(RS_K6N10_DIR, FFS_MAP_FILE);
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

        if (check_label("map_gates")) {
            run("opt -fast -full");
            run("memory_map");
            run("opt -full");
            run("techmap");
            run("opt");
        }

        if (check_label("map_luts")) {
            if (abc_script != "")
                run("abc -script " + abc_script);
            else {
                switch(goal) {
                    case Strategy::AREA:
                        {
                            string tmp_file("abc_tmp.scr");
                            std::ofstream out(tmp_file);
                            if (cec)
                                out << "write_eqn input.eqn;";
                            out << abc_base6_a21;
                            if (cec)
                                out << "write_eqn output.eqn; cec input.eqn output.eqn";
                            out.close();
                            run("abc -script " + tmp_file);
                            if (remove(tmp_file.c_str()) != 0)
                                log("Error deleting file: %s", tmp_file.c_str());
                            break;
                        }
                    case Strategy::DELAY:
                        break;
                    case Strategy::MIXED:
                        break;
                }
            }
            run("opt");
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
