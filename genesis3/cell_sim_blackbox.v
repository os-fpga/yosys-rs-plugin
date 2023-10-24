//
// BOOT_CLOCK black box model
// Internal BOOT_CLK connection
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module BOOT_CLOCK #(
  parameter PERIOD = 25.0 // Clock period for simulation purposes (nS)
  ) (
  output reg O
);
endmodule
`endcelldefine
//
// CARRY_CHAIN black box model
// FLE carry logic
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module CARRY_CHAIN (
  input logic P,
  input logic G,
  input logic CIN,
  output logic O,
  output logic COUT
);
endmodule
`endcelldefine
//
// CLK_BUF black box model
// Global clock buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module CLK_BUF (
  input logic I,
  output logic O
);
endmodule
`endcelldefine
//
// DFFNRE black box model
// Negedge D flipflop with async reset and enable
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DFFNRE (
  input logic D,
  input logic R,
  input logic E,
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// DFFRE black box model
// Posedge D flipflop with async reset and enable
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DFFRE (
  input logic D,
  input logic R,
  input logic E,
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// DSP19X2 black box model
// Paramatizable dual 10x9-bit multiplier accumulator
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
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
  input logic [9:0] A1,
  input logic [8:0] B1,
  output logic [18:0] Z1,
  output logic [8:0] DLY_B1,
  input logic [9:0] A2,
  input logic [8:0] B2,
  output logic [18:0] Z2,
  output logic [8:0] DLY_B2,
  input logic CLK,
  input logic RESET,
  input logic [4:0] ACC_FIR,
  input logic [2:0] FEEDBACK,
  input logic LOAD_ACC,
  input logic UNSIGNED_A,
  input logic UNSIGNED_B,
  input logic SATURATE,
  input logic [4:0] SHIFT_RIGHT,
  input logic ROUND,
  input logic SUBTRACT
);
endmodule
`endcelldefine
//
// DSP38 black box model
// Paramatizable 20x18-bit multiplier accumulator
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module DSP38 #(
  parameter DSP_MODE = "MULTIPLY_ACCUMULATE", // DSP arithmetic mode (MULTIPLY/MULTIPLY_ADD_SUB/MULTIPLY_ACCUMULATE)
  parameter [19:0] COEFF_0 = 20'h00000, // 20-bit A input coefficient 0
  parameter [19:0] COEFF_1 = 20'h00000, // 20-bit A input coefficient 1
  parameter [19:0] COEFF_2 = 20'h00000, // 20-bit A input coefficient 2
  parameter [19:0] COEFF_3 = 20'h00000, // 20-bit A input coefficient 3
  parameter OUTPUT_REG_EN = "TRUE", // Enable output register (TRUE/FALSE)
  parameter INPUT_REG_EN = "TRUE" // Enable input register (TRUE/FALSE)
  ) (
  input logic [19:0] A,
  input logic [17:0] B,
  input logic [5:0] ACC_FIR,
  output logic [37:0] Z,
  output reg [17:0] DLY_B,
  input logic CLK,
  input logic RESET,
  input logic [2:0] FEEDBACK,
  input logic LOAD_ACC,
  input logic SATURATE,
  input logic [5:0] SHIFT_RIGHT,
  input logic ROUND,
  input logic SUBTRACT,
  input logic UNSIGNED_A,
  input logic UNSIGNED_B
);
endmodule
`endcelldefine
//
// FIFO18KX2 black box model
// Dual 18Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module FIFO18KX2 #(
  parameter DATA_WRITE_WIDTH1 = 18, // FIFO data write width, FIFO 1
  parameter DATA_READ_WIDTH1 = 18, // FIFO data read width, FIFO 1
  parameter FIFO_TYPE1 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 1 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH1 = 11'h004, // 11-bit Programmable empty depth, FIFO 1
  parameter [10:0] PROG_FULL_THRESH1 = 11'h7fa, // 11-bit Programmable full depth, FIFO 1
  parameter DATA_WRITE_WIDTH2 = 18, // FIFO data write width, FIFO 2 (1-18)
  parameter DATA_READ_WIDTH2 = 18, // FIFO data read width, FIFO 2 (1-18)
  parameter FIFO_TYPE2 = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer, FIFO 2 (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [10:0] PROG_EMPTY_THRESH2 = 11'h004, // 11-bit Programmable empty depth, FIFO 2
  parameter [10:0] PROG_FULL_THRESH2 = 11'h7fa // 11-bit Programmable full depth, FIFO 2
  ) (
  input logic RESET1,
  input logic WR_CLK1,
  input logic RD_CLK1,
  input logic WR_EN1,
  input logic RD_EN1,
  input logic [DATA_WRITE_WIDTH1-1:0] WR_DATA1,
  output logic [DATA_READ_WIDTH1-1:0] RD_DATA1,
  output logic EMPTY1,
  output logic FULL1,
  output logic ALMOST_EMPTY1,
  output logic ALMOST_FULL1,
  output logic PROG_EMPTY1,
  output logic PROG_FULL1,
  output logic OVERFLOW1,
  output logic UNDERFLOW1,
  input logic RESET2,
  input logic WR_CLK2,
  input logic RD_CLK2,
  input logic WR_EN2,
  input logic RD_EN2,
  input logic [DATA_WRITE_WIDTH2-1:0] WR_DATA2,
  output logic [DATA_READ_WIDTH2-1:0] RD_DATA2,
  output logic EMPTY2,
  output logic FULL2,
  output logic ALMOST_EMPTY2,
  output logic ALMOST_FULL2,
  output logic PROG_EMPTY2,
  output logic PROG_FULL2,
  output logic OVERFLOW2,
  output logic UNDERFLOW2
);
endmodule
`endcelldefine
//
// FIFO36K black box model
// 36Kb FIFO
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module FIFO36K #(
  parameter DATA_WRITE_WIDTH = 36, // FIFO data write width (1-36)
  parameter DATA_READ_WIDTH = 36, // FIFO data read width (1-36)
  parameter FIFO_TYPE = "SYNCHRONOUS", // Synchronous or Asynchronous data transfer (SYNCHRONOUS/ASYNCHRONOUS)
  parameter [11:0] PROG_EMPTY_THRESH = 12'h004, // 12-bit Programmable empty depth
  parameter [11:0] PROG_FULL_THRESH = 12'hffa // 12-bit Programmable full depth
  ) (
  input logic RESET,
  input logic WR_CLK,
  input logic RD_CLK,
  input logic WR_EN,
  input logic RD_EN,
  input logic [DATA_WRITE_WIDTH-1:0] WR_DATA,
  output logic [DATA_READ_WIDTH-1:0] RD_DATA,
  output reg EMPTY,
  output reg FULL,
  output reg ALMOST_EMPTY,
  output reg ALMOST_FULL,
  output reg PROG_EMPTY,
  output reg PROG_FULL,
  output reg OVERFLOW,
  output reg UNDERFLOW
);
endmodule
`endcelldefine
//
// I_BUF black box model
// Input buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_BUF #(
  parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
`ifdef RAPIDSILICON_INTERNAL
  ,   parameter IOSTANDARD = "DEFAULT" // IO Standard
`endif // RAPIDSILICON_INTERNAL
  ) (
  input logic I,
  input logic EN,
  output logic O
);
endmodule
`endcelldefine
//
// I_BUF_DS black box model
// input differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_BUF_DS #(
  parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
`ifdef RAPIDSILICON_INTERNAL
  ,   parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
`endif // RAPIDSILICON_INTERNAL
  ) (
  input logic I_P,
  input logic I_N,
  input logic EN,
  output reg O
);
endmodule
`endcelldefine
//
// I_DDR black box model
// DDR input register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_DDR (
  input logic D,
  input logic R,
  input logic E,
  input logic C,
  output reg [1:0] Q
);
endmodule
`endcelldefine
//
// I_DELAY black box model
// Input Delay
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_DELAY #(
  parameter DELAY = 0 // TAP delay value (0-63)
  ) (
  input logic I,
  input logic DLY_LOAD,
  input logic DLY_ADJ,
  input logic DLY_INCDEC,
  output logic [5:0] DLY_TAP_VALUE,
  input logic CLK_IN,
  output logic O
);
endmodule
`endcelldefine
//
// I_SERDES black box model
// Input Serial Deserializer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module I_SERDES #(
  parameter DATA_RATE = "SDR", // Single or double data rate
  parameter WIDTH = 4, // Width of Deserialization (3-10)
  parameter DPA_MODE = "NONE" // Select Dynamic Phase Alignment or Clock Data Recovery (NONE/DPA/CDR)
  ) (
  input logic D,
  input logic RST,
  input logic FIFO_RST,
  input logic BITSLIP_ADJ,
  input logic EN,
  input logic CLK_IN,
  output logic CLK_OUT,
  output logic [WIDTH-1:0] Q,
  output logic DATA_VALID,
  output logic DPA_LOCK,
  output logic DPA_ERROR,
  input logic PLL_LOCK,
  input logic PLL_CLK
);
endmodule
`endcelldefine
//
// LUT1 black box model
// 1-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT1 #(
  parameter [1:0] INIT_VALUE = 2'h0 // 2-bit LUT logic value
  ) (
  input logic A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT2 black box model
// 2-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT2 #(
  parameter [3:0] INIT_VALUE = 4'h0 // 4-bit LUT logic value
  ) (
  input logic [1:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT3 black box model
// 3-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT3 #(
  parameter [7:0] INIT_VALUE = 8'h00 // 8-bit LUT logic value
  ) (
  input logic [2:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT4 black box model
// 4-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT4 #(
  parameter [15:0] INIT_VALUE = 16'h0000 // 16-bit LUT logic value
  ) (
  input logic [3:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT5 black box model
// 5-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT5 #(
  parameter [31:0] INIT_VALUE = 32'h00000000 // LUT logic value
  ) (
  input logic [4:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// LUT6 black box model
// 6-input lookup table (LUT)
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module LUT6 #(
  parameter [63:0] INIT_VALUE = 64'h0000000000000000 // 64-bit LUT logic value
  ) (
  input logic [5:0] A,
  output logic Y
);
endmodule
`endcelldefine
//
// O_BUF black box model
// Output buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUF
`ifdef RAPIDSILICON_INTERNAL
  #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
  )
`endif // RAPIDSILICON_INTERNAL
  (
  input logic I,
  output logic O
);
endmodule
`endcelldefine
//
// O_BUFT black box model
// Output tri-state buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUFT #(
  parameter WEAK_KEEPER = "NONE" // Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
`ifdef RAPIDSILICON_INTERNAL
  ,   parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DRIVE_STRENGTH = 2, // Drive strength in mA for LVCMOS standards
  parameter SLEW_RATE = "SLOW" // Transition rate for LVCMOS standards
`endif // RAPIDSILICON_INTERNAL
  ) (
  input logic I,
  input logic T,
  output logic O
);
endmodule
`endcelldefine
//
// O_BUFT_DS black box model
// Output differential tri-state buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUFT_DS #(
  parameter WEAK_KEEPER = "NONE" // Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
`ifdef RAPIDSILICON_INTERNAL
  ,   parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
`endif // RAPIDSILICON_INTERNAL
  ) (
  input logic I,
  input logic T,
  output logic O_P,
  output logic O_N
);
endmodule
`endcelldefine
//
// O_BUF_DS black box model
// Output differential buffer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_BUF_DS
`ifdef RAPIDSILICON_INTERNAL
  #(
  parameter IOSTANDARD = "DEFAULT", // IO Standard
  parameter DIFFERENTIAL_TERMINATION = "TRUE" // Enable differential termination
  )
`endif // RAPIDSILICON_INTERNAL
  (
  input logic I,
  output logic O_P,
  output logic O_N
);
endmodule
`endcelldefine
//
// O_DDR black box model
// DDR output register
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_DDR (
  input logic [1:0] D,
  input logic R,
  input logic E,
  input logic C,
  output reg Q
);
endmodule
`endcelldefine
//
// O_DELAY black box model
// Serdes output
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_DELAY #(
  parameter DELAY = 0 // TAP delay value (0-63)
  ) (
  input logic I,
  input logic DLY_LOAD,
  input logic DLY_ADJ,
  input logic DLY_INCDEC,
  output logic [5:0] DLY_TAP_VALUE,
  input logic CLK_IN,
  output logic O
);
endmodule
`endcelldefine
//
// O_SERDES black box model
// Output Serializer
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module O_SERDES #(
  parameter DATA_RATE = "SDR", // Single or double data rate (SDR/DDR)
  parameter WIDTH = 4, // Width of input data to serializer
  parameter CLOCK_PHASE = 0, // Clock phase
  parameter TX_MODE = "DATA" // Data or Clock output (DATA/CLOCK)
  ) (
  input logic [WIDTH-1:0] D,
  input logic RST,
  input logic LOAD_WORD,
  output logic OE,
  input logic CLK_EN,
  input logic CLK_IN,
  output logic CLK_OUT,
  output logic Q,
  input logic CHANNEL_BOND_SYNC_IN,
  output logic CHANNEL_BOND_SYNC_OUT,
  input logic PLL_LOCK,
  input logic PLL_CLK
);
endmodule
`endcelldefine
//
// PLL black box model
// Phase locked loop
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module PLL #(
  parameter DIVIDE_CLK_IN_BY_2 = "FALSE", // Enable input divider (TRUE/FALSE)
  parameter PLL_MULT = 16, // Clock multiplier value (16-1000)
  parameter PLL_DIV = 1, // Clock divider value (1-63)
  parameter CLK_OUT0_DIV = 2, // CLK_OUT0 divider value (2,3,4,5,6,7,8,10,12,16,20.24.32.40,48,64)
  parameter CLK_OUT1_DIV = 2, // CLK_OUT1 divider value (2,3,4,5,6,7,8,10,12,16,20.24.32.40,48,64)
  parameter CLK_OUT2_DIV = 2, // CLK_OUT2 divider value (2,3,4,5,6,7,8,10,12,16,20.24.32.40,48,64)
  parameter CLK_OUT3_DIV = 2 // CLK_OUT3 divider value (2,3,4,5,6,7,8,10,12,16,20.24.32.40,48,64)
  ) (
  input logic PLL_EN,
  input logic CLK_IN,
  input logic CLK_OUT0_EN,
  input logic CLK_OUT1_EN,
  input logic CLK_OUT2_EN,
  input logic CLK_OUT3_EN,
  output logic CLK_OUT0,
  output logic CLK_OUT1,
  output logic CLK_OUT2,
  output logic CLK_OUT3,
  output logic SERDES_FAST_CLK,
  output logic LOCK
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AHB_S black box model
// SOC interface connection AHB Slave
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AHB_S (
  output logic S0_HRESETN_I,
  output logic [31:0] S0_HADDR,
  output logic [2:0] S0_HBURST,
  output logic S0_HMASTLOCK,
  input logic S0_HREADY,
  output logic [3:0] S0_HPROT,
  input logic [31:0] S0_HRDATA,
  input logic S0_HRESP,
  output logic S0_HSEL,
  output logic [2:0] S0_HSIZE,
  output logic [1:0] S0_HTRANS,
  output logic [3:0] S0_HWBE,
  output logic [31:0] S0_HWDATA,
  output logic S0_HWRITE,
  input logic S0_HCLK
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AXI_M0 black box model
// SOC interface connection AXI Master 0
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AXI_M0 (
  input logic [31:0] M0_ARADDR,
  input logic [1:0] M0_ARBURST,
  input logic [3:0] M0_ARCACHE,
  input logic [3:0] M0_ARID,
  input logic [2:0] M0_ARLEN,
  input logic M0_ARLOCK,
  input logic [2:0] M0_ARPROT,
  output logic M0_ARREADY,
  input logic [2:0] M0_ARSIZE,
  input logic M0_ARVALID,
  input logic [31:0] M0_AWADDR,
  input logic [1:0] M0_AWBURST,
  input logic [3:0] M0_AWCACHE,
  input logic [3:0] M0_AWID,
  input logic [2:0] M0_AWLEN,
  input logic M0_AWLOCK,
  input logic [2:0] M0_AWPROT,
  output logic M0_AWREADY,
  input logic [2:0] M0_AWSIZE,
  input logic M0_AWVALID,
  output logic [3:0] M0_BID,
  input logic M0_BREADY,
  output logic [1:0] M0_BRESP,
  output logic M0_BVALID,
  output logic [63:0] M0_RDATA,
  output logic [3:0] M0_RID,
  output logic M0_RLAST,
  input logic M0_RREADY,
  output logic [1:0] M0_RRESP,
  output logic M0_RVALID,
  input logic [63:0] M0_WDATA,
  input logic M0_WLAST,
  output logic M0_WREADY,
  input logic [7:0] M0_WSTRB,
  input logic M0_WVALID,
  input logic M0_ACLK,
  output logic M0_ARESETN_I
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_AXI_M1 black box model
// SOC interface connection AXI Master 1
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_AXI_M1 (
  input logic [31:0] M1_ARADDR,
  input logic [1:0] M1_ARBURST,
  input logic [3:0] M1_ARCACHE,
  input logic [3:0] M1_ARID,
  input logic [2:0] M1_ARLEN,
  input logic M1_ARLOCK,
  input logic [2:0] M1_ARPROT,
  output logic M1_ARREADY,
  input logic [2:0] M1_ARSIZE,
  input logic M1_ARVALID,
  input logic [31:0] M1_AWADDR,
  input logic [1:0] M1_AWBURST,
  input logic [3:0] M1_AWCACHE,
  input logic [3:0] M1_AWID,
  input logic [2:0] M1_AWLEN,
  input logic M1_AWLOCK,
  input logic [2:0] M1_AWPROT,
  output logic M1_AWREADY,
  input logic [2:0] M1_AWSIZE,
  input logic M1_AWVALID,
  output logic [3:0] M1_BID,
  input logic M1_BREADY,
  output logic [1:0] M1_BRESP,
  output logic M1_BVALID,
  output logic [63:0] M1_RDATA,
  output logic [3:0] M1_RID,
  output logic M1_RLAST,
  input logic M1_RREADY,
  output logic [1:0] M1_RRESP,
  output logic M1_RVALID,
  input logic [63:0] M1_WDATA,
  input logic M1_WLAST,
  output logic M1_WREADY,
  input logic [7:0] M1_WSTRB,
  input logic M1_WVALID,
  input logic M1_ACLK,
  output logic M1_ARESETN_I
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_DMA black box model
// SOC DMA interface
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_DMA (
  input logic [3:0] DMA_REQ,
  output logic [3:0] DMA_ACK,
  input logic DMA_CLK,
  input logic DMA_RST_N
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_IRQ black box model
// SOC Interupt connection
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_IRQ (
  input logic [15:0] IRQ_SRC,
  output logic [15:0] IRQ_SET,
  input logic IRQ_CLK,
  input logic IRQ_RST_N
);
endmodule
`endcelldefine
//
// SOC_FPGA_INTF_JTAG black box model
// SOC JTAG connection
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module SOC_FPGA_INTF_JTAG (
  input logic BOOT_JTAG_TCK,
  output logic BOOT_JTAG_TDI,
  input logic BOOT_JTAG_TDO,
  output logic BOOT_JTAG_TMS,
  output logic BOOT_JTAG_TRSTN,
  input logic BOOT_JTAG_EN
);
endmodule
`endcelldefine
//
// TDP_RAM18KX2 black box model
// Dual 18Kb True-dual-port RAM
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
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
  input logic WEN_A1,
  input logic WEN_B1,
  input logic REN_A1,
  input logic REN_B1,
  input logic CLK_A1,
  input logic CLK_B1,
  input logic [1:0] BE_A1,
  input logic [1:0] BE_B1,
  input logic [13:0] ADDR_A1,
  input logic [13:0] ADDR_B1,
  input logic [15:0] WDATA_A1,
  input logic [1:0] WPARITY_A1,
  input logic [15:0] WDATA_B1,
  input logic [1:0] WPARITY_B1,
  output reg [15:0] RDATA_A1,
  output reg [1:0] RPARITY_A1,
  output reg [15:0] RDATA_B1,
  output reg [1:0] RPARITY_B1,
  input logic WEN_A2,
  input logic WEN_B2,
  input logic REN_A2,
  input logic REN_B2,
  input logic CLK_A2,
  input logic CLK_B2,
  input logic [1:0] BE_A2,
  input logic [1:0] BE_B2,
  input logic [13:0] ADDR_A2,
  input logic [13:0] ADDR_B2,
  input logic [15:0] WDATA_A2,
  input logic [1:0] WPARITY_A2,
  input logic [15:0] WDATA_B2,
  input logic [1:0] WPARITY_B2,
  output reg [15:0] RDATA_A2,
  output reg [1:0] RPARITY_A2,
  output reg [15:0] RDATA_B2,
  output reg [1:0] RPARITY_B2
);
endmodule
`endcelldefine
//
// TDP_RAM36K black box model
// 36Kb True-dual-port RAM
//
// Copyright (c) 2023 Rapid Silicon, Inc.  All rights reserved.
//
`celldefine
(* blackbox *)
module TDP_RAM36K #(
  parameter [32767:0] INIT = {32768{1'b0}}, // Initial Contents of memory
  parameter [2047:0] INIT_PARITY = {2048{1'b0}}, // Initial Contents of memory
  parameter WRITE_WIDTH_A = 36, // Write data width on port A (1-36)
  parameter READ_WIDTH_A = WRITE_WIDTH_A, // Read data width on port A (1-36)
  parameter WRITE_WIDTH_B = WRITE_WIDTH_A, // Write data width on port B (1-36)
  parameter READ_WIDTH_B = READ_WIDTH_A // Read data width on port B (1-36)
  ) (
  input logic WEN_A,
  input logic WEN_B,
  input logic REN_A,
  input logic REN_B,
  input logic CLK_A,
  input logic CLK_B,
  input logic [3:0] BE_A,
  input logic [3:0] BE_B,
  input logic [14:0] ADDR_A,
  input logic [14:0] ADDR_B,
  input logic [31:0] WDATA_A,
  input logic [3:0] WPARITY_A,
  input logic [31:0] WDATA_B,
  input logic [3:0] WPARITY_B,
  output reg [31:0] RDATA_A,
  output reg [3:0] RPARITY_A,
  output reg [31:0] RDATA_B,
  output reg [3:0] RPARITY_B
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
