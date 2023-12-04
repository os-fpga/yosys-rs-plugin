// Copyright (C) 2022 RapidSilicon
//
// In Genesis3, parameters MODE_BITS vectors have been reversed
// in order to match big endian behavior used by the fabric
// primitives DSP/BRAM (CASTORIP-121)

`define MODE_36 3'b110	// 36 or 32-bit
`define MODE_18 3'b010	// 18 or 16-bit
`define MODE_9  3'b100	// 9 or 8-bit
`define MODE_4  3'b001	// 4-bit
`define MODE_2  3'b011	// 32-bit
`define MODE_1  3'b101	// 32-bit

module BRAM2x18_TDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, B1BE, C1ADDR, C1DATA, C1EN, CLK1, CLK2, CLK3, CLK4, D1ADDR, D1DATA, D1EN, D1BE, E1ADDR, E1DATA, E1EN, F1ADDR, F1DATA, F1EN, F1BE, G1ADDR, G1DATA, G1EN, H1ADDR, H1DATA, H1EN, H1BE);
	parameter CFG_DBITS = 18;
	
    parameter PORT_A_DATA_WIDTH = 1;
    parameter PORT_B_DATA_WIDTH = 1;

    parameter PORT_C_DATA_WIDTH = 1;
    parameter PORT_D_DATA_WIDTH = 1;

    parameter PORT_E_DATA_WIDTH = 1;
    parameter PORT_F_DATA_WIDTH = 1;

    parameter PORT_G_DATA_WIDTH = 1;
    parameter PORT_H_DATA_WIDTH = 1;

    parameter PORT_B_DATA_WIDTH = 1;
    parameter PORT_A_DATA_WIDTH = 1;

    parameter PORT_A_WIDTH = 1;
    parameter PORT_B_WIDTH = 1;

    parameter PORT_C_WIDTH = 1;
    parameter PORT_D_WIDTH = 1;

    parameter PORT_E_WIDTH = 1;
    parameter PORT_F_WIDTH = 1;

    parameter PORT_G_WIDTH = 1;
    parameter PORT_H_WIDTH = 1;

    parameter CFG_ENABLE_B = 2;
	parameter CFG_ENABLE_D = 2;
	parameter CFG_ENABLE_F = 2;
	parameter CFG_ENABLE_H = 2;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [18431:0] INIT0 = 18432'b0;   // Komal: Initialize invalid bits of memory to zero as per EDA-1635
	parameter [18431:0] INIT1 = 18432'b0;   // Komal: Initialize invalid bits of memory to zero as per EDA-1635

	localparam CFG_ABITS = 14;    

    localparam [2:0]PORT_A_MODE = (PORT_A_WIDTH == 1)?`MODE_1:(PORT_A_WIDTH == 2)?`MODE_2:(PORT_A_WIDTH == 4)?`MODE_4:(PORT_A_WIDTH ==8)?`MODE_9:(PORT_A_WIDTH ==9)?`MODE_9:(PORT_A_WIDTH ==16)?`MODE_18:(PORT_A_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_B_MODE = (PORT_B_WIDTH == 1)?`MODE_1:(PORT_B_WIDTH == 2)?`MODE_2:(PORT_B_WIDTH == 4)?`MODE_4:(PORT_B_WIDTH ==8)?`MODE_9:(PORT_B_WIDTH ==9)?`MODE_9:(PORT_B_WIDTH ==16)?`MODE_18:(PORT_B_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_C_MODE = (PORT_C_WIDTH == 1)?`MODE_1:(PORT_C_WIDTH == 2)?`MODE_2:(PORT_C_WIDTH == 4)?`MODE_4:(PORT_C_WIDTH ==8)?`MODE_9:(PORT_C_WIDTH ==9)?`MODE_9:(PORT_C_WIDTH ==16)?`MODE_18:(PORT_C_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_D_MODE = (PORT_D_WIDTH == 1)?`MODE_1:(PORT_D_WIDTH == 2)?`MODE_2:(PORT_D_WIDTH == 4)?`MODE_4:(PORT_D_WIDTH ==8)?`MODE_9:(PORT_D_WIDTH ==9)?`MODE_9:(PORT_D_WIDTH ==16)?`MODE_18:(PORT_D_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_E_MODE = (PORT_E_WIDTH == 1)?`MODE_1:(PORT_E_WIDTH == 2)?`MODE_2:(PORT_E_WIDTH == 4)?`MODE_4:(PORT_E_WIDTH ==8)?`MODE_9:(PORT_E_WIDTH ==9)?`MODE_9:(PORT_E_WIDTH ==16)?`MODE_18:(PORT_E_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_F_MODE = (PORT_F_WIDTH == 1)?`MODE_1:(PORT_F_WIDTH == 2)?`MODE_2:(PORT_F_WIDTH == 4)?`MODE_4:(PORT_F_WIDTH ==8)?`MODE_9:(PORT_F_WIDTH ==9)?`MODE_9:(PORT_F_WIDTH ==16)?`MODE_18:(PORT_F_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_G_MODE = (PORT_G_WIDTH == 1)?`MODE_1:(PORT_G_WIDTH == 2)?`MODE_2:(PORT_G_WIDTH == 4)?`MODE_4:(PORT_G_WIDTH ==8)?`MODE_9:(PORT_G_WIDTH ==9)?`MODE_9:(PORT_G_WIDTH ==16)?`MODE_18:(PORT_G_WIDTH ==18)?`MODE_18:`MODE_36;
    localparam [2:0]PORT_H_MODE = (PORT_H_WIDTH == 1)?`MODE_1:(PORT_H_WIDTH == 2)?`MODE_2:(PORT_H_WIDTH == 4)?`MODE_4:(PORT_H_WIDTH ==8)?`MODE_9:(PORT_H_WIDTH ==9)?`MODE_9:(PORT_H_WIDTH ==16)?`MODE_18:(PORT_H_WIDTH ==18)?`MODE_18:`MODE_36;


	input CLK1;
	input CLK2;
	input CLK3;
	input CLK4;

	input [CFG_ABITS-1:0] A1ADDR;
	output [PORT_A_WIDTH-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [PORT_B_WIDTH-1:0] B1DATA;
	input B1EN;
	input [CFG_ENABLE_B-1:0] B1BE;

	input [CFG_ABITS-1:0] C1ADDR;
	output [PORT_C_WIDTH-1:0] C1DATA;
	input C1EN;

	input [CFG_ABITS-1:0] D1ADDR;
	input [PORT_D_WIDTH-1:0] D1DATA;
	input D1EN;
	input [CFG_ENABLE_D-1:0] D1BE;

	input [CFG_ABITS-1:0] E1ADDR;
	output [PORT_E_WIDTH-1:0] E1DATA;
	input E1EN;

	input [CFG_ABITS-1:0] F1ADDR;
	input [PORT_F_WIDTH-1:0] F1DATA;
	input F1EN;
	input [CFG_ENABLE_F-1:0] F1BE;

	input [CFG_ABITS-1:0] G1ADDR;
	output [PORT_G_WIDTH-1:0] G1DATA;
	input G1EN;

	input [CFG_ABITS-1:0] H1ADDR;
	input [PORT_H_WIDTH-1:0] H1DATA;
	input H1EN;
	input [CFG_ENABLE_H-1:0] H1BE;

	wire FLUSH1;
	wire FLUSH2;

	wire [14:CFG_ABITS] A1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] B1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] C1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] D1ADDR_CMPL = {15-CFG_ABITS{1'b0}};

	wire [14:0] A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
	wire [14:0] B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};
	wire [14:0] C1ADDR_TOTAL = {C1ADDR_CMPL, C1ADDR};
	wire [14:0] D1ADDR_TOTAL = {D1ADDR_CMPL, D1ADDR};

	wire [17:PORT_A_WIDTH] A1_RDATA_CMPL;
	wire [17:PORT_C_WIDTH] C1_RDATA_CMPL;
	wire [17:PORT_E_WIDTH] E1_RDATA_CMPL;
	wire [17:PORT_G_WIDTH] G1_RDATA_CMPL;

	wire [17:PORT_B_WIDTH] B1_WDATA_CMPL;
	wire [17:PORT_D_WIDTH] D1_WDATA_CMPL;
	wire [17:PORT_F_WIDTH] F1_WDATA_CMPL;
	wire [17:PORT_H_WIDTH] H1_WDATA_CMPL;

	wire [14:0] PORT_A1_ADDR;
	wire [13:0] PORT_A2_ADDR;
	wire [14:0] PORT_B1_ADDR;
	wire [13:0] PORT_B2_ADDR;

	assign PORT_A1_ADDR = A1EN ? (A1ADDR_TOTAL) : (B1EN ? (B1ADDR_TOTAL) : 15'd0);
	assign PORT_B1_ADDR = C1EN ? (C1ADDR_TOTAL) : (D1EN ? (D1ADDR_TOTAL) : 15'd0);
	assign PORT_A2_ADDR = E1EN ? (E1ADDR) : (F1EN ? (F1ADDR) : 14'd0);
	assign PORT_B2_ADDR = G1EN ? (G1ADDR) : (H1EN ? (H1ADDR) : 14'd0);


	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;

	wire [17:0] PORT_A1_RDATA;
	wire [17:0] PORT_B1_RDATA;
	wire [17:0] PORT_A2_RDATA;
	wire [17:0] PORT_B2_RDATA;

	wire [17:0] PORT_A1_WDATA;
	wire [17:0] PORT_B1_WDATA;
	wire [17:0] PORT_A2_WDATA;
	wire [17:0] PORT_B2_WDATA;



   /* defparam _TECHMAP_REPLACE_.MODE_BITS = { 1'd0,
    PORT_A_MODE, PORT_C_MODE, PORT_B_MODE, PORT_D_MODE, 4'd0, 12'b010100000000, 12'b010100000000, 1'd0,//(A1R,B1R,A1W,B1W)
    PORT_E_MODE, PORT_G_MODE, PORT_F_MODE, PORT_H_MODE, 4'd0, 11'b01010000000, 11'b01010000000, 1'b1   //(A2R,B2R,A2W,B2W)
    };
    */
	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16


    //PORT A
    case (PORT_A_WIDTH)
    9: begin
        //assign A1DATA = {PORT_A1_RDATA[16], PORT_A1_RDATA[7:0]};
        case (PORT_A_DATA_WIDTH)
            9: assign A1DATA = {PORT_A1_RDATA[16], PORT_A1_RDATA[7:0]};
            default: assign A1DATA = PORT_A1_RDATA[CFG_DBITS-1:0];
        endcase
    end
    18: begin
        //assign PORT_A1_RDATA = {A1DATA[17], A1DATA[8], A1DATA[16:9], A1DATA[7:0]};
        case (PORT_A_DATA_WIDTH)
            18: assign PORT_A1_RDATA = {A1DATA[17], A1DATA[8], A1DATA[16:9], A1DATA[7:0]};
            default: assign PORT_A1_RDATA = (PORT_A_DATA_WIDTH>18)?{A1DATA[17], A1DATA[8], A1DATA[16:9], A1DATA[7:0]}:A1DATA[CFG_DBITS-1:0];
        endcase
    end
    default: begin
        assign A1DATA = PORT_A1_RDATA[CFG_DBITS-1:0];
    end
endcase

    //PORT B
    case (PORT_B_WIDTH)
    9: begin
        //assign PORT_A1_WDATA = {B1_WDATA_CMPL[17], B1DATA[8], B1_WDATA_CMPL[16:9], B1DATA[7:0]};
        case (PORT_B_DATA_WIDTH)
           9 : assign PORT_A1_WDATA = {B1_WDATA_CMPL[17], B1DATA[8], B1_WDATA_CMPL[16:9], B1DATA[7:0]};
            default: assign PORT_A1_WDATA = {B1_WDATA_CMPL, B1DATA};
        endcase
    end
    18: begin
        //assign PORT_A1_WDATA = {B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]};
        case (PORT_B_DATA_WIDTH)
            18: assign PORT_A1_WDATA = {B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]};
            default: assign PORT_A1_WDATA = (PORT_B_DATA_WIDTH>18)?{B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]}:{B1_WDATA_CMPL, B1DATA};
        endcase
    end
    default: begin
        assign PORT_A1_WDATA = {B1_WDATA_CMPL, B1DATA};
    end
endcase

    //PORT C
    case (PORT_C_WIDTH)
    9: begin
        //assign C1DATA = {PORT_B1_RDATA[16], PORT_B1_RDATA[7:0]};
        case (PORT_C_DATA_WIDTH)
           9 : assign C1DATA = {PORT_B1_RDATA[16], PORT_B1_RDATA[7:0]};
            default: assign C1DATA = PORT_B1_RDATA[CFG_DBITS-1:0];
        endcase
    end
    18: begin
        //assign PORT_B1_RDATA = {C1DATA[17], C1DATA[8], C1DATA[16:9], C1DATA[7:0]};
        case (PORT_C_DATA_WIDTH)
            18  : assign PORT_B1_RDATA = {C1DATA[17], C1DATA[8], C1DATA[16:9], C1DATA[7:0]};
            default: assign PORT_B1_RDATA =(PORT_C_DATA_WIDTH>18)? {C1DATA[17], C1DATA[8], C1DATA[16:9], C1DATA[7:0]}:C1DATA[CFG_DBITS-1:0];
        endcase
    end
    default: begin
        assign C1DATA = PORT_B1_RDATA[CFG_DBITS-1:0];
    end
endcase

    //PORT D
    case (PORT_D_WIDTH)
    9: begin
        //assign PORT_B1_WDATA = {D1_WDATA_CMPL[17], D1DATA[8], D1_WDATA_CMPL[16:9], D1DATA[7:0]};
        case (PORT_D_DATA_WIDTH)
           9 : assign PORT_B1_WDATA = {D1_WDATA_CMPL[17], D1DATA[8], D1_WDATA_CMPL[16:9], D1DATA[7:0]};
            default: assign PORT_B1_WDATA = {D1_WDATA_CMPL, D1DATA};
        endcase
    end
    18: begin
        //assign PORT_B1_WDATA = {D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]};
        case (PORT_D_DATA_WIDTH)
           18 : assign PORT_B1_WDATA = {D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]};
            default: assign PORT_B1_WDATA = (PORT_D_DATA_WIDTH>18)?{D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]}:{D1_WDATA_CMPL, D1DATA};
        endcase
    end
    default: begin
        assign PORT_B1_WDATA = {D1_WDATA_CMPL, D1DATA};
    end
endcase
    
    //PORT E
    case (PORT_E_WIDTH)
    9: begin
        //assign E1DATA = {PORT_A2_RDATA[16], PORT_A2_RDATA[7:0]};
        case (PORT_E_DATA_WIDTH)
           9 : assign E1DATA = {PORT_A2_RDATA[16], PORT_A2_RDATA[7:0]};
            default: assign E1DATA = PORT_A2_RDATA[CFG_DBITS-1:0];
        endcase
    end
    18: begin
        //assign PORT_A2_RDATA = {E1DATA[17], E1DATA[8], E1DATA[16:9], E1DATA[7:0]};
        case (PORT_E_DATA_WIDTH)
          18  : assign PORT_A2_RDATA = {E1DATA[17], E1DATA[8], E1DATA[16:9], E1DATA[7:0]};
            default: assign PORT_A2_RDATA = (PORT_E_DATA_WIDTH>18)?{E1DATA[17], E1DATA[8], E1DATA[16:9], E1DATA[7:0]}: E1DATA[CFG_DBITS-1:0];
        endcase
    end
    default: begin
        assign E1DATA = PORT_A2_RDATA[CFG_DBITS-1:0];
    end
endcase

    //PORT F
    case (PORT_F_WIDTH)
    9: begin
        //assign PORT_A2_WDATA = {F1_WDATA_CMPL[17], F1DATA[8], F1_WDATA_CMPL[16:9], F1DATA[7:0]};
        case (PORT_F_DATA_WIDTH)
           9 : assign PORT_A2_WDATA = {F1_WDATA_CMPL[17], F1DATA[8], F1_WDATA_CMPL[16:9], F1DATA[7:0]};
            default: assign PORT_A2_WDATA = {F1_WDATA_CMPL, F1DATA};
        endcase
    end
    18: begin
        //assign PORT_A2_WDATA = {F1DATA[17], F1DATA[8], F1DATA[16:9], F1DATA[7:0]};
        case (PORT_F_DATA_WIDTH)
           18 : assign PORT_A2_WDATA = {F1DATA[17], F1DATA[8], F1DATA[16:9], F1DATA[7:0]};
            default: assign PORT_A2_WDATA = (PORT_F_DATA_WIDTH>18)?{F1DATA[17], F1DATA[8], F1DATA[16:9], F1DATA[7:0]}:{F1_WDATA_CMPL, F1DATA};
        endcase
    end
    default: begin
        assign PORT_A2_WDATA = {F1_WDATA_CMPL, F1DATA};
    end
endcase

    //PORT G
    case (PORT_G_WIDTH)
    9: begin
        //assign G1DATA = {PORT_B2_RDATA[16], PORT_B2_RDATA[7:0]};
        case (PORT_G_DATA_WIDTH)
            9: assign G1DATA = {PORT_B2_RDATA[16], PORT_B2_RDATA[7:0]};
            default:  assign G1DATA = PORT_B2_RDATA[CFG_DBITS-1:0];
        endcase
    end
    18: begin
        //assign PORT_B2_RDATA = {G1DATA[17], G1DATA[8], G1DATA[16:9], G1DATA[7:0]};
        case (PORT_G_DATA_WIDTH)
           18 : assign PORT_B2_RDATA = {G1DATA[17], G1DATA[8], G1DATA[16:9], G1DATA[7:0]};
            default: assign PORT_B2_RDATA = (PORT_G_DATA_WIDTH>18)?{G1DATA[17], G1DATA[8], G1DATA[16:9], G1DATA[7:0]}:G1DATA[CFG_DBITS-1:0];
        endcase
    end
    default: begin
        assign G1DATA = PORT_B2_RDATA[CFG_DBITS-1:0];
    end
endcase
    
    //PORT H
    case (PORT_H_WIDTH)
    9: begin
        //assign PORT_B2_WDATA = {H1_WDATA_CMPL[17], H1DATA[8], H1_WDATA_CMPL[16:9], H1DATA[7:0]};
        case (PORT_H_DATA_WIDTH)
           9: assign PORT_B2_WDATA = {H1_WDATA_CMPL[17], H1DATA[8], H1_WDATA_CMPL[16:9], H1DATA[7:0]};
            default: assign PORT_B2_WDATA = {H1_WDATA_CMPL, H1DATA};
        endcase
    end
    18: begin
        //assign PORT_B2_WDATA = {H1DATA[17], H1DATA[8], H1DATA[16:9], H1DATA[7:0]};
        case (PORT_H_DATA_WIDTH)
          18: assign PORT_B2_WDATA = {H1DATA[17], H1DATA[8], H1DATA[16:9], H1DATA[7:0]};
          default: assign PORT_B2_WDATA = (PORT_H_DATA_WIDTH>18)?{H1DATA[17], H1DATA[8], H1DATA[16:9], H1DATA[7:0]}:{H1_WDATA_CMPL, H1DATA};
        endcase
    end
    default: begin
        assign PORT_B2_WDATA = {H1_WDATA_CMPL, H1DATA};
    end
endcase

	wire PORT_A1_CLK = CLK1;
	wire PORT_A2_CLK = CLK3;
	wire PORT_B1_CLK = CLK2;
	wire PORT_B2_CLK = CLK4;

	wire PORT_A1_REN = A1EN;
	wire PORT_A1_WEN = B1EN;
	wire [CFG_ENABLE_B-1:0] PORT_A1_BE = B1BE;

	wire PORT_A2_REN = E1EN;
	wire PORT_A2_WEN = F1EN;
	wire [CFG_ENABLE_F-1:0] PORT_A2_BE = F1BE;

	wire PORT_B1_REN = C1EN;
	wire PORT_B1_WEN = D1EN;
	wire [CFG_ENABLE_D-1:0] PORT_B1_BE = D1BE;

	wire PORT_B2_REN = G1EN;
	wire PORT_B2_WEN = H1EN;
	wire [CFG_ENABLE_H-1:0] PORT_B2_BE = H1BE;

TDP_RAM18KX2 #(
        .INIT1 (INIT0[0*18432+:18432]), // Initial Contents of data memory, RAM 1
        .INIT1_PARITY ({2048{1'b0}}), // Initial Contents of parity memory, RAM 1
        .WRITE_WIDTH_A1 (PORT_B_WIDTH), // Write data width on port A, RAM 1 (1-18)
        .WRITE_WIDTH_B1 (PORT_D_WIDTH), // Write data width on port B, RAM 1 (1-18)
        .READ_WIDTH_A1 (PORT_A_WIDTH), // Read data width on port A, RAM 1 (1-18)
        .READ_WIDTH_B1 (PORT_C_WIDTH), // Read data width on port B, RAM     .
        .INIT2 (INIT1[0*18432+:18432]), // Initial Contents of memory, RAM 2
        .INIT2_PARITY  ({2048{1'b0}}), // Initial Contents of memory, RAM 2
        .WRITE_WIDTH_A2 (PORT_F_WIDTH), // Write data width on port A, RAM 2 (1-18)
        .WRITE_WIDTH_B2 (PORT_H_WIDTH), // Write data width on port B, RAM 2 (1-18)
        .READ_WIDTH_A2 (PORT_E_WIDTH), // Read data width on port A, RAM 2 (1-18)
        .READ_WIDTH_B2 (PORT_G_WIDTH) // Read data width on port B, RAM 2 (1-18)
    ) _TECHMAP_REPLACE_(

   .WEN_A1(PORT_A1_WEN),
   .WEN_B1(PORT_B1_WEN),
   .REN_A1(PORT_A1_REN),
   .REN_B1(PORT_B1_REN),
   .CLK_A1(PORT_A1_CLK),
   .CLK_B1(PORT_B1_CLK),
   .BE_A1(PORT_A1_BE),
   .BE_B1(PORT_B1_BE),
   .ADDR_A1(PORT_A1_ADDR),
   .ADDR_B1(PORT_B1_ADDR),
   .WDATA_A1(PORT_A1_WDATA[15:0]),
   .WPARITY_A1(PORT_A1_WDATA[17:16]),
   .WDATA_B1(PORT_B1_WDATA[15:0]),
   .WPARITY_B1(PORT_B1_WDATA[17:16]),
   .RDATA_A1(PORT_A1_RDATA[15:0]),
   .RPARITY_A1(PORT_A1_RDATA[17:16]),
   .RDATA_B1(PORT_B1_RDATA[15:0]),
   .RPARITY_B1(PORT_B1_RDATA[17:16]),

   .WEN_A2(PORT_A2_WEN),
   .WEN_B2(PORT_B2_WEN),
   .REN_A2(PORT_A2_REN),
   .REN_B2(PORT_B2_REN),
   .CLK_A2(PORT_A2_CLK),
   .CLK_B2(PORT_B2_CLK),
   .BE_A2(PORT_A2_BE),
   .BE_B2(PORT_B2_BE),
   .ADDR_A2(PORT_A2_ADDR),
   .ADDR_B2(PORT_B2_ADDR),
   .WDATA_A2(PORT_A2_WDATA[15:0]),
   .WPARITY_A2(PORT_A2_WDATA[17:16]),
   .WDATA_B2(PORT_B2_WDATA[15:0]),
   .WPARITY_B2(PORT_B2_WDATA[17:16]),
   .RDATA_A2(PORT_A2_RDATA[15:0]),
   .RPARITY_A2(PORT_A2_RDATA[17:16]),
   .RDATA_B2(PORT_B2_RDATA[15:0]),
   .RPARITY_B2(PORT_B2_RDATA[17:16])
);
	/*RS_TDP36K #(
		.INIT_i({INIT1[0*18432+:18432],INIT0[0*18432+:18432]})
	)_TECHMAP_REPLACE_(
		.WDATA_A1(PORT_A1_WDATA),
		.RDATA_A1(PORT_A1_RDATA),
		.ADDR_A1(PORT_A1_ADDR),
		.CLK_A1(PORT_A1_CLK),
		.REN_A1(PORT_A1_REN),
		.WEN_A1(PORT_A1_WEN),
		.BE_A1(PORT_A1_BE),

		.WDATA_A2(PORT_A2_WDATA),
		.RDATA_A2(PORT_A2_RDATA),
		.ADDR_A2(PORT_A2_ADDR),
		.CLK_A2(PORT_A2_CLK),
		.REN_A2(PORT_A2_REN),
		.WEN_A2(PORT_A2_WEN),
		.BE_A2(PORT_A2_BE),

		.WDATA_B1(PORT_B1_WDATA),
		.RDATA_B1(PORT_B1_RDATA),
		.ADDR_B1(PORT_B1_ADDR),
		.CLK_B1(PORT_B1_CLK),
		.REN_B1(PORT_B1_REN),
		.WEN_B1(PORT_B1_WEN),
		.BE_B1(PORT_B1_BE),

		.WDATA_B2(PORT_B2_WDATA),
		.RDATA_B2(PORT_B2_RDATA),
		.ADDR_B2(PORT_B2_ADDR),
		.CLK_B2(PORT_B2_CLK),
		.REN_B2(PORT_B2_REN),
		.WEN_B2(PORT_B2_WEN),
		.BE_B2(PORT_B2_BE),

		.FLUSH1(FLUSH1),
		.FLUSH2(FLUSH2)
	);*/

endmodule

module BRAM2x18_SDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, B1BE, C1ADDR, C1DATA, C1EN, CLK1, CLK2, CLK3, CLK4, D1ADDR, D1DATA, D1EN, D1BE);
	parameter CFG_DBITS = 18;
	parameter CFG_ENABLE_B = 2;
	parameter CFG_ENABLE_D = 2;

	parameter PORT_A_WIDTH=1;
	parameter PORT_B_WIDTH=1;

	parameter PORT_C_WIDTH=1;
	parameter PORT_D_WIDTH=1;

    parameter PORT_A_DATA_WIDTH=1;
	parameter PORT_B_DATA_WIDTH=1;

	parameter PORT_C_DATA_WIDTH=1;
	parameter PORT_D_DATA_WIDTH=1;

	parameter CLKPOL2 = 1;
	parameter CLKPOL3 = 1;
	parameter [18431:0] INIT0 = 18432'b0;   // Komal: Initialize invalid bits of memory to zero as per EDA-1635
	parameter [18431:0] INIT1 = 18432'b0;   // Komal: Initialize invalid bits of memory to zero as per EDA-1635
	
	localparam CFG_ABITS = 14;

	input CLK1;
	input CLK2;
	input CLK3;
	input CLK4;

	input [CFG_ABITS-1:0] A1ADDR;
	output [PORT_A_WIDTH-1:0] A1DATA;
	input A1EN;

	input [CFG_ABITS-1:0] B1ADDR;
	input [PORT_B_WIDTH-1:0] B1DATA;
	input B1EN;
	input [CFG_ENABLE_B-1:0] B1BE;

	input [CFG_ABITS-1:0] C1ADDR;
	output [PORT_C_WIDTH-1:0] C1DATA;
	input C1EN;

	input [CFG_ABITS-1:0] D1ADDR;
	input [PORT_D_WIDTH-1:0] D1DATA;
	input D1EN;
	input [CFG_ENABLE_D-1:0] D1BE;

	wire FLUSH1;
	wire FLUSH2;

	wire [14:CFG_ABITS] A1ADDR_CMPL = {15-CFG_ABITS{1'b0}};
	wire [14:CFG_ABITS] B1ADDR_CMPL = {15-CFG_ABITS{1'b0}};

	wire [14:0] A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
	wire [14:0] B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};

	wire [17:PORT_A_WIDTH] A1_RDATA_CMPL;
	wire [17:PORT_C_WIDTH] C1_RDATA_CMPL;

	wire [17:PORT_B_WIDTH] B1_WDATA_CMPL;
	wire [17:PORT_D_WIDTH] D1_WDATA_CMPL;

	wire [14:0] PORT_A1_ADDR;
	wire [13:0] PORT_A2_ADDR;
	wire [14:0] PORT_B1_ADDR;
	wire [13:0] PORT_B2_ADDR;

	assign PORT_A1_ADDR = A1ADDR_TOTAL;
	assign PORT_B1_ADDR = B1ADDR_TOTAL;
	assign PORT_A2_ADDR = C1ADDR;
	assign PORT_B2_ADDR = D1ADDR;
    // Assign Mode Bits for each port 

	assign FLUSH1 = 1'b0;
	assign FLUSH2 = 1'b0;

	wire [17:0] PORT_A1_RDATA;
	wire [17:0] PORT_B1_RDATA;
	wire [17:0] PORT_A2_RDATA;
	wire [17:0] PORT_B2_RDATA;

	wire [17:0] PORT_A1_WDATA;
	wire [17:0] PORT_B1_WDATA;
	wire [17:0] PORT_A2_WDATA;
	wire [17:0] PORT_B2_WDATA;

	// Assign read/write data - handle special case for 9bit mode
	// parity bit for 9bit mode is placed in R/W port on bit #16
	//Port B

	case (PORT_B_WIDTH)
		9: begin
			//assign PORT_B1_WDATA = {B1_WDATA_CMPL[17], B1DATA[8], B1_WDATA_CMPL[16:9], B1DATA[7:0]};
            case (PORT_B_DATA_WIDTH)
               9: assign PORT_B1_WDATA = {B1_WDATA_CMPL[17], B1DATA[8], B1_WDATA_CMPL[16:9], B1DATA[7:0]};
                default: assign PORT_B1_WDATA = {B1_WDATA_CMPL, B1DATA};
            endcase
		end
        18: begin
			//assign PORT_B1_WDATA = {B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]};
            case (PORT_B_DATA_WIDTH)
                18:begin 
                    assign PORT_B1_WDATA = {B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]};
                end
                default:begin
                    assign PORT_B1_WDATA = {B1_WDATA_CMPL, B1DATA};//:{B1DATA[17], B1DATA[8], B1DATA[16:9], B1DATA[7:0]};
                    end
            endcase
		end
		default: begin
			assign PORT_B1_WDATA = {B1_WDATA_CMPL, B1DATA};
		end
	endcase
	// Port A
	case (PORT_A_WIDTH)
	9: begin
		//assign A1DATA = {PORT_A1_RDATA[16], PORT_A1_RDATA[7:0]};
		assign PORT_A1_WDATA = {18{1'bx}};
        case (PORT_A_DATA_WIDTH)
            9: assign A1DATA = {PORT_A1_RDATA[16], PORT_A1_RDATA[7:0]};
            default: assign A1DATA = PORT_A1_RDATA[PORT_A_WIDTH-1:0];
        endcase
        
	end
    18: begin
		//assign PORT_A1_RDATA = {A1DATA[17],A1DATA[8],A1DATA[16:9], A1DATA[7:0]};
		assign PORT_A1_WDATA = {18{1'bx}};
        case (PORT_A_DATA_WIDTH)
            18: begin assign PORT_A1_RDATA = {A1DATA[17],A1DATA[8],A1DATA[16:9], A1DATA[7:0]};end
            default: begin 
                assign PORT_A1_RDATA = A1DATA[PORT_A_WIDTH-1:0];//:{A1DATA[17],A1DATA[8],A1DATA[16:9], A1DATA[7:0]}; 
            end
        endcase
	end
	default: begin
		assign A1DATA = PORT_A1_RDATA[PORT_A_WIDTH-1:0];
		assign PORT_A1_WDATA = {18{1'bx}};

	end
    endcase

	case (PORT_C_WIDTH)
		9: begin
			//assign C1DATA = {PORT_A2_RDATA[16], PORT_A2_RDATA[7:0]};
			assign PORT_A2_WDATA = {18{1'bx}};
            case (PORT_C_DATA_WIDTH)
                9: assign C1DATA = {PORT_A2_RDATA[16], PORT_A2_RDATA[7:0]};
                default: assign C1DATA = PORT_A2_RDATA[CFG_DBITS-1:0];
            endcase
		end
        18: begin
			//assign PORT_A2_RDATA = {C1DATA[17], C1DATA[8],C1DATA[16:9], C1DATA[7:0]};
			assign PORT_A2_WDATA = {18{1'bx}};
            case (PORT_C_DATA_WIDTH)
                18: assign PORT_A2_RDATA = {C1DATA[17], C1DATA[8],C1DATA[16:9], C1DATA[7:0]};
                default:begin 
                    assign PORT_A2_RDATA = C1DATA[CFG_DBITS-1:0];//:{C1DATA[17], C1DATA[8],C1DATA[16:9], C1DATA[7:0]};
                end
            endcase
		end
		default: begin
			assign C1DATA = PORT_A2_RDATA[CFG_DBITS-1:0];
			assign PORT_A2_WDATA = {18{1'bx}};
		end
	endcase
	// Port D
	case (PORT_D_WIDTH)
	9: begin
		//assign PORT_B2_WDATA = {D1_WDATA_CMPL[17], D1DATA[8], D1_WDATA_CMPL[16:9], D1DATA[7:0]};
        case (PORT_D_DATA_WIDTH)
            9: assign PORT_B2_WDATA = {D1_WDATA_CMPL[17], D1DATA[8], D1_WDATA_CMPL[16:9], D1DATA[7:0]};
            default: assign PORT_B2_WDATA = {D1_WDATA_CMPL, D1DATA};
        endcase
	end
    18: begin
		//assign PORT_B2_WDATA = {D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]};
        case (PORT_D_DATA_WIDTH)
            18: assign PORT_B2_WDATA = {D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]};
            default: begin 
                assign PORT_B2_WDATA = {D1_WDATA_CMPL, D1DATA};//:{D1DATA[17], D1DATA[8], D1DATA[16:9], D1DATA[7:0]};
            end
        endcase
	end
	default: begin
		assign PORT_B2_WDATA = {D1_WDATA_CMPL, D1DATA};

	end
    endcase

	wire PORT_A1_CLK = CLK1;
	wire PORT_A2_CLK = CLK3;
	wire PORT_B1_CLK = CLK2;
	wire PORT_B2_CLK = CLK4;

	wire PORT_A1_REN = A1EN;
	wire PORT_A1_WEN = 1'b0;
	wire [CFG_ENABLE_B-1:0] PORT_A1_BE = {PORT_A1_WEN,PORT_A1_WEN};

	wire PORT_A2_REN = C1EN;
	wire PORT_A2_WEN = 1'b0;
	wire [CFG_ENABLE_D-1:0] PORT_A2_BE = {PORT_A2_WEN,PORT_A2_WEN};

	wire PORT_B1_REN = 1'b0;
	wire PORT_B1_WEN = B1EN;
	wire [CFG_ENABLE_B-1:0] PORT_B1_BE = B1BE;

	wire PORT_B2_REN = 1'b0;
	wire PORT_B2_WEN = D1EN;
	wire [CFG_ENABLE_D-1:0] PORT_B2_BE = D1BE;

    TDP_RAM18KX2 #(
        .INIT1 (INIT0[0*18432+:18432]), // Initial Contents of data memory, RAM 1
        .INIT1_PARITY ({2048{1'b0}}), // Initial Contents of parity memory, RAM 1
        .WRITE_WIDTH_A1 (PORT_B_WIDTH), // Write data width on port A, RAM 1 (1-18)
        .WRITE_WIDTH_B1 (PORT_B_WIDTH), // Write data width on port B, RAM 1 (1-18)
        .READ_WIDTH_A1 (PORT_A_WIDTH), // Read data width on port A, RAM 1 (1-18)
        .READ_WIDTH_B1 (PORT_A_WIDTH), // Read data width on port B, RAM     .
        .INIT2 (INIT1[0*18432+:18432]), // Initial Contents of memory, RAM 2
        .INIT2_PARITY  ({2048{1'b0}}), // Initial Contents of memory, RAM 2
        .WRITE_WIDTH_A2 (PORT_D_WIDTH), // Write data width on port A, RAM 2 (1-18)
        .WRITE_WIDTH_B2 (PORT_D_WIDTH), // Write data width on port B, RAM 2 (1-18)
        .READ_WIDTH_A2 (PORT_C_WIDTH), // Read data width on port A, RAM 2 (1-18)
        .READ_WIDTH_B2 (PORT_C_WIDTH) // Read data width on port B, RAM 2 (1-18)
    ) _TECHMAP_REPLACE_(

   .WEN_A1(PORT_A1_WEN),
   .WEN_B1(PORT_B1_WEN),
   .REN_A1(PORT_A1_REN),
   .REN_B1(PORT_B1_REN),
   .CLK_A1(PORT_A1_CLK),
   .CLK_B1(PORT_B1_CLK),
   .BE_A1(PORT_A1_BE),
   .BE_B1(PORT_B1_BE),
   .ADDR_A1(PORT_A1_ADDR),
   .ADDR_B1(PORT_B1_ADDR),
   .WDATA_A1(PORT_A1_WDATA[15:0]), // Not used remains x
   .WPARITY_A1(PORT_A1_WDATA[17:16]),
   .WDATA_B1(PORT_B1_WDATA[15:0]),   // used as write port 1 
   .WPARITY_B1(PORT_B1_WDATA[17:16]),
   .RDATA_A1(PORT_A1_RDATA[15:0]),   // used as read port 1
   .RPARITY_A1(PORT_A1_RDATA[17:16]),
   .RDATA_B1(PORT_B1_RDATA[15:0]),
   .RPARITY_B1(PORT_B1_RDATA[17:16]),

   .WEN_A2(PORT_A2_WEN),
   .WEN_B2(PORT_B2_WEN),
   .REN_A2(PORT_A2_REN),
   .REN_B2(PORT_B2_REN),
   .CLK_A2(PORT_A2_CLK),
   .CLK_B2(PORT_B2_CLK),
   .BE_A2(PORT_A2_BE),
   .BE_B2(PORT_B2_BE),
   .ADDR_A2(PORT_A2_ADDR),
   .ADDR_B2(PORT_B2_ADDR),
   .WDATA_A2(PORT_A2_WDATA[15:0]), //Not used remains x
   .WPARITY_A2(PORT_A2_WDATA[17:16]),
   .WDATA_B2(PORT_B2_WDATA[15:0]), // used as write port 2
   .WPARITY_B2(PORT_B2_WDATA[17:16]),
   .RDATA_A2(PORT_A2_RDATA[15:0]), // used as write port 2
   .RPARITY_A2(PORT_A2_RDATA[17:16]),
   .RDATA_B2(PORT_B2_RDATA[15:0]),  
   .RPARITY_B2(PORT_B2_RDATA[17:16])
);
/*
	RS_TDP36K #(
		.INIT_i({INIT1[0*18432+:18432],INIT0[0*18432+:18432]})
	)_TECHMAP_REPLACE_(
		.WDATA_A1(PORT_A1_WDATA),
		.RDATA_A1(PORT_A1_RDATA),
		.ADDR_A1(PORT_A1_ADDR),
		.CLK_A1(PORT_A1_CLK),
		.REN_A1(PORT_A1_REN),
		.WEN_A1(PORT_A1_WEN),
		.BE_A1(PORT_A1_BE),

		.WDATA_A2(PORT_A2_WDATA),
		.RDATA_A2(PORT_A2_RDATA),
		.ADDR_A2(PORT_A2_ADDR),
		.CLK_A2(PORT_A2_CLK),
		.REN_A2(PORT_A2_REN),
		.WEN_A2(PORT_A2_WEN),
		.BE_A2(PORT_A2_BE),

		.WDATA_B1(PORT_B1_WDATA),
		.RDATA_B1(PORT_B1_RDATA),
		.ADDR_B1(PORT_B1_ADDR),
		.CLK_B1(PORT_B1_CLK),
		.REN_B1(PORT_B1_REN),
		.WEN_B1(PORT_B1_WEN),
		.BE_B1(PORT_B1_BE),

		.WDATA_B2(PORT_B2_WDATA),
		.RDATA_B2(PORT_B2_RDATA),
		.ADDR_B2(PORT_B2_ADDR),
		.CLK_B2(PORT_B2_CLK),
		.REN_B2(PORT_B2_REN),
		.WEN_B2(PORT_B2_WEN),
		.BE_B2(PORT_B2_BE),

		.FLUSH1(FLUSH1),
		.FLUSH2(FLUSH2)
	);*/
endmodule
