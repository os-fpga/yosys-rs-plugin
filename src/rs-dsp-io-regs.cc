#include "kernel/sigtools.h"
#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#define MODE_BITS_REGISTER_INPUTS_ID 92
#define MODE_BITS_OUTPUT_SELECT_START_ID 81
#define MODE_BITS_OUTPUT_SELECT_WIDTH 3

// Bits are accessed from right to left, but in GENESIS_2 
// MODE_BITS are stored in Big Endian order, so we have to 
// use reverse of the bit indecies for the access:
// actual bit idx = 83 --> access idx = 0
#define MODE_BITS_GENESIS2_START 4
#define MODE_BITS_GENESIS2_WIDTH 80
#define MODE_BITS_GENESIS2_ACCESS_REGISTER_INPUTS_ID 0 
#define MODE_BITS_GENESIS2_ACCESS_OUTPUT_SELECT_END_ID 1
#define MODE_BITS_GENESIS2_OUTPUT_SELECT_WIDTH 3

#define MODE_BITS_GENESIS3_START 0
#define MODE_BITS_GENESIS3_WIDTH 80
#define MODE_BITS_GENESIS3_OUTPUT_SELECT_WIDTH 3
#define MODE_BITS_GENESIS3_ACCESS_REGISTER_INPUTS_ID 83
#define MODE_BITS_GENESIS3_ACCESS_OUTPUT_SELECT_START_ID 80
bool is_genesis2 = false;
bool is_genesis3 = false;

// ============================================================================

struct rsDspIORegs : public Pass {

    const std::vector<std::string> ports2del_mult = {"load_acc", "subtract", "acc_fir", "dly_b"};
    const std::vector<std::string> ports2del_mult_acc = {"acc_fir", "dly_b"};
    const std::vector<std::string> ports2del_mult_add = {"dly_b"};
    const std::vector<std::string> ports2del_extension = {"saturate_enable", "shift_right", "round"};

    /// Temporary SigBit to SigBit helper map.
    SigMap m_SigMap;

    // ..........................................

    rsDspIORegs() : Pass("rs_dsp_io_regs", "Does something") {}

    void help() override
    {
        log("\n");
        log("    rs_dsp_io_regs [options] [selection]\n");
        log("\n");
        log("Looks for RS_DSP2/RS_DSP3 cells and changes their types depending\n");
        log("on their configuration.\n");
    }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *a_Design) override
    {
        log_header(a_Design, "Executing RS_DSP_IO_REGS pass.\n");

        size_t argidx;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            if (a_Args[argidx] == "-tech" && argidx + 1 < a_Args.size()) {
                argidx++;
                if(a_Args[argidx] == "genesis2")
                    is_genesis2 = true;
                else if (a_Args[argidx] == "genesis3")
                    is_genesis3 = true;
                else
                    log_error("Wrong argument specified for tech option");
            }
        }
        extra_args(a_Args, argidx, a_Design);

        for (auto module : a_Design->selected_modules()) {
            rs_dsp_io_regs_pass(module);
        }
    }

    // Returns a pair of mask and value describing constant bit connections of
    // a SigSpec
    std::pair<uint32_t, uint32_t> get_constant_mask_value(const RTLIL::SigSpec *sigspec)
    {
        uint32_t mask = 0L;
        uint32_t value = 0L;

        auto sigbits = sigspec->bits();
        for (ssize_t i = (sigbits.size() - 1); i >= 0; --i) {
            auto other = m_SigMap(sigbits[i]);

            mask <<= 1;
            value <<= 1;

            // A known constant
            if (!other.is_wire() && other.data != RTLIL::Sx) {
                mask |= 0x1;
                value |= (other.data == RTLIL::S1);
            }
        }

        return std::make_pair(mask, value);
    }

    void rs_dsp_io_regs_pass(RTLIL::Module *module)
    {
        // Setup the SigMap
        m_SigMap.clear();
        m_SigMap.set(module);

        for (auto cell : module->cells_) {
            std::string cell_type = cell.second->type.str();
            if (cell_type == RTLIL::escape_id("RS_DSPX2") ||
                    cell_type == RTLIL::escape_id("RS_DSP2")||
                    cell_type == RTLIL::escape_id("RS_DSP3") || 
                    cell_type == RTLIL::escape_id("RS_DSP")) {
                auto dsp = cell.second;

                if (!dsp->has_attribute(RTLIL::escape_id("is_inferred")) || dsp->get_bool_attribute(RTLIL::escape_id("is_inferred")) == false) {
                    continue;
                }

                bool del_clk = true;
                bool use_dsp_cfg_params = (cell_type == RTLIL::escape_id("RS_DSP3"));

                int reg_in_i;
                int out_sel_i;

                // Get DSP configuration
                if (use_dsp_cfg_params) {
                    // Read MODE_BITS at correct indexes
                    auto mode_bits = &dsp->getParam(RTLIL::escape_id("MODE_BITS"));
                    RTLIL::Const register_inputs;
                    register_inputs = mode_bits->bits.at(MODE_BITS_REGISTER_INPUTS_ID);
                    reg_in_i = register_inputs.as_int();

                    RTLIL::Const output_select;
                    output_select = mode_bits->extract(MODE_BITS_OUTPUT_SELECT_START_ID, MODE_BITS_OUTPUT_SELECT_WIDTH);
                    out_sel_i = output_select.as_int();
                } else if (is_genesis2) {
                    // Read MODE_BITS at correct indexes
                    auto mode_bits = &dsp->getParam(RTLIL::escape_id("MODE_BITS"));
                    RTLIL::Const register_inputs;
                    register_inputs = mode_bits->bits.at(MODE_BITS_GENESIS2_ACCESS_REGISTER_INPUTS_ID);
                    reg_in_i = register_inputs.as_int();

                    RTLIL::Const output_select;
                    output_select = mode_bits->extract(MODE_BITS_GENESIS2_ACCESS_OUTPUT_SELECT_END_ID, MODE_BITS_GENESIS2_OUTPUT_SELECT_WIDTH);
                    out_sel_i = output_select.as_int();

                    RTLIL::Const new_modebits;
                    new_modebits = mode_bits->extract(MODE_BITS_GENESIS2_START, MODE_BITS_GENESIS2_WIDTH);
                    dsp->setParam(RTLIL::escape_id("MODE_BITS"), new_modebits);
                } else if (is_genesis3) {
                    // Read MODE_BITS at correct indexes
                    auto mode_bits = &dsp->getParam(RTLIL::escape_id("MODE_BITS"));
                    RTLIL::Const register_inputs;
                    register_inputs = mode_bits->bits.at(MODE_BITS_GENESIS3_ACCESS_REGISTER_INPUTS_ID);
                    reg_in_i = register_inputs.as_int();

                    RTLIL::Const output_select;
                    output_select = mode_bits->extract(MODE_BITS_GENESIS3_ACCESS_OUTPUT_SELECT_START_ID, MODE_BITS_GENESIS3_OUTPUT_SELECT_WIDTH);
                    out_sel_i = output_select.as_int();

                    RTLIL::Const new_modebits;
                    new_modebits = mode_bits->extract(MODE_BITS_GENESIS3_START, MODE_BITS_GENESIS3_WIDTH);
                    dsp->setParam(RTLIL::escape_id("MODE_BITS"), new_modebits);
                } else {
                    // Read dedicated configuration ports
                    const RTLIL::SigSpec *register_inputs;
                    register_inputs = &dsp->getPort(RTLIL::escape_id("register_inputs"));
                    if (!register_inputs)
                        log_error("register_inputs port not found!");
                    auto reg_in_c = register_inputs->as_const();
                    reg_in_i = reg_in_c.as_int();

                    const RTLIL::SigSpec *output_select;
                    output_select = &dsp->getPort(RTLIL::escape_id("output_select"));
                    if (!output_select)
                        log_error("output_select port not found!");
                    auto out_sel_c = output_select->as_const();
                    out_sel_i = out_sel_c.as_int();
                }

                // Get the feedback port
                const RTLIL::SigSpec *feedback;
                feedback = &dsp->getPort(RTLIL::escape_id("feedback"));
                if (!feedback)
                    log_error("feedback port not found!");

                // Check if feedback is or can be set to 0 which implies MACC
                auto feedback_con = get_constant_mask_value(feedback);
                bool have_macc = (feedback_con.second == 0x0);
                // log("mask=0x%08X value=0x%08X\n", consts.first, consts.second);
                // log_error("=== END HERE ===\n");

                // Build new type name
                std::string new_type = cell_type;
                new_type += "_MULT";

                if (have_macc) {
                    if (is_genesis2) {
                        switch (out_sel_i) {
                        case 4:
                        case 5:
                            del_clk = false;
                            new_type += "ACC";
                            break;
                        default:
                            break;
                        }
                    } else if (is_genesis3) {
                        switch (out_sel_i) {
                        case 1:
                        case 5:
                            del_clk = false;
                            new_type += "ACC";
                            break;
                        default:
                            break;
                        }
                    } else {
                        switch (out_sel_i) {
                        case 1:
                        case 2:
                        case 3:
                        case 5:
                        case 7:
                            del_clk = false;
                            new_type += "ACC";
                            break;
                        default:
                            break;
                        }
                    }
                } else {
                    if (is_genesis2) {
                        switch (out_sel_i) {
                        case 2:
                        case 3:
                            del_clk = false;
                            new_type += "ADD";
                            break;
                        default:
                            break;
                        }
                    } else if (is_genesis3) {
                        switch (out_sel_i) {
                        case 2:
                        case 6:
                            del_clk = false;
                            new_type += "ADD";
                            break;
                        default:
                            break;
                        }
                    } else {
                        switch (out_sel_i) {
                        case 1:
                        case 2:
                        case 3:
                        case 5:
                        case 7:
                            new_type += "ADD";
                            break;
                        default:
                            break;
                        }
                    }
                }

                if (reg_in_i) {
                    del_clk = false;
                    new_type += "_REGIN";
                }

                if (is_genesis2) {
                    switch (out_sel_i) {
                    case 1:
                    case 3:
                    case 5:
                        del_clk = false;
                        new_type += "_REGOUT";
                        break;
                    default:
                        break;
                    }
                } else {
                    if (out_sel_i > 3) {
                        del_clk = false;
                        new_type += "_REGOUT";
                    }
                }

                // Set new type name
                dsp->type = RTLIL::IdString(new_type);

                std::vector<std::string> ports2del;

                if (del_clk) {
                    ports2del.push_back("clk");
                    if (is_genesis2 || is_genesis3){
                        ports2del.push_back("lreset");
                    }

                }

                if (is_genesis2) {
                    switch (out_sel_i) {
                    case 0:
                    case 1:
                        ports2del.insert(ports2del.end(), ports2del_mult.begin(), ports2del_mult.end());
                        ports2del.insert(ports2del.end(), ports2del_extension.begin(), ports2del_extension.end());
                        break;
                    case 2:
                    case 3:
                    case 4:
                    case 5:
                        if (have_macc) {
                            ports2del.insert(ports2del.end(), ports2del_mult_acc.begin(), ports2del_mult_acc.end());
                        }
                        break;
                    }
                } else if (is_genesis3) {
                    switch (out_sel_i) {
                        case 0:
                        case 4:
                            ports2del.insert(ports2del.end(), ports2del_mult.begin(), ports2del_mult.end());
                            ports2del.insert(ports2del.end(), ports2del_extension.begin(), ports2del_extension.end());
                            break;
                        case 2:
                        case 6:
                        case 1:
                        case 5:
                            if (have_macc) {
                                ports2del.insert(ports2del.end(), ports2del_mult_acc.begin(), ports2del_mult_acc.end());
                            }
                            break;
                    }
                } else {
                    switch (out_sel_i) {
                    case 0:
                    case 4:
                    case 6:
                        ports2del.insert(ports2del.end(), ports2del_mult.begin(), ports2del_mult.end());
                        // Mark for deleton additional configuration ports
                        if (!use_dsp_cfg_params) {
                            ports2del.insert(ports2del.end(), ports2del_extension.begin(), ports2del_extension.end());
                        }
                        break;
                    case 1:
                    case 2:
                    case 3:
                    case 5:
                    case 7:
                        if (have_macc) {
                            ports2del.insert(ports2del.end(), ports2del_mult_acc.begin(), ports2del_mult_acc.end());
                        } else {
                            ports2del.insert(ports2del.end(), ports2del_mult_add.begin(), ports2del_mult_add.end());
                        }
                        break;
                    }
                }

                for (auto portname : ports2del) {
                    const RTLIL::SigSpec *port = &dsp->getPort(RTLIL::escape_id(portname));
                    if (!port)
                        log_error("%s port not found!", portname.c_str());
                    dsp->connections_.erase(RTLIL::escape_id(portname));
                }
            }
        }

        // Clear the sigmap
        m_SigMap.clear();
    }

} rsDspIORegs;

PRIVATE_NAMESPACE_END
