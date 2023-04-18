// ---------------------------------------- //
// --------------- IO MODEL --------------- //
// --------------- TECHMAP ---------------- //
// ---------------------------------------- //


// ---------------------------------------- 

module CLK_BUF (
    input  logic I,             
    output logic O              
    );

    clkbuf _TECHMAP_REPLACE_ (.I(I), .O(O));

endmodule


// ---------------------------------------- 

module I_BUF#(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 0
    )(
        input  logic I, 
        input  logic C,            
        output logic O             
    );

    ibuf #(.PULL_UP_DOWN(PULL_UP_DOWN ), .SLEW_RATE(SLEW_RATE), .DELAY(DELAY),.REG_EN(REG_EN)) 
    TECHMAP_REPLACE_ (.I(I),.C(C),.O(O));

endmodule 


// ---------------------------------------- 

module I_BUF_DS  #(
        parameter SLEW_RATE = 1,
        parameter DELAY = 0
    )( 
        input  logic OE,
        input  logic I_N,
        input  logic I_P,             
        output logic O    
    );
    
    obuftds #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY)) 
    TECHMAP_REPLACE_ (.OE(OE), .I(I), .O_N(O_N), .O_P(O_P), .C(C));
    
endmodule


// ---------------------------------------- 

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

    iddr  #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY))  
    TECHMAP_REPLACE_(.D(D),.R(R),.C(C),.Q(Q),.DLY_LD(DLY_LD),.DLY_ADJ(DLY_ADJ),.DLY_INC(DLY_INC));

endmodule


// ---------------------------------------- 

module O_BUF#(
        parameter PULL_UP_DOWN = "NONE",
        parameter SLEW_RATE = "SLOW",
        parameter REG_EN = "TRUE",
        parameter DELAY = 00
    )(
        input  logic I,     
        input  logic C,    
        output logic O          
    );

    obuf #(.PULL_UP_DOWN(PULL_UP_DOWN ), .SLEW_RATE(SLEW_RATE), .DELAY(DELAY),.REG_EN(REG_EN)) 
    TECHMAP_REPLACE_ (.I(I),.C(C),.O(O));


endmodule


// ---------------------------------------- 

module O_BUFT_DS #(
        parameter SLEW_RATE = 1,
        parameter DELAY = 0
    )( 
        input  logic OE,
        input  logic I,       
        input  logic C,           
        output logic O_N,
        output logic O_P             
    );

    obuftds #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY)) 
    TECHMAP_REPLACE_ (.OE(OE), .I(I), .O_N(O_N), .O_P(O_P), .C(C));

endmodule


// ---------------------------------------- 

module O_BUFT#(
    parameter SLEW_RATE = 1,
    parameter DELAY = 0
  )(
    input  logic I,             
    input  logic OE,
    output logic O              
  );
    
  obuft #(.SLEW_RATE(SLEW_RATE), .DELAY(DELAY))
  TECHMAP_REPLACE_ (.I(I),.OE(OE),.O(O));

endmodule  


// ---------------------------------------- 

module O_DDR #(
    parameter SLEW_RATE = 1,
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
  TECHMAP_REPLACE_ (.D(D),.R(R),.C(C),.Q(Q),.DLY_ADJ(DLY_ADJ),.DLY_LD(DLY_LD),.DLY_INC(DLY_INC));
  

endmodule