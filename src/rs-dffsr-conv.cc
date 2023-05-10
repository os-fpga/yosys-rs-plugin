#include "kernel/sigtools.h"
#include "kernel/yosys.h"

USING_YOSYS_NAMESPACE
PRIVATE_NAMESPACE_BEGIN
// ============================================================================

struct rsDffsrConv : public Pass {
    // ..........................................

    rsDffsrConv() : Pass("rs_dffsr_conv", "Implements the $DFF_SR cells using DFFR, DFFS, DFF and LUT cells.") {}

    void help() override
    {
        log("\n");
        log("    rs_dffsr_comv [selection]\n");
        log("\n");
        log("Looks for $DFF_SR cells and implements it by using DFFR, DFFS, DFF and LUT cells\n");
    }
	
	void rs_dffsr_converter(RTLIL::Module* module, RTLIL::Design* design)
	{
		for(auto& cell : module->selected_cells()){
			if(cell->type.substr(0, 7) == "$_DFFSR"){
				RTLIL::Wire* output_not = module->addWire(RTLIL::escape_id(cell->name.str() + "inv_wire_out"));
				RTLIL::Wire* data_not = module->addWire(RTLIL::escape_id(cell->name.str() + "inv_wire_data"));
				RTLIL::Wire* conn_xor = module->addWire(RTLIL::escape_id(cell->name.str() + "xor_wire"));
				RTLIL::Wire* conn1 = module->addWire(RTLIL::escape_id(cell->name.str() + "mux_wire_a"));
				RTLIL::Wire* conn2 = module->addWire(RTLIL::escape_id(cell->name.str() + "mux_wire_b"));
				RTLIL::Wire* conn3 = module->addWire(RTLIL::escape_id(cell->name.str() + "mux_wire_s"));

				RTLIL::SigSpec mux_a(conn1), mux_b(conn2), mux_s(conn3), d_not(data_not), not_in(output_not), xor_in(conn_xor);

				module->addNot(RTLIL::escape_id(cell->name.str() + "inv_out"), not_in, mux_a);
				module->addNot(RTLIL::escape_id(cell->name.str() + "inv_data"), cell->getPort("\\D"), d_not);
				module->addXor(RTLIL::escape_id(cell->name.str() + "xor"), xor_in, mux_b, mux_s);
				module->addMux(RTLIL::escape_id(cell->name.str() + "mux"), mux_a, mux_b, mux_s, cell->getPort("\\Q"));
				if(cell->type.substr(0, 8) == "$_DFFSR_"){
					module->addAdff(RTLIL::escape_id(cell->name.str() + "dffr"), cell->getPort("\\C"), cell->getPort("\\R"), cell->getPort("\\D"), mux_b, RTLIL::Const(0 , cell->getPort("\\R").size()));
					module->addAdff(RTLIL::escape_id(cell->name.str() + "dffs"), cell->getPort("\\C"), cell->getPort("\\S"), d_not, not_in, RTLIL::Const(0 , cell->getPort("\\S").size()));
					module->addDff(RTLIL::escape_id(cell->name.str() + "dff"), cell->getPort("\\C"), cell->getPort("\\D"), xor_in);
				} else {
					module->addAdffe(RTLIL::escape_id(cell->name.str() + "dffre"), cell->getPort("\\C"), cell->getPort("\\E"), cell->getPort("\\R"), cell->getPort("\\D"), mux_b, RTLIL::Const(0 , cell->getPort("\\R").size()));
					module->addAdffe(RTLIL::escape_id(cell->name.str() + "dffse"), cell->getPort("\\C"), cell->getPort("\\E"),cell->getPort("\\S"), d_not, not_in, RTLIL::Const(0 , cell->getPort("\\S").size()));
					module->addDffe(RTLIL::escape_id(cell->name.str() + "dffe"), cell->getPort("\\C"), cell->getPort("\\E"), cell->getPort("\\D"), xor_in);
				}
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
            rs_dffsr_converter(module, a_Design);
        }
    }
} rsDffsrConv;

PRIVATE_NAMESPACE_END
