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
        .PAR_TX_DWID(1 ),
        .PAR_RX_DWID(1 ),
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
    input  logic I_P,             
    output logic O    
  );
  import GBOX_CONFIG::*;
  localparam GBOX_CONFIG::GBOX_MODE GEARBOX_MODE = MODE_DIFFS_RX;
  
  
  // ---------------------------------------- 
  // Internal Signals
  logic system_reset_n;
  
  
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
  .PAR_TX_DWID(1 ),
  .PAR_RX_DWID(1 ),
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
  .fast_clk ( ),
  .i2g_rx_in (),
  .fast_phase_clk ( 'b0),
  .f2g_tx_reset_n ( 1'b1),
  .f2g_trx_core_clk ( ),
  .f2g_tx_dly_ld (),
  .f2g_tx_dly_adj ( 'b0),
  .f2g_tx_dly_inc ( 'b0),
  .f2g_tx_oe (1'b1),
  .f2g_tx_out (),
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
  .g2f_rx_in (),
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
  .PAR_TX_DWID(1 ),
  .PAR_RX_DWID(2),
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
  .fast_clk ( ),
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
  .g2i_tx_out (Q),
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
  
  
  wire VDD;
  wire VDDIO;
  wire VDD18;
  wire VREF;
  wire VSS;
  wire IOA;
  wire IOB;
  
  assign VDD   = 1'b1;
  assign VDDIO = 1'b1;  
  assign VDD18 = 1'bZ;  
  assign VREF  = 1'b1; 
  assign VSS   = 1'b0;
  
  assign O = IOA;
  
  
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
    .PAR_TX_DWID(1 ),
    .PAR_RX_DWID(1 ),
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
    .g2f_rx_in (),
    .g2f_rx_dvalid ()
  );
  
  /*
   // ----------------------------------------
    //  GEAR BOX HPIO TOP
    //  INSTANCE
    // ---------------------------------------- 
  gbox_hpio 
  #(
  .PAR_TYPE(1 ),
  .PAR_TX_DWID(10 ),
  .PAR_RX_DWID(10 ),
  .PAR_TWID (6 )
  )
  gbox_hpio_dut (
  .VDD (VDD ),
  .VDDIO (VDDIO ),
  .VDD18 (VDD18 ),
  .VREF (VREF ),
  .VSS (VSS ),
  .POC (1'b1),
  .DFEN ({GEARBOX_MODE[32] && GEARBOX_MODE[32]}),
  .AICP ('0),
  .AICN ('0),
  .MCA (GEARBOX_MODE[32]),
  .MCB (GEARBOX_MODE[32]),
  .SRA (GEARBOX_MODE[33]),
  .SRB (GEARBOX_MODE[33]),
  .PEA (GEARBOX_MODE[34]),
  .PEB (GEARBOX_MODE[34]),
  .PUDA (GEARBOX_MODE[35]),
  .PUDB (GEARBOX_MODE[35]),
  .DFODTEN (GEARBOX_MODE[36] || GEARBOX_MODE[36]),// GEARBOX_MODE[36]}
  .CDETA ( ),
  .CDETB ( ),
  .IOA (IOA),
  .IOB (IOB),
  .system_reset_n (system_reset_n),
  .pll_lock (1'b1),
  .cfg_rate_sel ( {GEARBOX_MODE[3:0],GEARBOX_MODE[3:0]}),
  .cfg_done (1'b1),
  .cfg_chan_master ({GEARBOX_MODE[4],GEARBOX_MODE[4]} ),
  .cfg_tx_clk_phase ({GEARBOX_MODE[11:10],GEARBOX_MODE[11:10]}),
  .cfg_tx_clk_io ({GEARBOX_MODE[6],GEARBOX_MODE[6]}),
  .cfg_peer_is_on ({GEARBOX_MODE[5],GEARBOX_MODE[5]}),
  .cfg_tx_bypass ({GEARBOX_MODE[9],GEARBOX_MODE[9]}),
  .cfg_rx_bypass ({GEARBOX_MODE[20],GEARBOX_MODE[20]}),
  .cfg_tx_mode ({GEARBOX_MODE[30],GEARBOX_MODE[30]}),
  .cfg_rx_mode ({GEARBOX_MODE[31],GEARBOX_MODE[31]}),
  .cfg_mipi_mode ({GEARBOX_MODE[29],GEARBOX_MODE[29]}),
  .cfg_tx_dly ({GEARBOX_MODE[17:12],GEARBOX_MODE[17:12]}),
  .cfg_rx_dly ({GEARBOX_MODE[26:21],GEARBOX_MODE[26:21]}),
  .cfg_tx_ddr_mode ({GEARBOX_MODE[8:7],GEARBOX_MODE[8:7]}),
  .cfg_rx_ddr_mode ({GEARBOX_MODE[19:18],GEARBOX_MODE[19:18]} ),
  .fast_clk (C),
  .fast_phase_clk (C),
  .f2g_trx_reset_n (1),
  .f2g_trx_core_clk (C),
  .f2g_tx_dly_ld ('b0),
  .f2g_tx_dly_adj ('b0),
  .f2g_tx_dly_inc ('b0),
  .f2g_tx_oe (OE),
  .f2g_tx_out (I),
  .f2g_in_en (GB_SELECT?2'b10:2'b01),
  .f2g_tx_dvalid ('b0),
  .f2g_rx_sfifo_reset ('b1),
  .f2g_rx_dly_ld ('b0),
  .f2g_rx_dly_adj ('b0),
  .f2g_rx_dly_inc ('b0),
  .f2g_rx_bitslip_adj ('b0),
  .cfg_rx_dpa_mode ({GEARBOX_MODE[28:27],GEARBOX_MODE[28:27]}),
  .f2g_rx_dpa_restart ('b0),
  .fast_clk_sync_in ( ),
  .fast_cdr_clk_sync_in ( ),
  .fast_clk_sync_out ( ),
  .fast_cdr_clk_sync_out ( ),
  .cdr_clk ( ),
  .g2f_tx_dly_tap ( ),
  .g2f_core_clk ( ),
  .g2f_rx_cdr_core_clk ( ),
  .g2f_rx_dpa_lock ( ),
  .g2f_rx_dpa_error ( ),
  .g2f_rx_dpa_phase ( ),
  .g2f_rx_dly_tap ( ),
  .g2f_rx_in (),
  .g2f_rx_dvalid  ( )
  );
  */
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
  
  wire VDD;
  wire VDDIO;
  wire VDD18;
  wire VREF;
  wire VSS;
  wire IOA;
  wire IOB;
  
  assign VDD   = 1'b1;
  assign VDDIO = 1'b1;  
  assign VDD18 = 1'bZ;  
  assign VREF  = 1'b1; 
  assign VSS   = 1'b0;
  
  assign O_P = IOA;
  assign O_N = IOB;
  
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
    .fast_phase_clk ( C),
    .f2g_tx_reset_n ( 1'b1),
    .f2g_trx_core_clk ( ),
    .f2g_tx_dly_ld (),
    .f2g_tx_dly_adj ( 'b0),
    .f2g_tx_dly_inc ( 'b0),
    .f2g_tx_oe (OE),
    .f2g_tx_out ({'b0,I}),
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
    .g2f_rx_in (),
    .g2f_rx_dvalid ()
  );
  /*
  // ----------------------------------------
  //  GEAR BOX HPIO TOP
  //  INSTANCE
  // ---------------------------------------- 
  gbox_hpio 
  #(
  .PAR_TYPE(1 ),
  .PAR_TX_DWID(10 ),
  .PAR_RX_DWID(10 ),
  .PAR_TWID (6 )
  )
  gbox_hpio_dut (
  .VDD (VDD ),
  .VDDIO (VDDIO ),
  .VDD18 (VDD18 ),
  .VREF (VREF ),
  .VSS (VSS ),
  .POC (1'b1),
  .DFEN ({GEARBOX_MODE[32] && GEARBOX_MODE[32]}),
  .AICP ('0),
  .AICN ('0),
  .MCA (GEARBOX_MODE[32]),
  .MCB (GEARBOX_MODE[32]),
  .SRA (GEARBOX_MODE[33]),
  .SRB (GEARBOX_MODE[33]),
  .PEA (GEARBOX_MODE[34]),
  .PEB (GEARBOX_MODE[34]),
  .PUDA (GEARBOX_MODE[35]),
  .PUDB (GEARBOX_MODE[35]),
  .DFODTEN (GEARBOX_MODE[36] || GEARBOX_MODE[36]),// GEARBOX_MODE[36]}
  .CDETA ( ),
  .CDETB ( ),
  .IOA (IOA),
  .IOB (IOB),
  .system_reset_n (system_reset_n),
  .pll_lock (1'b1),
  .cfg_rate_sel ( {GEARBOX_MODE[3:0],GEARBOX_MODE[3:0]}),
  .cfg_done (1'b1),
  .cfg_chan_master ({GEARBOX_MODE[4],GEARBOX_MODE[4]} ),
  .cfg_tx_clk_phase ({GEARBOX_MODE[11:10],GEARBOX_MODE[11:10]}),
  .cfg_tx_clk_io ({GEARBOX_MODE[6],GEARBOX_MODE[6]}),
  .cfg_peer_is_on ({GEARBOX_MODE[5],GEARBOX_MODE[5]}),
  .cfg_tx_bypass ({GEARBOX_MODE[9],GEARBOX_MODE[9]}),
  .cfg_rx_bypass ({GEARBOX_MODE[20],GEARBOX_MODE[20]}),
  .cfg_tx_mode ({GEARBOX_MODE[30],GEARBOX_MODE[30]}),
  .cfg_rx_mode ({GEARBOX_MODE[31],GEARBOX_MODE[31]}),
  .cfg_mipi_mode ({GEARBOX_MODE[29],GEARBOX_MODE[29]}),
  .cfg_tx_dly ({GEARBOX_MODE[17:12],GEARBOX_MODE[17:12]}),
  .cfg_rx_dly ({GEARBOX_MODE[26:21],GEARBOX_MODE[26:21]}),
  .cfg_tx_ddr_mode ({GEARBOX_MODE[8:7],GEARBOX_MODE[8:7]}),
  .cfg_rx_ddr_mode ({GEARBOX_MODE[19:18],GEARBOX_MODE[19:18]} ),
  .fast_clk (C),
  .fast_phase_clk (C),
  .f2g_trx_reset_n (f2g_rx_reset_n),
  .f2g_trx_core_clk (C),
  .f2g_tx_dly_ld ('b0),
  .f2g_tx_dly_adj ('b0),
  .f2g_tx_dly_inc ('b0),
  .f2g_tx_oe (OE),
  .f2g_tx_out (I),
  .f2g_in_en (GB_SELECT?2'b10:2'b01),
  .f2g_tx_dvalid ('b0),
  .f2g_rx_sfifo_reset ('b1),
  .f2g_rx_dly_ld ('b0),
  .f2g_rx_dly_adj ('b0),
  .f2g_rx_dly_inc ('b0),
  .f2g_rx_bitslip_adj ('b0),
  .cfg_rx_dpa_mode ({GEARBOX_MODE[28:27],GEARBOX_MODE[28:27]}),
  .f2g_rx_dpa_restart ('b0),
  .fast_clk_sync_in ( ),
  .fast_cdr_clk_sync_in ( ),
  .fast_clk_sync_out ( ),
  .fast_cdr_clk_sync_out ( ),
  .cdr_clk ( ),
  .g2f_tx_dly_tap ( ),
  .g2f_core_clk ( ),
  .g2f_rx_cdr_core_clk ( ),
  .g2f_rx_dpa_lock ( ),
  .g2f_rx_dpa_error ( ),
  .g2f_rx_dpa_phase ( ),
  .g2f_rx_dly_tap ( ),
  .g2f_rx_in (),
  .g2f_rx_dvalid  ( )
  );
  */
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
