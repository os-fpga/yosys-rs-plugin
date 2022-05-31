/* Generated by Yosys 0.16+6 (git sha1 7f5477eb1, gcc 9.1.0 -fPIC -Os) */

(* dynports =  1  *)
(* top =  1  *)
(* src = "bram_sdp.v:142.1-172.10" *)
module BRAM_SDP_4x4096(clk, rce, ra, rq, wce, wa, wd);
  (* src = "/home/users/lilit.hunanyan/workspace/bram/yosys_verific_rs/yosys/install/bin/../share/yosys/rapidsilicon/genesis/brams_map.v:322.22-322.33" *)
  (* unused_bits = "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31" *)
  wire [35:4] _0_;
  (* src = "/home/users/lilit.hunanyan/workspace/bram/yosys_verific_rs/yosys/install/bin/../share/yosys/rapidsilicon/genesis/brams_map.v:318.14-318.19" *)
  (* unused_bits = "0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35" *)
  wire [35:0] _1_;
  (* src = "bram_sdp.v:155.12-155.15" *)
  input clk;
  wire clk;
  (* src = "bram_sdp.v:157.26-157.28" *)
  input [11:0] ra;
  wire [11:0] ra;
  (* src = "bram_sdp.v:156.26-156.29" *)
  input rce;
  wire rce;
  (* src = "bram_sdp.v:158.26-158.28" *)
  output [3:0] rq;
  wire [3:0] rq;
  (* src = "bram_sdp.v:160.26-160.28" *)
  input [11:0] wa;
  wire [11:0] wa;
  (* src = "bram_sdp.v:159.26-159.29" *)
  input wce;
  wire wce;
  (* src = "bram_sdp.v:161.26-161.28" *)
  input [3:0] wd;
  wire [3:0] wd;
  (* module_not_derived = 32'd1 *)
  (* src = "/home/users/lilit.hunanyan/workspace/bram/yosys_verific_rs/yosys/install/bin/../share/yosys/rapidsilicon/genesis/brams_map.v:408.9-442.3" *)
  TDP36K #(
    .MODE_BITS(81'h001402824900140141248)
  ) \BRAM_4x4096.memory.0.0.0  (
    .ADDR_A1_i({ 1'h0, ra, 2'h0 }),
    .ADDR_A2_i({ ra, 2'h0 }),
    .ADDR_B1_i({ 1'h0, wa, 2'h0 }),
    .ADDR_B2_i({ wa, 2'h0 }),
    .BE_A1_i({ rce, rce }),
    .BE_A2_i({ rce, rce }),
    .BE_B1_i({ 1'hx, wce }),
    .BE_B2_i(2'hx),
    .CLK_A1_i(clk),
    .CLK_A2_i(clk),
    .CLK_B1_i(clk),
    .CLK_B2_i(clk),
    .FLUSH1_i(1'h0),
    .FLUSH2_i(1'h0),
    .RDATA_A1_o({ _0_[17:4], rq }),
    .RDATA_A2_o(_0_[35:18]),
    .RDATA_B1_o(_1_[17:0]),
    .RDATA_B2_o(_1_[35:18]),
    .REN_A1_i(rce),
    .REN_A2_i(rce),
    .REN_B1_i(1'h0),
    .REN_B2_i(1'h0),
    .RESET_ni(1'h1),
    .WDATA_A1_i(18'h3ffff),
    .WDATA_A2_i(18'h3ffff),
    .WDATA_B1_i({ 14'hxxxx, wd }),
    .WDATA_B2_i(18'hxxxxx),
    .WEN_A1_i(1'h0),
    .WEN_A2_i(1'h0),
    .WEN_B1_i(wce),
    .WEN_B2_i(wce)
  );
endmodule