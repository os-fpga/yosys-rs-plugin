#include "kernel/sigtools.h"
#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN
// ============================================================================

struct rsDffConv : public Pass {
    // ..........................................

    rsDffConv() : Pass("rs_dff_conv", "Implements the DFF_SR cells using DFFR, DFFS, DFF and LUT cells.") {}

    void help() override
    {
        log("\n");
        log("    rs_dff_comv [selection]\n");
        log("\n");
        log("Looks for $DFF_SR cells and implements it by using DFFR, DFFS, DFF and LUT cells\n");
    }

	void rs_dffsr_converter(RTLIL::Module* module)
	{
		for(auto& cell : module->selected_cells()){
			if(cell->type.substr(0, 8) == "$_DFFSR_"){
				RTLIL::Cell* dffr_cell = module->addAdff(RTLIL::escape_id("DFFR"), cell->getPort("C"), cell->getPort("R"), cell->getPort("D"), cell->getPort("Q"), RTLIL::Const(1));
				RTLIL::Cell* dffs_cell = module->addAdff(RTLIL::escape_id("DFFS"), cell->getPort("C"), cell->getPort("S"), cell->getPort("D"), cell->getPort("Q"), RTLIL::Const(0));
				RTLIL::Cell* dff_cell = module->addDff(RTLIL::escape_id("DFF"), cell->getPort("C"), cell->getPort("D"), cell->getPort("Q"));
				RTLIL::Cell* lut_cell = module->addMux(RTLIL::escape_id("MUX"), dffr_cell->getPort("Q"), dffs_cell->getPort("Q"), dff_cell->getPort("Q"), cell->getPort("Q"));
				dffr_cell->setPort("Q", lut_cell->getPort("Y"));
				module->remove(cell);
			}
		}

	
	}
    void execute(std::vector<std::string> a_Args, RTLIL::Design *a_Design) override
    {
        log_header(a_Design, "Executing RS_DFFSR_CONV pass.\n");

        size_t argidx;
        for (argidx = 1; argidx < a_Args.size(); argidx++) {
            break;
        }
        extra_args(a_Args, argidx, a_Design);

        for (auto module : a_Design->selected_modules()) {
            rs_dffsr_converter(module);
        }
    }
} rsDspIORegs;

PRIVATE_NAMESPACE_END
