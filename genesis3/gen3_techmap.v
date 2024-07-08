module I_SERDES_rs (...);
parameter DATA_RATE = "SDR"; // Single or double data rate (SDR/DDR)
parameter WIDTH = 4; // Width of Deserialization (3-10)
parameter DPA_MODE = "NONE"; // Select Dynamic Phase Alignment or Clock Data Recovery (NONE/DPA/CDR)
input  D;
input  RX_RST;
input  BITSLIP_ADJ;
input  EN;
input  CLK_IN;
output  CLK_OUT;
output  [WIDTH-1:0] Q;
output  DATA_VALID;
output  DPA_LOCK;
output  DPA_ERROR;
input  PLL_LOCK;
input  PLL_CLK;

I_SERDES #(
    .DATA_RATE(DATA_RATE),
    .WIDTH(WIDTH),
    .DPA_MODE(DPA_MODE)
)
_TECHMAP_REPLACE_ (
    .D(D),              
    .RX_RST(RX_RST),        
    .BITSLIP_ADJ(BITSLIP_ADJ),   
    .EN(EN),            
    .CLK_IN(CLK_IN),        
    .CLK_OUT(CLK_OUT),           
    .Q(Q),     
    .DATA_VALID(DATA_VALID),       
    .DPA_LOCK(DPA_LOCK),
    .DPA_ERROR(DPA_ERROR),
    .PLL_LOCK(PLL_LOCK),          
    .PLL_CLK(PLL_CLK)         
  );


endmodule

module O_SERDES_rs(...);

parameter DATA_RATE = "SDR"; // Single or double data rate (SDR/DDR)
parameter WIDTH = 4; // Width of input data to serializer (3-10)

input  [WIDTH-1:0] D;
input  RST;
input  LOAD_WORD;
input  CLK_IN;
input  OE_IN;
output OE_OUT;
output Q;
input  CHANNEL_BOND_SYNC_IN;
output CHANNEL_BOND_SYNC_OUT;
input  PLL_LOCK;
input  PLL_CLK;

O_SERDES #(.DATA_RATE(DATA_RATE),.WIDTH(WIDTH)) 
_TECHMAP_REPLACE_ (
  .D(D),      // D input bus
  .RST(RST),           // Active-low, asynchronous reset
  .LOAD_WORD(LOAD_WORD),     // Load word input
  .CLK_IN(CLK_IN),        // Fabric clock input
  .OE_IN(OE_IN),         // Output tri-state enable input
  .OE_OUT(OE_OUT),            // Output tri-state enable output (conttect to O_BUFT or inferred tri-state signal)
  .Q(Q),             // Data output (Connect to output port, buffer or O_DELAY)
  .CHANNEL_BOND_SYNC_IN(CHANNEL_BOND_SYNC_IN),
  .CHANNEL_BOND_SYNC_OUT(CHANNEL_BOND_SYNC_OUT),
  .PLL_LOCK(PLL_LOCK),          // PLL lock input
  .PLL_CLK(PLL_CLK)         // PLL clock input
);
endmodule

module PLL_rs(...);

parameter DIVIDE_CLK_IN_BY_2 = "FALSE"; // Enable input divider (TRUE/FALSE)
parameter PLL_MULT = 16; // VCO clock multiplier value (16-1000)
parameter PLL_DIV = 1; // VCO clock divider value (1-63)
parameter PLL_POST_DIV = 2; // VCO clock post-divider value (2,4,6,8,10,12,14,16,18,20,24,28,30,32,36,40,42,48,50,56,60,70,72,84,98)

input  PLL_EN;
input  CLK_IN;
output reg CLK_OUT;
output reg CLK_OUT_DIV2;
output reg CLK_OUT_DIV3;
output reg CLK_OUT_DIV4;
output reg SERDES_FAST_CLK;
output reg LOCK;

PLL #(.DIVIDE_CLK_IN_BY_2 (DIVIDE_CLK_IN_BY_2),
      .PLL_MULT (PLL_MULT),
      .PLL_DIV (PLL_DIV),
      .PLL_POST_DIV (PLL_POST_DIV) 
) 
_TECHMAP_REPLACE_(
  
  .PLL_EN(PLL_EN),
  .CLK_IN(CLK_IN),
  .CLK_OUT(CLK_OUT),
  .CLK_OUT_DIV2(CLK_OUT_DIV2),
  .CLK_OUT_DIV3(CLK_OUT_DIV3),
  .CLK_OUT_DIV4(CLK_OUT_DIV4),
  .SERDES_FAST_CLK(SERDES_FAST_CLK),
  .LOCK(LOCK)
);
endmodule

module SOC_FPGA_TEMPERATURE_rs(...);


parameter INITIAL_TEMPERATURE = 25;
parameter TEMPERATURE_FILE = "";

output reg [7:0] TEMPERATURE;
output reg VALID;
output reg ERROR;

SOC_FPGA_TEMPERATURE #(
  .INITIAL_TEMPERATURE(INITIAL_TEMPERATURE),
  .TEMPERATURE_FILE(TEMPERATURE_FILE)
  )
_TECHMAP_REPLACE_
(
  .TEMPERATURE(TEMPERATURE),
  .VALID(VALID),
  .ERROR(ERROR)

);
endmodule

module O_SERDES_CLK_rs(...);

parameter DATA_RATE = "SDR"; // Single or double data rate (SDR/DDR)
parameter CLOCK_PHASE = 0; // Clock phase (0,90,180,270)

input  CLK_EN;
output reg OUTPUT_CLK;
input PLL_LOCK;
input PLL_CLK;

O_SERDES_CLK #(.DATA_RATE (DATA_RATE),.CLOCK_PHASE(CLOCK_PHASE))
_TECHMAP_REPLACE_(
.CLK_EN(CLK_EN),
.OUTPUT_CLK(OUTPUT_CLK),
.PLL_LOCK(PLL_LOCK),
.PLL_CLK(PLL_CLK)

);
endmodule

module O_DELAY_rs(...);

parameter DELAY = 0; // TAP delay value (0-63)

input  I;
input  DLY_LOAD;
input  DLY_ADJ;
input  DLY_INCDEC;
output  [5:0] DLY_TAP_VALUE;
input  CLK_IN;
output  O;


O_DELAY#(.DELAY(DELAY))

_TECHMAP_REPLACE_(
  .I(I),
  .DLY_LOAD(DLY_LOAD),
  .DLY_ADJ(DLY_ADJ),
  .DLY_INCDEC(DLY_INCDEC),
  .DLY_TAP_VALUE(DLY_TAP_VALUE),
  .CLK_IN(CLK_IN),
  .O(O)
);
endmodule

module O_BUFT_DS_rs(...);

parameter WEAK_KEEPER = "NONE";
input  I;
input  T;
output  O_P;
output  O_N;

O_BUFT_DS #(.WEAK_KEEPER(WEAK_KEEPER)) _TECHMAP_REPLACE_(

 .I(I),
 .T(T),
 .O_P(O_P),
 .O_N(O_N)
);

endmodule

module BOOT_CLOCK_rs (...);

parameter PERIOD = 25.0; // Clock period for simulation purposes (nS)
output reg O;

BOOT_CLOCK #(.PERIOD(PERIOD)) _TECHMAP_REPLACE_(.O(O));
endmodule

module I_BUF_DS_rs(...);


parameter WEAK_KEEPER = "NONE";
parameter IOSTANDARD = "DEFAULT";
parameter DIFFERENTIAL_TERMINATION = "TRUE" ;


input  I_P;
input  I_N;
input  EN;
output reg O;

I_BUF_DS #(
.WEAK_KEEPER(WEAK_KEEPER),
.IOSTANDARD(IOSTANDARD) ,
.DIFFERENTIAL_TERMINATION (DIFFERENTIAL_TERMINATION)
)_TECHMAP_REPLACE_(
  .I_P(I_P),
  .I_N(I_N),
  .EN(EN),
  .O(O)
);

endmodule