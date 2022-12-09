//
// Copyright (C) 2022 RapidSilicon
//Tuesday, November 15, 2022
`timescale  1 ps / 1 ps
// genesis2 DFFs and LATChes
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop
//------------------------------------------------------------------------------
(* blackbox *)
module dff(
    input D,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop
//------------------------------------------------------------------------------
(* blackbox *)
module dffn(
    input D,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high synchronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module sdff(
    input D,
    input R,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high synchronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module sdffn(
    input D,
    input R,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high asynchronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module dffr(
    input D,
    input R,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high asynchronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module dffnr(
    input D,
    input R,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module dffe(
    input D,
    input E,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module dffne(
    input D,
    input E,
    input C,
    output reg Q
);
endmodule


//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
//  active-high synchronous reset
//  active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module sdffre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-high synchronous reset
// active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module sdffnre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-high asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module dffre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-high asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
(* blackbox *)
module dffnre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Positive level-sensitive latch
//------------------------------------------------------------------------------
(* blackbox *)
module latch(
    input D,
    input G,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch
//------------------------------------------------------------------------------
(* blackbox *)
module latchn(
    input D,
    input G,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module latchr(
    input D,
    input G,
    input R,
    output reg Q
);
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
(* blackbox *)
module latchnr(
    input D,
    input G,
    input R,
    output reg Q
);
endmodule


//DSP primitives//
(* blackbox *)
module RS_DSP ( 
    input   [19:0] a,
    input   [17:0] b,
    input   [ 5:0] acc_fir,
    output  [37:0] z,
    output  [17:0] dly_b,

    (* clkbuf_sink *)
    input         clk,
    input         lreset,

    input   [2:0] feedback,	 
    input         load_acc,
    input         unsigned_a,
    input         unsigned_b,
    input         saturate_enable,
    input   [5:0] shift_right,
    input         round,
    input         subtract
 
);
 
    parameter [83:0] MODE_BITS = 84'd0; 

 
endmodule


(* blackbox *)
module RS_DSP_MULT ( 
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    input   [2:0] feedback,
    input         unsigned_a,
    input         unsigned_b
    
);

parameter [79:0] MODE_BITS = 80'd0; 

endmodule

(* blackbox *)
module RS_DSP_MULT_REGIN ( 
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input         clk,
    input         lreset,

    input   [2:0] feedback,
    input         unsigned_a,
    input         unsigned_b
    
);

parameter [79:0] MODE_BITS = 80'd0;    
endmodule

(* blackbox *)
module RS_DSP_MULT_REGOUT ( 
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input         clk,
    input         lreset,

    input   [2:0] feedback,
    input         unsigned_a,
    input         unsigned_b
    
);

    
parameter [79:0] MODE_BITS = 80'd0;    
endmodule


(* blackbox *)
module RS_DSP_MULT_REGIN_REGOUT ( 
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input         clk,
    input         lreset,

    input   [2:0] feedback,
    input         unsigned_a,
    input         unsigned_b
    
);

   
parameter [79:0] MODE_BITS = 80'd0; 
    
endmodule


(* blackbox *)
module RS_DSP_MULTADD (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input   [ 5:0] acc_fir,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,

   
    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract

);

parameter [79:0] MODE_BITS = 80'd0; 

 
endmodule

(* blackbox *)
module RS_DSP_MULTADD_REGIN (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input   [ 5:0] acc_fir,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,


    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract
    
);

parameter [79:0] MODE_BITS = 80'd0; 
  
endmodule

(* blackbox *)
module RS_DSP_MULTADD_REGOUT (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input   [ 5:0] acc_fir,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,


    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract

);

parameter [79:0] MODE_BITS = 80'd0; 

endmodule

(* blackbox *)
module RS_DSP_MULTADD_REGIN_REGOUT (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input   [ 5:0] acc_fir,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,


    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract
);

parameter [79:0] MODE_BITS = 80'd0; 
  
endmodule

(* blackbox *)
module RS_DSP_MULTACC (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input          load_acc,
    input   [ 2:0] feedback,
    input          unsigned_a,
    input          unsigned_b,

    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract
);
parameter [79:0] MODE_BITS = 80'd0; 
  
endmodule

(* blackbox *)
module RS_DSP_MULTACC_REGIN (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,

  
    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract

);

parameter [79:0] MODE_BITS = 80'd0; 
  
endmodule

(* blackbox *)
module RS_DSP_MULTACC_REGOUT (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,

    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract
);

parameter [79:0] MODE_BITS = 80'd0; 

endmodule

(* blackbox *)
module RS_DSP_MULTACC_REGIN_REGOUT (
    input   [19:0] a,
    input   [17:0] b,
    output  [37:0] z,

    (* clkbuf_sink *)
    input          clk,
    input          lreset,

    input   [ 2:0] feedback,
    input          load_acc,
    input          unsigned_a,
    input          unsigned_b,

    input          saturate_enable,
    input   [ 5:0] shift_right,
    input          round,
    input          subtract
);

parameter [79:0] MODE_BITS = 80'd0; 
  
endmodule

//TDP BRAM //FIFO

(* blackbox *)
module RS_TDP36K (
    WEN_A1,
    WEN_B1,
    REN_A1,
    REN_B1,
    CLK_A1,
    CLK_B1,
    BE_A1,
    BE_B1,
    ADDR_A1,
    ADDR_B1,
    WDATA_A1,
    WDATA_B1,
    RDATA_A1,
    RDATA_B1,
    FLUSH1,
    WEN_A2,
    WEN_B2,
    REN_A2,
    REN_B2,
    CLK_A2,
    CLK_B2,
    BE_A2,
    BE_B2,
    ADDR_A2,
    ADDR_B2,
    WDATA_A2,
    WDATA_B2,
    RDATA_A2,
    RDATA_B2,
    FLUSH2
);
    parameter [80:0] MODE_BITS = 81'd0;
    parameter [36863:0] INIT_i = 36864'h0;


    input wire WEN_A1;
    input wire WEN_B1;
    input wire REN_A1;
    input wire REN_B1;
    (* clkbuf_sink *)
    input wire CLK_A1;
    (* clkbuf_sink *)
    input wire CLK_B1;
    input wire [1:0] BE_A1;
    input wire [1:0] BE_B1;
    input wire [14:0] ADDR_A1;
    input wire [14:0] ADDR_B1;
    input wire [17:0] WDATA_A1;
    input wire [17:0] WDATA_B1;
    output reg [17:0] RDATA_A1;
    output reg [17:0] RDATA_B1;
    input wire FLUSH1;
    input wire WEN_A2;
    input wire WEN_B2;
    input wire REN_A2;
    input wire REN_B2;
    (* clkbuf_sink *)
    input wire CLK_A2;
    (* clkbuf_sink *)
    input wire CLK_B2;
    input wire [1:0] BE_A2;
    input wire [1:0] BE_B2;
    input wire [13:0] ADDR_A2;
    input wire [13:0] ADDR_B2;
    input wire [17:0] WDATA_A2;
    input wire [17:0] WDATA_B2;
    output reg [17:0] RDATA_A2;
    output reg [17:0] RDATA_B2;
    input wire FLUSH2;
   
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

    parameter CFG_ABITS = 10;
    parameter CFG_DBITS = 36;
    parameter CFG_ENABLE_B = 4;

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
