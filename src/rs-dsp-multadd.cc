// Copyright (C) 2022 RapidSilicon
//

#include "kernel/yosys.h"
#include "kernel/modtools.h"
#include "kernel/ffinit.h"
#include "kernel/ff.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN

// Bits are accessed from right to left, but in GENESIS_2
// MODE_BITS are stored in Big Endian order, so we have to
// use reverse of the bit indecies for the access:
// actual bit idx = 83 --> access idx = 0
#define MODE_BITS_GENESIS2_REGISTER_INPUTS_ID 0
#define MODE_BITS_GENESIS3_REGISTER_INPUTS_ID 83
#define MODE_BITS_REGISTER_INPUTS_ID 92

#define MODE_BITS_OUTPUT_SELECT_START_ID 1
#define MODE_BITS_OUTPUT_SELECT_WIDTH 3
bool is_genesis;
bool is_genesis2;
bool is_genesis3;
struct RsDspMultAddWorker
{
    RTLIL::Module *m_module;
    SigMap m_sigmap;
    FfInitVals m_initvals;
    RsDspMultAddWorker(RTLIL::Module *module) :
        m_module(module), m_sigmap(module), m_initvals(&m_sigmap, module) {}

    bool run_opt_clean = false;

    void run_scr (bool gen, bool gen3,RTLIL::Design *design) {
        SigMap sigmap(design->top_module());

        std::vector<Cell *> mul_cells;
        std::vector<Cell *> shl_cells;
        std::vector<Cell *> add_cells_;
        std::vector<Cell *> dff_cells_;
        RTLIL::Cell *shift_left_cell;
        RTLIL::Cell *mult_coeff;
        RTLIL::Cell *mult_add_cell;
        RTLIL::Cell *regout_cell;
        RTLIL::Cell *regout_mult_cell;
        RTLIL::Cell *shiftl_PB_cell;

        bool add_shl = false;
        bool add_mul = false;
        bool mult_coef = false;
        bool add_regout = false;
        bool acc_multA = false;
        bool shiftl_PB_Reg = false;
        for (auto &cell : m_module->selected_cells()) {
            if(cell->type == RTLIL::escape_id("$mul")){
                mul_cells.push_back(cell);
                continue;
            }
            if(cell->type == RTLIL::escape_id("$shl")){
                shl_cells.push_back(cell);
                continue;
            }
            if(cell->type == RTLIL::escape_id("$add")){
                add_cells_.push_back(cell);
                continue;
            }
            if (RTLIL::builtin_ff_cell_types().count(cell->type)) {
                    //adding all DFF cells of design
                    dff_cells_.push_back(cell);
                    continue;
            }
        }
        // If the following structure is found in the rtlil model than we can infr a MULTADD for RS-DSP
        //                         _______                 ____________
        //                        |       |               |            |
        //  Coefficint[19:0] ---->|       |               |            |
        //                        |  Mult |-------------> |            |
        //        In_B[19:0] ---->|       |               |            |
        //                        |_______|               |            |
        //                         _______                |   Adder    |------->   output                   
        //                        |       |               |            |
        //        In_A[19:0] ---->|       |               |            |
        //                        | Shift |-------------> |            |
        //      acc_fir[5:0] ---->| Left  |               |            |
        //                        |_______|               |____________|
        //                                                
        //
        //
        //                    ________________________________________________________________
        //                   |                                                                |
        //                   |     _______                 ____________                       |
        //                   |    |       |               |            |                      |
        //         ACC[19:0] `--->|       |               |            |         _________    |
        //                        |  Mult |-------------> |            |        |         |___|-----------------------------> output
        //        In_B[19:0] ---->|       |               |            |------->|D       Q|
        //                        |_______|               |            |        |         |
        //                         _______                |   Adder    |        |   ACC   |                      
        //                        |       |               |            |        |         |
        //        In_A[19:0] ---->|       |               |            |  clk-->|         |
        //                        | Shift |-------------> |            |        |_________|
        //      acc_fir[5:0] ---->| Left  |               |            |
        //                        |_______|               |____________|

        for (auto &add_cell : add_cells_) {
            add_shl = false;
            add_mul = false;
            mult_coef = false;
            add_regout = false;
            acc_multA = false;
            shiftl_PB_Reg = false;
            for (auto &conn_add : add_cell->connections()) {
                for (auto &shl_cell : shl_cells) {
                    for (auto &conn_shl : shl_cell->connections()) {
                        if (conn_add.second==conn_shl.second){
                            // log("Signal MSB Chunk = %s",log_signal(conn_shl.second.extract(0,20)));
                            shift_left_cell = shl_cell;
                            mult_add_cell = add_cell;
                            add_shl = true;
                            break;
                        }
                    }
                }
                for (auto &mul_cell : mul_cells) {
                    for (auto &conn_mul : mul_cell->connections()) {
                        for (auto dff_ : dff_cells_){
                            if (GetSize(dff_->getPort(ID::Q))>20){
                                if (conn_mul.second == (dff_->getPort(ID::Q)).extract(0,20)){
                                    acc_multA = true;
                                    regout_mult_cell = dff_;
                                    mult_coeff = mul_cell;
                                    mult_add_cell = add_cell;
                                    add_mul = true;
                                    break;
                                }
                            }
                        }

                        if (conn_mul.second.is_fully_const()){
                            mult_coef = true;
                        }
                        
                        if (conn_add.second==conn_mul.second){
                            mult_coeff = mul_cell;
                            mult_add_cell = add_cell;
                            add_mul = true;
                            break;
                        }
                    }                    
                }
            }
            if (add_mul && add_shl && (mult_coef || acc_multA)){
                RTLIL::IdString type;

                string cell_base_name = "dsp_t1";
                string cell_size_name = "_20x18x64";
                string cell_cfg_name = "_cfg_ports";
                string cell_full_name = cell_base_name + cell_size_name + cell_cfg_name;
                type = RTLIL::escape_id(cell_full_name);
                size_t tgt_a_width;
                size_t tgt_b_width;
                size_t tgt_z_width;
                size_t a_width = GetSize(mult_coeff->getPort(ID(A)));
                size_t b_width = GetSize(mult_coeff->getPort(ID(B)));
                size_t z_width = GetSize(mult_coeff->getPort(ID(Y)));
                size_t min_width = std::min(a_width, b_width);
                size_t max_width = std::max(a_width, b_width);

                // Signed / unsigned
                bool a_signed = mult_coeff->getParam(ID(A_SIGNED)).as_bool();
                bool b_signed = mult_coeff->getParam(ID(B_SIGNED)).as_bool();

                if (min_width <= 2 && max_width <= 2 && z_width <= 4) {
                    // Too narrow
                    continue;
                } else if (min_width <= 9 && max_width <= 10 && z_width <= 19 && (is_genesis || is_genesis3)) {
                    // Enabled support of Fracturable DSP MODE for Genesis3 for newly Added DSP19X2 Primitive 
                    cell_size_name = "_10x9x32";
                    if (is_genesis3){
                        cell_cfg_name = "_cfg_params";
                        cell_full_name = cell_base_name + cell_size_name + cell_cfg_name;
                        // Updating the cell type to "dsp_t1_10x9x32_cfg_params" for genesis3
                        type = RTLIL::escape_id(cell_full_name); 
                    }
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
                    continue;
                }
                log("Inferring MULTADD %zux%zu->%zu as %s from:\n", a_width, b_width, z_width, RTLIL::unescape_id(type).c_str());
                for (auto cell : {mult_coeff, mult_add_cell, shift_left_cell}) { //Awais: unescape $neg which is being handled in MACC
                    if (cell != nullptr) {
                        log(" %s (%s)\n", RTLIL::unescape_id(cell->name).c_str(), RTLIL::unescape_id(cell->type).c_str());
                    }
                }
                // Build the DSP cell name
                std::string name;
                name += RTLIL::unescape_id(mult_coeff->name) + "_";
                name += RTLIL::unescape_id(shift_left_cell->name) + "_";
                name += RTLIL::unescape_id(mult_add_cell->name);

                // Add the DSP cell
                bool shiftl_A_valid_size = false;
                bool valid_shiftl_chunk = false;
                RTLIL::SigSpec chunk_msb;
                #if 0 // if verific on-> verific append A input with MSB to match the size of Y output, so we have original value of A input in the chunk[0]
                    if (!(shift_left_cell->getPort(ID::A).is_chunk())){
                        int size_chunk = 0 ;
                        RTLIL::IdString chunk_id;
                        std::vector<SigChunk> chunks_ = sigmap(shift_left_cell->getPort(ID::A));
                        size_chunk = GetSize(shift_left_cell->getPort(ID::A));
                        int n = 0 ;
                        chunk_msb = chunks_.at(0);
                        if (GetSize(chunks_.at(0))<=20 && GetSize(shift_left_cell->getPort(ID::B))<=6){
                            shiftl_A_valid_size = true;
                        }
                        for (auto &chunk_ : chunks_){
                            if (n>0 && chunk_msb[GetSize(chunks_.at(0))-1] == chunk_){
                                valid_shiftl_chunk  = true;
                            }
                            else{
                                valid_shiftl_chunk  = false;
                            }
                            n++;
                        }
                    }
                    if (!(shiftl_A_valid_size && valid_shiftl_chunk)) {
                        continue;
                    };
                #endif
                #if 1
                    if (GetSize(shift_left_cell->getPort(ID::A))<=20 && GetSize(shift_left_cell->getPort(ID::B))<=6){
                        shiftl_A_valid_size = true;
                        chunk_msb = shift_left_cell->getPort(ID::A);
                    }
                    if (!(shiftl_A_valid_size)) {
                        continue;
                    };
                #endif
                RTLIL::Cell *cell_muladd = m_module->addCell(RTLIL::escape_id(name), type);

                // Set attributes
                RTLIL::SigSpec sig_a;
                RTLIL::SigSpec sig_b;
                RTLIL::SigSpec sig_z;
                cell_muladd->set_bool_attribute(RTLIL::escape_id("is_inferred"), true);
                sig_a = chunk_msb;
                // we can have feedback from accomulator register or we can have coefficients for A input of mult
                if (acc_multA){ 
                    if (mult_coeff->getPort(ID::B) == (regout_mult_cell->getPort(ID::Q)).extract(0,20)){
                        cell_muladd->setPort(RTLIL::escape_id("a_i"), sig_a);
                        sig_b = mult_coeff->getPort(ID::A);
                        cell_muladd->setPort(RTLIL::escape_id("b_i"),sig_b);
                    }
                    else if (mult_coeff->getPort(ID::A) == (regout_mult_cell->getPort(ID::Q)).extract(0,20)){
                        cell_muladd->setPort(RTLIL::escape_id("a_i"), sig_a);
                        sig_b = mult_coeff->getPort(ID::B);
                        cell_muladd->setPort(RTLIL::escape_id("b_i"), sig_b);
                    }
                    cell_muladd->setPort(RTLIL::escape_id("unsigned_a_i"),mult_coeff->getParam(ID::A_SIGNED).as_bool()?RTLIL::S0:RTLIL::S1);
                    cell_muladd->setPort(RTLIL::escape_id("unsigned_b_i"),mult_coeff->getParam(ID::B_SIGNED).as_bool()?RTLIL::S0:RTLIL::S1);
                }
                else if (mult_coeff->getPort(ID::B).is_fully_const()){
                    cell_muladd->setParam(RTLIL::escape_id("COEFF_0"), mult_coeff->getPort(ID::B).as_const());
                    sig_b = mult_coeff->getPort(ID::A);
                    cell_muladd->setPort(RTLIL::escape_id("b_i"), sig_b);
                    cell_muladd->setPort(RTLIL::escape_id("a_i"), sig_a);
                    cell_muladd->setPort(RTLIL::escape_id("unsigned_b_i"),mult_coeff->getParam(ID::A_SIGNED).as_bool()?RTLIL::S0:RTLIL::S1);
                }
                else{
                    cell_muladd->setParam(RTLIL::escape_id("COEFF_0"), mult_coeff->getPort(ID::A).as_const());
                    sig_b = mult_coeff->getPort(ID::B);
                    cell_muladd->setPort(RTLIL::escape_id("b_i"), sig_b);
                    cell_muladd->setPort(RTLIL::escape_id("a_i"), sig_a);
                    cell_muladd->setPort(RTLIL::escape_id("unsigned_b_i"),mult_coeff->getParam(ID::B_SIGNED).as_bool()?RTLIL::S0:RTLIL::S1);
                }

                sig_a.extend_u0(tgt_a_width, a_signed);
                sig_b.extend_u0(tgt_b_width, b_signed);
                RTLIL::SigSpec sig_f;
                if (acc_multA){                            
                    sig_f.append(RTLIL::S1);
                    sig_f.append(RTLIL::S1);
                    sig_f.append(RTLIL::S0);
                }
                else { 
                    sig_f.append(RTLIL::S1);
                    sig_f.append(RTLIL::S1);
                    sig_f.append(RTLIL::S1);
                }

                cell_muladd->setPort(RTLIL::escape_id("feedback_i"), sig_f);
                if (acc_multA){
                    cell_muladd->setPort(RTLIL::escape_id("load_acc_i"), RTLIL::SigSpec(RTLIL::S1));
                }
                else{
                    cell_muladd->setPort(RTLIL::escape_id("load_acc_i"), RTLIL::SigSpec(RTLIL::S0));
                }
                cell_muladd->setPort(RTLIL::escape_id("subtract_i"), RTLIL::SigSpec(RTLIL::S0));

                // Connect control ports
                if (!acc_multA)
                    cell_muladd->setPort(RTLIL::escape_id("unsigned_a_i"),shift_left_cell->getParam(ID::A_SIGNED).as_bool()?RTLIL::S0:RTLIL::S1);
               
                if ((cell_cfg_name == "_cfg_params") && is_genesis3){
                    cell_muladd->setParam(RTLIL::escape_id("SATURATE_ENABLE"), RTLIL::Const(RTLIL::S0));
                    cell_muladd->setParam(RTLIL::escape_id("SHIFT_RIGHT"), RTLIL::Const(RTLIL::S0, 6));
                    cell_muladd->setParam(RTLIL::escape_id("ROUND"), RTLIL::Const(RTLIL::S0));
                    cell_muladd->setParam(RTLIL::escape_id("REGISTER_INPUTS"), RTLIL::Const(RTLIL::S0));
                    cell_muladd->setParam(RTLIL::escape_id("DSP_RST_POL"), RTLIL::Const(RTLIL::S0));
                    cell_muladd->setParam(RTLIL::escape_id("DSP_RST"),  RTLIL::Const(RTLIL::S0));
                    cell_muladd->setParam(RTLIL::escape_id("DSP_CLK"), RTLIL::Const(RTLIL::S0));
                }
                else{
                    cell_muladd->setPort(RTLIL::escape_id("saturate_enable_i"), RTLIL::SigSpec(RTLIL::S0));
                    cell_muladd->setPort(RTLIL::escape_id("shift_right_i"), RTLIL::SigSpec(RTLIL::S0, 6));
                    cell_muladd->setPort(RTLIL::escape_id("round_i"), RTLIL::SigSpec(RTLIL::S0));
                }
                
                RTLIL::SigSpec clk;
                RTLIL::SigSpec reset;
                cell_muladd->setPort(RTLIL::escape_id("clock_i"), clk);
                cell_muladd->setPort(RTLIL::escape_id("reset_i"), reset);
                // Check if there is an output register connected
                for (auto dff_cell : dff_cells_){
                    if (mult_add_cell->getPort(ID::Y) == dff_cell->getPort(ID::D)){
                        regout_cell = dff_cell;
                        add_regout = true;
                    }
                    if (dff_cell->getPort(ID::Q) ==  shift_left_cell->getPort(ID::B)){
                        shiftl_PB_cell = dff_cell;
                        shiftl_PB_Reg = true;
                        RTLIL::SigSpec acc_fir;
                        acc_fir = dff_cell->getPort(ID::D);
                        acc_fir.extend_u0(6, 0);
                        cell_muladd->setPort(RTLIL::escape_id("acc_fir_i"), acc_fir);
                    }
                }
                if (!shiftl_PB_Reg){
                    RTLIL::SigSpec acc_fir;
                    acc_fir = shift_left_cell->getPort(ID::B);
                    acc_fir.extend_u0(6, 0);
                    cell_muladd->setPort(RTLIL::escape_id("acc_fir_i"), acc_fir);
                }
                if (is_genesis3){
                    if (add_regout){
                        cell_muladd->setParam(RTLIL::escape_id("OUTPUT_SELECT"), RTLIL::Const(6, 3));
                        cell_muladd->setPort(RTLIL::escape_id("z_o"), regout_cell->getPort(ID::Q));
                        m_module->remove(regout_cell);
                    }
                    else{
                        cell_muladd->setParam(RTLIL::escape_id("OUTPUT_SELECT"), RTLIL::Const(2, 3));
                        cell_muladd->setPort(RTLIL::escape_id("z_o"), mult_add_cell->getPort(ID::Y));
                    }
                }
                if (is_genesis2){
                    if (add_regout){
                        cell_muladd->setParam(RTLIL::escape_id("OUTPUT_SELECT"), RTLIL::Const(3, 3));
                        cell_muladd->setPort(RTLIL::escape_id("z_o"), regout_cell->getPort(ID::Q));
                        m_module->remove(regout_cell);
                    }
                    else{
                        cell_muladd->setParam(RTLIL::escape_id("OUTPUT_SELECT"), RTLIL::Const(2, 3));
                        cell_muladd->setPort(RTLIL::escape_id("z_o"), mult_add_cell->getPort(ID::Y));
                    }
                }

                auto sh_rem = std::find(shl_cells.begin(), shl_cells.end(), shift_left_cell);
                if (sh_rem != shl_cells.end()) {
                    int indexToRemove = std::distance(shl_cells.begin(), sh_rem);
                    shl_cells.erase(shl_cells.begin()+indexToRemove);
                }
                auto mul_rem = std::find(mul_cells.begin(), mul_cells.end(), mult_coeff);
                if (mul_rem != mul_cells.end()) {
                    int indexToRemove = std::distance(mul_cells.begin(), mul_rem);
                    mul_cells.erase(mul_cells.begin()+indexToRemove);
                }
	            m_module->remove(mult_add_cell);
	            m_module->remove(shift_left_cell);
	            m_module->remove(mult_coeff);
                if (shiftl_PB_Reg){
                    auto ff_rem = std::find(dff_cells_.begin(), dff_cells_.end(), shiftl_PB_cell);
                    if (ff_rem != dff_cells_.end()) {
                        int indexToRemove = std::distance(dff_cells_.begin(), ff_rem);
                        dff_cells_.erase(dff_cells_.begin()+indexToRemove);
                    }
    	            m_module->remove(shiftl_PB_cell);
                }
            }
        }
    }
};

struct RSDspMultAddPass : public Pass {
    RSDspMultAddPass() : Pass("rs-dsp-multadd", "pack multadd into DSP") { }
    void help() override
    {
        //   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
        log("\n");
        log("    Rs_dsp_multadd [selection]\n");
        log("\n");
        log("    This pass packs DSP input registers inside DSP component\n");
        log("\n");
    }

    void execute(std::vector<std::string> a_Args, RTLIL::Design *design) override
    {
        log_header(design, "Executing RS_DSP_MULTADD pass.\n");
        bool gen3 = false;
        bool gen = false;
        size_t argidx;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            if (a_Args[argidx] == "-genesis3")
                is_genesis3 = true;
            if (a_Args[argidx] == "-genesis2")
                is_genesis2 = true;
            if (a_Args[argidx] == "-genesis")
                is_genesis = true;
        }
        
        extra_args(a_Args, argidx, design);

        for (auto mod : design->selected_modules()) {
            RsDspMultAddWorker worker(mod);
            worker.run_scr(gen,gen3,design);
            // if (worker.run_opt_clean)
            //     Pass::call(design, "opt_clean");
        }
    }
} RSDspMultAddPass;

PRIVATE_NAMESPACE_END
