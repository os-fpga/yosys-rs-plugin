package GBOX_CONFIG;

// [40:0 ] {MC[40:37], DFODTEN[36], PUD[35], PE[34], SR[33], DFEN/cfg_dif[32], cfg_rx_mode[31],
//          cfg_tx_mode[30], cfg_mipi_mode[29], cfg_rx_dpa_mode[28:27], cfg_rx_dly[26:21], 
//          cfg_rx_bypass[20], cfg_rx_ddr_mode[19:18], cfg_tx_dly[17:12], cfg_tx_clk_phase[11:10], 
//          cfg_tx_bypass[9], cfg_tx_ddr_mode[8:7], cfg_tx_clk_io[6], cfg_peer_is_on[5], 
//          cfg_chan_master[4], cfg_rate_sel[3:0] }

        typedef enum logic [40:0]{

                MODE_BP_DIR_RX   = 41'b0000_0000_1000_0111_1111_0000_0000_0000_0000_0000,
                MODE_BP_SDR_RX   = 41'b0000_0000_1000_0000_0001_1000_0000_0000_0000_0000,
                MODE_BP_DDR_RX   = 41'b0000_0000_1110_0111_1111_0100_0000_0000_0000_0000, 
                MODE_DIFFS_RX    = 41'b0000_0001_1000_0000_0001_1000_0000_0000_0000_0000,

                // MODE_BP_PEER_ON_RX = 41'b0000_0000_1000_0111_1111_0000_0000_0000_0011_0000, 
                
                MODE_BP_DIR_TX   = 41'b0000_0000_0100_0000_0000_0000_0000_0010_0000_0000,
                MODE_BP_SDR_TX   = 41'b0000_0000_0100_0000_0000_0000_0000_0011_0000_0000,
                MODE_BP_DDR_TX   = 41'b0000_0000_0100_0110_0000_0000_0000_0010_1000_0000,
                MODE_CLK_BUF_TX  = 41'b0000_0000_0100_0000_0000_0000_0000_0010_0100_0000,

                MODE_DIFFS_TX    = 41'b0000_0001_0100_0000_0000_0000_0000_0011_0000_0000,
                // MODE_BP_PEER_ON_TX = 41'b0000_0000_0100_0000_0000_0000_0000_0010_0011_0000,

                MODE_PULLUP      = 41'b0000_0110_0000_0000_0000_0000_0000_0000_0000_0000,
                MODE_PULLDOWN    = 41'b0000_0010_0000_0000_0000_0000_0000_0000_0000_0000,
                MODE_ZEROED      = 41'b0

        }  GBOX_MODE;

endpackage
