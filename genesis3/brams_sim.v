// Copyright (C) 2022 RapidSilicon
//11/11/2022
// In Genesis3, parameters MODE_BITS vectors have been reversed
// in order to match big endian behavior used by the fabric
// primitives DSP/BRAM (CASTORIP-121)

module TDP_BRAM18 (
    (* clkbuf_sink *)
    input wire CLOCKA,
    (* clkbuf_sink *)
    input wire CLOCKB,
    input wire READENABLEA,
    input wire READENABLEB,
    input wire [13:0] ADDRA,
    input wire [13:0] ADDRB,
    input wire [15:0] WRITEDATAA,
    input wire [15:0] WRITEDATAB,
    input wire [1:0] WRITEDATAAP,
    input wire [1:0] WRITEDATABP,
    input wire WRITEENABLEA,
    input wire WRITEENABLEB,
    input wire [1:0] BYTEENABLEA,
    input wire [1:0] BYTEENABLEB,
    //input [2:0] WRITEDATAWIDTHA,
    //input [2:0] WRITEDATAWIDTHB,
    //input [2:0] READDATAWIDTHA,
    //input [2:0] READDATAWIDTHB,
    output wire [15:0] READDATAA,
    output wire [15:0] READDATAB,
    output wire [1:0] READDATAAP,
    output wire [1:0] READDATABP
);
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter integer READ_WIDTH_A = 0;
    parameter integer READ_WIDTH_B = 0;
    parameter integer WRITE_WIDTH_A = 0;
    parameter integer WRITE_WIDTH_B = 0;

endmodule

module BRAM2x18_TDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, B1BE, C1ADDR, C1DATA, C1EN, CLK1, CLK2, CLK3, CLK4, D1ADDR, D1DATA, D1EN, D1BE, E1ADDR, E1DATA, E1EN, F1ADDR, F1DATA, F1EN, F1BE, G1ADDR, G1DATA, G1EN, H1ADDR, H1DATA, H1EN, H1BE);
    parameter CFG_ABITS = 11;
    parameter CFG_DBITS = 18;
    parameter CFG_ENABLE_B = 2;
    parameter CFG_ENABLE_D = 2;
    parameter CFG_ENABLE_F = 2;
    parameter CFG_ENABLE_H = 2;

    parameter CLKPOL2 = 1;
    parameter CLKPOL3 = 1;
    parameter [18431:0] INIT0 = 18432'bx;
    parameter [18431:0] INIT1 = 18432'bx;

    localparam MODE_36 = 3'b110;    // 36 or 32-bit
    localparam MODE_18 = 3'b010;    // 18 or 16-bit
    localparam MODE_9  = 3'b100;    // 9 or 8-bit
    localparam MODE_4  = 3'b001;    // 4-bit
    localparam MODE_2  = 3'b011;    // 32-bit
    localparam MODE_1  = 3'b101;    // 32-bit

    input CLK1;
    input CLK2;
    input CLK3;
    input CLK4;

    input [CFG_ABITS-1:0] A1ADDR;
    output [CFG_DBITS-1:0] A1DATA;
    input A1EN;

    input [CFG_ABITS-1:0] B1ADDR;
    input [CFG_DBITS-1:0] B1DATA;
    input B1EN;
    input [CFG_ENABLE_B-1:0] B1BE;

    input [CFG_ABITS-1:0] C1ADDR;
    output [CFG_DBITS-1:0] C1DATA;
    input C1EN;

    input [CFG_ABITS-1:0] D1ADDR;
    input [CFG_DBITS-1:0] D1DATA;
    input D1EN;
    input [CFG_ENABLE_D-1:0] D1BE;

    input [CFG_ABITS-1:0] E1ADDR;
    output [CFG_DBITS-1:0] E1DATA;
    input E1EN;

    input [CFG_ABITS-1:0] F1ADDR;
    input [CFG_DBITS-1:0] F1DATA;
    input F1EN;
    input [CFG_ENABLE_F-1:0] F1BE;

    input [CFG_ABITS-1:0] G1ADDR;
    output [CFG_DBITS-1:0] G1DATA;
    input G1EN;

    input [CFG_ABITS-1:0] H1ADDR;
    input [CFG_DBITS-1:0] H1DATA;
    input H1EN;
    input [CFG_ENABLE_H-1:0] H1BE;

    wire FLUSH1;
    wire FLUSH2;
    wire SPLIT;

    wire [13:CFG_ABITS] A1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] B1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] C1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] D1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] E1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] F1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] G1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] H1ADDR_CMPL = {14-CFG_ABITS{1'b0}};

    wire [13:0] A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
    wire [13:0] B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};
    wire [13:0] C1ADDR_TOTAL = {C1ADDR_CMPL, C1ADDR};
    wire [13:0] D1ADDR_TOTAL = {D1ADDR_CMPL, D1ADDR};
    wire [13:0] E1ADDR_TOTAL = {E1ADDR_CMPL, E1ADDR};
    wire [13:0] F1ADDR_TOTAL = {F1ADDR_CMPL, F1ADDR};
    wire [13:0] G1ADDR_TOTAL = {G1ADDR_CMPL, G1ADDR};
    wire [13:0] H1ADDR_TOTAL = {H1ADDR_CMPL, H1ADDR};

    wire [17:CFG_DBITS] A1_RDATA_CMPL;
    wire [17:CFG_DBITS] C1_RDATA_CMPL;
    wire [17:CFG_DBITS] E1_RDATA_CMPL;
    wire [17:CFG_DBITS] G1_RDATA_CMPL;

    wire [17:CFG_DBITS] B1_WDATA_CMPL;
    wire [17:CFG_DBITS] D1_WDATA_CMPL;
    wire [17:CFG_DBITS] F1_WDATA_CMPL;
    wire [17:CFG_DBITS] H1_WDATA_CMPL;

    wire [13:0] PORT_A1_ADDR;
    wire [13:0] PORT_A2_ADDR;
    wire [13:0] PORT_B1_ADDR;
    wire [13:0] PORT_B2_ADDR;

    assign FLUSH1 = 1'b0;
    assign FLUSH2 = 1'b0;

    wire [17:0] PORT_A1_RDATA = {A1_RDATA_CMPL, A1DATA};
    wire [17:0] PORT_B1_RDATA = {C1_RDATA_CMPL, C1DATA};
    wire [17:0] PORT_A2_RDATA = {E1_RDATA_CMPL, E1DATA};
    wire [17:0] PORT_B2_RDATA = {G1_RDATA_CMPL, G1DATA};

    wire [17:0] PORT_A1_WDATA = {B1_WDATA_CMPL, B1DATA};
    wire [17:0] PORT_B1_WDATA = {D1_WDATA_CMPL, D1DATA};
    wire [17:0] PORT_A2_WDATA = {F1_WDATA_CMPL, F1DATA};
    wire [17:0] PORT_B2_WDATA = {H1_WDATA_CMPL, H1DATA};

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

    case (CFG_DBITS)
        1: begin
            assign PORT_A1_ADDR = A1EN ? A1ADDR_TOTAL : (B1EN ? B1ADDR_TOTAL : 14'd0);
            assign PORT_B1_ADDR = C1EN ? C1ADDR_TOTAL : (D1EN ? D1ADDR_TOTAL : 14'd0);
            assign PORT_A2_ADDR = E1EN ? E1ADDR_TOTAL : (F1EN ? F1ADDR_TOTAL : 14'd0);
            assign PORT_B2_ADDR = G1EN ? G1ADDR_TOTAL : (H1EN ? H1ADDR_TOTAL : 14'd0);

            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        2: begin
            assign PORT_A1_ADDR = A1EN ? (A1ADDR_TOTAL << 1) : (B1EN ? (B1ADDR_TOTAL << 1) : 14'd0);
            assign PORT_B1_ADDR = C1EN ? (C1ADDR_TOTAL << 1) : (D1EN ? (D1ADDR_TOTAL << 1) : 14'd0);
            assign PORT_A2_ADDR = E1EN ? (E1ADDR_TOTAL << 1) : (F1EN ? (F1ADDR_TOTAL << 1) : 14'd0);
            assign PORT_B2_ADDR = G1EN ? (G1ADDR_TOTAL << 1) : (H1EN ? (H1ADDR_TOTAL << 1) : 14'd0);
            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        4: begin
            assign PORT_A1_ADDR = A1EN ? (A1ADDR_TOTAL << 2) : (B1EN ? (B1ADDR_TOTAL << 2) : 14'd0);
            assign PORT_B1_ADDR = C1EN ? (C1ADDR_TOTAL << 2) : (D1EN ? (D1ADDR_TOTAL << 2) : 14'd0);
            assign PORT_A2_ADDR = E1EN ? (E1ADDR_TOTAL << 2) : (F1EN ? (F1ADDR_TOTAL << 2) : 14'd0);
            assign PORT_B2_ADDR = G1EN ? (G1ADDR_TOTAL << 2) : (H1EN ? (H1ADDR_TOTAL << 2) : 14'd0);
            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        8, 9: begin
            assign PORT_A1_ADDR = A1EN ? (A1ADDR_TOTAL << 3) : (B1EN ? (B1ADDR_TOTAL << 3) : 14'd0);
            assign PORT_B1_ADDR = C1EN ? (C1ADDR_TOTAL << 3) : (D1EN ? (D1ADDR_TOTAL << 3) : 14'd0);
            assign PORT_A2_ADDR = E1EN ? (E1ADDR_TOTAL << 3) : (F1EN ? (F1ADDR_TOTAL << 3) : 14'd0);
            assign PORT_B2_ADDR = G1EN ? (G1ADDR_TOTAL << 3) : (H1EN ? (H1ADDR_TOTAL << 3) : 14'd0);
            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        16, 18: begin
            assign PORT_A1_ADDR = A1EN ? (A1ADDR_TOTAL << 4) : (B1EN ? (B1ADDR_TOTAL << 4) : 14'd0);
            assign PORT_B1_ADDR = C1EN ? (C1ADDR_TOTAL << 4) : (D1EN ? (D1ADDR_TOTAL << 4) : 14'd0);
            assign PORT_A2_ADDR = E1EN ? (E1ADDR_TOTAL << 4) : (F1EN ? (F1ADDR_TOTAL << 4) : 14'd0);
            assign PORT_B2_ADDR = G1EN ? (G1ADDR_TOTAL << 4) : (H1EN ? (H1ADDR_TOTAL << 4) : 14'd0);
            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        default: begin
            assign PORT_A1_ADDR = A1EN ? A1ADDR_TOTAL : (B1EN ? B1ADDR_TOTAL : 14'd0);
            assign PORT_B1_ADDR = C1EN ? C1ADDR_TOTAL : (D1EN ? D1ADDR_TOTAL : 14'd0);
            assign PORT_A2_ADDR = E1EN ? E1ADDR_TOTAL : (F1EN ? F1ADDR_TOTAL : 14'd0);
            assign PORT_B2_ADDR = G1EN ? G1ADDR_TOTAL : (H1EN ? H1ADDR_TOTAL : 14'd0);
            RS_TDP36K #(
                .MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end
    endcase
endmodule

module BRAM2x18_SDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, B1BE, C1ADDR, C1DATA, C1EN, CLK1, CLK2, D1ADDR, D1DATA, D1EN, D1BE);
    parameter CFG_ABITS = 11;
    parameter CFG_DBITS = 18;
    parameter CFG_ENABLE_B = 2;
    parameter CFG_ENABLE_D = 2;

    parameter CLKPOL2 = 1;
    parameter CLKPOL3 = 1;
    parameter [18431:0] INIT0 = 18432'bx;
    parameter [18431:0] INIT1 = 18432'bx;

    localparam MODE_36 = 3'b110;    // 36 or 32-bit
    localparam MODE_18 = 3'b010;    // 18 or 16-bit
    localparam MODE_9  = 3'b100;    // 9 or 8-bit
    localparam MODE_4  = 3'b001;    // 4-bit
    localparam MODE_2  = 3'b011;    // 32-bit
    localparam MODE_1  = 3'b101;    // 32-bit

    input CLK1;
    input CLK2;

    input [CFG_ABITS-1:0] A1ADDR;
    output [CFG_DBITS-1:0] A1DATA;
    input A1EN;

    input [CFG_ABITS-1:0] B1ADDR;
    input [CFG_DBITS-1:0] B1DATA;
    input B1EN;
    input [CFG_ENABLE_B-1:0] B1BE;

    input [CFG_ABITS-1:0] C1ADDR;
    output [CFG_DBITS-1:0] C1DATA;
    input C1EN;

    input [CFG_ABITS-1:0] D1ADDR;
    input [CFG_DBITS-1:0] D1DATA;
    input D1EN;
    input [CFG_ENABLE_D-1:0] D1BE;

    wire FLUSH1;
    wire FLUSH2;

    wire [13:CFG_ABITS] A1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] B1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] C1ADDR_CMPL = {14-CFG_ABITS{1'b0}};
    wire [13:CFG_ABITS] D1ADDR_CMPL = {14-CFG_ABITS{1'b0}};

    wire [13:0] A1ADDR_TOTAL = {A1ADDR_CMPL, A1ADDR};
    wire [13:0] B1ADDR_TOTAL = {B1ADDR_CMPL, B1ADDR};
    wire [13:0] C1ADDR_TOTAL = {C1ADDR_CMPL, C1ADDR};
    wire [13:0] D1ADDR_TOTAL = {D1ADDR_CMPL, D1ADDR};

    wire [17:CFG_DBITS] A1_RDATA_CMPL;
    wire [17:CFG_DBITS] C1_RDATA_CMPL;

    wire [17:CFG_DBITS] B1_WDATA_CMPL;
    wire [17:CFG_DBITS] D1_WDATA_CMPL;

    wire [13:0] PORT_A1_ADDR;
    wire [13:0] PORT_A2_ADDR;
    wire [13:0] PORT_B1_ADDR;
    wire [13:0] PORT_B2_ADDR;

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
    case (CFG_DBITS)
        9: begin
            assign A1DATA = {PORT_A1_RDATA[16], PORT_A1_RDATA[7:0]};
            assign C1DATA = {PORT_A2_RDATA[16], PORT_A2_RDATA[7:0]};
            assign PORT_A1_WDATA = {18{1'b0}};
            assign PORT_B1_WDATA = {B1_WDATA_CMPL[17], B1DATA[8], B1_WDATA_CMPL[16:9], B1DATA[7:0]};
            assign PORT_A2_WDATA = {18{1'b0}};
            assign PORT_B2_WDATA = {D1_WDATA_CMPL[17], D1DATA[8], D1_WDATA_CMPL[16:9], D1DATA[7:0]};
        end
        default: begin
            assign A1DATA = PORT_A1_RDATA[CFG_DBITS-1:0];
            assign C1DATA = PORT_A2_RDATA[CFG_DBITS-1:0];
            assign PORT_A1_WDATA = {18{1'b1}};
            assign PORT_B1_WDATA = {B1_WDATA_CMPL, B1DATA};
            assign PORT_A2_WDATA = {18{1'b1}};
            assign PORT_B2_WDATA = {D1_WDATA_CMPL, D1DATA};

        end
    endcase

    wire PORT_A1_CLK = CLK1;
    wire PORT_A2_CLK = CLK2;
    wire PORT_B1_CLK = CLK1;
    wire PORT_B2_CLK = CLK2;

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

    case (CFG_DBITS)
        1: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL;
            assign PORT_B1_ADDR = B1ADDR_TOTAL;
            assign PORT_A2_ADDR = C1ADDR_TOTAL;
            assign PORT_B2_ADDR = D1ADDR_TOTAL;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        2: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL << 1;
            assign PORT_B1_ADDR = B1ADDR_TOTAL << 1;
            assign PORT_A2_ADDR = C1ADDR_TOTAL << 1;
            assign PORT_B2_ADDR = D1ADDR_TOTAL << 1;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        4: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL << 2;
            assign PORT_B1_ADDR = B1ADDR_TOTAL << 2;
            assign PORT_A2_ADDR = C1ADDR_TOTAL << 2;
            assign PORT_B2_ADDR = D1ADDR_TOTAL << 2;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        8, 9: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL << 3;
            assign PORT_B1_ADDR = B1ADDR_TOTAL << 3;
            assign PORT_A2_ADDR = C1ADDR_TOTAL << 3;
            assign PORT_B2_ADDR = D1ADDR_TOTAL << 3;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        16, 18: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL << 4;
            assign PORT_B1_ADDR = B1ADDR_TOTAL << 4;
            assign PORT_A2_ADDR = C1ADDR_TOTAL << 4;
            assign PORT_B2_ADDR = D1ADDR_TOTAL << 4;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end

        default: begin
            assign PORT_A1_ADDR = A1ADDR_TOTAL;
            assign PORT_B1_ADDR = B1ADDR_TOTAL;
            assign PORT_A2_ADDR = D1ADDR_TOTAL;
            assign PORT_B2_ADDR = C1ADDR_TOTAL;
            RS_TDP36K #(.MODE_BITS({ 1'b1,
                11'd10, 11'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0
                }),
                .INIT_i({INIT0[0*18432+:18432],INIT1[0*18432+:18432]})
            )bram_2x18k(
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
            );
        end
    endcase

endmodule

module \_$_mem_v2_asymmetric (RD_ADDR, RD_ARST, RD_CLK, RD_DATA, RD_EN, RD_SRST, WR_ADDR, WR_CLK, WR_DATA, WR_EN);
    parameter CFG_ABITS = 10;
    parameter CFG_DBITS = 36;
    parameter CFG_ENABLE_B = 4;

    localparam CLKPOL2 = 1;
    localparam CLKPOL3 = 1;

    parameter READ_ADDR_WIDTH = 11;
    parameter READ_DATA_WIDTH = 16;
    parameter WRITE_ADDR_WIDTH = 10;
    parameter WRITE_DATA_WIDTH = 32;
    parameter ABITS = 0;
    parameter MEMID = 0;
    parameter [36863:0] INIT = 36864'bx;
    parameter OFFSET = 0;
    parameter RD_ARST_VALUE = 0;
    parameter RD_CE_OVER_SRST = 0;
    parameter RD_CLK_ENABLE = 0;
    parameter RD_CLK_POLARITY = 0;
    parameter RD_COLLISION_X_MASK = 0;
    parameter RD_PORTS = 0;
    parameter RD_SRST_VALUE = 0;
    parameter RD_TRANSPARENCY_MASK = 0;
    parameter RD_WIDE_CONTINUATION = 0;
    parameter SIZE = 0;
    parameter WIDTH = 0;
    parameter WR_CLK_ENABLE = 0;
    parameter WR_CLK_POLARITY = 0;
    parameter WR_PORTS = 0;
    parameter WR_PRIORITY_MASK = 0;
    parameter WR_WIDE_CONTINUATION = 0;

    localparam MODE_36  = 3'b111;   // 36 or 32-bit
    localparam MODE_18  = 3'b110;   // 18 or 16-bit
    localparam MODE_9   = 3'b101;   // 9 or 8-bit
    localparam MODE_4   = 3'b100;   // 4-bit
    localparam MODE_2   = 3'b010;   // 32-bit
    localparam MODE_1   = 3'b001;   // 32-bit

    input RD_CLK;
    input WR_CLK;
    input RD_ARST;
    input RD_SRST;

    input [CFG_ABITS-1:0] RD_ADDR;
    output [CFG_DBITS-1:0] RD_DATA;
    input RD_EN;

    input [CFG_ABITS-1:0] WR_ADDR;
    input [CFG_DBITS-1:0] WR_DATA;
    input [CFG_ENABLE_B-1:0] WR_EN;

    wire [14:0] RD_ADDR_15;
    wire [14:0] WR_ADDR_15;

    wire [35:0] DOBDO;

    wire [14:CFG_ABITS] RD_ADDR_CMPL;
    wire [14:CFG_ABITS] WR_ADDR_CMPL;
    wire [35:CFG_DBITS] RD_DATA_CMPL;
    wire [35:CFG_DBITS] WR_DATA_CMPL;

    wire [14:0] RD_ADDR_TOTAL;
    wire [14:0] WR_ADDR_TOTAL;
    wire [35:0] RD_DATA_TOTAL;
    wire [35:0] WR_DATA_TOTAL;

    wire FLUSH1;
    wire FLUSH2;

    assign RD_ADDR_CMPL = {15-CFG_ABITS{1'b0}};
    assign WR_ADDR_CMPL = {15-CFG_ABITS{1'b0}};

    assign RD_ADDR_TOTAL = {RD_ADDR_CMPL, RD_ADDR};
    assign WR_ADDR_TOTAL = {WR_ADDR_CMPL, WR_ADDR};

    assign RD_DATA_TOTAL = {RD_DATA_CMPL, RD_DATA};
    assign WR_DATA_TOTAL = {WR_DATA_CMPL, WR_DATA};

    assign FLUSH1 = 1'b0;
    assign FLUSH2 = 1'b0;

    case (CFG_DBITS)
        1: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL;
            assign WR_ADDR_15 = WR_ADDR_TOTAL;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_1, MODE_1, MODE_1, MODE_1, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
              //  .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end

        2: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL << 1;
            assign WR_ADDR_15 = WR_ADDR_TOTAL << 1;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_2, MODE_2, MODE_2, MODE_2, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end

        4: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL << 2;
            assign WR_ADDR_15 = WR_ADDR_TOTAL << 2;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_4, MODE_4, MODE_4, MODE_4, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end
        8, 9: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL << 3;
            assign WR_ADDR_15 = WR_ADDR_TOTAL << 3;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_9, MODE_9, MODE_9, MODE_9, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end

        16, 18: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL << 4;
            assign WR_ADDR_15 = WR_ADDR_TOTAL << 4;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_18, MODE_18, MODE_18, MODE_18, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end
        32, 36: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL << 5;
            assign WR_ADDR_15 = WR_ADDR_TOTAL << 5;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end
        default: begin
            assign RD_ADDR_15 = RD_ADDR_TOTAL;
            assign WR_ADDR_15 = WR_ADDR_TOTAL;
            RS_TDP36K #(
                .MODE_BITS({ 1'b0,
                11'd10, 11'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0,
                12'd10, 12'd10, 4'd0, MODE_36, MODE_36, MODE_36, MODE_36, 1'd0
                }),
                .INIT_i(INIT[0*36864+:36864])
            )bram_asymmetric(
               // .RESET_n(1'b1),
                .WDATA_A1(18'h3FFFF),
                .WDATA_A2(18'h3FFFF),
                .RDATA_A1(RD_DATA_TOTAL[17:0]),
                .RDATA_A2(RD_DATA_TOTAL[35:18]),
                .ADDR_A1(RD_ADDR_15),
                .ADDR_A2(RD_ADDR_15),
                .CLK_A1(RD_CLK),
                .CLK_A2(RD_CLK),
                .REN_A1(RD_EN),
                .REN_A2(RD_EN),
                .WEN_A1(1'b0),
                .WEN_A2(1'b0),
                .BE_A1({RD_EN, RD_EN}),
                .BE_A2({RD_EN, RD_EN}),
        
                .WDATA_B1(WR_DATA[17:0]),
                .WDATA_B2(WR_DATA[35:18]),
                .RDATA_B1(DOBDO[17:0]),
                .RDATA_B2(DOBDO[35:18]),
                .ADDR_B1(WR_ADDR_15),
                .ADDR_B2(WR_ADDR_15),
                .CLK_B1(WR_CLK),
                .CLK_B2(WR_CLK),
                .REN_B1(1'b0),
                .REN_B2(1'b0),
                .WEN_B1(WR_EN[0]),
                .WEN_B2(WR_EN[0]),
                .BE_B1(WR_EN[1:0]),
                .BE_B2(WR_EN[3:2]),
        
                .FLUSH1(FLUSH1),
                .FLUSH2(FLUSH2)
            );
        end
    endcase
endmodule
