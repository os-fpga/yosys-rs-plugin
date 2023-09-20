// ---------------------------------------- //
// --------------- IO MODEL --------------- //
// -------------- BLACK BOXES ------------- //
// ---------------------------------------- //

// ---------------------------------------- 
`celldefine
(* blackbox *)
module CLK_BUF (
    input  logic I,             
    output logic O              
    );

endmodule
`endcelldefine

// ---------------------------------------- 

`celldefine
(* blackbox *)
module IO_BUF
  (
    input  logic I,     
    input  logic T,
    inout  wire  IO,
    output logic O
  );
  
endmodule 
`endcelldefine

// ---------------------------------------- 

`celldefine
(* blackbox *)
module IO_BUF_DS
  (
    input  logic I,     
    input  logic T,
    inout  wire IOP,
    inout  wire ION,
    output logic O
  );

endmodule // IO_BUF_DS
`endcelldefine

// ---------------------------------------- 
`celldefine
(* blackbox *)
module I_BUF #(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 0
    )(
        input  logic I, 
        input  logic C,            
        output logic O             
    );
endmodule 
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module I_BUF_DS #(
    parameter SLEW_RATE = "SLOW",
    parameter DELAY = 0
  )( 
    input  logic OE,    
    input  logic C,
    input  logic I_N,
    input  logic I_P,             
    output logic O    
  );

endmodule
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module I_DDR #(
    parameter SLEW_RATE = "SLOW",
    parameter DELAY = 0
  )(
    input  logic D, 
    input  logic R,
    input  logic DLY_ADJ,
    input  logic DLY_LD,     
    input  logic DLY_INC,
    input  logic C,          
    output logic [1:0] Q              
  );

endmodule
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module O_BUF #(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 0
)(
    input  logic I,     
    input  logic C,    
    output logic O          
);


endmodule
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module O_BUFT_DS #(
    parameter SLEW_RATE =  "SLOW" ,
    parameter DELAY = 0
  )(
    input  logic OE,    // Output enable
    input  logic I,     // Input
    input  logic C,     // Clock      
    output logic O_N,   // Output N
    output logic O_P    // Output P
              
  );

endmodule
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module O_BUFT  #(
    parameter SLEW_RATE = "SLOW",
    parameter DELAY = 0
  )(
    input  logic I,             
    input  logic OE,
    output logic O              
  );
    
endmodule  
`endcelldefine


// ---------------------------------------- 

`celldefine
(* blackbox *)
module O_DDR #(
    parameter SLEW_RATE =  "SLOW" ,
    parameter DELAY = 0
  )(
    input  logic [1:0] D,
    input  logic R,             
    input  logic E,
    input  logic DLY_ADJ,
    input  logic DLY_LD,
    input  logic DLY_INC,             
    input  logic C,                      
    output logic Q              
  );

endmodule
`endcelldefine

// ---------------------------------------- 

`celldefine
(* blackbox *)
module O_SERDES #(
  parameter DATA_RATE="DDR",          // SDR,DDR
            CLOCK_PHASE = 0,           // 0,90,180,270
            WIDTH = 4,                // 3,4,6,7,8,9,10
            DELAY = 0                 // 0-31 to WIDTH<=5, 0-63 for WIDTH>5
  )(
     input logic [WIDTH-1:0] D,       // Parallel data
     input logic RST,                 // Active low reset
     input logic LOAD_WORD,           // Input to load parallel data into register
     input logic DLY_LOAD,            // Load delay
     input logic DLY_ADJ,             // Adjust delay
     input logic DLY_INCDEC,          // Increment or decerement delay
     input logic CLK_EN,
     input logic CLK_IN,              // Core clock coming from fabric
     input logic PLL_LOCK,            // PLL lock signal
     input logic PLL_FAST_CLK,        // Fast clock coming from PLL (Max 2.5GHz)
     input logic [3:0] FAST_PHASE_CLK,// Four differnt phases fast clock (0, 90, 180, 270)
     input logic OE,                  // Output enable
     output logic CLK_OUT,            // Core clock coming from gearbox to fabric
     output logic Q,                  // Serial data out
     output logic [5:0] DLY_TAP_VALUE,// Delay tap values
     input logic CHANNEL_BOND_SYNC_IN,
     output logic CHANNEL_BOND_SYNC_OUT
    );

endmodule
`endcelldefine

// ---------------------------------------- 

`celldefine
(* blackbox *)
module I_SERDES #(
  parameter DATA_RATE = "SDR",         // SDR,DDR
            WIDTH = 4,                 // 3,4,6,7,8,9,10
            DPA_MODE = "NONE",         // NONE, DPA, CDR
            DELAY = 0                  // 0-31 to WIDTH<=5, 0-63 for WIDTH>5

  )(
      input logic D,                   // Serila data in
      input logic RST,                 // Active low reset
      input logic DPA_RST,             // Reset DPA block
      input logic FIFO_RST,            // Reset synchronous FIFO
      input logic DLY_LOAD,            // Load delay  (assert for 2 clock cycles)
      input logic DLY_ADJ,             // Adjust delay (should remain high for 2 clock cycles)
      input logic DLY_INCDEC,          // Increment or decrement delay (should remain high for 2 clock cycles)
      input logic BITSLIP_ADJ,         // To adjust bit slip. (Need to stable for at least 2 core clock cycles)
      input logic EN,
      input logic CLK_IN,              // Core clock coming from fabric
      input logic PLL_FAST_CLK,        // Fast clock coming from PLL (Max 2.5 GHz)
      input logic [3:0] FAST_PHASE_CLK,// Four differnt phases fast clock (0, 90, 180, 270)
      input logic PLL_LOCK,            // PLL lock signal
      output logic CLK_OUT,            // Core clock coming from gearbox to fabric
      output logic CDR_CORE_CLK,            // Core clock coming from gearbox to fabrc in CDR mode only
      output logic [WIDTH-1 : 0] Q,    // parallel data out
      output logic DATA_VALID,         // Data valid signal
      output logic [5:0] DLY_TAP_VALUE,// Delay tap values
      output logic DPA_LOCK,           // DPA lock signal goes high when DPA block lock the most alligned phase
      output logic DPA_ERROR           // DPA error if DPA does not find any closest alligned phase
    );

endmodule // I_SERDES
`endcelldefine

//------------------------------------------------------------------------------
// Copyright (C) 2022 RapidSilicon
// genesis3 DFFs and LATChes
//
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-Low asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module DFFRE(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-Low asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module DFFNRE(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
endmodule
`endcelldefine


//------------------------------------------------------------------------------
// Positive level-sensitive latch
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module latch(
    input D,
    input G,
    output reg Q
);
endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module latchn(
    input D,
    input G,
    output reg Q
);
endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module latchr(
    input D,
    input G,
    input R,
    output reg Q
);
endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module latchnr(
    input D,
    input G,
    input R,
    output reg Q
);
endmodule
`endcelldefine


//DSP primitives//
`celldefine
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
`endcelldefine


`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine


`celldefine
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
`endcelldefine


`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

//TDP BRAM //FIFO

`celldefine
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
`endcelldefine


`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
(* blackbox *)
module \$lut (A, Y);
parameter WIDTH = 0;
parameter LUT = 0;

input [WIDTH-1:0] A;
output Y;

endmodule
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
(* blackbox *)
module SOC_FPGA_INTF_DMA (
    // FPGA DMA
    input  logic [         3:0] DMA_REQ          ,
    output logic [         3:0] DMA_ACK          ,
    input  logic                DMA_CLK          ,
    input  logic                DMA_RST_N     

);

endmodule
`endcelldefine

`celldefine
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
`endcelldefine

`celldefine
(* blackbox *)
module SOC_FPGA_INTF_IRQ (
    // FPGA IRQ
    input  logic [        15:0] IRQ_SRC          ,
    output logic [        15:0] IRQ_SET          ,
    input  logic                IRQ_CLK		 ,
    input  logic                IRQ_RST_N

);

endmodule
`endcelldefine

`celldefine
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
`endcelldefine


`celldefine
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
endmodule // soc_fpga_intf
`endcelldefine

// --------------------------------------------------------------------------
// ---------------- Copyright (C) 2023 RapidSilicon -------------------------
// --------------------------------------------------------------------------
// ------------------- FIFO18K Primitive Blackbox----------------------------
// --------------------------------------------------------------------------

`celldefine
(* blackbox *)
module FIFO18K #(
// Parameters
parameter   DATA_WIDTH          = 5'd18,
parameter   SYNC_FIFO           = 1'b1,
parameter   PROG_FULL_THRESH    = 12'b100000000000,
parameter   PROG_EMPTY_THRESH   = 12'b111111111100
)
(
// Input/Output
input wire  [DATA_WIDTH-1:0] WR_DATA,
output wire [DATA_WIDTH-1:0] RD_DATA,
output wire EMPTY,
output wire FULL,
output wire OVERFLOW,
output wire UNDERFLOW,
input wire  RDEN,
input wire  WREN,
output wire ALMOST_EMPTY,
output wire ALMOST_FULL,
output wire PROG_EMPTY,
output wire PROG_FULL,
input wire  WRCLK,
input wire  RDCLK,
input wire  RESET
);

endmodule // FIFO18K
`endcelldefine

// --------------------------------------------------------------------------
// ---------------- Copyright (C) 2023 RapidSilicon -------------------------
// --------------------------------------------------------------------------
// ------------------- FIFO36K Primitive Blackbox----------------------------
// --------------------------------------------------------------------------

`celldefine
(* blackbox *)
module FIFO36K #(
// Parameters
parameter   DATA_WIDTH          = 6'd36,
parameter   SYNC_FIFO           = 1'b1,
parameter   PROG_FULL_THRESH    = 12'b100000000000,
parameter   PROG_EMPTY_THRESH   = 12'b111111111100
)
(
// Input/Output
input wire  [DATA_WIDTH-1:0] WR_DATA,
output wire [DATA_WIDTH-1:0] RD_DATA,
output wire EMPTY,
output wire FULL,
output wire OVERFLOW,
output wire UNDERFLOW,
input wire  RDEN,
input wire  WREN,
output wire ALMOST_EMPTY,
output wire ALMOST_FULL,
output wire PROG_EMPTY,
output wire PROG_FULL,
input wire  WRCLK,
input wire  RDCLK,
input wire  RESET
);

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Copyright (C) 2022 RapidSilicon
// LUT Primitives
//
//
//------------------------------------------------------------------------------

`celldefine
(* blackbox *)
module LUT1 (A, Y);
    parameter INIT_VALUE = 2'h0;
    input wire A;
    output wire Y;

endmodule
`endcelldefine

`celldefine
(* blackbox *)
module LUT2 (A, Y);
    parameter INIT_VALUE = 4'h0;
    input wire [1:0] A;
    output wire Y;

endmodule
`endcelldefine

`celldefine
(* blackbox *)
module LUT3 (A, Y);
    parameter INIT_VALUE = 8'h0;
    input wire [2:0] A;
    output wire Y;

endmodule
`endcelldefine

`celldefine
(* blackbox *)
module LUT4 (A, Y);
    parameter INIT_VALUE = 16'h0;
    input wire [3:0] A;
    output wire Y;

endmodule
`endcelldefine

`celldefine
(* blackbox *)
module LUT5 (A, Y);
    parameter INIT_VALUE = 32'h0;
    input wire [4:0] A;
    output wire Y;

endmodule
`endcelldefine

`celldefine
(* blackbox *)
module LUT6 (A, Y);
    parameter INIT_VALUE = 64'h0;
    input wire [5:0] A;
    output wire Y;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Copyright (C) 2022 RapidSilicon
// CARRY CHAIN Primitive
//
//
//------------------------------------------------------------------------------

`celldefine
(* blackbox *)
module CARRY_CHAIN(P, G, CIN, SUMOUT, COUT);
    input wire  P, G, CIN;
    output wire SUMOUT, COUT;
endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Copyright (C) 2022 RapidSilicon
// DSP38 Primitive
//
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module DSP38 #(
    parameter [19:0] COEFF_0        = 20'h0,
    parameter [19:0] COEFF_1        = 20'h0,
    parameter [19:0] COEFF_2        = 20'h0,
    parameter [19:0] COEFF_3        = 20'h0,
    parameter        OUTPUT_REG_EN  = "TRUE",
    parameter        INPUT_REG_EN   = "TRUE",
    parameter        DSP_MODE       = "MULTIPLY_ACCUMULATE" // (MULTIPLY, MULTIPLY_ADD_SUB)
) (
    input  wire [19:0] A,
    input  wire [17:0] B,
    input  wire  [5:0] ACC_FIR,
    output wire [37:0] Z,
    output wire [17:0] DLY_B,
    input wire       CLK,
    input wire       RESET,
    input wire       UNSIGNED_A,
    input wire       UNSIGNED_B,
    input wire [2:0] FEEDBACK,
    input wire       LOAD_ACC,
    input wire       SATURATE,
    input wire [5:0] SHIFT_RIGHT,
    input wire       ROUND,
    input wire       SUBTRACT
);
endmodule
`endcelldefine

//------------------------------------------------------------------------------
//
// Copyright (C) 2023 RapidSilicon
//
// genesis3 LLATChes
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// Positive level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------

`celldefine
(* blackbox *)
module LATCH(D, G, Q);
  input D;
  input G;
  output Q;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHN(D, G, Q);
  input D;
  input G;
  output Q;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine
//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHNR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
`celldefine
(* blackbox *)
module LATCHNS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;

endmodule
`endcelldefine
