/*
 *  yosys -- Yosys Open SYnthesis Suite
 *
 *  Copyright (C) 2022  Marcelina Kościelnicka <mwk@0x04.net>
 *
 *  Permission to use, copy, modify, and/or distribute this software for any
 *  purpose with or without fee is hereby granted, provided that the above
 *  copyright notice and this permission notice appear in all copies.
 *
 *  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 *  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 *  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 *  ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 *  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
 *  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
 *  OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 *
 */

#include "kernel/yosys.h"
#include "kernel/modtools.h"
#include "kernel/ffinit.h"
#include "kernel/ff.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

struct RsPackDspRegsWorker
{
    int count = 0;
    RTLIL::Module *m_module;
    SigMap m_sigmap;
    FfInitVals m_initvals;

    RsPackDspRegsWorker(RTLIL::Module *module) :
        m_module(module), m_sigmap(module), m_initvals(&m_sigmap, module) {}

    void run (RTLIL::Design *design) {

        std::vector<Cell *> DSP_used_cells;
        std::vector<Cell *> DFF_used_cells;
        std::vector<Cell *> ALL_cells_of_design;
// ----- A piece of code that got all DSPs, DFF, and another cells -----
        for (auto cell : m_module->selected_cells()) {
            // Get name of DSP for checking type
            std::string cell_type_str = cell->type.str();
            if (cell_type_str == RTLIL::escape_id("RS_DSP2") || cell_type_str == RTLIL::escape_id("RS_DSP3")) {
                //adding all DSP cells of design
                DSP_used_cells.push_back(cell);
                // if cell type not DSP or DFF add as other cell
                ALL_cells_of_design.push_back(cell);
                continue;
            }
            if (RTLIL::builtin_ff_cell_types().count(cell->type)) {
                //adding all DFF cells of design
                DFF_used_cells.push_back(cell);
                continue;
            }
            // if cell type not DSP or DFF add as other cell
            ALL_cells_of_design.push_back(cell);
        }

        std::vector <RTLIL::Cell*> DSP_driven_only_by_DFF;
        RTLIL::SigSpec DFF_clk;
        RTLIL::SigSpec DFF_rst;

// ----- A piece of code that filters all DSP leaving only those with only DFF in the input  -----
        // Getting each DSP from all DSPs of our MODULE
        for (auto &it_dsp : DSP_used_cells) {
            log_debug("Working with DSP by name: %s.\n", it_dsp->name.c_str());

            // if the port of DSP driven from DFF
            bool port_a_from_dff = false;
            bool port_b_from_dff = false;
            // if we check somthing and need to ignore selected DSP
            bool ignore_dsp = false;
            // if we check somthing and need to ignore selected DFF
            bool next_dff = false;
            // Get RESET and CLK SigSpec to compare with another DFF RESET and CLK SigSpecs which drive DSP signals
            bool for_first_dff = true;
            // get it_dsp SigSpec of ports "\a" and "\b"
            RTLIL::SigSpec DSP_port_a = it_dsp->getPort(RTLIL::escape_id("\\a"));
            RTLIL::SigSpec DSP_port_b = it_dsp->getPort(RTLIL::escape_id("\\b"));

            // Getting each cell of DESIGN to check if there is connection between
            for (auto &it_cell : ALL_cells_of_design) {
                next_dff = false;
                // skip if cell is the same DSP
                if (it_cell->name == it_dsp->name)
                    continue;
                // Getting all connections of each cell
                for (auto &conn_cell : it_cell->connections_) {
                    // Checking if one of the Ports of DSP is driven from other cell
                    for (auto bit_cell : m_sigmap(conn_cell.second)) {
                        for (auto bit_dsp : m_sigmap(DSP_port_a)) {
                            if (bit_cell == bit_dsp) {
                                log_debug("There is a connection between DSP port ( \\a ) and Cell port ( %s )\n", conn_cell.first.c_str());
                                ignore_dsp = true;
                                // exit DSP bits loop
                                break;
                            }
                        }
                        // exit cell bits loop
                        if (ignore_dsp)
                            break;
                        for (auto bit_dsp : m_sigmap(DSP_port_b)) {
                            if (bit_cell == bit_dsp) {
                                log_debug("There is a connection between DSP port ( \\b ) and Cell port ( %s )\n", conn_cell.first.c_str());
                                ignore_dsp = true;
                                // exit DSP bits loop
                                break;
                            }
                        }
                        // exit cell bits loop
                        if (ignore_dsp)
                            break;
                    }
                    // exit cell connections loop
                    if (ignore_dsp)
                        break;
                }
                // exit cells loop
                if (ignore_dsp)
                    break;
            }
            // pick next DSP
            if (ignore_dsp)
                continue;

            // Getting each DFF from all DFFs of our MODULE
            for (auto &it_dff : DFF_used_cells) {
                log_debug("Working with DFF by name: %s.\n", it_dff->name.c_str());
                FfData ff(&m_initvals, it_dff);
                // Getting all connections of each dff

                // Lambda function for action when having connection between DSP and DFF
                auto check_dff = [&DFF_rst, &DFF_clk, &for_first_dff, &ff, &ignore_dsp, &next_dff, this](bool &port_from_dff, char working_port) {
                    log_debug("There is a connection between DSP port ( \\%c ) and DFF port ( q )\n", working_port);
                    if (ff.has_ce || ff.has_sr || ff.has_aload) {
                        ignore_dsp = true;
                        return;
                    }
                    if (for_first_dff) {
                        // Getting selected DFF RESET and CLOCK SigSepc
                        DFF_rst = ff.sig_arst;
                        DFF_clk = ff.sig_clk;
                        // if DSP port is driven from DFF make it true
                        port_from_dff = true;
                        // first time desable
                        for_first_dff = false;
                        // pick next dff
                        next_dff = true;
                    } else {
                        if (ff.sig_arst == m_sigmap(DFF_rst) && ff.sig_clk == m_sigmap(DFF_clk)) {
                            port_from_dff = true;
                            next_dff = true;
                        } else {
                            ignore_dsp = true;
                        }
                    }
                };

                // getting all bits of selected DFF port ( q )
                for (auto bit_dff : m_sigmap(ff.sig_q)) {
                    // getting all bits of DSP port ( a )
                    for (auto bit_dsp : m_sigmap(DSP_port_a)) {
                        // comparing if DFF port bit is the same as DSP port bit
                        if (bit_dff == bit_dsp) {
                            // calling lambda function for port ( a )
                            check_dff(port_a_from_dff, 'a');
                            // we cancel the comparison of the remaining bits because it is already clear that the DSP port receives a signal from the DFF
                            break;
                        }
                    }
                    if (ignore_dsp)
                        break;
                    // getting all bits of DSP port ( b )
                    for (auto bit_dsp : m_sigmap(DSP_port_b)) {
                        // comparing if DFF port bit is the same as DSP port bit
                        if (bit_dff == bit_dsp) {
                            // calling lambda function for port ( a )
                            check_dff(port_b_from_dff, 'b');
                            // we cancel the comparison of the remaining bits because it is already clear that the DSP port receives a signal from the DFF
                            break;
                        }
                    }
                    if (next_dff || ignore_dsp) {break;}
                }
                if (ignore_dsp)
                    break;
                if (next_dff)
                    continue;
            }
            if (ignore_dsp)
                continue;

            // if DSP data ports is driven from DFFs add that DSP to vector
            if (port_a_from_dff && port_b_from_dff && !ignore_dsp) {
                DSP_driven_only_by_DFF.push_back(it_dsp);
            }
        }

// ----- A piece of code that works with DSP connections  -----
        // Getting all DSP that are confirmed for treatment
        for (auto &DSP_driven_DFF : DSP_driven_only_by_DFF) {
            // creating new SigSpecs with which we will change the SigSpecs of DSP ports A and B
            RTLIL::SigSpec new_sigspec_for_a;
            RTLIL::SigSpec new_sigspec_for_b;

            // get selected DSP SigSpec of ports "\a" and "\b"
            RTLIL::SigSpec DSP_port_a = DSP_driven_DFF->getPort(RTLIL::escape_id("\\a"));
            RTLIL::SigSpec DSP_port_b = DSP_driven_DFF->getPort(RTLIL::escape_id("\\b"));

            for (auto &it_dff : DFF_used_cells) {
                FfData ff(&m_initvals, it_dff);

                SigBit ankap_bit;

                // will be used as DFF-DSP sig_bit_index for new SigSpec;
                int sig_bit_index_a = 0;
                int sig_bit_index_b = 0;

                    // Getting all bits of dsp port (a)
                    for (auto bit_dsp : m_sigmap(DSP_port_a)) {
                        // Getting all bits of selected DFF port (q) to find wich bit is connected with DSP port (a)
                        for (auto bit_dff : m_sigmap(ff.sig_q)) {
                            // we compare to make sure that a given bit in DSP is actually a bit for DFF
                            if (bit_dff == bit_dsp) {
                                // adding that taken bit to a new SigSpec
                                new_sigspec_for_a.append(ff.sig_d[sig_bit_index_a]);
                                // adding DFF-DSP index for next bit
                                sig_bit_index_a++;
                            }
                        }
                    }

                    // Getting all bits of dsp port (a)
                    for (auto bit_dsp : m_sigmap(DSP_port_b)) {
                        // Getting all bits of selected DFF port (q) to find wich bit is connected with DSP port (a)
                        for (auto bit_dff : m_sigmap(ff.sig_q)) {
                            // we compare to make sure that a given bit in DSP is actually a bit for DFF
                            if (bit_dff == bit_dsp) {
                                // adding that taken bit to a new SigSpec
                                new_sigspec_for_b.append(ff.sig_d[sig_bit_index_b]);
                                // adding DFF-DSP index for next bit
                                sig_bit_index_b++;
                            }
                        }
                    }

            // After all DFFs will be changed DSP port ( a ) and ( b )
            if (&it_dff == &DFF_used_cells.back()) {
                DSP_driven_DFF->setPort("\\a", new_sigspec_for_a);
                DSP_driven_DFF->setPort("\\b", new_sigspec_for_b);
            }

            // Getting DSP Reginster inputs port to change value 1
            if (DSP_driven_DFF->type.c_str() == RTLIL::escape_id("RS_DSP2"))
                DSP_driven_DFF->setPort(RTLIL::escape_id("register_inputs"), RTLIL::S1);
            if (DSP_driven_DFF->type.c_str() == RTLIL::escape_id("RS_DSP3"))
                DSP_driven_DFF->setParam(RTLIL::escape_id("register_inputs"), RTLIL::S1);

            // Getting DSP clock port to connect it with DFF clock port
                DSP_driven_DFF->setPort(RTLIL::escape_id("\\clk"), DFF_clk);
            // Getting DSP reset port to connect it with DFF reset port
                DSP_driven_DFF->setPort(RTLIL::escape_id("\\reset"), DFF_rst);
            }
        }
    }
};

struct RsPackDspRegsPass : public Pass {
    RsPackDspRegsPass() : Pass("rs_pack_dsp_regs", "pack DSP input registers") { }
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    Rs_pack_dsp_regs [selection]\n");
        log("\n");
        log("This pass packs DSP input registers inside DSP component\n");
        log("\n");
    }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *design) override
    {
        log_header(design, "Executing rs_pack_dsp_regs pass.\n");

        extra_args(a_Args, 1, design);

        for (auto mod : design->selected_modules()) {
			RsPackDspRegsWorker worker(mod);
			worker.run(design);
		}
    }
} RsPackDspRegsPass;

PRIVATE_NAMESPACE_END