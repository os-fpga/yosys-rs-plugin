// Copyright (C) 2022 RapidSilicon
//

`define MODE_36 3'b110	// 36 or 32-bit
`define MODE_18 3'b010	// 18 or 16-bit
`define MODE_9  3'b100	// 9 or 8-bit
`define MODE_4  3'b001	// 4-bit
`define MODE_2  3'b011	// 32-bit
`define MODE_1  3'b101	// 32-bit

module \$__RS_FACTOR_BRAM36_TDP (...);
	parameter INIT = 0;
	parameter WIDTH = 1;
	
	parameter PORT_B_WR_BE_WIDTH = 1;
	parameter PORT_A_RD_SRST_VALUE = 1;
	
	parameter PORT_D_WR_BE_WIDTH = 1;

	localparam ABITS = 15;
	localparam CFG_ENABLE = 4;

    input CLK_C1;
    input CLK_C2;

	input 				PORT_A_CLK;
	input [ABITS-1:0] 		PORT_A_ADDR;
	output [WIDTH-1:0]		PORT_A_RD_DATA;
	input 				PORT_A_RD_EN;
	
	input 				PORT_B_CLK;
	input [ABITS-1:0] 		PORT_B_ADDR;
	input [WIDTH-1:0] 		PORT_B_WR_DATA;
	input 				PORT_B_WR_EN;
	input [PORT_B_WR_BE_WIDTH-1:0]	PORT_B_WR_BE;

	input 				PORT_C_CLK;
	input [ABITS-1:0] 		PORT_C_ADDR;
	output [WIDTH-1:0]		PORT_C_RD_DATA;
	input 				PORT_C_RD_EN;
	
	input 				PORT_D_CLK;
	input [ABITS-1:0] 		PORT_D_ADDR;
	input [WIDTH-1:0] 		PORT_D_WR_DATA;
	input 				PORT_D_WR_EN;
	input [PORT_B_WR_BE_WIDTH-1:0]	PORT_D_WR_BE;


	wire FLUSH1;
	wire FLUSH2;
	wire SPLIT;

	wire [CFG_ENABLE-1:PORT_B_WR_BE_WIDTH] B1EN_CMPL = {CFG_ENABLE-PORT_B_WR_BE_WIDTH{1'b0}};
	wire [CFG_ENABLE-1:PORT_D_WR_BE_WIDTH] D1EN_CMPL = {CFG_ENABLE-PORT_D_WR_BE_WIDTH{1'b0}};

	wire [CFG_ENABLE-1:0] B1EN = {B1EN_CMPL, PORT_B_WR_BE};
	wire [CFG_ENABLE-1:0] D1EN = {D1EN_CMPL, PORT_D_WR_BE};

	wire [35:WIDTH] B1DATA_CMPL;
	wire [35:WIDTH] D1DATA_CMPL;

	wire [35:0] A1DATA_TOTAL;
	wire [35:0] B1DATA_TOTAL;
	wire [35:0] C1DATA_TOTAL;
	wire [35:0] D1DATA_TOTAL;

	wire [ABITS-1:0] 		A_ADDR;
	wire [ABITS-1:0] 		B_ADDR;

	assign A_ADDR = PORT_A_RD_EN ? PORT_A_ADDR : (PORT_B_WR_EN ? PORT_B_ADDR : 15'd0);
	assign B_ADDR = PORT_C_RD_EN ? PORT_C_ADDR : (PORT_D_WR_EN ? PORT_D_ADDR : 15'd0);


	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16
	case (WIDTH)
		9: begin
			assign PORT_A_RD_DATA = {A1DATA_TOTAL[16], A1DATA_TOTAL[7:0]};
			assign PORT_C_RD_DATA = {C1DATA_TOTAL[16], C1DATA_TOTAL[7:0]};
			assign B1DATA_TOTAL = {B1DATA_CMPL[35:17], PORT_B_WR_DATA[8], B1DATA_CMPL[16:9], PORT_B_WR_DATA[7:0]};
			assign D1DATA_TOTAL = {D1DATA_CMPL[35:17], PORT_D_WR_DATA[8], D1DATA_CMPL[16:9], PORT_D_WR_DATA[7:0]};
		end
		default: begin
			assign PORT_A_RD_DATA = A1DATA_TOTAL[WIDTH-1:0];
			assign PORT_C_RD_DATA = C1DATA_TOTAL[WIDTH-1:0];
			assign B1DATA_TOTAL = {B1DATA_CMPL, PORT_B_WR_DATA};
			assign D1DATA_TOTAL = {D1DATA_CMPL, PORT_D_WR_DATA};
		end
	endcase

	case (WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_1, `MODE_1, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_1, `MODE_1, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_2, `MODE_2, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_2, `MODE_2, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_4, `MODE_4, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_4, `MODE_4, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_9, `MODE_9, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_9, `MODE_9, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_18, `MODE_18, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_18, `MODE_18, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,
				`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end
	endcase


	assign SPLIT = 1'b0;
	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;
    
	TDP36K #(
        .INIT_i(INIT)
        ) _TECHMAP_REPLACE_ (
		.RESET_ni(1'b1),
		.WDATA_A1_i(B1DATA_TOTAL[17:0]),
		.WDATA_A2_i(B1DATA_TOTAL[35:18]),
		.RDATA_A1_o(A1DATA_TOTAL[17:0]),
		.RDATA_A2_o(A1DATA_TOTAL[35:18]),
		.ADDR_A1_i(A_ADDR),
		.ADDR_A2_i(A_ADDR),
		.CLK_A1_i(PORT_A_CLK),
		.CLK_A2_i(PORT_A_CLK),
		.REN_A1_i(PORT_A_RD_EN),
		.REN_A2_i(PORT_A_RD_EN),
		.WEN_A1_i(PORT_B_WR_EN),
		.WEN_A2_i(PORT_B_WR_EN),
		.BE_A1_i({B1EN[1:0]}),
		.BE_A2_i({B1EN[3:2]}),

		.WDATA_B1_i(D1DATA_TOTAL[17:0]),
		.WDATA_B2_i(D1DATA_TOTAL[35:18]),
		.RDATA_B1_o(C1DATA_TOTAL[17:0]),
		.RDATA_B2_o(C1DATA_TOTAL[35:18]),
		.ADDR_B1_i(B_ADDR),
		.ADDR_B2_i(B_ADDR),
		.CLK_B1_i(PORT_C_CLK),
		.CLK_B2_i(PORT_C_CLK),
		.REN_B1_i(PORT_C_RD_EN),
		.REN_B2_i(PORT_C_RD_EN),
		.WEN_B1_i(PORT_D_WR_EN),
		.WEN_B2_i(PORT_D_WR_EN),
		.BE_B1_i({D1EN[1:0]}),
		.BE_B2_i({D1EN[3:2]}),

		.FLUSH1_i(FLUSH1),
		.FLUSH2_i(FLUSH2)
	);
endmodule

// ------------------------------------------------------------------------

module \$__RS_FACTOR_BRAM18_TDP (...);
	parameter INIT = 0;
	parameter WIDTH = 1;
	
	parameter PORT_B_WR_BE_WIDTH = 1;
	parameter PORT_A_RD_SRST_VALUE = 1;
	
	parameter PORT_D_WR_BE_WIDTH = 1;
	parameter PORT_C_RD_SRST_VALUE = 1;

	localparam ABITS = 14;
	localparam CLKPOL2 = 1;
	localparam CLKPOL3 = 1;
    
    input CLK_C1;
    input CLK_C2;
	
    input 				PORT_A_CLK;
	input [ABITS-1:0] 		PORT_A_ADDR;
	output [WIDTH-1:0]		PORT_A_RD_DATA;
	input 				PORT_A_RD_EN;
	
	input 				PORT_B_CLK;
	input [ABITS-1:0] 		PORT_B_ADDR;
	input [WIDTH-1:0] 		PORT_B_WR_DATA;
	input 				PORT_B_WR_EN;
	input [PORT_B_WR_BE_WIDTH-1:0]	PORT_B_WR_BE;
	
    input 				PORT_C_CLK;
	input [ABITS-1:0] 		PORT_C_ADDR;
	output [WIDTH-1:0]		PORT_C_RD_DATA;
	input 				PORT_C_RD_EN;
	
	input 				PORT_D_CLK;
	input [ABITS-1:0] 		PORT_D_ADDR;
	input [WIDTH-1:0] 		PORT_D_WR_DATA;
	input 				PORT_D_WR_EN;
	input [PORT_D_WR_BE_WIDTH-1:0]	PORT_D_WR_BE;

	BRAM2x18_TDP #(
		.CFG_DBITS(WIDTH),
		.CFG_ENABLE_B(PORT_B_WR_BE_WIDTH),
		.CFG_ENABLE_D(PORT_D_WR_BE_WIDTH),
		.CLKPOL2(CLKPOL2),
		.CLKPOL2(CLKPOL2),
		.CLKPOL3(CLKPOL3),
		.INIT0(INIT)
	) _TECHMAP_REPLACE_ (
		.A1ADDR(PORT_A_ADDR),
		.A1DATA(PORT_A_RD_DATA),
		.A1EN(PORT_A_RD_EN),
		.B1ADDR(PORT_B_ADDR),
		.B1DATA(PORT_B_WR_DATA),
		.B1EN(PORT_B_WR_EN),
		.B1BE(PORT_B_WR_BE),
		.CLK1(PORT_A_CLK),

		.C1ADDR(PORT_C_ADDR),
		.C1DATA(PORT_C_RD_DATA),
		.C1EN(PORT_C_RD_EN),
		.D1ADDR(PORT_D_ADDR),
		.D1DATA(PORT_D_WR_DATA),
		.D1EN(PORT_D_WR_EN),
		.D1BE(PORT_D_WR_BE),
		.CLK2(PORT_C_CLK),

		.E1ADDR(),
		.E1DATA(),
		.E1EN(),
		.F1ADDR(),
		.F1DATA(),
		.F1EN(),
		.CLK3(),

		.G1ADDR(),
		.G1DATA(),
		.G1EN(),
		.H1ADDR(),
		.H1DATA(),
		.H1EN(),
		.CLK4()
	);
endmodule

module \$__RS_FACTOR_BRAM18_SDP (...);
	//parameter WIDTH = 1; 
    parameter PORT_B_WR_BE_WIDTH = 1;
	parameter PORT_A_WIDTH=1;
	parameter PORT_B_WIDTH=1;

    parameter [18431:0] INIT = 18432'bx;

    localparam CLKPOL2 = 1;
	localparam CLKPOL3 = 1;
    localparam ABITS = 14;

    input PORT_A_CLK;
	input PORT_B_CLK;

	input [ABITS-1:0] PORT_A_ADDR;
	output [PORT_A_WIDTH-1:0] PORT_A_RD_DATA;
	input PORT_A_RD_EN;

	input [ABITS-1:0] PORT_B_ADDR;
	input [PORT_B_WIDTH-1:0] PORT_B_WR_DATA;
	input PORT_B_WR_EN;
	input [PORT_B_WR_BE_WIDTH-1:0] PORT_B_WR_BE;

	BRAM2x18_SDP #(
		.CFG_DBITS(),
		.PORT_A_WIDTH(PORT_A_WIDTH),
		.PORT_B_WIDTH(PORT_B_WIDTH),
		.CFG_ENABLE_B(PORT_B_WR_BE_WIDTH),
		.CLKPOL2(CLKPOL2),
		.CLKPOL3(CLKPOL3),
		.INIT0(INIT)
	) _TECHMAP_REPLACE_ (
		.A1ADDR(PORT_A_ADDR),
		.A1DATA(PORT_A_RD_DATA),
		.A1EN(PORT_A_RD_EN),
		.CLK1(PORT_A_CLK),

		.B1ADDR(PORT_B_ADDR),
		.B1DATA(PORT_B_WR_DATA),
		.B1EN(PORT_B_WR_EN),
		.B1BE(PORT_B_WR_BE),
		.CLK2(PORT_B_CLK)
	);
endmodule

module \$__RS_FACTOR_BRAM36_SDP (...);
	//parameter WIDTH = 1;
	parameter PORT_B_WIDTH=1;
	parameter PORT_A_WIDTH=1;
	parameter PORT_B_WR_BE_WIDTH = 1;

	parameter [36863:0] INIT = 36864'bx;
	
    localparam ABITS = 15;
	localparam CFG_ENABLE = 4;

	input PORT_A_CLK;
	input PORT_B_CLK;

	input [ABITS-1:0] PORT_A_ADDR;
	output [PORT_A_WIDTH-1:0] PORT_A_RD_DATA;
	input PORT_A_RD_EN;

	input [ABITS-1:0] PORT_B_ADDR;
	input [PORT_B_WIDTH-1:0] PORT_B_WR_DATA;
	input PORT_B_WR_EN;
	input [PORT_B_WR_BE_WIDTH-1:0] PORT_B_WR_BE;

	wire [35:0] DOBDO;
	wire [35:PORT_A_WIDTH] A1DATA_CMPL;
	wire [35:PORT_B_WIDTH] B1DATA_CMPL;
	wire [35:0] A1DATA_TOTAL;
	wire [35:0] B1DATA_TOTAL;

	wire FLUSH1;
	wire FLUSH2;

	wire [CFG_ENABLE-1:PORT_B_WR_BE_WIDTH] B1EN_CMPL = {CFG_ENABLE-PORT_B_WR_BE_WIDTH{1'b0}};
	wire [CFG_ENABLE-1:0] B1EN = {B1EN_CMPL, PORT_B_WR_BE};

	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16
	case (PORT_A_WIDTH)
		9: begin
			assign PORT_A_RD_DATA = {A1DATA_TOTAL[16], A1DATA_TOTAL[7:0]};
	
		end
		default: begin
			assign PORT_A_RD_DATA = A1DATA_TOTAL[PORT_A_WIDTH-1:0];
			
		end
	endcase
	case (PORT_B_WIDTH)
	9: begin
		
		assign B1DATA_TOTAL = {B1DATA_CMPL[35:17], PORT_B_WR_DATA[8], B1DATA_CMPL[16:9], PORT_B_WR_DATA[7:0]};
	end
	default: begin
		
		assign B1DATA_TOTAL = {B1DATA_CMPL, PORT_B_WR_DATA};
	end
endcase

	case (PORT_B_WIDTH)
		1: begin
			case (PORT_A_WIDTH)
			1: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_1, `MODE_1, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_1, `MODE_1, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end

			2: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_2, `MODE_2, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_2, `MODE_2, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end

			4: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_4, `MODE_4, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_4, `MODE_4, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end

			8, 9: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_9, `MODE_9, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_9, `MODE_9, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end

			16, 18: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_18, `MODE_18, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_18, `MODE_18, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end

			32, 36: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_36, `MODE_36, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end
			default: begin
				defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_1, `MODE_1, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_36, `MODE_36, `MODE_1, `MODE_1, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
			end
			endcase
		end

	2: begin
		case (PORT_A_WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_1, `MODE_1, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_1, `MODE_1, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_2, `MODE_2, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_2, `MODE_2, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_4, `MODE_4, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_4, `MODE_4, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_9, `MODE_9, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_9, `MODE_9, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_18, `MODE_18, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_18, `MODE_18, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_36, `MODE_36, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_2, `MODE_2, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_36, `MODE_36, `MODE_2, `MODE_2, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end
	endcase

	end

	4: begin
		case (PORT_A_WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_1, `MODE_1, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_1, `MODE_1, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_2, `MODE_2, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_2, `MODE_2, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_4, `MODE_4, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_4, `MODE_4, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_9, `MODE_9, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_9, `MODE_9, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_18, `MODE_18, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_18, `MODE_18, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_36, `MODE_36, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_36, `MODE_36, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_4, `MODE_4, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_4, `MODE_4, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
	endcase

	end

	8, 9: begin
		case (PORT_A_WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
				`MODE_1, `MODE_1, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
				`MODE_1, `MODE_1, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
			};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_2, `MODE_2, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_2, `MODE_2, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_4, `MODE_4, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_4, `MODE_4, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_9, `MODE_9, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_9, `MODE_9, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_18, `MODE_18, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_18, `MODE_18, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_9, `MODE_9, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_9, `MODE_9, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
	endcase

	end

	16, 18: begin
		case (PORT_A_WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_1, `MODE_1, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_1, `MODE_1, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_2, `MODE_2, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_2, `MODE_2, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_4, `MODE_4, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_4, `MODE_4, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_9, `MODE_9, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_9, `MODE_9, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_18, `MODE_18, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_18, `MODE_18, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_18, `MODE_18, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_18, `MODE_18, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
	endcase

	end

	32, 36: begin
		case (PORT_A_WIDTH)
		1: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_1, `MODE_1, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_1, `MODE_1, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		2: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_2, `MODE_2, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_2, `MODE_2, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		4: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_4, `MODE_4, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_4, `MODE_4, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		8, 9: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_9, `MODE_9, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_9, `MODE_9, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		16, 18: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_18, `MODE_18, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_18, `MODE_18, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end

		32, 36: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
		default: begin
			defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
			`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
			`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
		};
		end
	endcase

	end
	default: begin
		defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
		`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0, //(A1R,B1R,A1W,B1W)
		`MODE_36, `MODE_36, `MODE_36, `MODE_36, 4'd0, 11'b01010000000, 11'b01010000000, 1'b0
	};
	end
endcase
	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;

	TDP36K #(
        .INIT_i(INIT)
         ) _TECHMAP_REPLACE_ (
		.RESET_ni(1'b1),
		.WDATA_A1_i(18'h3FFFF),
		.WDATA_A2_i(18'h3FFFF),
		.RDATA_A1_o(A1DATA_TOTAL[17:0]),
		.RDATA_A2_o(A1DATA_TOTAL[35:18]),
		.ADDR_A1_i(PORT_A_ADDR),
		.ADDR_A2_i(PORT_A_ADDR),
		.CLK_A1_i(PORT_A_CLK),
		.CLK_A2_i(PORT_A_CLK),
		.REN_A1_i(PORT_A_RD_EN),
		.REN_A2_i(PORT_A_RD_EN),
		.WEN_A1_i(1'b0),
		.WEN_A2_i(1'b0),
		.BE_A1_i(2'b0),
		.BE_A2_i(2'b0),

		.WDATA_B1_i(B1DATA_TOTAL[17:0]),
		.WDATA_B2_i(B1DATA_TOTAL[35:18]),
		.RDATA_B1_o(DOBDO[17:0]),
		.RDATA_B2_o(DOBDO[35:18]),
		.ADDR_B1_i(PORT_B_ADDR),
		.ADDR_B2_i(PORT_B_ADDR),
		.CLK_B1_i(PORT_B_CLK),
		.CLK_B2_i(PORT_B_CLK),
		.REN_B1_i(1'b0),
		.REN_B2_i(1'b0),
		.WEN_B1_i(PORT_B_WR_EN),
		.WEN_B2_i(PORT_B_WR_EN),
		.BE_B1_i(B1EN[1:0]),
		.BE_B2_i(B1EN[3:2]),

		.FLUSH1_i(FLUSH1),
		.FLUSH2_i(FLUSH2)
	);
endmodule
