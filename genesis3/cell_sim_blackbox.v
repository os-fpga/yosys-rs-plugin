//
// Copyright (C) 2022 RapidSilicon
// genesis3 DFFs and LATChes
//
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-Low asynchronous reset and
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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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
    output  [17:0] dly_b,

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

(* blackbox *)
module \$lut (A, Y);
parameter WIDTH = 0;
parameter LUT = 0;

input [WIDTH-1:0] A;
output Y;

endmodule

(* blackbox *)
module SOC_FPGA_INTF_AHB_S (
    output logic  		  S0_HRESETN_I  ,
    output logic   [        31:0] S0_HADDR     ,
    output logic   [         2:0] S0_HBURST    ,
    output logic                  S0_HMASTLOCK ,
    input  logic                  S0_HREADY    ,
    output logic   [         3:0] S0_HPROT     ,
    input  logic   [        31:0] S0_HRDATA    ,
    input  logic                  S0_HRESP     ,
    output logic                  S0_HSEL      ,
    output logic   [         2:0] S0_HSIZE     ,
    output logic   [         1:0] S0_HTRANS    ,
    output logic   [         3:0] S0_HWBE      ,
    output logic   [        31:0] S0_HWDATA    ,
    output logic                  S0_HWRITE    ,
    input  logic                  S0_HCLK
);
endmodule

(* blackbox *)
module SOC_FPGA_INTF_AXI_M0 (
    // AXI master 0
    input  logic [        31:0] M0_ARADDR   ,
    input  logic [         1:0] M0_ARBURST  ,
    input  logic [         3:0] M0_ARCACHE  ,
    input  logic [         3:0] M0_ARID     ,
    input  logic [         2:0] M0_ARLEN    ,
    input  logic                M0_ARLOCK   ,
    input  logic [         2:0] M0_ARPROT   ,
    output logic                M0_ARREADY  ,
    input  logic [         2:0] M0_ARSIZE   ,
    input  logic                M0_ARVALID  ,
    input  logic [        31:0] M0_AWADDR   ,
    input  logic [         1:0] M0_AWBURST  ,
    input  logic [         3:0] M0_AWCACHE  ,
    input  logic [         3:0] M0_AWID     ,
    input  logic [         2:0] M0_AWLEN    ,
    input  logic                M0_AWLOCK   ,
    input  logic [         2:0] M0_AWPROT   ,
    output logic                M0_AWREADY  ,
    input  logic [         2:0] M0_AWSIZE   ,
    input  logic                M0_AWVALID  ,
    output logic [         3:0] M0_BID      ,
    input  logic                M0_BREADY   ,
    output logic [         1:0] M0_BRESP    ,
    output logic                M0_BVALID   ,
    output logic [        63:0] M0_RDATA    ,
    output logic [         3:0] M0_RID      ,
    output logic                M0_RLAST    ,
    input  logic                M0_RREADY   ,
    output logic [         1:0] M0_RRESP    ,
    output logic                M0_RVALID   ,
    input  logic [        63:0] M0_WDATA    ,
    input  logic                M0_WLAST    ,
    output logic                M0_WREADY   ,
    input  logic [         7:0] M0_WSTRB    ,
    input  logic                M0_WVALID   ,
    input                  	M0_ACLK     ,
    output                  	M0_ARESETN_I 
);
endmodule

(* blackbox *)
module SOC_FPGA_INTF_AXI_M1 (
    //AXI master 1
    input  logic [        31:0] M1_ARADDR   ,
    input  logic [         1:0] M1_ARBURST  ,
    input  logic [         3:0] M1_ARCACHE  ,
    input  logic [         3:0] M1_ARID     ,
    input  logic [         3:0] M1_ARLEN    ,
    input  logic                M1_ARLOCK   ,
    input  logic [         2:0] M1_ARPROT   ,
    output logic                M1_ARREADY  ,
    input  logic [         2:0] M1_ARSIZE   ,
    input  logic                M1_ARVALID  ,
    input  logic [        31:0] M1_AWADDR   ,
    input  logic [         1:0] M1_AWBURST  ,
    input  logic [         3:0] M1_AWCACHE  ,
    input  logic [         3:0] M1_AWID     ,
    input  logic [         3:0] M1_AWLEN    ,
    input  logic                M1_AWLOCK   ,
    input  logic [         2:0] M1_AWPROT   ,
    output logic                M1_AWREADY  ,
    input  logic [         2:0] M1_AWSIZE   ,
    input  logic                M1_AWVALID  ,
    output logic [         3:0] M1_BID      ,
    input  logic                M1_BREADY   ,
    output logic [         1:0] M1_BRESP    ,
    output logic                M1_BVALID   ,
    output logic [        31:0] M1_RDATA    ,
    output logic [         3:0] M1_RID      ,
    output logic                M1_RLAST    ,
    input  logic                M1_RREADY   ,
    output logic [         1:0] M1_RRESP    ,
    output logic                M1_RVALID   ,
    input  logic [        31:0] M1_WDATA    ,
    input  logic                M1_WLAST    ,
    output logic                M1_WREADY   ,
    input  logic [         3:0] M1_WSTRB    ,
    input  logic                M1_WVALID   ,
    input                  	M1_ACLK     ,
    output                  	M1_ARESETN_I        
);
endmodule

(* blackbox *)
module SOC_FPGA_INTF_AXI_M0_M1 (
    // AXI master 0
    input  logic [        31:0] M0_ARADDR   ,
    input  logic [         1:0] M0_ARBURST  ,
    input  logic [         3:0] M0_ARCACHE  ,
    input  logic [         3:0] M0_ARID     ,
    input  logic [         2:0] M0_ARLEN    ,
    input  logic                M0_ARLOCK   ,
    input  logic [         2:0] M0_ARPROT   ,
    output logic                M0_ARREADY  ,
    input  logic [         2:0] M0_ARSIZE   ,
    input  logic                M0_ARVALID  ,
    input  logic [        31:0] M0_AWADDR   ,
    input  logic [         1:0] M0_AWBURST  ,
    input  logic [         3:0] M0_AWCACHE  ,
    input  logic [         3:0] M0_AWID     ,
    input  logic [         2:0] M0_AWLEN    ,
    input  logic                M0_AWLOCK   ,
    input  logic [         2:0] M0_AWPROT   ,
    output logic                M0_AWREADY  ,
    input  logic [         2:0] M0_AWSIZE   ,
    input  logic                M0_AWVALID  ,
    output logic [         3:0] M0_BID      ,
    input  logic                M0_BREADY   ,
    output logic [         1:0] M0_BRESP    ,
    output logic                M0_BVALID   ,
    output logic [        63:0] M0_RDATA    ,
    output logic [         3:0] M0_RID      ,
    output logic                M0_RLAST    ,
    input  logic                M0_RREADY   ,
    output logic [         1:0] M0_RRESP    ,
    output logic                M0_RVALID   ,
    input  logic [        63:0] M0_WDATA    ,
    input  logic                M0_WLAST    ,
    output logic                M0_WREADY   ,
    input  logic [         7:0] M0_WSTRB    ,
    input  logic                M0_WVALID   ,
    //AXI master 1
    input  logic [        31:0] M1_ARADDR   ,
    input  logic [         1:0] M1_ARBURST  ,
    input  logic [         3:0] M1_ARCACHE  ,
    input  logic [         3:0] M1_ARID     ,
    input  logic [         3:0] M1_ARLEN    ,
    input  logic                M1_ARLOCK   ,
    input  logic [         2:0] M1_ARPROT   ,
    output logic                M1_ARREADY  ,
    input  logic [         2:0] M1_ARSIZE   ,
    input  logic                M1_ARVALID  ,
    input  logic [        31:0] M1_AWADDR   ,
    input  logic [         1:0] M1_AWBURST  ,
    input  logic [         3:0] M1_AWCACHE  ,
    input  logic [         3:0] M1_AWID     ,
    input  logic [         3:0] M1_AWLEN    ,
    input  logic                M1_AWLOCK   ,
    input  logic [         2:0] M1_AWPROT   ,
    output logic                M1_AWREADY  ,
    input  logic [         2:0] M1_AWSIZE   ,
    input  logic                M1_AWVALID  ,
    output logic [         3:0] M1_BID      ,
    input  logic                M1_BREADY   ,
    output logic [         1:0] M1_BRESP    ,
    output logic                M1_BVALID   ,
    output logic [        31:0] M1_RDATA    ,
    output logic [         3:0] M1_RID      ,
    output logic                M1_RLAST    ,
    input  logic                M1_RREADY   ,
    output logic [         1:0] M1_RRESP    ,
    output logic                M1_RVALID   ,
    input  logic [        31:0] M1_WDATA    ,
    input  logic                M1_WLAST    ,
    output logic                M1_WREADY   ,
    input  logic [         3:0] M1_WSTRB    ,
    input  logic                M1_WVALID   ,
    input                  	M0_ACLK     ,
    input                  	M1_ACLK     ,
    output                  	M0_ARESETN_I, 
    output                  	M1_ARESETN_I        
);
endmodule

(* blackbox *)
module SOC_FPGA_INTF_DMA (
    // FPGA DMA
    input  logic [         3:0] DMA_REQ          ,
    output logic [         3:0] DMA_ACK          ,
    input  logic                DMA_CLK          ,
    input  logic                DMA_RST_N     

);

endmodule

(* blackbox *)
module SOC_FPGA_INTF_GPIO (
    // FPGA GPIO
    output logic  [        39:0] GPIO_O       ,
    input  logic  [        39:0] GPIO_I       ,
    input  logic  [        39:0] GPIO_OEN     ,
    input  logic                 GPIO_CLK     ,
    input  logic                 GPIO_RST_N    

);

endmodule

(* blackbox *)
module SOC_FPGA_INTF_IRQ (
    // FPGA IRQ
    input  logic [        15:0] IRQ_SRC          ,
    output logic [        15:0] IRQ_SET          ,
    input  logic                IRQ_CLK		 ,
    input  logic                IRQ_RST_N

);

endmodule

(* blackbox *)
module SOC_FPGA_INTF_JTAG (
    // JTAG
    input      logic        BOOT_JTAG_TCK                ,
    output     logic        BOOT_JTAG_TDI                ,
    input      logic        BOOT_JTAG_TDO                ,
    output     logic        BOOT_JTAG_TMS                ,
    output     logic        BOOT_JTAG_TRSTN              ,
    input      logic        BOOT_JTAG_EN                 
);

endmodule


(* blackbox *)
module soc_fpga_intf (
    // FPGA fabric clocks
    input  logic                clk_fpga_fabric_irq       ,
    input  logic                clk_fpga_fabric_dma       ,
    input  logic                clk_fpga_fabric_gpio       ,
    input  logic                rst_n_fpga_fabric_irq     ,
    input  logic                rst_n_fpga_fabric_dma     ,
    input  logic                rst_n_fpga_fabric_gpio    ,
    output  logic                rst_n_fpga0             ,
    output  logic                rst_n_fpga1             ,
    output  logic                rst_n_fpga_s             ,


    input  logic clk_fpga_fabric_m0,
    input  logic clk_fpga_fabric_m1,
    input  logic clk_fpga_fabric_s0,

    //
    //output logic                   global_reset_fpga,
    //output logic [2:0]             rwm_control_fpga,

    //config controller status
    //output logic                cfg_done                  ,
    //output logic                cfg_error                 ,
    //AHB slave
    output logic [        31:0] fpga_clk_ahb_s0_haddr     ,
    output logic [         2:0] fpga_clk_ahb_s0_hburst    ,
    output logic                fpga_clk_ahb_s0_hmastlock ,
    input  logic                fpga_clk_ahb_s0_hready    ,
    output logic [         3:0] fpga_clk_ahb_s0_hprot     ,
    input  logic [        31:0] fpga_clk_ahb_s0_hrdata    ,
    input  logic                fpga_clk_ahb_s0_hresp     ,
    output logic                fpga_clk_ahb_s0_hsel      ,
    output logic [         2:0] fpga_clk_ahb_s0_hsize     ,
    output logic [         1:0] fpga_clk_ahb_s0_htrans    ,
    output logic [         3:0] fpga_clk_ahb_s0_hwbe      ,
    output logic [        31:0] fpga_clk_ahb_s0_hwdata    ,
    output logic                fpga_clk_ahb_s0_hwrite    ,
    // AXI master 0
    input  logic [        31:0] fpga_clk_axi_m0_ar_addr   ,
    input  logic [         1:0] fpga_clk_axi_m0_ar_burst  ,
    input  logic [         3:0] fpga_clk_axi_m0_ar_cache  ,
    input  logic [         3:0] fpga_clk_axi_m0_ar_id     ,
    input  logic [         2:0] fpga_clk_axi_m0_ar_len    ,
    input  logic                fpga_clk_axi_m0_ar_lock   ,
    input  logic [         2:0] fpga_clk_axi_m0_ar_prot   ,
    output logic                fpga_clk_axi_m0_ar_ready  ,
    input  logic [         2:0] fpga_clk_axi_m0_ar_size   ,
    input  logic                fpga_clk_axi_m0_ar_valid  ,
    input  logic [        31:0] fpga_clk_axi_m0_aw_addr   ,
    input  logic [         1:0] fpga_clk_axi_m0_aw_burst  ,
    input  logic [         3:0] fpga_clk_axi_m0_aw_cache  ,
    input  logic [         3:0] fpga_clk_axi_m0_aw_id     ,
    input  logic [         2:0] fpga_clk_axi_m0_aw_len    ,
    input  logic                fpga_clk_axi_m0_aw_lock   ,
    input  logic [         2:0] fpga_clk_axi_m0_aw_prot   ,
    output logic                fpga_clk_axi_m0_aw_ready  ,
    input  logic [         2:0] fpga_clk_axi_m0_aw_size   ,
    input  logic                fpga_clk_axi_m0_aw_valid  ,
    output logic [         3:0] fpga_clk_axi_m0_b_id      ,
    input  logic                fpga_clk_axi_m0_b_ready   ,
    output logic [         1:0] fpga_clk_axi_m0_b_resp    ,
    output logic                fpga_clk_axi_m0_b_valid   ,
    output logic [        63:0] fpga_clk_axi_m0_r_data    ,
    output logic [         3:0] fpga_clk_axi_m0_r_id      ,
    output logic                fpga_clk_axi_m0_r_last    ,
    input  logic                fpga_clk_axi_m0_r_ready   ,
    output logic [         1:0] fpga_clk_axi_m0_r_resp    ,
    output logic                fpga_clk_axi_m0_r_valid   ,
    input  logic [        63:0] fpga_clk_axi_m0_w_data    ,
    input  logic                fpga_clk_axi_m0_w_last    ,
    output logic                fpga_clk_axi_m0_w_ready   ,
    input  logic [         7:0] fpga_clk_axi_m0_w_strb    ,
    input  logic                fpga_clk_axi_m0_w_valid   ,
    //AXI master 1
    input  logic [        31:0] fpga_clk_axi_m1_ar_addr   ,
    input  logic [         1:0] fpga_clk_axi_m1_ar_burst  ,
    input  logic [         3:0] fpga_clk_axi_m1_ar_cache  ,
    input  logic [         3:0] fpga_clk_axi_m1_ar_id     ,
    input  logic [         3:0] fpga_clk_axi_m1_ar_len    ,
    input  logic                fpga_clk_axi_m1_ar_lock   ,
    input  logic [         2:0] fpga_clk_axi_m1_ar_prot   ,
    output logic                fpga_clk_axi_m1_ar_ready  ,
    input  logic [         2:0] fpga_clk_axi_m1_ar_size   ,
    input  logic                fpga_clk_axi_m1_ar_valid  ,
    input  logic [        31:0] fpga_clk_axi_m1_aw_addr   ,
    input  logic [         1:0] fpga_clk_axi_m1_aw_burst  ,
    input  logic [         3:0] fpga_clk_axi_m1_aw_cache  ,
    input  logic [         3:0] fpga_clk_axi_m1_aw_id     ,
    input  logic [         3:0] fpga_clk_axi_m1_aw_len    ,
    input  logic                fpga_clk_axi_m1_aw_lock   ,
    input  logic [         2:0] fpga_clk_axi_m1_aw_prot   ,
    output logic                fpga_clk_axi_m1_aw_ready  ,
    input  logic [         2:0] fpga_clk_axi_m1_aw_size   ,
    input  logic                fpga_clk_axi_m1_aw_valid  ,
    output logic [         3:0] fpga_clk_axi_m1_b_id      ,
    input  logic                fpga_clk_axi_m1_b_ready   ,
    output logic [         1:0] fpga_clk_axi_m1_b_resp    ,
    output logic                fpga_clk_axi_m1_b_valid   ,
    output logic [        31:0] fpga_clk_axi_m1_r_data    ,
    output logic [         3:0] fpga_clk_axi_m1_r_id      ,
    output logic                fpga_clk_axi_m1_r_last    ,
    input  logic                fpga_clk_axi_m1_r_ready   ,
    output logic [         1:0] fpga_clk_axi_m1_r_resp    ,
    output logic                fpga_clk_axi_m1_r_valid   ,
    input  logic [        31:0] fpga_clk_axi_m1_w_data    ,
    input  logic                fpga_clk_axi_m1_w_last    ,
    output logic                fpga_clk_axi_m1_w_ready   ,
    input  logic [         3:0] fpga_clk_axi_m1_w_strb    ,
    input  logic                fpga_clk_axi_m1_w_valid   ,
    // FPGA IRQ
    input  logic [        15:0] fpga_clk_irq_src          ,
    output logic [        15:0] fpga_clk_irq_set          ,
    // FPGA DMA
    input  logic [         3:0] fpga_clk_dma_req          ,
    output logic [         3:0] fpga_clk_dma_ack          ,

    // FPGA JTAG
  input      logic        fpga_jtag_tck                ,
  output     logic        fpga_jtag_tdi                ,
  input      logic        fpga_jtag_tdo                ,
  output     logic        fpga_jtag_tms                ,
  output     logic        fpga_jtag_trstn              ,
  input      logic        fpga_jtag_en                 ,
  input      logic        soc_fpga_jtag_tdi                ,
  output     logic        soc_fpga_jtag_tdo                ,
  input      logic        soc_fpga_jtag_tms                ,
  input      logic        soc_fpga_jtag_trstn              ,
    // FPGA GPIO
    output logic  [        39:0] fpga_pad_c       ,
    input  logic  [        39:0] fpga_pad_i       ,
    input  logic  [        39:0] fpga_pad_oen     
    //output  logic 	    sc_enable                 ,
    //output  logic 	    sc_mode                   ,
    //input   logic [  311:0] sc_tail                   ,
   //testmode
    //input  logic                   testmode 

);
endmodule