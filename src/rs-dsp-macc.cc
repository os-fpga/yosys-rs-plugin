/*
 *  Copyright (C) 2022 RapidSilicon
 *
 */
#include "kernel/sigtools.h"
#include "kernel/yosys.h"
#include "kernel/modtools.h"
#include "kernel/ffinit.h"
#include "kernel/ff.h"

extern int DSP_COUNTER;
USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

#include "../pmgen/rs-dsp-macc.h"

// ============================================================================
bool use_dsp_cfg_params;
bool is_genesis2;
bool is_genesis3;
int max_dsp;

struct RsDspMaccWorker
{
    RTLIL::Module *m_module;
    SigMap m_sigmap;
    FfInitVals m_initvals;
    RsDspMaccWorker(RTLIL::Module *module) :
        m_module(module), m_sigmap(module), m_initvals(&m_sigmap, module) {}

    bool run_opt_clean = false;

    void run_scr (bool gen, bool gen3,RTLIL::Design *design) {
        SigMap sigmap(design->top_module());
        // $shl->InputA<<InputB (WIDTH <= 6) and ((MultInput * coefficient) || (MultInput * acc[19:0]) + $shl) could be the candidate for multadd cell
        std::vector<Cell *> mul_cells;
        std::vector<Cell *> neg_cells;
        std::vector<Cell *> add_cells_;
        std::vector<Cell *> mux_cells_;
        std::vector<Cell *> dff_cells_;
        RTLIL::Cell *neg;
        RTLIL::Cell *mul;
        RTLIL::Cell *add;
        RTLIL::Cell *ff;
        RTLIL::Cell *mux;

        bool add_mul = false;
        bool add_regout = false;
        bool neg_mul = false;
        bool mux_valid = false;
        bool muxA_valid = false;
        bool muxB_valid = false;
        bool muxY_valid = false;
        for (auto &cell : m_module->selected_cells()) {
            if(cell->type == RTLIL::escape_id("$mul")){
                mul_cells.push_back(cell);
                continue;
            }
            if(cell->type == RTLIL::escape_id("$neg")){
                neg_cells.push_back(cell);
                continue;
            }
            if(cell->type == RTLIL::escape_id("$add")){
                add_cells_.push_back(cell);
                continue;
            }

            if(cell->type == RTLIL::escape_id("$sub")){
                add_cells_.push_back(cell);
                continue;
            }
            if(cell->type == RTLIL::escape_id("$mux")){
                mux_cells_.push_back(cell);
                continue;
            }
            if (RTLIL::builtin_ff_cell_types().count(cell->type)) {
                    //adding all DFF cells of design
                    dff_cells_.push_back(cell);
                    continue;
            }
        }
        for (auto &add_cell : add_cells_) {
            add = add_cell;
            add_mul = false;
            add_regout = false;
            mux_valid = false;
            muxA_valid = false;
            muxB_valid = false;
            muxY_valid = false;
            // shiftl_PB_Reg = false;
            for (auto dff_ : dff_cells_){
                if (((add_cell->getPort(ID::A) == dff_->getPort(ID::Q))||(add_cell->getPort(ID::B) == dff_->getPort(ID::Q))) && add_cell->getPort(ID::Y) == dff_->getPort(ID::D)){
                    add_regout = true;
                    ff = dff_;
                    break;
                }
                else if ((add_cell->getPort(ID::A) == dff_->getPort(ID::Q))|| add_cell->getPort(ID::B) == dff_->getPort(ID::Q)){
                    for (auto &mux_cell : mux_cells_) {
                        if ((mux_cell->getPort(ID::Y) == dff_->getPort(ID::D) && (mux_cell->getPort(ID::A) == add_cell->getPort(ID::Y) || mux_cell->getPort(ID::B) == add_cell->getPort(ID::Y)))){
                            ff = dff_;
                            add_regout = true;
                            muxY_valid = true;
                            mux = mux_cell;
                            for (auto &mul_cell : mul_cells) {
                                if (mux_cell->getPort(ID::A) == mul_cell->getPort(ID::Y) || mux_cell->getPort(ID::B) == mul_cell->getPort(ID::Y)){
                                    muxA_valid = true;
                                    mul = mul_cell;
                                    break;
                                }
                            }
                            if (muxY_valid && muxA_valid) {
                                mux_valid = true;
                                break;
                            }
                        }
                    }
                }
            }

            if (add_regout && !mux_valid){
                for (auto &mux_cell : mux_cells_) {
                    if ((mux_cell->getPort(ID::Y) == add_cell->getPort(ID::A))||(mux_cell->getPort(ID::Y) == add_cell->getPort(ID::B))){
                        muxY_valid = true;
                        mux = mux_cell;
                        for (auto &mul_cell : mul_cells) {
                            if (mux_cell->getPort(ID::A) == mul_cell->getPort(ID::Y) || mux_cell->getPort(ID::B) == mul_cell->getPort(ID::Y)){
                                muxA_valid = true;
                                mul = mul_cell;
                                break;
                            }
                        }
                        for (auto &neg_cell : neg_cells) {
                            if (mux_cell->getPort(ID::A) == neg_cell->getPort(ID::Y) || mux_cell->getPort(ID::B) == neg_cell->getPort(ID::Y)){
                                muxB_valid = true;
                                neg = neg_cell;
                                break;
                            }
                        }
                        if (muxY_valid && muxA_valid && muxB_valid) {
                            mux_valid = true;
                            break;
                        }
                    }
                }
                if (!mux_valid) {
                        for (auto &mul_cell : mul_cells) {
                        neg_mul = false;
                        for (auto &neg_cell : neg_cells) {
                            if (mul_cell->getPort(ID::Y) == neg_cell->getPort(ID::A)){
                                neg = neg_cell;
                                mul = mul_cell;
                                if ((add_cell->getPort(ID::A) == neg_cell->getPort(ID::Y))||(add_cell->getPort(ID::B) == neg_cell->getPort(ID::Y))) {
                                    neg_mul = true;
                                    break;
                                }
                            }
                            
                        }
                        if (((add_cell->getPort(ID::A) == mul_cell->getPort(ID::Y))||(add_cell->getPort(ID::B) == mul_cell->getPort(ID::Y))) && !neg_mul){
                            add_mul = true;
                            mul = mul_cell;
                        }
                    }
                }
            }
            
            if (!(mux_valid || neg_mul || add_mul)){
                continue;
            }
            // Accept only posedge clocked FFs
            FfData _ff_(&m_initvals, ff);
            if (ff->getParam(ID(CLK_POLARITY)).as_int() != 1) {
                return;
            }
            if (max_dsp != -1 && DSP_COUNTER > max_dsp) {
                return;
            }
            ++DSP_COUNTER;
            // Get port widths
            size_t a_width = GetSize(mul->getPort(ID(A)));
            size_t b_width = GetSize(mul->getPort(ID(B)));
            size_t z_width = GetSize(ff->getPort(ID(Q)));

            size_t min_width = std::min(a_width, b_width);
            size_t max_width = std::max(a_width, b_width);

            // Signed / unsigned
            bool a_signed = mul->getParam(ID(A_SIGNED)).as_bool();
            bool b_signed = mul->getParam(ID(B_SIGNED)).as_bool();

            // Determine DSP type or discard if too narrow / wide
            RTLIL::IdString type;
            size_t tgt_a_width;
            size_t tgt_b_width;
            size_t tgt_z_width;

            string cell_base_name = "dsp_t1";
            string cell_size_name = "";
            string cell_cfg_name = "";
            string cell_full_name = "";

            if (min_width <= 2 && max_width <= 2 && z_width <= 4) {
                // Too narrow
                return;
            } else if (min_width <= 9 && max_width <= 10 && z_width <= 19 && !is_genesis2 && !is_genesis3) {
                cell_size_name = "_10x9x32";
                tgt_a_width = 10;
                tgt_b_width = 9;
                tgt_z_width = 19;
            } else if (min_width <= 18 && max_width <= 20 && z_width <= 38) {
                cell_size_name = "_20x18x64";
                tgt_a_width = 20;
                tgt_b_width = 18;
                tgt_z_width = 38;
            } else {
                // Too wide
                return;
            }

            if (use_dsp_cfg_params)
                cell_cfg_name = "_cfg_params";
            else
                cell_cfg_name = "_cfg_ports";

            cell_full_name = cell_base_name + cell_size_name + cell_cfg_name;

            type = RTLIL::escape_id(cell_full_name);
            log("Inferring MACC %zux%zu->%zu as %s from:\n", a_width, b_width, z_width, RTLIL::unescape_id(type).c_str());

            for (auto cell : {mul, add, ff}) { //Awais: unescape $neg which is being handled in MACC
                if (cell != nullptr) {
                    log(" %s (%s)\n", RTLIL::unescape_id(cell->name).c_str(), RTLIL::unescape_id(cell->type).c_str());
                }
            }
            if (mux_valid){
                log(" %s (%s)\n", RTLIL::unescape_id(mux->name).c_str(), RTLIL::unescape_id(mux->type).c_str());
            }
            if (neg_mul || muxB_valid){
                log(" %s (%s)\n", RTLIL::unescape_id(neg->name).c_str(), RTLIL::unescape_id(neg->type).c_str());
            }

            // Build the DSP cell name
            std::string name;
            name += RTLIL::unescape_id(mul->name) + "_";
            name += RTLIL::unescape_id(add->name) + "_";
            if (mux_valid) {
                name += RTLIL::unescape_id(mux->name) + "_";
            }
            name += RTLIL::unescape_id(ff->name);

            // Add the DSP cell
            RTLIL::Cell *cell = m_module->addCell(RTLIL::escape_id(name), type);

            // Set attributes
            cell->set_bool_attribute(RTLIL::escape_id("is_inferred"), true);

            // Get input/output data signals
            RTLIL::SigSpec sig_a;
            RTLIL::SigSpec sig_b;
            RTLIL::SigSpec sig_z;

            if (a_width >= b_width) {
                sig_a = mul->getPort(ID(A));
                sig_b = mul->getPort(ID(B));
            } else {
                sig_a = mul->getPort(ID(B));
                sig_b = mul->getPort(ID(A));
            }

            sig_z = add_regout ? ff->getPort(ID(Q)) : ff->getPort(ID(D));

            // Connect input data ports, sign extend / pad with zeros
            sig_a.extend_u0(tgt_a_width, a_signed);
            sig_b.extend_u0(tgt_b_width, b_signed);
            cell->setPort(RTLIL::escape_id("a_i"), sig_a);
            cell->setPort(RTLIL::escape_id("b_i"), sig_b);

            // Connect output data port, pad if needed
            if ((size_t)GetSize(sig_z) < tgt_z_width) {
                auto *wire = m_module->addWire(NEW_ID, tgt_z_width - GetSize(sig_z));
                sig_z.append(wire);
            }
            cell->setPort(RTLIL::escape_id("z_o"), sig_z);

            // Connect clock, reset and enable
            cell->setPort(RTLIL::escape_id("clock_i"), ff->getPort(ID(CLK)));

            RTLIL::SigSpec rst;
            RTLIL::SigSpec ena;
            if (ff->hasPort(ID(ARST)) && _ff_.has_arst) {
                if (ff->getParam(ID(ARST_POLARITY)).as_int() != 1) {
                    rst = m_module->Not(NEW_ID, ff->getPort(ID(ARST)));
                } else {
                    rst = ff->getPort(ID(ARST));
                }
            } else if (ff->hasPort(ID(SRST)) && _ff_.has_srst){
                // EDA-1766 ff is inserted to handle syncronous reset
                RTLIL::SigSpec rst_sync = m_module->addWire(NEW_ID,GetSize(ff->getPort(ID(SRST))));
                m_module->addDff(NEW_ID, ff->getPort(ID(CLK)),ff->getPort(ID(SRST)),rst_sync,ff->getParam(ID(SRST_POLARITY)).as_int());
                if (ff->getParam(ID(SRST_POLARITY)).as_int() != 1) {
                    rst = m_module->Not(NEW_ID, rst_sync);
                } else {
                    rst = rst_sync;
                }
            }
            else {
                    rst = RTLIL::SigSpec(RTLIL::S0);
            }

            if (ff->hasPort(ID(EN))) {
                if (ff->getParam(ID(EN_POLARITY)).as_int() != 1) {
                    ena = m_module->Not(NEW_ID, ff->getPort(ID(EN)));
                } else {
                    ena = ff->getPort(ID(EN));
                }
            } else {
                ena = RTLIL::SigSpec(RTLIL::S1);
            }

            cell->setPort(RTLIL::escape_id("reset_i"), rst);
            cell->setPort(RTLIL::escape_id("load_acc_i"), ena);

            // Insert feedback_i control logic used for clearing / loading the accumulator
            if (mux_valid) {
                RTLIL::SigSpec sig_s = mux->getPort(ID(S));

                // Depending on the mux port ordering insert inverter if needed
                if (!muxB_valid && (mux->getPort(ID::A) == mul->getPort(ID::Y))) {
                    sig_s = m_module->Not(NEW_ID, sig_s);
                }

                // Assemble the full control signal for the feedback_i port
                RTLIL::SigSpec sig_f;
                if (neg_mul || muxB_valid){ // Awais: append 0 to feedback control signal, if MACC is of type, macc_out = sub?acc-mul:acc+mul;
                    sig_f.append(RTLIL::S0);
                }
                else{
                    sig_f.append(sig_s);
                }
                
                sig_f.append(RTLIL::S0);
                sig_f.append(RTLIL::S0);
                cell->setPort(RTLIL::escape_id("feedback_i"), sig_f);
            }
            // No acc clear/load
            else {
                cell->setPort(RTLIL::escape_id("feedback_i"), RTLIL::SigSpec(RTLIL::S0, 3));
            }

            // Connect control ports
            cell->setPort(RTLIL::escape_id("unsigned_a_i"), RTLIL::SigSpec(a_signed ? RTLIL::S0 : RTLIL::S1));
            cell->setPort(RTLIL::escape_id("unsigned_b_i"), RTLIL::SigSpec(b_signed ? RTLIL::S0 : RTLIL::S1));

            // Connect config bits
            if (use_dsp_cfg_params) {
                cell->setParam(RTLIL::escape_id("SATURATE_ENABLE"), RTLIL::Const(RTLIL::S0));
                cell->setParam(RTLIL::escape_id("SHIFT_RIGHT"), RTLIL::Const(RTLIL::S0, 6));
                cell->setParam(RTLIL::escape_id("ROUND"), RTLIL::Const(RTLIL::S0));
                cell->setParam(RTLIL::escape_id("REGISTER_INPUTS"), RTLIL::Const(RTLIL::S0));
                // 3 - output post acc; 1 - output pre acc
                cell->setParam(RTLIL::escape_id("OUTPUT_SELECT"), add_regout ? RTLIL::Const(1, 3) : RTLIL::Const(3, 3));
            } else {
                cell->setPort(RTLIL::escape_id("saturate_enable_i"), RTLIL::SigSpec(RTLIL::S0));
                cell->setPort(RTLIL::escape_id("shift_right_i"), RTLIL::SigSpec(RTLIL::S0, 6));
                cell->setPort(RTLIL::escape_id("round_i"), RTLIL::SigSpec(RTLIL::S0));
                if (is_genesis2) {
                    cell->setParam(RTLIL::escape_id("REGISTER_INPUTS"), RTLIL::Const(RTLIL::S0));
                    // 4 - output post acc; 5 - output pre acc
                    cell->setParam(RTLIL::escape_id("OUTPUT_SELECT"), add_regout ? RTLIL::Const(4, 3) : RTLIL::Const(5, 3));
                } else if (is_genesis3) {
                    cell->setParam(RTLIL::escape_id("REGISTER_INPUTS"), RTLIL::Const(RTLIL::S0));
                    // 3 - output post acc; 1 - output pre acc
                    cell->setParam(RTLIL::escape_id("OUTPUT_SELECT"), add_regout ? RTLIL::Const(1, 3) : RTLIL::Const(3, 3));
                } else {
                    cell->setPort(RTLIL::escape_id("register_inputs_i"), RTLIL::SigSpec(RTLIL::S0));
                    // 3 - output post acc; 1 - output pre acc
                    cell->setPort(RTLIL::escape_id("output_select_i"), add_regout ? RTLIL::Const(1, 3) : RTLIL::Const(3, 3));
                }
            }

            bool subtract = (add->type == RTLIL::escape_id("$sub"));
            
            // Awais: handle mux select signal for accomulator as per MACC type
            if (mux_valid) {
                RTLIL::SigSpec sig_s = mux->getPort(ID(S));
                // Depending on the mux port ordering insert inverter if needed
                // log_assert(mux_ba == ID(A) || mux_ba == ID(B));
                if (mux->getPort(ID(A)) == add->getPort(ID(Y)) or ((neg_mul || muxB_valid) && add->type == RTLIL::escape_id("$add"))) {
                    sig_s = m_module->Not(NEW_ID, sig_s);
                }
                if (!(neg_mul || muxB_valid) and add->type == RTLIL::escape_id("$add"))
                    cell->setPort(RTLIL::escape_id("subtract_i"), RTLIL::S0);
                else
                    cell->setPort(RTLIL::escape_id("subtract_i"),  sig_s);
                
            }
            else{
                cell->setPort(RTLIL::escape_id("subtract_i"), RTLIL::SigSpec(subtract ? RTLIL::S1 : RTLIL::S0));
            }
            auto ff_rem = std::find(dff_cells_.begin(), dff_cells_.end(), ff);
            if (ff_rem != dff_cells_.end()) {
                int indexToRemove = std::distance(dff_cells_.begin(), ff_rem);
                dff_cells_.erase(dff_cells_.begin()+indexToRemove);
            }
            auto mul_rem = std::find(mul_cells.begin(), mul_cells.end(), mul);
            if (mul_rem != mul_cells.end()) {
                int indexToRemove = std::distance(mul_cells.begin(), mul_rem);
                mul_cells.erase(mul_cells.begin()+indexToRemove);
            }
            
            // Mark the cells for removal
            m_module->remove(mul);
            m_module->remove(add);
            if (mux_valid) {
                auto mux_rem = std::find(mux_cells_.begin(), mux_cells_.end(), mux);
                if (mux_rem != mux_cells_.end()) {
                    int indexToRemove = std::distance(mux_cells_.begin(), mux_rem);
                    mux_cells_.erase(mux_cells_.begin()+indexToRemove);
                }
                m_module->remove(mux);
            }
            m_module->remove(ff);
            if (neg_mul || muxB_valid){
                auto neg_rem = std::find(neg_cells.begin(), neg_cells.end(), neg);
                if (neg_rem != neg_cells.end()) {
                    int indexToRemove = std::distance(neg_cells.begin(), neg_rem);
                    neg_cells.erase(neg_cells.begin()+indexToRemove);
                }
                m_module->remove(neg);  // Awais: remove $neg, it is handle in MACC
            }
        }
        
        run_opt_clean = true;
    }
};

struct RSDspMacc : public Pass {

    RSDspMacc() : Pass("rs_dsp_macc", "Does something") {}

    void help() override
    {
        log("\n");
        log("    rs_dsp_macc [options] [selection]\n");
        log("\n");
        log("    -use_dsp_cfg_params\n");
        log("        By default use DSP blocks with configuration bits available at module ports.\n");
        log("        Specifying this forces usage of DSP block with configuration bits available as module parameters.\n");
        log("    -genesis2\n");
        log("        By default use Genesis technology DSP blocks.\n");
        log("        Specifying this forces usage of Genesis2 technology DSP blocks.\n");
        log("    -max_dsp\n");
        log("        Specifies the maximum number of inferred DSP blocks.\n");
        log("\n");
    }

    void clear_flags() override { use_dsp_cfg_params = false; }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *a_Design) override
    {
        log_header(a_Design, "Executing RS_DSP_MACC pass.\n");

        size_t argidx;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            if (a_Args[argidx] == "-use_dsp_cfg_params") {
                use_dsp_cfg_params = true;
                continue;
            }
            if (a_Args[argidx] == "-genesis2") {
                is_genesis2 = true;
                // dsp_cfg_params is not supported in Genesis2
                use_dsp_cfg_params = false;
                continue;
            }
            if (a_Args[argidx] == "-genesis3") {
                is_genesis3 = true;
                // dsp_cfg_params is not supported in Genesis2
                use_dsp_cfg_params = false;
                continue;
            }
            if (a_Args[argidx] == "-max_dsp"  && argidx + 1 < a_Args.size()) {
                max_dsp = std::stoi(a_Args[++argidx]);
                continue;
            }

            break;
        }
        extra_args(a_Args, argidx, a_Design);
        
        for (auto mod : a_Design->selected_modules()) {
            RsDspMaccWorker worker(mod);
            worker.run_scr(is_genesis2,is_genesis3,a_Design);
            if (worker.run_opt_clean)
                Pass::call(a_Design, "opt_clean");
        }

        // for (auto module : a_Design->selected_modules()) {
        //     rs_dsp_macc_pm(module, module->selected_cells()).run_rs_dsp_macc(create_rs_macc_dsp);
        // }
    }
} RSDspMacc;

PRIVATE_NAMESPACE_END
