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