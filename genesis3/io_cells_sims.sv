// ---------------------------------------- //
// -------------- CLK_BUF ----------------- //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module clkbuf (
  input  logic I,             
  output logic O              
  );

  import GBOX_CONFIG::*;
    localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_CLK_BUF_TX;

  // ---------------------------------------- 
  // Internal Signals
  logic system_reset_n;
  logic g2i_tx_clk, g2i_tx_out;

  assign O = GEARBOX_MODE[6] ? I: g2i_tx_out ;

  // initial begin
  //   system_reset_n      = 1'b0;        
  //   #1;
  //   system_reset_n      = 1'b1;        
  // end

  // // ----------------------------------------
  // //  GEAR BOX TOP
  // //  INSTANCE
  // // ---------------------------------------- 
  // gbox_top 
  //     #(
  //     .PAR_TX_DWID(10 ),
  //     .PAR_RX_DWID(10 ),
  //     .PAR_TWID (6 )
  //     )
  // gbox_top_dut (
  //     .system_reset_n (system_reset_n ),
  //     .pll_lock (1'b0 ),
  //     .cfg_rate_sel (GEARBOX_MODE[3:0] ),
  //     .cfg_chan_master (GEARBOX_MODE[4] ),
  //     .cfg_peer_is_on (GEARBOX_MODE[5] ),
  //     //.cfg_tx_clk_io(GEARBOX_MODE[6]),
  //     .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
  //     .cfg_tx_bypass (GEARBOX_MODE[9] ),
  //     .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
  //     // .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
  //     .cfg_tx_dly (DELAY), 
  //     .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
  //     .cfg_rx_bypass (GEARBOX_MODE[20] ),
  //     .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
  //     .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
  //     // .cfg_mipi_mode(GEARBOX_MODE[29])
  //     .cfg_tx_mode (GEARBOX_MODE[30] ),
  //     .cfg_rx_mode (GEARBOX_MODE[31] ),
  //     .cfg_dif (GEARBOX_MODE[32] ),
  //     .cfg_done (1'b1 ),
  //     .fast_clk ( I),
  //     .i2g_rx_in (),
  //     .fast_phase_clk ({I.I.I}),
  //     .f2g_tx_reset_n ( 1'b1),
  //     .f2g_trx_core_clk (I),
  //     .f2g_tx_dly_ld (),
  //     .f2g_tx_dly_adj ( 'b0),
  //     .f2g_tx_dly_inc ( 'b0),
  //     .f2g_tx_oe (1'b1),
  //     .f2g_tx_out ({'b0}),
  //     .f2g_in_en ( 'b0),
  //     .f2g_tx_dvalid (1'b1 ),
  //     .f2g_rx_reset_n ('b0),
  //     .f2g_rx_sfifo_reset ('b0 ),
  //     .f2g_rx_dly_ld ('b0),
  //     .f2g_rx_dly_adj ('b0 ),
  //     .f2g_rx_dly_inc ( 'b0),
  //     .f2g_rx_bitslip_adj ('b0),
  //     .f2g_rx_dpa_restart ('b0),
  //     .fast_clk_sync_in ( 'b0),
  //     .fast_cdr_clk_sync_in ('b0 ),
  //     .peer_data_in ('b0),
  //     .fast_clk_sync_out ( ),
  //     .fast_cdr_clk_sync_out (),
  //     .g2i_tx_out (g2i_tx_out),
  //     .g2i_tx_oe ( ),
  //     .g2i_tx_clk (g2i_tx_clk),
  //     .g2i_ie ( ),
  //     .cdr_clk (),
  //     .g2f_tx_dly_tap (),
  //     .g2f_core_clk ( ),
  //     .g2f_rx_cdr_core_clk ( ),
  //     .g2f_rx_dpa_lock ( ),
  //     .g2f_rx_dpa_error ( ),
  //     .g2f_rx_dpa_phase ( ),
  //     .g2f_rx_dly_tap ( ),
  //     .g2f_rx_in (),
  //     .g2f_rx_dvalid ()
  // );
endmodule 
// ---------------------------------------- //
// --------------- I_BUF ------------------ //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module ibuf#(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 0
    )(
        input  logic I, 
        input  logic C,            
        output logic O             
    );

    import GBOX_CONFIG::*;
    localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = (PULL_UP_DOWN == "NONE")?  (REG_EN =="TRUE")? MODE_BP_SDR_RX : MODE_BP_DIR_RX:
                                                     (PULL_UP_DOWN == "UP")? MODE_PULLUP : MODE_PULLDOWN;
                                                    

    // ---------------------------------------- 
    // Internal Signals
    logic system_reset_n;
    logic dly_ld;

    initial begin
        dly_ld = 1;
        system_reset_n      = 1'b0;        
        #1;
        system_reset_n      = 1'b1;
        repeat(4) @(posedge C); 
        dly_ld = 0;        
    end

    // ----------------------------------------
    //  GEAR BOX TOP
    //  INSTANCE
    // ---------------------------------------- 
    gbox_top 
        #(
        .PAR_TX_DWID(10 ),
        .PAR_RX_DWID(10 ),
        .PAR_TWID (6 )
        )
    gbox_top_dut (
        .system_reset_n (system_reset_n ),
        .pll_lock (1'b1 ),
        .cfg_rate_sel (GEARBOX_MODE[3:0] ),
        .cfg_chan_master (GEARBOX_MODE[4] ),
        .cfg_peer_is_on (GEARBOX_MODE[5] ),
        //.cfg_tx_clk_io(GEARBOX_MODE[6]),
        .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
        .cfg_tx_bypass (GEARBOX_MODE[9] ),
        .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
        .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
        .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
        .cfg_rx_bypass (GEARBOX_MODE[20] ),
        // .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
        .cfg_rx_dly (DELAY ), 
        .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
        // .cfg_mipi_mode(GEARBOX_MODE[29])
        .cfg_tx_mode (GEARBOX_MODE[30] ),
        .cfg_rx_mode (GEARBOX_MODE[31] ),
        .cfg_dif (GEARBOX_MODE[32] ),
        .cfg_done (1'b1 ),
        .fast_clk (C),
        .i2g_rx_in (I),
        .fast_phase_clk (),
        .f2g_tx_reset_n ( 1'b0),
        .f2g_trx_core_clk (C),
        .f2g_tx_dly_ld (),
        .f2g_tx_dly_adj ( 'b0),
        .f2g_tx_dly_inc ( 'b0),
        .f2g_tx_oe (1'b1),
        .f2g_tx_out (),
        .f2g_in_en ( 'b0),
        .f2g_tx_dvalid (1'b0 ),
        .f2g_rx_reset_n ('b1),
        .f2g_rx_sfifo_reset ('b0 ),
        .f2g_rx_dly_ld (dly_ld),
        .f2g_rx_dly_adj ('b0 ),
        .f2g_rx_dly_inc ( 'b0),
        .f2g_rx_bitslip_adj ('b0),
        .f2g_rx_dpa_restart ('b0),
        .fast_clk_sync_in ( 'b0),
        .fast_cdr_clk_sync_in ('b0 ),
        .peer_data_in ('b0),
        .fast_clk_sync_out ( ),
        .fast_cdr_clk_sync_out (),
        .g2i_tx_out (),
        .g2i_tx_oe ( ),
        .g2i_tx_clk (),
        .g2i_ie ( ),
        .cdr_clk (),
        .g2f_tx_dly_tap (),
        .g2f_core_clk ( ),
        .g2f_rx_cdr_core_clk (),
        .g2f_rx_dpa_lock ( ),
        .g2f_rx_dpa_error ( ),
        .g2f_rx_dpa_phase ( ),
        .g2f_rx_dly_tap ( ),
        .g2f_rx_in (O),
        .g2f_rx_dvalid ()
    );

endmodule 
// ---------------------------------------- //
// -------------- I_BUF_DS ---------------- //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module ibufds  #(
    parameter SLEW_RATE = 1,
    parameter DELAY = 0
  )( 
    input  logic OE,
    input  logic I_N,
    input  logic C,
    input  logic I_P,             
    output logic O    
  );
  import GBOX_CONFIG::*;
  localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_DIFFS_RX;
  
  
  // ---------------------------------------- 
  // Internal Signals
  logic system_reset_n;
  logic Oin;
  
  assign O = OE?Oin:1'bZ;
  
  initial begin
  system_reset_n      = 1'b0;        
  #1;
  system_reset_n      = 1'b1;        
  end
  
  // ----------------------------------------
  //  GEAR BOX TOP
  //  INSTANCE
  // ---------------------------------------- 
  gbox_top 
  #(
  .PAR_TX_DWID(10 ),
  .PAR_RX_DWID(10 ),
  .PAR_TWID (6 )
  )
  gbox_top_dut (
  .system_reset_n (system_reset_n ),
  .pll_lock (1'b1 ),
  .cfg_rate_sel (GEARBOX_MODE[3:0] ),
  .cfg_chan_master (GEARBOX_MODE[4] ),
  .cfg_peer_is_on (GEARBOX_MODE[5] ),
  //.cfg_tx_clk_io(GEARBOX_MODE[6]),
  .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
  .cfg_tx_bypass (GEARBOX_MODE[9] ),
  .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
  .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
  .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
  .cfg_rx_bypass (GEARBOX_MODE[20] ),
  .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
  .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
  // .cfg_mipi_mode(GEARBOX_MODE[29])
  .cfg_tx_mode (GEARBOX_MODE[30] ),
  .cfg_rx_mode (GEARBOX_MODE[31] ),
  .cfg_dif (GEARBOX_MODE[32] ),
  .cfg_done (1'b1 ),
  .fast_clk (C),
  .i2g_rx_in (I_P),
  .fast_phase_clk ( 'b0),
  .f2g_tx_reset_n ( 1'b0),
  .f2g_trx_core_clk ( ),
  .f2g_tx_dly_ld (),
  .f2g_tx_dly_adj ( 'b0),
  .f2g_tx_dly_inc ( 'b0),
  .f2g_tx_oe (1'b1),
  .f2g_tx_out (),
  .f2g_in_en ( 'b0),
  .f2g_tx_dvalid (1'b1 ),
  .f2g_rx_reset_n ('b1),
  .f2g_rx_sfifo_reset ('b1 ),
  .f2g_rx_dly_ld ('b0),
  .f2g_rx_dly_adj ('b0 ),
  .f2g_rx_dly_inc ( 'b0),
  .f2g_rx_bitslip_adj ('b0),
  .f2g_rx_dpa_restart ('b0),
  .fast_clk_sync_in ( 'b0),
  .fast_cdr_clk_sync_in ('b0 ),
  .peer_data_in ('b0),
  .fast_clk_sync_out ( ),
  .fast_cdr_clk_sync_out (),
  .g2i_tx_out (),
  .g2i_tx_oe ( ),
  .g2i_tx_clk ( ),
  .g2i_ie ( ),
  .cdr_clk (),
  .g2f_tx_dly_tap (),
  .g2f_core_clk ( ),
  .g2f_rx_cdr_core_clk ( ),
  .g2f_rx_dpa_lock ( ),
  .g2f_rx_dpa_error ( ),
  .g2f_rx_dpa_phase ( ),
  .g2f_rx_dly_tap ( ),
  .g2f_rx_in (Oin),
  .g2f_rx_dvalid ()
  );
  
endmodule 
// ---------------------------------------- //
// --------------- I_DDR ------------------ //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module iddr #(
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

  
  import GBOX_CONFIG::*;
  localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_BP_DDR_RX;
  
  
  // ---------------------------------------- 
  // Internal Signals
  logic system_reset_n;
  
  initial begin
    system_reset_n      = 1'b0;        
    #1;
    system_reset_n      = 1'b1;
    repeat(4) @(posedge C); 
end
  
  // ----------------------------------------
  //  GEAR BOX TOP
  //  INSTANCE
  // ---------------------------------------- 
  gbox_top 
  #(
  .PAR_TX_DWID(10 ),
  .PAR_RX_DWID(10),
  .PAR_TWID (6 )
  )
  gbox_top_dut (
  .system_reset_n (system_reset_n ),
  .pll_lock (1'b1 ),
  .cfg_rate_sel (GEARBOX_MODE[3:0] ),
  .cfg_chan_master (GEARBOX_MODE[4] ),
  .cfg_peer_is_on (GEARBOX_MODE[5] ),
  //.cfg_tx_clk_io(GEARBOX_MODE[6]),
  .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
  .cfg_tx_bypass (GEARBOX_MODE[9] ),
  .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
  .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
  .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
  .cfg_rx_bypass (GEARBOX_MODE[20] ),
  // .cfg_rx_dly (GEARBOX_MODE[26:21]  ),   
  .cfg_rx_dly (DELAY ), 

  .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
  // .cfg_mipi_mode(GEARBOX_MODE[29])
  .cfg_tx_mode (GEARBOX_MODE[30] ),
  .cfg_rx_mode (GEARBOX_MODE[31] ),
  .cfg_dif (GEARBOX_MODE[32] ),
  .cfg_done (1'b1 ),
  .fast_clk (C),
  .i2g_rx_in (D),
  .fast_phase_clk ( 'b0),
  .f2g_tx_reset_n ( 1'b1),
  .f2g_trx_core_clk (C),
  .f2g_tx_dly_ld (),
  .f2g_tx_dly_adj ( 'b0),
  .f2g_tx_dly_inc ( 'b0),
  .f2g_tx_oe (1'b1),
  .f2g_tx_out (),
  .f2g_in_en ( 'b0),
  .f2g_tx_dvalid (1'b1 ),
  .f2g_rx_reset_n (R),
  .f2g_rx_sfifo_reset ('b0 ),
  .f2g_rx_dly_ld (DLY_LD),
  .f2g_rx_dly_adj (DLY_ADJ),
  .f2g_rx_dly_inc (DLY_INC),
  .f2g_rx_bitslip_adj ('b0),
  .f2g_rx_dpa_restart ('b0),
  .fast_clk_sync_in ( 'b0),
  .fast_cdr_clk_sync_in ('b0 ),
  .peer_data_in ('b0),
  .fast_clk_sync_out ( ),
  .fast_cdr_clk_sync_out (),
  .g2i_tx_out (),
  .g2i_tx_oe ( ),
  .g2i_tx_clk ( ),
  .g2i_ie ( ),
  .cdr_clk (),
  .g2f_tx_dly_tap (),
  .g2f_core_clk ( ),
  .g2f_rx_cdr_core_clk ( ),
  .g2f_rx_dpa_lock ( ),
  .g2f_rx_dpa_error ( ),
  .g2f_rx_dpa_phase ( ),
  .g2f_rx_dly_tap ( ),
  .g2f_rx_in (Q),
  .g2f_rx_dvalid ()
  );
  
  endmodule 
    
// ---------------------------------------- //
// -------------- IO_BUF ------------------ //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module iobuf
( 
  input  logic I,     
  input  logic T,
  inout  wire  IO,
  output logic O
);
import GBOX_CONFIG::*;
localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_IO_BUF;


// ---------------------------------------- 
// Internal Signals
logic system_reset_n;
wire I_in, O_in;

assign IO = T ? 1'bz:O_in;
assign I_in = IO;
initial begin
system_reset_n      = 1'b0;        
#1;
system_reset_n      = 1'b1;        
end

// ----------------------------------------
//  GEAR BOX TOP
//  INSTANCE
// ---------------------------------------- 
gbox_top 
#(
.PAR_TX_DWID(10 ),
.PAR_RX_DWID(10 ),
.PAR_TWID (6 )
)
gbox_top_dut (
.system_reset_n (system_reset_n ),
.pll_lock (1'b1 ),
.cfg_rate_sel (GEARBOX_MODE[3:0] ),
.cfg_chan_master (GEARBOX_MODE[4] ),
.cfg_peer_is_on (GEARBOX_MODE[5] ),
//.cfg_tx_clk_io(GEARBOX_MODE[6]),
.cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
.cfg_tx_bypass (GEARBOX_MODE[9] ),
.cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
.cfg_tx_dly (GEARBOX_MODE[17:12] ), 
.cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
.cfg_rx_bypass (GEARBOX_MODE[20] ),
.cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
.cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
//   .cfg_mipi_mode(GEARBOX_MODE[29])
.cfg_tx_mode (GEARBOX_MODE[30] ),
.cfg_rx_mode (GEARBOX_MODE[31] ),
.cfg_dif (GEARBOX_MODE[32] ),
.cfg_done (1'b1 ),
.fast_clk ( ),
.i2g_rx_in (I_in),
.fast_phase_clk ( 'b0),
.f2g_tx_reset_n ( 1'b1),
.f2g_trx_core_clk ( ),
.f2g_tx_dly_ld (1'b1),
.f2g_tx_dly_adj ( 1'b0),
.f2g_tx_dly_inc ( 1'b0),
.f2g_tx_oe (~T),
.f2g_tx_out (I),
.f2g_in_en (T),
.f2g_tx_dvalid (1'b1 ),
.f2g_rx_reset_n (1'b0),
.f2g_rx_sfifo_reset (1'b0 ),
.f2g_rx_dly_ld (1'b1),
.f2g_rx_dly_adj (1'b0 ),
.f2g_rx_dly_inc (1 'b0),
.f2g_rx_bitslip_adj (1'b0),
.f2g_rx_dpa_restart (1'b0),
.fast_clk_sync_in (1'b0),
.fast_cdr_clk_sync_in (1'b0 ),
.peer_data_in (1'b0),
.fast_clk_sync_out ( ),
.fast_cdr_clk_sync_out (),
.g2i_tx_out (O_in),
.g2i_tx_oe ( ),
.g2i_tx_clk ( ),
.g2i_ie ( ),
.cdr_clk (),
.g2f_tx_dly_tap (),
.g2f_core_clk ( ),
.g2f_rx_cdr_core_clk ( ),
.g2f_rx_dpa_lock ( ),
.g2f_rx_dpa_error ( ),
.g2f_rx_dpa_phase ( ),
.g2f_rx_dly_tap ( ),
.g2f_rx_in (O),
.g2f_rx_dvalid ()
);

endmodule 
 // ---------------------------------------- //
// -------------- IO_BUF_DS --------------- //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module iobufds
(  
  input  logic I,     
  input  logic T,
  inout  wire  IOP,
  inout  wire  ION,
  output logic O
);

import GBOX_CONFIG::*;
localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_IO_BUF_DS;


// ---------------------------------------- 
// Internal Signals
logic system_reset_n;
wire I_in, O_in;

assign IOP = T ? 1'bz:O_in;
assign ION = T ? 1'bz:~O_in;

assign I_in = IOP;

initial begin
system_reset_n      = 1'b0;        
#1;
system_reset_n      = 1'b1;        
end

// ----------------------------------------
//  GEAR BOX TOP
//  INSTANCE
// ---------------------------------------- 
gbox_top 
#(
.PAR_TX_DWID(10 ),
.PAR_RX_DWID(10 ),
.PAR_TWID (6 )
)
gbox_top_dut (
.system_reset_n (system_reset_n ),
.pll_lock (1'b1 ),
.cfg_rate_sel (GEARBOX_MODE[3:0] ),
.cfg_chan_master (GEARBOX_MODE[4] ),
.cfg_peer_is_on (GEARBOX_MODE[5] ),
//.cfg_tx_clk_io(GEARBOX_MODE[6]),
.cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
.cfg_tx_bypass (GEARBOX_MODE[9] ),
.cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
.cfg_tx_dly (GEARBOX_MODE[17:12] ), 
.cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
.cfg_rx_bypass (GEARBOX_MODE[20] ),
.cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
.cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
//   .cfg_mipi_mode(GEARBOX_MODE[29])
.cfg_tx_mode (GEARBOX_MODE[30] ),
.cfg_rx_mode (GEARBOX_MODE[31] ),

.cfg_dif (GEARBOX_MODE[32] ),
.cfg_done (1'b1 ),
.fast_clk ( ),
.i2g_rx_in (I_in),
.fast_phase_clk ( 'b0),
.f2g_tx_reset_n ( 1'b1),
.f2g_trx_core_clk ( ),
.f2g_tx_dly_ld (1'b1),
.f2g_tx_dly_adj ( 1'b0),
.f2g_tx_dly_inc ( 1'b0),
.f2g_tx_oe (~T),
.f2g_tx_out (I),
.f2g_in_en (T),
.f2g_tx_dvalid (1'b1 ),
.f2g_rx_reset_n (1'b0),
.f2g_rx_sfifo_reset (1'b0 ),
.f2g_rx_dly_ld (1'b1),
.f2g_rx_dly_adj (1'b0 ),
.f2g_rx_dly_inc (1 'b0),
.f2g_rx_bitslip_adj (1'b0),
.f2g_rx_dpa_restart (1'b0),
.fast_clk_sync_in (1'b0),
.fast_cdr_clk_sync_in (1'b0 ),
.peer_data_in (1'b0),
.fast_clk_sync_out ( ),
.fast_cdr_clk_sync_out (),
.g2i_tx_out (O_in),
.g2i_tx_oe ( ),
.g2i_tx_clk ( ),
.g2i_ie ( ),
.cdr_clk (),
.g2f_tx_dly_tap (),
.g2f_core_clk ( ),
.g2f_rx_cdr_core_clk ( ),
.g2f_rx_dpa_lock ( ),
.g2f_rx_dpa_error ( ),
.g2f_rx_dpa_phase ( ),
.g2f_rx_dly_tap ( ),
.g2f_rx_in (O),
.g2f_rx_dvalid ()
);

endmodule 
// ---------------------------------------- //
// --------------- O_BUF ------------------ //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module obuf#(
    parameter PULL_UP_DOWN = "NONE",
    parameter SLEW_RATE = "SLOW",
    parameter REG_EN = "TRUE",
    parameter DELAY = 00
)(
    input  logic I,     // Input
    input  logic C,     // Clock in case of REG_EN is true
    output logic O      // Output         
);

import GBOX_CONFIG::*;
localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = (PULL_UP_DOWN == "NONE")? (REG_EN =="TRUE")? MODE_BP_SDR_TX:MODE_BP_DIR_TX:
                                                 (PULL_UP_DOWN == "UP")? MODE_PULLUP : MODE_PULLDOWN;
// ---------------------------------------- 
// Internal Signals
logic system_reset_n;
logic dly_ld;





initial begin
    dly_ld = 1;
    system_reset_n      = 1'b0;        
    #1;
    system_reset_n      = 1'b1;
    repeat(4) @(posedge C); 
    dly_ld = 0;        
end



// ----------------------------------------
//  GEAR BOX TOP
//  INSTANCE
// ---------------------------------------- 
gbox_top 
    #(
    .PAR_TX_DWID(10 ),
    .PAR_RX_DWID(10 ),
    .PAR_TWID (6 )
    )
gbox_top_dut (
    .system_reset_n (system_reset_n ),
    .pll_lock (1'b1 ),
    .cfg_rate_sel (GEARBOX_MODE[3:0] ),
    .cfg_chan_master (GEARBOX_MODE[4] ),
    .cfg_peer_is_on (GEARBOX_MODE[5] ),
    //.cfg_tx_clk_io(GEARBOX_MODE[6]),
    .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
    .cfg_tx_bypass (GEARBOX_MODE[9] ),
    .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
    .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
    .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
    .cfg_rx_bypass (GEARBOX_MODE[20] ),
    // .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
    .cfg_rx_dly (DELAY ), 
    .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
    // .cfg_mipi_mode(GEARBOX_MODE[29])
    .cfg_tx_mode (GEARBOX_MODE[30] ),
    .cfg_rx_mode (GEARBOX_MODE[31] ),
    .cfg_dif (GEARBOX_MODE[32] ),
    .cfg_done (1'b1 ),
    .fast_clk (C),
    .i2g_rx_in (),
    .fast_phase_clk (),
    .f2g_tx_reset_n ( 1'b0),
    .f2g_trx_core_clk (C),
    .f2g_tx_dly_ld (dly_ld),
    .f2g_tx_dly_adj ( 'b0),
    .f2g_tx_dly_inc ( 'b0),
    .f2g_tx_oe (1'b1),
    .f2g_tx_out (I),
    .f2g_in_en ( 'b0),
    .f2g_tx_dvalid (1'b0 ),
    .f2g_rx_reset_n ('b1),
    .f2g_rx_sfifo_reset ('b0 ),
    .f2g_rx_dly_ld (),
    .f2g_rx_dly_adj ('b0 ),
    .f2g_rx_dly_inc ( 'b0),
    .f2g_rx_bitslip_adj ('b0),
    .f2g_rx_dpa_restart ('b0),
    .fast_clk_sync_in ( 'b0),
    .fast_cdr_clk_sync_in ('b0 ),
    .peer_data_in ('b0),
    .fast_clk_sync_out ( ),
    .fast_cdr_clk_sync_out (),
    .g2i_tx_out (O),
    .g2i_tx_oe ( ),
    .g2i_tx_clk (),
    .g2i_ie ( ),
    .cdr_clk (),
    .g2f_tx_dly_tap (),
    .g2f_core_clk ( ),
    .g2f_rx_cdr_core_clk (),
    .g2f_rx_dpa_lock ( ),
    .g2f_rx_dpa_error ( ),
    .g2f_rx_dpa_phase ( ),
    .g2f_rx_dly_tap ( ),
    .g2f_rx_in (),
    .g2f_rx_dvalid ()
);

endmodule 

// ---------------------------------------- //
// ------------- O_BUFT_DS ---------------- //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module obuftds #(
        parameter SLEW_RATE = 1,
        parameter DELAY = 0
    )( 
        input  logic OE,
        input  logic I,       
        input  logic C,           
        output logic O_N,
        output logic O_P             
    );

    import GBOX_CONFIG::*;
    localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_DIFFS_TX;

    // ---------------------------------------- 
    // Internal Signals
    logic system_reset_n;
    logic dly_ld;
    logic O;
    logic f2g_rx_reset_n;
    logic g2i_ie;
    assign O_P = g2i_ie?O:1'bZ;
    assign O_N = g2i_ie?~O_P:1'bZ;

    initial begin
        dly_ld = 1;
        f2g_rx_reset_n      = 1'b0;
        system_reset_n      = 1'b0;        
        #1;
        system_reset_n      = 1'b1;
        f2g_rx_reset_n      = 1'b1;
        repeat(4) @(posedge C); 
        dly_ld = 0;        
    end
    
    // ----------------------------------------
    //  GEAR BOX TOP
    //  INSTANCE
    // ---------------------------------------- 
    gbox_top 
        #(
        .PAR_TX_DWID(10 ),
        .PAR_RX_DWID(10 ),
        .PAR_TWID (6 )
        )
    gbox_top_dut (
        .system_reset_n (system_reset_n ),
        .pll_lock (1'b1 ),
        .cfg_rate_sel (GEARBOX_MODE[3:0] ),
        .cfg_chan_master (GEARBOX_MODE[4] ),
        .cfg_peer_is_on (GEARBOX_MODE[5] ),
        //.cfg_tx_clk_io(GEARBOX_MODE[6]),
        .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
        .cfg_tx_bypass (GEARBOX_MODE[9] ),
        .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
        // .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
        .cfg_tx_dly (DELAY), 
        .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
        .cfg_rx_bypass (GEARBOX_MODE[20] ),
        .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
        .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
        // .cfg_mipi_mode(GEARBOX_MODE[29])
        .cfg_tx_mode (GEARBOX_MODE[30] ),
        .cfg_rx_mode (GEARBOX_MODE[31] ),
        .cfg_dif (GEARBOX_MODE[32] ),
        .cfg_done (1'b1 ),
        .fast_clk ( C),
        .i2g_rx_in (),
        .fast_phase_clk ( 0),
        .f2g_tx_reset_n ( 1'b1),
        .f2g_trx_core_clk (C ),
        .f2g_tx_dly_ld (),
        .f2g_tx_dly_adj ( 'b0),
        .f2g_tx_dly_inc ( 'b0),
        .f2g_tx_oe (OE),
        .f2g_tx_out ({'b0,I}),
        .f2g_in_en ( OE),
        .f2g_tx_dvalid (1'b1 ),
        .f2g_rx_reset_n ('b0),
        .f2g_rx_sfifo_reset ('b0 ),
        .f2g_rx_dly_ld ('b0),
        .f2g_rx_dly_adj ('b0 ),
        .f2g_rx_dly_inc ( 'b0),
        .f2g_rx_bitslip_adj ('b0),
        .f2g_rx_dpa_restart ('b0),
        .fast_clk_sync_in ( 'b0),
        .fast_cdr_clk_sync_in ('b0 ),
        .peer_data_in ('b0),
        .fast_clk_sync_out ( ),
        .fast_cdr_clk_sync_out (),
        .g2i_tx_out (O),
        .g2i_tx_oe ( ),
        .g2i_tx_clk ( ),
        .g2i_ie (g2i_ie ),
        .cdr_clk (),
        .g2f_tx_dly_tap (),
        .g2f_core_clk ( ),
        .g2f_rx_cdr_core_clk ( ),
        .g2f_rx_dpa_lock ( ),
        .g2f_rx_dpa_error ( ),
        .g2f_rx_dpa_phase ( ),
        .g2f_rx_dly_tap ( ),
        .g2f_rx_in (),
        .g2f_rx_dvalid ()
    );

endmodule 

// ---------------------------------------- //
// --------------- O_BUFT ----------------- //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //

module obuft#(
    parameter SLEW_RATE = 1,
    parameter DELAY = 0
  )(
    input  logic I,             
    input  logic OE,
    output logic O              
  );
    
  import GBOX_CONFIG::*;
  localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_BP_SDR_TX;


  // ---------------------------------------- 
  // Internal Signals
  logic system_reset_n;
  logic CLK;
  logic dly_ld;

  initial begin
      CLK = 0;
      dly_ld = 1;
      system_reset_n      = 1'b0;        
      #1;
      system_reset_n      = 1'b1;
      repeat(4) @(posedge CLK); 
      dly_ld = 0;        
  end

  always #5 CLK = ~CLK;
  // ----------------------------------------
  //  GEAR BOX TOP
  //  INSTANCE
  // ---------------------------------------- 
  gbox_top 
  #(
  .PAR_TX_DWID(10 ),
  .PAR_RX_DWID(10 ),
  .PAR_TWID (6 )
  )
  gbox_top_dut (
  .system_reset_n (system_reset_n ),
  .pll_lock (1'b1 ),
  .cfg_rate_sel (GEARBOX_MODE[3:0] ),
  .cfg_chan_master (GEARBOX_MODE[4] ),
  .cfg_peer_is_on (GEARBOX_MODE[5] ),
  //.cfg_tx_clk_io(GEARBOX_MODE[6]),
  .cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
  .cfg_tx_bypass (GEARBOX_MODE[9] ),
  .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
  // .cfg_tx_dly (GEARBOX_MODE[17:12] ), 
  .cfg_tx_dly (DELAY), 
  .cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
  .cfg_rx_bypass (GEARBOX_MODE[20] ),
  .cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
  .cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
  // .cfg_mipi_mode(GEARBOX_MODE[29])
  .cfg_tx_mode (GEARBOX_MODE[30] ),
  .cfg_rx_mode (GEARBOX_MODE[31] ),
  .cfg_dif (GEARBOX_MODE[32] ),
  .cfg_done (1'b1 ),
  .fast_clk (CLK),
  .i2g_rx_in (),
  .fast_phase_clk (CLK),
  .f2g_tx_reset_n ( 1'b1),
  .f2g_trx_core_clk ( ),
  .f2g_tx_dly_ld (dly_ld),
  .f2g_tx_dly_adj ( 'b0),
  .f2g_tx_dly_inc ( 'b0),
  .f2g_tx_oe (OE),
  .f2g_tx_out ({'b0,I}),
  .f2g_in_en ( 'b0),
  .f2g_tx_dvalid (),
  .f2g_rx_reset_n ('b0),
  .f2g_rx_sfifo_reset ('b0 ),
  .f2g_rx_dly_ld ('b0),
  .f2g_rx_dly_adj ('b0 ),
  .f2g_rx_dly_inc ( 'b0),
  .f2g_rx_bitslip_adj ('b0),
  .f2g_rx_dpa_restart ('b0),
  .fast_clk_sync_in ( 'b0),
  .fast_cdr_clk_sync_in ('b0 ),
  .peer_data_in ('b0),
  .fast_clk_sync_out ( ),
  .fast_cdr_clk_sync_out (),
  .g2i_tx_out (O),
  .g2i_tx_oe ( ),
  .g2i_tx_clk ( ),
  .g2i_ie ( ),
  .cdr_clk (),
  .g2f_tx_dly_tap (),
  .g2f_core_clk ( ),
  .g2f_rx_cdr_core_clk ( ),
  .g2f_rx_dpa_lock ( ),
  .g2f_rx_dpa_error ( ),
  .g2f_rx_dpa_phase ( ),
  .g2f_rx_dly_tap ( ),
  .g2f_rx_in (),
  .g2f_rx_dvalid ()
  );

endmodule 
// ---------------------------------------- //
// --------------- O_DDR ------------------ //
// --------- Complex IO Primitive---------- //
// ---------------------------------------- //


module oddr #(
    parameter SLEW_RATE = 1,
    parameter DELAY = 0
  )(
    input  logic [1:0] D,
    input  logic R,             
    input  logic E,
    input  logic DLY_ADJ,     // Delay Adjust
    input  logic DLY_LD,
    input  logic DLY_INC,     // Delay Increment             
    input  logic C,                      
    output logic Q              
  );

import GBOX_CONFIG::*;
localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_BP_DDR_TX;


// ---------------------------------------- 
// Internal Signals
logic system_reset_n;
logic CLK;

initial begin
    CLK = 0;
    system_reset_n      = 1'b0;        
    #1;
    system_reset_n      = 1'b1;
          
end

always #5 CLK = ~CLK;
// ----------------------------------------
//  GEAR BOX TOP
//  INSTANCE
// ---------------------------------------- 
gbox_top 
#(
.PAR_TX_DWID(10 ),
.PAR_RX_DWID(10 ),
.PAR_TWID (6 )
)
gbox_top_dut (
.system_reset_n (system_reset_n ),
.pll_lock (1'b1 ),
.cfg_rate_sel (GEARBOX_MODE[3:0] ),
.cfg_chan_master (GEARBOX_MODE[4] ),
.cfg_peer_is_on (GEARBOX_MODE[5] ),
//.cfg_tx_clk_io(GEARBOX_MODE[6]),
.cfg_tx_ddr_mode (GEARBOX_MODE[8:7] ),
.cfg_tx_bypass (GEARBOX_MODE[9] ),
.cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
.cfg_tx_dly (GEARBOX_MODE[17:12] ), 
.cfg_rx_ddr_mode (GEARBOX_MODE[19:18] ),
.cfg_rx_bypass (GEARBOX_MODE[20] ),
.cfg_rx_dly (GEARBOX_MODE[26:21]  ), 
.cfg_rx_dpa_mode (GEARBOX_MODE[28:27] ),
// .cfg_mipi_mode(GEARBOX_MODE[29])
.cfg_tx_mode (GEARBOX_MODE[30] ),
.cfg_rx_mode (GEARBOX_MODE[31] ),
.cfg_dif (GEARBOX_MODE[32] ),
.cfg_done (1'b1 ),
.fast_clk (CLK ),
.i2g_rx_in (),
.fast_phase_clk ( CLK),
.f2g_tx_reset_n ( 1'b1),
.f2g_trx_core_clk (C),
.f2g_tx_dly_ld  ( DLY_LD),
.f2g_tx_dly_adj ( DLY_ADJ),
.f2g_tx_dly_inc ( DLY_INC),
.f2g_tx_oe (E),
.f2g_tx_out ({'b0,D}),
.f2g_in_en ( 'b0),
.f2g_tx_dvalid (1'b1 ),
.f2g_rx_reset_n ('b0),
.f2g_rx_sfifo_reset ('b0 ),
.f2g_rx_dly_ld ('b0),
.f2g_rx_dly_adj ('b0 ),
.f2g_rx_dly_inc ( 'b0),
.f2g_rx_bitslip_adj ('b0),
.f2g_rx_dpa_restart ('b0),
.fast_clk_sync_in ( 'b0),
.fast_cdr_clk_sync_in ('b0 ),
.peer_data_in ('b0),
.fast_clk_sync_out ( ),
.fast_cdr_clk_sync_out (),
.g2i_tx_out (Q),
.g2i_tx_oe ( ),
.g2i_tx_clk ( ),
.g2i_ie ( ),
.cdr_clk( ),
.g2f_tx_dly_tap( ),
.g2f_core_clk ( ),
.g2f_rx_cdr_core_clk ( ),
.g2f_rx_dpa_lock ( ),
.g2f_rx_dpa_error ( ),
.g2f_rx_dpa_phase ( ),
.g2f_rx_dly_tap ( ),
.g2f_rx_in (),
.g2f_rx_dvalid ()
);

endmodule 
module iserdes #(
    parameter DATA_RATE = "DDR",
              WIDTH = 4,
              DPA_MODE = "DPA",
              DELAY = 0

    )(
     input logic D,
     input logic RST,
     input logic FIFO_RST,
     input logic DPA_RST,
     input logic DLY_LOAD,
     input logic DLY_ADJ,
     input logic DLY_INCDEC,
     input logic BITSLIP_ADJ,
     input logic EN,
     input logic CLK_IN,
     input logic PLL_FAST_CLK,
     input logic [3:0] FAST_PHASE_CLK,
     input logic PLL_LOCK,
     output logic CLK_OUT,
     output logic CDR_CORE_CLK, 
     output logic [WIDTH-1 : 0] Q,
     output logic DATA_VALID,
     output logic [5:0] DLY_TAP_VALUE,
     output logic DPA_LOCK,
     output logic DPA_ERROR
    );

    import GBOX_CONFIG::*;
    localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_ISERDES;
    
    wire [1:0] DDR_mode, DPA_mode;
    assign DDR_mode = (DATA_RATE == "DDR") ? 2'b01 : 2'b10;
    assign DPA_mode = (DPA_MODE == "NONE") ? 2'b00 : (DPA_MODE == "DPA") ? 2'b11 : 2'b10;
    // ----------------------------------------
    //  GEAR BOX TOP
    //  INSTANCE
    // ---------------------------------------- 

    gbox_top # (
        .PAR_TX_DWID(WIDTH),
        .PAR_RX_DWID(WIDTH),
        .PAR_TWID (6)
    )
    gbox_top_dut (
        .system_reset_n (RST ),
        .pll_lock (PLL_LOCK),
        .cfg_rate_sel (WIDTH),
        .cfg_chan_master (GEARBOX_MODE[4] ),
        .cfg_peer_is_on (GEARBOX_MODE[5] ),
        .cfg_tx_ddr_mode (GEARBOX_MODE[8:7]),
        .cfg_tx_bypass (GEARBOX_MODE[9] ),
        .cfg_tx_clk_phase (GEARBOX_MODE[11:10] ),
        .cfg_tx_dly (GEARBOX_MODE[17:12]  ), 
        .cfg_rx_ddr_mode (DDR_mode),
        .cfg_rx_bypass (GEARBOX_MODE[18] ),
        .cfg_rx_dly (DELAY ), 
        .cfg_rx_dpa_mode (DPA_mode),
        .cfg_tx_mode (GEARBOX_MODE[30] ),
        .cfg_rx_mode (GEARBOX_MODE[31] ),
        .cfg_dif (GEARBOX_MODE[32] ),
        .cfg_done (1'b1 ),
        .fast_clk (PLL_FAST_CLK),
        .i2g_rx_in (D),
        .fast_phase_clk (FAST_PHASE_CLK),
        .f2g_tx_reset_n ( RST),
        .f2g_trx_core_clk (CLK_IN),
        .f2g_tx_dly_ld ('b0),
        .f2g_tx_dly_adj ( 'b0),
        .f2g_tx_dly_inc ( 'b0),
        .f2g_tx_oe ('b0),
        .f2g_tx_out ('b0),
        .f2g_in_en ( 'b0),
        .f2g_tx_dvalid (1'b0 ),
        .f2g_rx_reset_n (RST),
        .f2g_rx_sfifo_reset (FIFO_RST),
        .f2g_rx_dly_ld (DLY_LOAD),
        .f2g_rx_dly_adj (DLY_ADJ),
        .f2g_rx_dly_inc ( DLY_INCDEC),
        .f2g_rx_bitslip_adj (BITSLIP_ADJ),
        .f2g_rx_dpa_restart (DPA_RST),
        .fast_clk_sync_in ( 'b0),
        .fast_cdr_clk_sync_in ('b0 ),
        .peer_data_in ('b0),
        .fast_clk_sync_out ( ),
        .fast_cdr_clk_sync_out (),
        .g2i_tx_out (),
        .g2i_tx_oe ( ),
        .g2i_tx_clk (),
        .g2i_ie ( ),
        .cdr_clk (),
        .g2f_tx_dly_tap (),
        .g2f_core_clk ( CLK_OUT),
        .g2f_rx_cdr_core_clk (CDR_CORE_CLK),
        .g2f_rx_dpa_lock ( DPA_LOCK),
        .g2f_rx_dpa_error (DPA_ERROR ),
        .g2f_rx_dpa_phase ( ),
        .g2f_rx_dly_tap ( DLY_TAP_VALUE),
        .g2f_rx_in (Q),
        .g2f_rx_dvalid (DATA_VALID)
    );
    
  
endmodule 
`timescale 1ns/1ps

module oserdes #(
  parameter DATA_RATE="DDR",
            CLOCK_PHASE = 0,  
            WIDTH = 4,        
            DELAY = 0
) (
  input logic [WIDTH-1:0] D,
  input logic RST,
  input logic LOAD_WORD,
  input logic DLY_LOAD,
  input logic DLY_ADJ,
  input logic DLY_INCDEC,
  input logic CLK_EN,
  input logic CLK_IN,
  input logic PLL_LOCK,
  input logic PLL_FAST_CLK,
  input logic [3:0] FAST_PHASE_CLK,
  input logic OE,
  output logic CLK_OUT,
  output logic Q,                  
  output logic [5:0] DLY_TAP_VALUE,
  input logic CHANNEL_BOND_SYNC_IN,
  output logic CHANNEL_BOND_SYNC_OUT 
);

import GBOX_CONFIG::*;
localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_OSERDES;


logic [1:0] DDR_mode,CLK_Phase;
assign DDR_mode = (DATA_RATE == "DDR") ? 2'b01 : 2'b10;
assign CLK_Phase = (CLOCK_PHASE == 0) ? 2'b00 : (CLOCK_PHASE == 90) ? 2'b01 : (CLOCK_PHASE == 180) ? 2'b10 : 2'b11;



// Internal Signals

gbox_top # (
    .PAR_TX_DWID(WIDTH),
    .PAR_RX_DWID(WIDTH),
    .PAR_TWID (6)
)
gbox_top_dut (
    .system_reset_n (RST ),
    .pll_lock (PLL_LOCK ),
    .cfg_rate_sel (WIDTH),
    .cfg_chan_master (GEARBOX_MODE[4] ),
    .cfg_peer_is_on (GEARBOX_MODE[5] ),
    .cfg_tx_ddr_mode (DDR_mode),
    .cfg_tx_bypass (GEARBOX_MODE[9] ),
    .cfg_tx_clk_phase (CLK_Phase),
    .cfg_tx_dly (DELAY ), 
    .cfg_rx_ddr_mode (GEARBOX_MODE[19:18]),
    .cfg_rx_bypass (GEARBOX_MODE[20] ),
    .cfg_rx_dly (GEARBOX_MODE[26:21]), 
    .cfg_rx_dpa_mode (GEARBOX_MODE[28:27]),
    .cfg_tx_mode (GEARBOX_MODE[30] ),
    .cfg_rx_mode (GEARBOX_MODE[31] ),
    .cfg_dif (GEARBOX_MODE[32] ),
    .cfg_done (1'b1 ),
    .fast_clk (PLL_FAST_CLK),
    .i2g_rx_in (1'b0),
    .fast_phase_clk (FAST_PHASE_CLK),
    .f2g_tx_reset_n ( RST),
    .f2g_trx_core_clk (CLK_IN),
    .f2g_tx_dly_ld (DLY_LOAD),
    .f2g_tx_dly_adj ( DLY_ADJ),
    .f2g_tx_dly_inc (DLY_INCDEC),
    .f2g_tx_oe (OE),
    .f2g_tx_out (D),
    .f2g_in_en ( 'b1),
    .f2g_tx_dvalid (LOAD_WORD),
    .f2g_rx_reset_n ('b0),
    .f2g_rx_sfifo_reset ('b0 ),
    .f2g_rx_dly_ld ('b0),
    .f2g_rx_dly_adj ('b0 ),
    .f2g_rx_dly_inc ( 'b0),
    .f2g_rx_bitslip_adj ('b0),
    .f2g_rx_dpa_restart ('b0),
    .fast_clk_sync_in ( CHANNEL_BOND_SYNC_IN),
    .fast_cdr_clk_sync_in ('b0 ),
    .peer_data_in ('b0),
    .fast_clk_sync_out (CHANNEL_BOND_SYNC_OUT ),
    .fast_cdr_clk_sync_out (),
    .g2i_tx_out (Q),
    .g2i_tx_oe ( ),
    .g2i_tx_clk (),
    .g2i_ie ( ),
    .cdr_clk (),
    .g2f_tx_dly_tap (DLY_TAP_VALUE),
    .g2f_core_clk (CLK_OUT),
    .g2f_rx_cdr_core_clk (),
    .g2f_rx_dpa_lock ( ),
    .g2f_rx_dpa_error ( ),
    .g2f_rx_dpa_phase ( ),
    .g2f_rx_dly_tap ( ),
    .g2f_rx_in (),
    .g2f_rx_dvalid ()
);

endmodule 