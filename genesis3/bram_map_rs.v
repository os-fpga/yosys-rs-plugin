`celldefine
module TDP_RAM36K #(
  parameter [32767:0] INIT = {32768{1'b0}}, // Initial Contents of memory
  parameter [2047:0] INIT_PARITY = {2048{1'b0}}, // Initial Contents of memory
  parameter WRITE_WIDTH_A = 36, // Write data width on port A (1-36)
  parameter READ_WIDTH_A = WRITE_WIDTH_A, // Read data width on port A (1-36)
  parameter WRITE_WIDTH_B = WRITE_WIDTH_A, // Write data width on port B (1-36)
  parameter READ_WIDTH_B = READ_WIDTH_A // Read data width on port B (1-36)
  ) (
  input wire WEN_A,
  input wire WEN_B,
  input wire REN_A,
  input wire REN_B,
  input wire CLK_A,
  input wire CLK_B,
  input wire [3:0] BE_A,
  input wire [3:0] BE_B,
  input wire [14:0] ADDR_A,
  input wire [14:0] ADDR_B,
  input wire [31:0] WDATA_A,
  input wire [3:0] WPARITY_A,
  input wire [31:0] WDATA_B,
  input wire [3:0] WPARITY_B,
  output reg [31:0] RDATA_A,
  output reg [3:0] RPARITY_A,
  output reg [31:0] RDATA_B,
  output reg [3:0] RPARITY_B
);
endmodule
`endcelldefine 

`celldefine
module TDP_RAM18KX2 #(
  parameter [16383:0] INIT1 = {16384{1'b0}}, // Initial Contents of data memory, RAM 1
  parameter [2047:0] INIT1_PARITY = {2048{1'b0}}, // Initial Contents of parity memory, RAM 1
  parameter WRITE_WIDTH_A1 = 18, // Write data width on port A, RAM 1 (1-18)
  parameter WRITE_WIDTH_B1 = 18, // Write data width on port B, RAM 1 (1-18)
  parameter READ_WIDTH_A1 = 18, // Read data width on port A, RAM 1 (1-18)
  parameter READ_WIDTH_B1 = 18, // Read data width on port B, RAM 1 (1-18)
  parameter [16383:0] INIT2 = {16384{1'b0}}, // Initial Contents of memory, RAM 2
  parameter [2047:0] INIT2_PARITY = {2048{1'b0}}, // Initial Contents of memory, RAM 2
  parameter WRITE_WIDTH_A2 = 18, // Write data width on port A, RAM 2 (1-18)
  parameter WRITE_WIDTH_B2 = 18, // Write data width on port B, RAM 2 (1-18)
  parameter READ_WIDTH_A2 = 18, // Read data width on port A, RAM 2 (1-18)
  parameter READ_WIDTH_B2 = 18 // Read data width on port B, RAM 2 (1-18)
  ) (
  input  WEN_A1,
  input  WEN_B1,
  input  REN_A1,
  input  REN_B1,
  input  CLK_A1,
  input  CLK_B1,
  input  [1:0] BE_A1,
  input  [1:0] BE_B1,
  input  [13:0] ADDR_A1,
  input  [13:0] ADDR_B1,
  input  [15:0] WDATA_A1,
  input  [1:0] WPARITY_A1,
  input  [15:0] WDATA_B1,
  input  [1:0] WPARITY_B1,
  output reg [15:0] RDATA_A1,
  output reg [1:0] RPARITY_A1,
  output reg [15:0] RDATA_B1,
  output reg [1:0] RPARITY_B1,
  input  WEN_A2,
  input  WEN_B2,
  input  REN_A2,
  input  REN_B2,
  input  CLK_A2,
  input  CLK_B2,
  input  [1:0] BE_A2,
  input  [1:0] BE_B2,
  input  [13:0] ADDR_A2,
  input  [13:0] ADDR_B2,
  input  [15:0] WDATA_A2,
  input  [1:0] WPARITY_A2,
  input  [15:0] WDATA_B2,
  input  [1:0] WPARITY_B2,
  output reg [15:0] RDATA_A2,
  output reg [1:0] RPARITY_A2,
  output reg [15:0] RDATA_B2,
  output reg [1:0] RPARITY_B2
);
endmodule
`endcelldefine


// TODO:Added as blackbox subject to change
module RS_DSP3 ( 
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
    parameter DSP_CLK = "";
    parameter DSP_RST = "";
    parameter DSP_RST_POL = "";
endmodule


// TODO: Added(as blackbox subject to change) to clear the hierarchy pass (As current DSP19X2.v giving syntax error for yosys read_verilog)
`celldefine
module DSP19X2 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ACCUMULATE)
  parameter [9:0] COEFF1_0 = 10'h000, // Multiplier 1 10-bit A input coefficient 0
  parameter [9:0] COEFF1_1 = 10'h000, // Multiplier 1 10-bit A input coefficient 1
  parameter [9:0] COEFF1_2 = 10'h000, // Multiplier 1 10-bit A input coefficient 2
  parameter [9:0] COEFF1_3 = 10'h000, // Multiplier 1 10-bit A input coefficient 3
  parameter [9:0] COEFF2_0 = 10'h000, // Multiplier 2 10-bit A input coefficient 0
  parameter [9:0] COEFF2_1 = 10'h000, // Multiplier 2 10-bit A input coefficient 1
  parameter [9:0] COEFF2_2 = 10'h000, // Multiplier 2 10-bit A input coefficient 2
  parameter [9:0] COEFF2_3 = 10'h000, // Multiplier 2 10-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
  ) (
  input  [9:0] A1,
  input  [8:0] B1,
  output  [18:0] Z1,
  output  [8:0] DLY_B1,
  input  [9:0] A2,
  input  [8:0] B2,
  output  [18:0] Z2,
  output  [8:0] DLY_B2,
  input  CLK,
  input  RESET,
  input  [4:0] ACC_FIR,
  input  [2:0] FEEDBACK,
  input  LOAD_ACC,
  input  UNSIGNED_A,
  input  UNSIGNED_B,
  input  SATURATE,
  input  [4:0] SHIFT_RIGHT,
  input  ROUND,
  input  SUBTRACT
);
endmodule
`endcelldefine