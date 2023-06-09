 //---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : CLK_BUF IO Primitive
//   Filename    : CLK_BUF.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//----------------------------------------

module CLK_BUF (
    input  logic I,             
    output logic O              
    );
  
    clkbuf CLK_BUF_inst (.I(I), .O(O));
  
  endmodule 
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 
//    Version     : 0.1
//    Description : IBUF IO Primitive
//    Filename    : IBUF.sv
//   
//   ------------------------------------  
//    Revision:
//      March-2023 - Initial version.
//    End Revision:
//---------------------------------------  

  module I_BUF #(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 0
  )(
    input  logic I,     // Input
    input  logic C,     // Clock in case of REG_EN is true
    output logic O      // Output         
  );
  
  ibuf #(.PULL_UP_DOWN(PULL_UP_DOWN ), .SLEW_RATE(SLEW_RATE), .DELAY(DELAY),.REG_EN(REG_EN)) 
  ibuf_inst (.I(I),.C(C),.O(O));
    
  // synopsys translate_off

  initial begin
    assert (REG_EN == "FALSE" ||  REG_EN == "TRUE")               else $error("Incorrect REG_EN Value");
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")          else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                            else $error("DELAY parameter out of range");
    assert (PULL_UP_DOWN == "UP" ||  PULL_UP_DOWN == "DOWN" ||  PULL_UP_DOWN == "NONE")   else $error("Incorrect PULL_UP_DOWN Value");
  end 
  // synopsys translate_on

endmodule 
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : I_BUF_DS IO Primitive
//   Filename    : I_BUF_DS.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//----------------------------------------
 
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
  
  ibufds #(.SLEW_RATE(SLEW_RATE),.DELAY(DELAY)) 
  ibufds_inst (.OE(OE), .I_N(I_N),.I_P(I_P),.O(O),.C(C));
 
  // synopsys translate_off

  initial begin
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")    else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                      else $error("DELAY parameter out of range");
  end 
  // synopsys translate_on

endmodule 
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : I_DDR IO Primitive
//   Filename    : I_DDR.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//---------------------------------------- 
module I_DDR #(
    parameter DELAY = 0,
    parameter SLEW_RATE = "SLOW"
    )(
    input  logic D,           // Input
    input  logic R,           // RESET
    input  logic DLY_ADJ,     // Delay Adjust    
    input  logic DLY_LD,      // Load Delay 
    input  logic DLY_INC,     // Delay Increment
    input  logic C,           // CLK
    output logic [1:0] Q      // Output        
  );
  
  iddr  #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY))  
  iddr_inst(.D(D),.R(R),.C(C),.Q(Q),.DLY_LD(DLY_LD),.DLY_ADJ(DLY_ADJ),.DLY_INC(DLY_INC));

  // synopsys translate_off

  initial begin
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")  else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                    else $error("DELAY parameter out of range");
  end 
  // synopsys translate_on
  
  
endmodule 
`timescale 1ns/1ps
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : ISERDES Primitive
//   Filename    : I_SERDES.sv
//   
//   -------------------------------------  
//   Revision:
//     April-2023 - Initial version.
//   End Revision:
//---------------------------------------- 
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

    iserdes # (
      .DATA_RATE(DATA_RATE), 
      .WIDTH(WIDTH), 
      .DPA_MODE(DPA_MODE), 
      .DELAY(DELAY)
    )
    I_SERDES_inst ( 
      .D(D),
      .RST(RST),
      .DPA_RST(DPA_RST),
      .FIFO_RST(FIFO_RST),
      .DLY_LOAD(DLY_LOAD),
      .DLY_ADJ(DLY_ADJ),
      .DLY_INCDEC(DLY_INCDEC),
      .BITSLIP_ADJ(BITSLIP_ADJ),
      .EN(EN),
      .CLK_IN(CLK_IN),
      .PLL_FAST_CLK(PLL_FAST_CLK),
      .FAST_PHASE_CLK(FAST_PHASE_CLK),
      .PLL_LOCK(PLL_LOCK),
      .CLK_OUT(CLK_OUT),
      .CDR_CORE_CLK(CDR_CORE_CLK),
      .Q(Q),                  
      .DATA_VALID(DATA_VALID),
      .DLY_TAP_VALUE(DLY_TAP_VALUE),              
      .DPA_LOCK(DPA_LOCK),
      .DPA_ERROR(DPA_ERROR)  
    );

    initial begin
      assert (DATA_RATE == "DDR"  || DATA_RATE == "SDR")   else   $error("Incorrect DDR_RATE value");
      assert (WIDTH >= 3  && WIDTH <= 10)                  else   $error("Incorrect WIDTH value");
      assert (DPA_MODE == "NONE"  || DPA_MODE == "DPA" || DPA_MODE == "CDR")   else   $error("Incorrect DPA_MODE value");
      assert (DELAY >= 0  && DELAY <= 63)                  else   $error("DELAY parameter out of range");
        
    end

endmodule
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 
//    Version     : 0.1
//    Description : IO_BUF IO Primitive
//    Filename    : IO_BUF.sv
//   
//   ------------------------------------  
//    Revision:
//      March-2023 - Initial version.
//    End Revision:
//---------------------------------------  

module IO_BUF
  (
    input  logic I,     
    input  logic T,
    inout  wire  IO,
    output logic O
  );
  
  iobuf iobuf_inst (.I(I),.IO(IO),.T(T),.O(O));
  
endmodule 
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 
//    Version     : 0.1
//    Description : IO_BUF_DS IO Primitive
//    Filename    : IO_BUF_DS.sv
//   
//   ------------------------------------  
//    Revision:
//      March-2023 - Initial version.
//    End Revision:
//---------------------------------------  

module IO_BUF_DS
  (
    input  logic I,     
    input  logic T,
    inout  wire IOP,
    inout  wire ION,
    output logic O
  );

  iobufds iobufds_inst (.I(I),.IOP(IOP),.ION(ION),.T(T),.O(O));

endmodule 
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 
//    Version     : 0.1
//    Description : OBUF IO Primitive
//    Filename    : OBUF.sv
//   
//   ------------------------------------  
//    Revision:
//      March-2023 - Initial version.
//    End Revision:
//---------------------------------------  

module O_BUF #(
  parameter PULL_UP_DOWN = "NONE",
  parameter SLEW_RATE = "SLOW",
  parameter REG_EN = "TRUE",
  parameter DELAY = 0
  )(
    input  logic I,     // Input
    input  logic C,     // Clock in case of REG_EN is true
    output logic O      // Output             
  );

  obuf #(.PULL_UP_DOWN(PULL_UP_DOWN ), .SLEW_RATE(SLEW_RATE), .DELAY(DELAY),.REG_EN(REG_EN)) 
  obuf_inst (.I(I),.C(C),.O(O));

  // synopsys translate_off

  initial begin
    assert (REG_EN == "FALSE" ||  REG_EN == "TRUE")               else $error("Incorrect REG_EN Value");
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")          else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                            else $error("DELAY parameter out of range");
    assert (PULL_UP_DOWN == "UP" ||  PULL_UP_DOWN == "DOWN" ||  PULL_UP_DOWN == "NONE")   else $error("Incorrect PULL_UP_DOWN Value");
  end 

  // synopsys translate_on

endmodule 
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : OBUFT IO Primitive
//   Filename    : OBUFT.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//---------------------------------------- 

module O_BUFT  #(
    parameter SLEW_RATE = "SLOW",
    parameter DELAY = 0
  )(
    input  logic I,             
    input  logic OE,
    output logic O              
  );
  
  obuft #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY))
  O_BUFT_dut (.I(I),.OE(OE),.O(O));
  // synopsys translate_off
 
  initial begin
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")    else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                      else $error("DELAY parameter out of range");
  end 
  // synopsys translate_on
  
endmodule 
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : O_BUFT_DS IO Primitive
//   Filename    : O_BUFT_DS.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//---------------------------------------- 

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

  obuftds #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY)) 
  obuftds_inst (.OE(OE), .I(I), .O_N(O_N), .O_P(O_P), .C(C));
  // synopsys translate_off
 
  initial begin
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")    else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                      else $error("DELAY parameter out of range");
  end 
  // synopsys translate_on

endmodule 
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : O_DDR IO Primitive
//   Filename    : O_DDR.sv
//   
//   -------------------------------------  
//   Revision:
//     March-2023 - Initial version.
//   End Revision:
//---------------------------------------- 

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


  oddr #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY)) 
  oddr_inst (.D(D),.R(R),.C(C),.Q(Q),.DLY_ADJ(DLY_ADJ),.DLY_LD(DLY_LD),.DLY_INC(DLY_INC));
     
  // synopsys translate_off
  initial begin
    assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")    else $error("Incorrect SLEW_RATE Value");
    assert (DELAY >= 0 && DELAY <= 63)                      else $error("DELAY parameter out of range");
  end 
   // synopsys translate_on


endmodule 
`timescale 1ns/1ps
//---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 
//   Version     : 0.1
//   Description : OSERDES Primitive
//   Filename    : O_SERDES.sv
//   
//   -------------------------------------  
//   Revision:
//     April-2023 - Initial version.
//   End Revision:
//---------------------------------------- 
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

    oserdes #(
      .DATA_RATE(DATA_RATE),  
      .CLOCK_PHASE(CLOCK_PHASE),    
      .WIDTH(WIDTH),              
      .DELAY(DELAY)               
    ) O_SERDES_inst (
      .D(D),                     
      .RST(RST),
      .DLY_LOAD(DLY_LOAD),
      .DLY_ADJ(DLY_ADJ),
      .DLY_INCDEC(DLY_INCDEC),
      .CLK_EN(CLK_EN),
      .CLK_IN(CLK_IN),
      .PLL_LOCK(PLL_LOCK),
      .PLL_FAST_CLK(PLL_FAST_CLK),
      .FAST_PHASE_CLK(FAST_PHASE_CLK),
      .OE(OE),
      .CLK_OUT(CLK_OUT),
      .Q(Q),                  
      .LOAD_WORD(LOAD_WORD),
      .DLY_TAP_VALUE(DLY_TAP_VALUE), 
      .CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
      .CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT)
    ); 

    initial begin
      assert (DATA_RATE == "DDR"  || DATA_RATE == "SDR")   else   $error("Incorrect DDR_RATE value");
      assert (WIDTH >= 3  && WIDTH <= 10)                  else   $error("Incorrect WIDTH value");
      assert (DELAY >= 0  && DELAY <= 63)                  else   $error("DELAY parameter out of range");

    end

endmodule