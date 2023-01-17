// Copyright (C) 2022 RapidSilicon
//

//module dff(
//    output reg Q,
//    input D,
//    (* clkbuf_sink *)
//    input C
//);
//    parameter [0:0] INIT = 1'b0;
//    initial Q = INIT;
//    always @(posedge C)
//        Q <= D;
//endmodule
//
//module dffn(
//    output reg Q,
//    input D,
//    (* clkbuf_sink *)
//    input C
//);
//    parameter [0:0] INIT = 1'b0;
//    initial Q = INIT;
//    always @(negedge C)
//        Q <= D;
//endmodule

(* blackbox *)
module dffsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
endmodule

(* blackbox *)
module dffnsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
endmodule

(* blackbox *)
module latchsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
endmodule

(* blackbox *)
module latchnsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
endmodule

(* blackbox *)
module sh_dff(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C
);
endmodule

(* blackbox *)
module adder_carry(
    output sumout,
    output cout,
    input p,
    input g,
    input cin
);
endmodule

(* blackbox *)
module sdffr(
    output reg Q,
    input D,
    input R,
    (* clkbuf_sink *)
    (* invertible_pin = "IS_C_INVERTED" *)
    input C
);
endmodule

(* blackbox *)
module sdffs(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    (* invertible_pin = "IS_C_INVERTED" *)
    input C,
    input S
);
endmodule

(* blackbox *)
module TDP36K (
    RESET_ni,
    WEN_A1_i,
    WEN_B1_i,
    REN_A1_i,
    REN_B1_i,
    CLK_A1_i,
    CLK_B1_i,
    BE_A1_i,
    BE_B1_i,
    ADDR_A1_i,
    ADDR_B1_i,
    WDATA_A1_i,
    WDATA_B1_i,
    RDATA_A1_o,
    RDATA_B1_o,
    FLUSH1_i,
    WEN_A2_i,
    WEN_B2_i,
    REN_A2_i,
    REN_B2_i,
    CLK_A2_i,
    CLK_B2_i,
    BE_A2_i,
    BE_B2_i,
    ADDR_A2_i,
    ADDR_B2_i,
    WDATA_A2_i,
    WDATA_B2_i,
    RDATA_A2_o,
    RDATA_B2_o,
    FLUSH2_i
);
    parameter [80:0] MODE_BITS = 81'd0;
    parameter [36863:0] INIT_i = 36864'h0;

    input wire RESET_ni;

    input wire WEN_A1_i;
    input wire WEN_B1_i;
    input wire REN_A1_i;
    input wire REN_B1_i;
    (* clkbuf_sink *)
    input wire CLK_A1_i;
    (* clkbuf_sink *)
    input wire CLK_B1_i;
    input wire [1:0] BE_A1_i;
    input wire [1:0] BE_B1_i;
    input wire [14:0] ADDR_A1_i;
    input wire [14:0] ADDR_B1_i;
    input wire [17:0] WDATA_A1_i;
    input wire [17:0] WDATA_B1_i;
    output reg [17:0] RDATA_A1_o;
    output reg [17:0] RDATA_B1_o;
    input wire FLUSH1_i;
    input wire WEN_A2_i;
    input wire WEN_B2_i;
    input wire REN_A2_i;
    input wire REN_B2_i;
    (* clkbuf_sink *)
    input wire CLK_A2_i;
    (* clkbuf_sink *)
    input wire CLK_B2_i;
    input wire [1:0] BE_A2_i;
    input wire [1:0] BE_B2_i;
    input wire [13:0] ADDR_A2_i;
    input wire [13:0] ADDR_B2_i;
    input wire [17:0] WDATA_A2_i;
    input wire [17:0] WDATA_B2_i;
    output reg [17:0] RDATA_A2_o;
    output reg [17:0] RDATA_B2_o;
    input wire FLUSH2_i;
endmodule

(* blackbox *)
module RS_DSP1 (
    input wire [19:0] a,
    input wire [17:0] b,
    (* clkbuf_sink *)
    input wire clk0,
    (* clkbuf_sink *)
    input wire clk1,
    input wire [ 1:0] feedback0,
    input wire [ 1:0] feedback1,
    input wire        load_acc0,
    input wire        load_acc1,
    input wire        reset0,
    input wire        reset1,
    output reg [37:0] z
);
    parameter MODE_BITS = 27'b00000000000000000000000000;
endmodule  /* RS_DSP1 */



// ---------------------------------------- //
// ----- DSP cells simulation modules ----- //
// --------- Control bits in ports -------- //
// ---------------------------------------- //

(* blackbox *)
module RS_DSP2 ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    input  wire [ 5:0] acc_fir,
    output wire [37:0] z,
    output wire [17:0] dly_b,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       load_acc,
    input  wire       unsigned_a,
    input  wire       unsigned_b,

    input  wire       f_mode,
    input  wire [2:0] output_select,
    input  wire       saturate_enable,
    input  wire [5:0] shift_right,
    input  wire       round,
    input  wire       subtract,
    input  wire       register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b,

    input  wire       f_mode,
    input  wire [2:0] output_select,
    input  wire       register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULT_REGIN ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b,

    input  wire       f_mode,
    input  wire [2:0] output_select,
    input  wire       register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULT_REGOUT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b,
    input  wire       f_mode,
    input  wire [2:0] output_select,
    input  wire       register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULT_REGIN_REGOUT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b,
    input  wire       f_mode,
    input  wire [2:0] output_select,
    input  wire       register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTADD (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTADD_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTADD_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTADD_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTACC (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire        load_acc,
    input  wire [ 2:0] feedback,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTACC_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTACC_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule

(* blackbox *)
module RS_DSP2_MULTACC_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,

    input  wire        f_mode,
    input  wire [ 2:0] output_select,
    input  wire        saturate_enable,
    input  wire [ 5:0] shift_right,
    input  wire        round,
    input  wire        subtract,
    input  wire        register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;
endmodule


// ---------------------------------------- //
// ----- DSP cells simulation modules ----- //
// ------ Control bits in parameters ------ //
// ---------------------------------------- //

(* blackbox *)
module RS_DSP3 ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    input  wire [ 5:0] acc_fir,
    output wire [37:0] z,
    output wire [17:0] dly_b,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       load_acc,
    input  wire       unsigned_a,
    input  wire       unsigned_b,
    input  wire       subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire       reset,

    input  wire [2:0] feedback,
    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULT_REGIN ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,

    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULT_REGOUT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,

    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULT_REGIN_REGOUT ( // TODO: Name subject to change
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire       clk,
    input  wire       reset,

    input  wire [2:0] feedback,

    input  wire       unsigned_a,
    input  wire       unsigned_b
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTADD (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTADD_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTADD_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTADD_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire [ 5:0] acc_fir,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTACC (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTACC_REGIN (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTACC_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module RS_DSP3_MULTACC_REGIN_REGOUT (
    input  wire [19:0] a,
    input  wire [17:0] b,
    output wire [37:0] z,

    (* clkbuf_sink *)
    input  wire        clk,
    input  wire        reset,

    input  wire [ 2:0] feedback,
    input  wire        load_acc,
    input  wire        unsigned_a,
    input  wire        unsigned_b,
    input  wire        subtract
);

    parameter [92:0] MODE_BITS = 93'b0;
endmodule

(* blackbox *)
module BRAM2x18_TDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, C1ADDR, C1DATA, C1EN, CLK1, CLK2, CLK3, CLK4, D1ADDR, D1DATA, D1EN, E1ADDR, E1DATA, E1EN, F1ADDR, F1DATA, F1EN, G1ADDR, G1DATA, G1EN, H1ADDR, H1DATA, H1EN);
    parameter CFG_ABITS = 11;
    parameter CFG_DBITS = 18;
    parameter CFG_ENABLE_B = 4;
    parameter CFG_ENABLE_D = 4;
    parameter CFG_ENABLE_F = 4;
    parameter CFG_ENABLE_H = 4;

    parameter CLKPOL2 = 1;
    parameter CLKPOL3 = 1;
    parameter [18431:0] INIT0 = 18432'bx;
    parameter [18431:0] INIT1 = 18432'bx;

    input CLK1;
    input CLK2;
    input CLK3;
    input CLK4;

    input [CFG_ABITS-1:0] A1ADDR;
    output [CFG_DBITS-1:0] A1DATA;
    input A1EN;

    input [CFG_ABITS-1:0] B1ADDR;
    input [CFG_DBITS-1:0] B1DATA;
    input [CFG_ENABLE_B-1:0] B1EN;

    input [CFG_ABITS-1:0] C1ADDR;
    output [CFG_DBITS-1:0] C1DATA;
    input C1EN;

    input [CFG_ABITS-1:0] D1ADDR;
    input [CFG_DBITS-1:0] D1DATA;
    input [CFG_ENABLE_D-1:0] D1EN;

    input [CFG_ABITS-1:0] E1ADDR;
    output [CFG_DBITS-1:0] E1DATA;
    input E1EN;

    input [CFG_ABITS-1:0] F1ADDR;
    input [CFG_DBITS-1:0] F1DATA;
    input [CFG_ENABLE_F-1:0] F1EN;

    input [CFG_ABITS-1:0] G1ADDR;
    output [CFG_DBITS-1:0] G1DATA;
    input G1EN;

    input [CFG_ABITS-1:0] H1ADDR;
    input [CFG_DBITS-1:0] H1DATA;
    input [CFG_ENABLE_H-1:0] H1EN;
endmodule

(* blackbox *)
module BRAM2x18_SDP (A1ADDR, A1DATA, A1EN, B1ADDR, B1DATA, B1EN, C1ADDR, C1DATA, C1EN, CLK1, CLK2, D1ADDR, D1DATA, D1EN);
    parameter CFG_ABITS = 11;
    parameter CFG_DBITS = 18;
    parameter CFG_ENABLE_B = 4;
    parameter CFG_ENABLE_D = 4;

    parameter CLKPOL2 = 1;
    parameter CLKPOL3 = 1;
    parameter [18431:0] INIT0 = 18432'bx;
    parameter [18431:0] INIT1 = 18432'bx;

    input CLK1;
    input CLK2;

    input [CFG_ABITS-1:0] A1ADDR;
    output [CFG_DBITS-1:0] A1DATA;
    input A1EN;

    input [CFG_ABITS-1:0] B1ADDR;
    input [CFG_DBITS-1:0] B1DATA;
    input [CFG_ENABLE_B-1:0] B1EN;

    input [CFG_ABITS-1:0] C1ADDR;
    output [CFG_DBITS-1:0] C1DATA;
    input C1EN;

    input [CFG_ABITS-1:0] D1ADDR;
    input [CFG_DBITS-1:0] D1DATA;
    input [CFG_ENABLE_D-1:0] D1EN;
endmodule

(* blackbox *)
module \_$_mem_v2_asymmetric (RD_ADDR, RD_ARST, RD_CLK, RD_DATA, RD_EN, RD_SRST, WR_ADDR, WR_CLK, WR_DATA, WR_EN);
    localparam CFG_ABITS = 10;
    localparam CFG_DBITS = 36;
    localparam CFG_ENABLE_B = 4;

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
    parameter RD_INIT_VALUE = 0;
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
endmodule

(* blackbox *)
module \$lut (A, Y);
parameter WIDTH = 0;
parameter LUT = 0;

input [WIDTH-1:0] A;
output Y;

endmodule
