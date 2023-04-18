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
  input  logic I_N,
  input  logic I_P,             
  output logic O    
);

ibufds #(.SLEW_RATE(SLEW_RATE),.DELAY(DELAY)) 
ibufds_inst (.OE(OE), .I_N(I_N),.I_P(I_P),.O(O));
// synopsys translate_off
initial begin
  assert (SLEW_RATE == "SLOW" ||  SLEW_RATE == "FAST")    else $error("Incorrect SLEW_RATE Value");
  assert (DELAY >= 0 && DELAY <= 63)                      else $error("DELAY parameter out of range");
end 
// synopsys translate_on
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