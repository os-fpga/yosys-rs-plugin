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

struct OptDFfCleanWorker
{
	int count = 0;
	RTLIL::Module *module;
	ModIndex index;
	FfInitVals initvals;

	OptDFfCleanWorker(RTLIL::Module *module) :
		module(module), index(module), initvals(&index.sigmap, module)
	{
		log("Discovering LUTs.\n\n");
	}
};


struct OptDFfCleanWorkerPass : public Pass {
	OptDFfCleanWorkerPass() : Pass("dff_clean", "get rid of unnecessary DFFs") { }
	void help() override
	{
		//   |---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|---v---|
		log("\n");
		log("    dff_clean [selection]\n");
		log("\n");
		log("This pass makes it possible to use all the DFFs in the DSP and not add new DFFs to the design in an empty space\n");
		log("\n");
	}	

	void execute(std::vector<std::string> args, RTLIL::Design *design) override
	{		
		int total_count = 0;

		std::vector <std::string> DSP_modules_names {"\\RS_DSP1", "\\RS_DSP2", "\\RS_DSP2_MULT","\\RS_DSP2_MULT_REGIN", "\\RS_DSP2_MULT_REGOUT", 
		"\\RS_DSP2_MULT_REGIN_REGOUT", "\\RS_DSP2_MULTADD", "\\RS_DSP2_MULTADD_REGIN", "\\RS_DSP2_MULTADD_REGOUT", "\\RS_DSP2_MULTADD_REGIN_REGOUT", 
		"\\RS_DSP2_MULTACC", "\\RS_DSP2_MULTACC_REGIN", "\\RS_DSP2_MULTACC_REGOUT", "\\RS_DSP2_MULTACC_REGIN_REGOUT", "\\dsp_t1_20x18x64_cfg_ports", 
		"\\dsp_t1_10x9x32_cfg_ports", "\\dsp_t1_sim_cfg_ports", "\\RS_DSP3", "\\RS_DSP3_MULT ", "\\RS_DSP3_MULT_REGIN", "\\RS_DSP3_MULT_REGOUT", 
		"\\RS_DSP3_MULT_REGIN_REGOUT", "\\RS_DSP3_MULTADD", "\\RS_DSP3_MULTADD_REGIN", "\\RS_DSP3_MULTADD_REGOUT", "\\RS_DSP3_MULTADD_REGIN_REGOUT", 
		"\\RS_DSP3_MULTACC", "\\RS_DSP3_MULTACC_REGIN", "\\RS_DSP3_MULTACC_REGOUT", "\\RS_DSP3_MULTACC_REGIN_REGOUT", "\\dsp_t1_20x18x64_cfg_params", 
		"\\dsp_t1_10x9x32_cfg_params", "\\dsp_t1_sim_cfg_params"};
	
		std::vector<Cell *> DSP_used_cells;
		std::vector<Cell *> DFF_used_cells;
		std::vector<Cell *> ALL_cells_of_design;
		
		for (auto module : design->selected_modules())
		{
			SigMap sigmap(module);
			OptDFfCleanWorker worker(module);			
			total_count += worker.count;
			for (auto cell : module->selected_cells()) {
				//std::cout << "CELL: " << cell->type.c_str() << std::endl << std::endl;

				bool dsp_found_ = false;
				for (auto it : DSP_modules_names) {
					if (it == cell->type.c_str()){						
						DSP_used_cells.push_back(cell); //adding all DSP cells of design
						dsp_found_ = true;
					}
				}
				if (dsp_found_)
					continue;
				if (module->design->selected(module, cell) && RTLIL::builtin_ff_cell_types().count(cell->type)){
					DFF_used_cells.push_back(cell); //adding all DFF cells of design
					continue;
				}
				ALL_cells_of_design.push_back(cell);
			}	

			std::vector <RTLIL::Cell*> DSP_that_drives_from_DFF;
			RTLIL::SigSpec DFF_clk;
			RTLIL::SigSpec DFF_rst;
			
			// Getting each DSP from all DSPs of our MODULE
			for (auto &it_dsp : DSP_used_cells){
				std::cout << "Working with DSP by name: " <<  it_dsp->name.c_str() << std::endl;

				// if the port of DSP driven from DFF
				bool port_a_from_dff = false;
				bool port_b_from_dff = false;
				// if secelted DFF have enable pin, dont add that DSP to vector;
				bool dff_have_enable_pin = false;
				// Get RESET and CLK SigSpec to compare with another DFF RESET and CLK SigSpecs wich drive DSP signals
				bool for_first_dff = true;
				// get it_dsp SigSpec of ports "\a" and "\b"
				RTLIL::SigSpec DSP_port_a = sigmap(it_dsp->getPort("\\a"));
				RTLIL::SigSpec DSP_port_b = sigmap(it_dsp->getPort("\\b"));
				// Getting each DFF from all DFFs of our MODULE
				for (auto &it_dff : DFF_used_cells){
					std::cout << "-- Working with DFF by name: " <<  it_dff->name.c_str() << std::endl;
					// Getting all connections of each dff
					for (auto &conn_dff : it_dff->connections_) {
						// Getting selected DFF RESET and CLOCK SigSepc
						if (for_first_dff){
							if(sigmap(conn_dff.second) == sigmap(it_dff->getPort("\\ARST"))){
								DFF_rst = it_dff->getPort("\\ARST");
							}
							if(sigmap(conn_dff.second) == sigmap(it_dff->getPort("\\CLK"))){
								DFF_clk = it_dff->getPort("\\CLK");
							}
						}
						// check if there was connection between DSP and DFF

						// if DSP port b is driven from DFF make it true
						if (sigmap(DSP_port_a) == sigmap(conn_dff.second)){ 
							std::cout << "\tThere was connection between DSP port ( \\a ) and DFF port ( " << conn_dff.first.c_str() << " )" << std::endl;
							if (for_first_dff){
								port_a_from_dff = true;
							}else{
								if (sigmap(it_dff->getPort("\\ARST")) == sigmap(DFF_rst) && sigmap(it_dff->getPort("\\CLK")) == sigmap(DFF_clk)){
									port_a_from_dff = true;
								}
							}
						}
						// if DSP port b is driven from DFF make it true
						if (sigmap(DSP_port_b) == sigmap(conn_dff.second)){ 
							std::cout << "\tThere was connection between DSP port ( \\b ) and DFF port ( " << conn_dff.first.c_str() << " )" << std::endl;
							if (for_first_dff){
								port_b_from_dff = true;
							}else{
								if (sigmap(it_dff->getPort("\\ARST")) == sigmap(DFF_rst) && sigmap(it_dff->getPort("\\CLK")) == sigmap(DFF_clk)){
									port_b_from_dff = true;
								}
							}
						}
						// Checking if DFF have Enable port
						if (strcmp(conn_dff.first.c_str(), "\\EN")){
							dff_have_enable_pin = true;
						}
					}
					// first time desable
					if (for_first_dff){
						for_first_dff = false;
					}
				}
				// if DSP data ports is driven from DFFs add that DSP to vector
				if (port_a_from_dff && port_b_from_dff && !dff_have_enable_pin){
					DSP_that_drives_from_DFF.push_back(it_dsp);
				}
			}


			// Getting all DSP that are confirmed for treatment
			for (auto &DSP_driven_DFF : DSP_used_cells){
				// Getting selected DSP port ( a ) and ( b )
				RTLIL::SigSpec DSP_port_a = sigmap(DSP_driven_DFF->getPort("\\a"));
				RTLIL::SigSpec DSP_port_b = sigmap(DSP_driven_DFF->getPort("\\b"));
				// Getting all connetions of selected DSP
				for (auto &conn_dsp : DSP_driven_DFF->connections_){
					// Getting all DFF_s to find connetions that are connected with DSP
					for (auto &it_dff : DFF_used_cells){
						// Getting all connections of each selected DFF
						for (auto &conn_dff : it_dff->connections_){
							// if sleceted DSP connection is DSP port ( a )
							if (sigmap(conn_dff.second) == DSP_port_a){
								// connectiong DSP port ( a ) with DFF data input port
								DSP_driven_DFF->setPort("\\a", it_dff->getPort("\\D"));
							}
							if (sigmap(conn_dff.second) == DSP_port_b){
								// connectiong DSP port ( b ) with DFF data input port
								DSP_driven_DFF->setPort("\\b", it_dff->getPort("\\D"));
							}							
						}
					}
					// Getting DSP Reginster inputs port to change value 1
					if (sigmap(conn_dsp.second) == sigmap(DSP_driven_DFF->getPort("\\register_inputs"))){
						DSP_driven_DFF->setPort(RTLIL::escape_id("register_inputs"), RTLIL::S1);
					}
					// Getting DSP clock port to connect it with DFF clock port
					if (conn_dsp.second == DSP_driven_DFF->getPort("\\clk")){
						DSP_driven_DFF->setPort("\\clk", DFF_clk);
					}
					// Getting DSP reset port to connect it with DFF reset port
					if (conn_dsp.second == DSP_driven_DFF->getPort("\\reset")){
						DSP_driven_DFF->setPort("\\reset", DFF_rst);
					}
				}
			}
		}
	}
} OptDFfCleanWorkerPass;

PRIVATE_NAMESPACE_END
