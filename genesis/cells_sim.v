// Copyright (C) 2022 RapidSilicon
//

//module dff(
//    output reg Q,
//    input D,
//    (* clkbuf_sink *)
//    input C
//);
//    parameter [0:0] INIT = 1'b0;
//    initial Q = INIT;
//    always @(posedge C)
//        Q <= D;
//endmodule
//
//module dffn(
//    output reg Q,
//    input D,
//    (* clkbuf_sink *)
//    input C
//);
//    parameter [0:0] INIT = 1'b0;
//    initial Q = INIT;
//    always @(negedge C)
//        Q <= D;
//endmodule

module dffsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge C or negedge S or negedge R)
        if (!R)
            Q <= 1'b0;
        else if (!S)
            Q <= 1'b1;
        else if (E)
            Q <= D;
        
endmodule

module dffnsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(negedge C or negedge S or negedge R)
        if (!R)
            Q <= 1'b0;
        else if (!S)
            Q <= 1'b1;
        else if (E)
            Q <= D;
        
endmodule

module latchsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @*
        if (!R) 
            Q <= 1'b0;
        else if (!S) 
            Q <= 1'b1;
        else if (E && G) 
            Q <= D;
endmodule

module latchnsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @*
        if (!R) 
            Q <= 1'b0;
        else if (!S) 
            Q <= 1'b1;
        else if (E && !G) 
            Q <= D;
endmodule


module io_scff(
    output reg Q,
    input D,
    input SI,
    input R,
    input clk
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge clk or negedge R)
        if (!R)
            Q <= SI;
        else 
            Q <= D;
            
endmodule

module scff(
    output reg Q,
    output reg SO,
    input D,
    input SI,
    input S,
    input R,
    input E,
    input clk
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    initial SO = INIT;
    wire out_w;

    assign out_w = E ? SI : D;

    always @(posedge clk or negedge S or negedge R)
        if (!R) begin
            Q <= 1'b0;
            SO <= 1'b1;
        end
        else if (!S) begin
            Q <= 1'b1;
            SO <= 1'b0;
        end
        else begin
            Q <= out_w;
            SO <= ~out_w;
        end
            
endmodule

module sh_dff(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge C)
        Q <= D;
endmodule

module adder_carry(
    output sumout,
    output cout,
    input p,
    input g,
    input cin
);
    assign sumout = p ^ cin;
    assign cout = p ? cin : g;

endmodule

module sdffr(
    output reg Q,
    input D,
    input R,
    (* clkbuf_sink *)
    (* invertible_pin = "IS_C_INVERTED" *)
    input C
);
    parameter [0:0] INIT = 1'b0;
    parameter [0:0] IS_C_INVERTED = 1'b0;
    initial Q = INIT;
    case(|IS_C_INVERTED)
          1'b0:
            always @(posedge C)
                if (R == 1)
                        Q <= 1'b0;
                else
                        Q <= D;
          1'b1:
            always @(negedge C)
                if (R == 1)
                        Q <= 1'b0;
                else
                        Q <= D;
    endcase
endmodule

module sdffs(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    (* invertible_pin = "IS_C_INVERTED" *)
    input C,
    input S
);
    parameter [0:0] INIT = 1'b0;
    parameter [0:0] IS_C_INVERTED = 1'b0;
    initial Q = INIT;
    case(|IS_C_INVERTED)
          1'b0:
            always @(posedge C)
              if (S == 1)
                Q <= 1'b1;
              else
                Q <= D;
          1'b1:
            always @(negedge C)
              if (S == 1)
                Q <= 1'b1;
              else
                Q <= D;
        endcase
endmodule

module TDP_BRAM18 (
    (* clkbuf_sink *)
    input CLOCKA,
    (* clkbuf_sink *)
    input CLOCKB,
    input READENABLEA,
    input READENABLEB,
    input [13:0] ADDRA,
    input [13:0] ADDRB,
    input [15:0] WRITEDATAA,
    input [15:0] WRITEDATAB,
    input [1:0] WRITEDATAAP,
    input [1:0] WRITEDATABP,
    input WRITEENABLEA,
    input WRITEENABLEB,
    input [1:0] BYTEENABLEA,
    input [1:0] BYTEENABLEB,
    //input [2:0] WRITEDATAWIDTHA,
    //input [2:0] WRITEDATAWIDTHB,
    //input [2:0] READDATAWIDTHA,
    //input [2:0] READDATAWIDTHB,
    output [15:0] READDATAA,
    output [15:0] READDATAB,
    output [1:0] READDATAAP,
    output [1:0] READDATABP
);
    parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
    parameter integer READ_WIDTH_A = 0;
    parameter integer READ_WIDTH_B = 0;
    parameter integer WRITE_WIDTH_A = 0;
    parameter integer WRITE_WIDTH_B = 0;

endmodule

`default_nettype wire
module TDP36K (
    RESET_ni,
    WEN_A1_i,
    WEN_B1_i,
    REN_A1_i,
    REN_B1_i,
    CLK_A1_i,
    CLK_B1_i,
    BE_A1_i,
    BE_B1_i,
    ADDR_A1_i,
    ADDR_B1_i,
    WDATA_A1_i,
    WDATA_B1_i,
    RDATA_A1_o,
    RDATA_B1_o,
    FLUSH1_i,
    WEN_A2_i,
    WEN_B2_i,
    REN_A2_i,
    REN_B2_i,
    CLK_A2_i,
    CLK_B2_i,
    BE_A2_i,
    BE_B2_i,
    ADDR_A2_i,
    ADDR_B2_i,
    WDATA_A2_i,
    WDATA_B2_i,
    RDATA_A2_o,
    RDATA_B2_o,
    FLUSH2_i
);
    parameter [80:0] MODE_BITS = 81'd0;

    // First 18K RAMFIFO (41 bits)
    localparam [ 0:0] SYNC_FIFO1_i  = MODE_BITS[0];
    localparam [ 2:0] RMODE_A1_i    = MODE_BITS[3 : 1];
    localparam [ 2:0] RMODE_B1_i    = MODE_BITS[6 : 4];
    localparam [ 2:0] WMODE_A1_i    = MODE_BITS[9 : 7];
    localparam [ 2:0] WMODE_B1_i    = MODE_BITS[12:10];
    localparam [ 0:0] FMODE1_i      = MODE_BITS[13];
    localparam [ 0:0] POWERDN1_i    = MODE_BITS[14];
    localparam [ 0:0] SLEEP1_i      = MODE_BITS[15];
    localparam [ 0:0] PROTECT1_i    = MODE_BITS[16];
    localparam [11:0] UPAE1_i       = MODE_BITS[28:17];
    localparam [11:0] UPAF1_i       = MODE_BITS[40:29];

    // Second 18K RAMFIFO (39 bits)
    localparam [ 0:0] SYNC_FIFO2_i  = MODE_BITS[41];
    localparam [ 2:0] RMODE_A2_i    = MODE_BITS[44:42];
    localparam [ 2:0] RMODE_B2_i    = MODE_BITS[47:45];
    localparam [ 2:0] WMODE_A2_i    = MODE_BITS[50:48];
    localparam [ 2:0] WMODE_B2_i    = MODE_BITS[53:51];
    localparam [ 0:0] FMODE2_i      = MODE_BITS[54];
    localparam [ 0:0] POWERDN2_i    = MODE_BITS[55];
    localparam [ 0:0] SLEEP2_i      = MODE_BITS[56];
    localparam [ 0:0] PROTECT2_i    = MODE_BITS[57];
    localparam [10:0] UPAE2_i       = MODE_BITS[68:58];
    localparam [10:0] UPAF2_i       = MODE_BITS[79:69];

    // Split (1 bit)
    localparam [ 0:0] SPLIT_i       = MODE_BITS[80];

    parameter [36863:0] INIT_i = 36864'h0;

    input RESET_ni;
    input wire WEN_A1_i;
    input wire WEN_B1_i;
    input wire REN_A1_i;
    input wire REN_B1_i;
    (* clkbuf_sink *)
    input wire CLK_A1_i;
    (* clkbuf_sink *)
    input wire CLK_B1_i;
    input wire [1:0] BE_A1_i;
    input wire [1:0] BE_B1_i;
    input wire [14:0] ADDR_A1_i;
    input wire [14:0] ADDR_B1_i;
    input wire [17:0] WDATA_A1_i;
    input wire [17:0] WDATA_B1_i;
    output reg [17:0] RDATA_A1_o;
    output reg [17:0] RDATA_B1_o;
    input wire FLUSH1_i;
    input wire WEN_A2_i;
    input wire WEN_B2_i;
    input wire REN_A2_i;
    input wire REN_B2_i;
    (* clkbuf_sink *)
    input wire CLK_A2_i;
    (* clkbuf_sink *)
    input wire CLK_B2_i;
    input wire [1:0] BE_A2_i;
    input wire [1:0] BE_B2_i;
    input wire [13:0] ADDR_A2_i;
    input wire [13:0] ADDR_B2_i;
    input wire [17:0] WDATA_A2_i;
    input wire [17:0] WDATA_B2_i;
    output reg [17:0] RDATA_A2_o;
    output reg [17:0] RDATA_B2_o;
    input wire FLUSH2_i;
    wire EMPTY2;
    wire EPO2;
    wire EWM2;
    wire FULL2;
    wire FMO2;
    wire FWM2;
    wire EMPTY1;
    wire EPO1;
    wire EWM1;
    wire FULL1;
    wire FMO1;
    wire FWM1;
    wire UNDERRUN1;
    wire OVERRUN1;
    wire UNDERRUN2;
    wire OVERRUN2;
    wire UNDERRUN3;
    wire OVERRUN3;
    wire EMPTY3;
    wire EPO3;
    wire EWM3;
    wire FULL3;
    wire FMO3;
    wire FWM3;
    wire ram_fmode1;
    wire ram_fmode2;
    wire [17:0] ram_rdata_a1;
    wire [17:0] ram_rdata_b1;
    wire [17:0] ram_rdata_a2;
    wire [17:0] ram_rdata_b2;
    reg [17:0] ram_wdata_a1;
    reg [17:0] ram_wdata_b1;
    reg [17:0] ram_wdata_a2;
    reg [17:0] ram_wdata_b2;
    reg [14:0] laddr_a1;
    reg [14:0] laddr_b1;
    wire [13:0] ram_addr_a1;
    wire [13:0] ram_addr_b1;
    wire [13:0] ram_addr_a2;
    wire [13:0] ram_addr_b2;
    wire smux_clk_a1;
    wire smux_clk_b1;
    wire smux_clk_a2;
    wire smux_clk_b2;
    reg [1:0] ram_be_a1;
    reg [1:0] ram_be_a2;
    reg [1:0] ram_be_b1;
    reg [1:0] ram_be_b2;
    wire [2:0] ram_rmode_a1;
    wire [2:0] ram_wmode_a1;
    wire [2:0] ram_rmode_b1;
    wire [2:0] ram_wmode_b1;
    wire [2:0] ram_rmode_a2;
    wire [2:0] ram_wmode_a2;
    wire [2:0] ram_rmode_b2;
    wire [2:0] ram_wmode_b2;
    wire ram_ren_a1;
    wire ram_ren_b1;
    wire ram_ren_a2;
    wire ram_ren_b2;
    wire ram_wen_a1;
    wire ram_wen_b1;
    wire ram_wen_a2;
    wire ram_wen_b2;
    wire ren_o;
    wire [11:0] ff_raddr;
    wire [11:0] ff_waddr;
    reg [35:0] fifo_rdata;
    wire [1:0] fifo_rmode;
    wire [1:0] fifo_wmode;
    wire [1:0] bwl;
    wire [17:0] pl_dout0;
    wire [17:0] pl_dout1;
    wire sclk_a1;
    wire sclk_b1;
    wire sclk_a2;
    wire sclk_b2;
    wire sreset;
    wire flush1;
    wire flush2;
    assign sreset = RESET_ni;
    assign flush1 = ~FLUSH1_i;
    assign flush2 = ~FLUSH2_i;
    assign ram_fmode1 = FMODE1_i & SPLIT_i;
    assign ram_fmode2 = FMODE2_i & SPLIT_i;
    assign smux_clk_a1 = CLK_A1_i;
    assign smux_clk_b1 = (FMODE1_i ? (SYNC_FIFO1_i ? CLK_A1_i : CLK_B1_i) : CLK_B1_i);
    assign smux_clk_a2 = (SPLIT_i ? CLK_A2_i : CLK_A1_i);
    assign smux_clk_b2 = (SPLIT_i ? (FMODE2_i ? (SYNC_FIFO2_i ? CLK_A2_i : CLK_B2_i) : CLK_B2_i) : (FMODE1_i ? (SYNC_FIFO1_i ? CLK_A1_i : CLK_B1_i) : CLK_B1_i));
    assign sclk_a1 = smux_clk_a1;
    assign sclk_a2 = smux_clk_a2;
    assign sclk_b1 = smux_clk_b1;
    assign sclk_b2 = smux_clk_b2;
    assign ram_ren_a1 = (SPLIT_i ? REN_A1_i : (FMODE1_i ? 0 : REN_A1_i));
    assign ram_ren_a2 = (SPLIT_i ? REN_A2_i : (FMODE1_i ? 0 : REN_A1_i));
    assign ram_ren_b1 = (SPLIT_i ? REN_B1_i : (FMODE1_i ? ren_o : REN_B1_i));
    assign ram_ren_b2 = (SPLIT_i ? REN_B2_i : (FMODE1_i ? ren_o : REN_B1_i));
    localparam MODE_36 = 3'b011;
    assign ram_wen_a1 = (SPLIT_i ? WEN_A1_i : (FMODE1_i ? ~FULL3 & WEN_A1_i : (WMODE_A1_i == MODE_36 ? WEN_A1_i : WEN_A1_i & ~ADDR_A1_i[4])));
    assign ram_wen_a2 = (SPLIT_i ? WEN_A2_i : (FMODE1_i ? ~FULL3 & WEN_A1_i : (WMODE_A1_i == MODE_36 ? WEN_A1_i : WEN_A1_i & ADDR_A1_i[4])));
    assign ram_wen_b1 = (SPLIT_i ? WEN_B1_i : (WMODE_B1_i == MODE_36 ? WEN_B1_i : WEN_B1_i & ~ADDR_B1_i[4]));
    assign ram_wen_b2 = (SPLIT_i ? WEN_B2_i : (WMODE_B1_i == MODE_36 ? WEN_B1_i : WEN_B1_i & ADDR_B1_i[4]));
    assign ram_addr_a1 = (SPLIT_i ? ADDR_A1_i[13:0] : (FMODE1_i ? {ff_waddr[11:2], ff_waddr[0], 3'b000} : {ADDR_A1_i[14:5], ADDR_A1_i[3:0]}));
    assign ram_addr_b1 = (SPLIT_i ? ADDR_B1_i[13:0] : (FMODE1_i ? {ff_raddr[11:2], ff_raddr[0], 3'b000} : {ADDR_B1_i[14:5], ADDR_B1_i[3:0]}));
    assign ram_addr_a2 = (SPLIT_i ? ADDR_A2_i[13:0] : (FMODE1_i ? {ff_waddr[11:2], ff_waddr[0], 3'b000} : {ADDR_A1_i[14:5], ADDR_A1_i[3:0]}));
    assign ram_addr_b2 = (SPLIT_i ? ADDR_B2_i[13:0] : (FMODE1_i ? {ff_raddr[11:2], ff_raddr[0], 3'b000} : {ADDR_B1_i[14:5], ADDR_B1_i[3:0]}));
    assign bwl = (SPLIT_i ? ADDR_A1_i[4:3] : (FMODE1_i ? ff_waddr[1:0] : ADDR_A1_i[4:3]));
    localparam MODE_18 = 3'b010;
    localparam MODE_9 = 3'b001;
    always @(*) begin : WDATA_SEL
        case (SPLIT_i)
            1: begin
                ram_wdata_a1 = WDATA_A1_i;
                ram_wdata_a2 = WDATA_A2_i;
                ram_wdata_b1 = WDATA_B1_i;
                ram_wdata_b2 = WDATA_B2_i;
                ram_be_a2 = BE_A2_i;
                ram_be_b2 = BE_B2_i;
                ram_be_a1 = BE_A1_i;
                ram_be_b1 = BE_B1_i;
            end
            0: begin
                case (WMODE_A1_i)
                    MODE_36: begin
                        ram_wdata_a1 = WDATA_A1_i;
                        ram_wdata_a2 = WDATA_A2_i;
                        ram_be_a2 = (FMODE1_i ? 2'b11 : BE_A2_i);
                        ram_be_a1 = (FMODE1_i ? 2'b11 : BE_A1_i);
                    end
                    MODE_18: begin
                        ram_wdata_a1 = WDATA_A1_i;
                        ram_wdata_a2 = WDATA_A1_i;
                        ram_be_a1 = (FMODE1_i ? (ff_waddr[1] ? 2'b00 : 2'b11) : BE_A1_i);
                        ram_be_a2 = (FMODE1_i ? (ff_waddr[1] ? 2'b11 : 2'b00) : BE_A1_i);
                    end
                    MODE_9: begin
                        ram_wdata_a1[7:0] = WDATA_A1_i[7:0];
                        ram_wdata_a1[16] = WDATA_A1_i[16];
                        ram_wdata_a1[15:8] = WDATA_A1_i[7:0];
                        ram_wdata_a1[17] = WDATA_A1_i[16];
                        ram_wdata_a2[7:0] = WDATA_A1_i[7:0];
                        ram_wdata_a2[16] = WDATA_A1_i[16];
                        ram_wdata_a2[15:8] = WDATA_A1_i[7:0];
                        ram_wdata_a2[17] = WDATA_A1_i[16];
                        case (bwl)
                            0: {ram_be_a2, ram_be_a1} = 4'b0001;
                            1: {ram_be_a2, ram_be_a1} = 4'b0010;
                            2: {ram_be_a2, ram_be_a1} = 4'b0100;
                            3: {ram_be_a2, ram_be_a1} = 4'b1000;
                        endcase
                    end
                    default: begin
                        ram_wdata_a1 = WDATA_A1_i;
                        ram_wdata_a2 = WDATA_A1_i;
                        ram_be_a2 = (FMODE1_i ? 2'b11 : BE_A1_i);
                        ram_be_a1 = (FMODE1_i ? 2'b11 : BE_A1_i);
                    end
                endcase
                case (WMODE_B1_i)
                    MODE_36: begin
                        ram_wdata_b1 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B1_i);
                        ram_wdata_b2 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B2_i);
                        ram_be_b2 = BE_B2_i;
                        ram_be_b1 = BE_B1_i;
                    end
                    MODE_18: begin
                        ram_wdata_b1 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B1_i);
                        ram_wdata_b2 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B1_i);
                        ram_be_b1 = BE_B1_i;
                        ram_be_b2 = BE_B1_i;
                    end
                    MODE_9: begin
                        ram_wdata_b1[7:0] = WDATA_B1_i[7:0];
                        ram_wdata_b1[16] = WDATA_B1_i[16];
                        ram_wdata_b1[15:8] = WDATA_B1_i[7:0];
                        ram_wdata_b1[17] = WDATA_B1_i[16];
                        ram_wdata_b2[7:0] = WDATA_B1_i[7:0];
                        ram_wdata_b2[16] = WDATA_B1_i[16];
                        ram_wdata_b2[15:8] = WDATA_B1_i[7:0];
                        ram_wdata_b2[17] = WDATA_B1_i[16];
                        case (ADDR_B1_i[4:3])
                            0: {ram_be_b2, ram_be_b1} = 4'b0001;
                            1: {ram_be_b2, ram_be_b1} = 4'b0010;
                            2: {ram_be_b2, ram_be_b1} = 4'b0100;
                            3: {ram_be_b2, ram_be_b1} = 4'b1000;
                        endcase
                    end
                    default: begin
                        ram_wdata_b1 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B1_i);
                        ram_wdata_b2 = (FMODE1_i ? 18'b000000000000000000 : WDATA_B1_i);
                        ram_be_b2 = BE_B1_i;
                        ram_be_b1 = BE_B1_i;
                    end
                endcase
            end
        endcase
    end
    assign ram_rmode_a1 = (SPLIT_i ? (RMODE_A1_i == MODE_36 ? MODE_18 : RMODE_A1_i) : (RMODE_A1_i == MODE_36 ? MODE_18 : RMODE_A1_i));
    assign ram_rmode_a2 = (SPLIT_i ? (RMODE_A2_i == MODE_36 ? MODE_18 : RMODE_A2_i) : (RMODE_A1_i == MODE_36 ? MODE_18 : RMODE_A1_i));
    assign ram_wmode_a1 = (SPLIT_i ? (WMODE_A1_i == MODE_36 ? MODE_18 : WMODE_A1_i) : (WMODE_A1_i == MODE_36 ? MODE_18 : (FMODE1_i ? MODE_18 : WMODE_A1_i)));
    assign ram_wmode_a2 = (SPLIT_i ? (WMODE_A2_i == MODE_36 ? MODE_18 : WMODE_A2_i) : (WMODE_A1_i == MODE_36 ? MODE_18 : (FMODE1_i ? MODE_18 : WMODE_A1_i)));
    assign ram_rmode_b1 = (SPLIT_i ? (RMODE_B1_i == MODE_36 ? MODE_18 : RMODE_B1_i) : (RMODE_B1_i == MODE_36 ? MODE_18 : (FMODE1_i ? MODE_18 : RMODE_B1_i)));
    assign ram_rmode_b2 = (SPLIT_i ? (RMODE_B2_i == MODE_36 ? MODE_18 : RMODE_B2_i) : (RMODE_B1_i == MODE_36 ? MODE_18 : (FMODE1_i ? MODE_18 : RMODE_B1_i)));
    assign ram_wmode_b1 = (SPLIT_i ? (WMODE_B1_i == MODE_36 ? MODE_18 : WMODE_B1_i) : (WMODE_B1_i == MODE_36 ? MODE_18 : WMODE_B1_i));
    assign ram_wmode_b2 = (SPLIT_i ? (WMODE_B2_i == MODE_36 ? MODE_18 : WMODE_B2_i) : (WMODE_B1_i == MODE_36 ? MODE_18 : WMODE_B1_i));
    always @(*) begin : FIFO_READ_SEL
        case (RMODE_B1_i)
            MODE_36: fifo_rdata = {ram_rdata_b2[17:16], ram_rdata_b1[17:16], ram_rdata_b2[15:0], ram_rdata_b1[15:0]};
            MODE_18: fifo_rdata = (ff_raddr[1] ? {18'b000000000000000000, ram_rdata_b2} : {18'b000000000000000000, ram_rdata_b1});
            MODE_9:
                case (ff_raddr[1:0])
                    0: fifo_rdata = {19'b0000000000000000000, ram_rdata_b1[16], 8'b00000000, ram_rdata_b1[7:0]};
                    1: fifo_rdata = {19'b0000000000000000000, ram_rdata_b1[17], 8'b00000000, ram_rdata_b1[15:8]};
                    2: fifo_rdata = {19'b0000000000000000000, ram_rdata_b2[16], 8'b00000000, ram_rdata_b2[7:0]};
                    3: fifo_rdata = {19'b0000000000000000000, ram_rdata_b2[17], 8'b00000000, ram_rdata_b2[15:8]};
                endcase
            default: fifo_rdata = {ram_rdata_b2, ram_rdata_b1};
        endcase
    end
    localparam MODE_1 = 3'b101;
    localparam MODE_2 = 3'b110;
    localparam MODE_4 = 3'b100;
    always @(*) begin : RDATA_SEL
        case (SPLIT_i)
            1: begin
                RDATA_A1_o = (FMODE1_i ? {10'b0000000000, EMPTY1, EPO1, EWM1, UNDERRUN1, FULL1, FMO1, FWM1, OVERRUN1} : ram_rdata_a1);
                RDATA_B1_o = ram_rdata_b1;
                RDATA_A2_o = (FMODE2_i ? {10'b0000000000, EMPTY2, EPO2, EWM2, UNDERRUN2, FULL2, FMO2, FWM2, OVERRUN2} : ram_rdata_a2);
                RDATA_B2_o = ram_rdata_b2;
            end
            0: begin
                if (FMODE1_i) begin
                    RDATA_A1_o = {10'b0000000000, EMPTY3, EPO3, EWM3, UNDERRUN3, FULL3, FMO3, FWM3, OVERRUN3};
                    RDATA_A2_o = 18'b000000000000000000;
                end
                else
                    case (RMODE_A1_i)
                        MODE_36: begin
                            RDATA_A1_o = {ram_rdata_a1[17:0]};
                            RDATA_A2_o = {ram_rdata_a2[17:0]};
                        end
                        MODE_18: begin
                            RDATA_A1_o = (laddr_a1[4] ? ram_rdata_a2 : ram_rdata_a1);
                            RDATA_A2_o = 18'b000000000000000000;
                        end
                        MODE_9: begin
                            RDATA_A1_o = (laddr_a1[4] ? {{2 {ram_rdata_a2[16]}}, {2 {ram_rdata_a2[7:0]}}} : {{2 {ram_rdata_a1[16]}}, {2 {ram_rdata_a1[7:0]}}});
                            RDATA_A2_o = 18'b000000000000000000;
                        end
                        MODE_4: begin
                            RDATA_A2_o = 18'b000000000000000000;
                            RDATA_A1_o[17:4] = 14'b00000000000000;
                            RDATA_A1_o[3:0] = (laddr_a1[4] ? ram_rdata_a2[3:0] : ram_rdata_a1[3:0]);
                        end
                        MODE_2: begin
                            RDATA_A2_o = 18'b000000000000000000;
                            RDATA_A1_o[17:2] = 16'b0000000000000000;
                            RDATA_A1_o[1:0] = (laddr_a1[4] ? ram_rdata_a2[1:0] : ram_rdata_a1[1:0]);
                        end
                        MODE_1: begin
                            RDATA_A2_o = 18'b000000000000000000;
                            RDATA_A1_o[17:1] = 17'b00000000000000000;
                            RDATA_A1_o[0] = (laddr_a1[4] ? ram_rdata_a2[0] : ram_rdata_a1[0]);
                        end
                        default: begin
                            RDATA_A1_o = {ram_rdata_a2[1:0], ram_rdata_a1[15:0]};
                            RDATA_A2_o = {ram_rdata_a2[17:16], ram_rdata_a1[17:16], ram_rdata_a2[15:2]};
                        end
                    endcase
                case (RMODE_B1_i)
                    MODE_36: begin
                        RDATA_B1_o = {ram_rdata_b1};
                        RDATA_B2_o = {ram_rdata_b2};
                    end
                    MODE_18: begin
                        RDATA_B1_o = (FMODE1_i ? fifo_rdata[17:0] : (laddr_b1[4] ? ram_rdata_b2 : ram_rdata_b1));
                        RDATA_B2_o = 18'b000000000000000000;
                    end
                    MODE_9: begin
                        RDATA_B1_o = (FMODE1_i ? {fifo_rdata[17:0]} : (laddr_b1[4] ? {1'b0, ram_rdata_b2[16], 8'b00000000, ram_rdata_b2[7:0]} : {1'b0, ram_rdata_b1[16], 8'b00000000, ram_rdata_b1[7:0]}));
                        RDATA_B2_o = 18'b000000000000000000;
                    end
                    MODE_4: begin
                        RDATA_B2_o = 18'b000000000000000000;
                        RDATA_B1_o[17:4] = 14'b00000000000000;
                        RDATA_B1_o[3:0] = (laddr_b1[4] ? ram_rdata_b2[3:0] : ram_rdata_b1[3:0]);
                    end
                    MODE_2: begin
                        RDATA_B2_o = 18'b000000000000000000;
                        RDATA_B1_o[17:2] = 16'b0000000000000000;
                        RDATA_B1_o[1:0] = (laddr_b1[4] ? ram_rdata_b2[1:0] : ram_rdata_b1[1:0]);
                    end
                    MODE_1: begin
                        RDATA_B2_o = 18'b000000000000000000;
                        RDATA_B1_o[17:1] = 17'b00000000000000000;
                        RDATA_B1_o[0] = (laddr_b1[4] ? ram_rdata_b2[0] : ram_rdata_b1[0]);
                    end
                    default: begin
                        RDATA_B1_o = ram_rdata_b1;
                        RDATA_B2_o = ram_rdata_b2;
                    end
                endcase
            end
        endcase
    end
    always @(posedge sclk_a1 or negedge sreset)
        if (sreset == 0)
            laddr_a1 <= 1'sb0;
        else
            laddr_a1 <= ADDR_A1_i;
    always @(posedge sclk_b1 or negedge sreset)
        if (sreset == 0)
            laddr_b1 <= 1'sb0;
        else
            laddr_b1 <= ADDR_B1_i;
    assign fifo_wmode = ((WMODE_A1_i == MODE_36) ? 2'b00 : ((WMODE_A1_i == MODE_18) ? 2'b01 : ((WMODE_A1_i == MODE_9) ? 2'b10 : 2'b00)));
    assign fifo_rmode = ((RMODE_B1_i == MODE_36) ? 2'b00 : ((RMODE_B1_i == MODE_18) ? 2'b01 : ((RMODE_B1_i == MODE_9) ? 2'b10 : 2'b00)));
    fifo_ctl #(
        .ADDR_WIDTH(12),
        .FIFO_WIDTH(3'd4),
        .DEPTH(7)
    ) fifo36_ctl(
        .rclk(sclk_b1),
        .rst_R_n(flush1),
        .wclk(sclk_a1),
        .rst_W_n(flush1),
        .ren(REN_B1_i),
        .wen(ram_wen_a1),
        .sync(SYNC_FIFO1_i),
        .rmode(fifo_rmode),
        .wmode(fifo_wmode),
        .ren_o(ren_o),
        .fflags({FULL3, FMO3, FWM3, OVERRUN3, EMPTY3, EPO3, EWM3, UNDERRUN3}),
        .raddr(ff_raddr),
        .waddr(ff_waddr),
        .upaf(UPAF1_i),
        .upae(UPAE1_i)
    );
    TDP18K_FIFO #(
        .UPAF_i(UPAF1_i[10:0]),
        .UPAE_i(UPAE1_i[10:0]),
        .SYNC_FIFO_i(SYNC_FIFO1_i),
        .POWERDN_i(POWERDN1_i),
        .SLEEP_i(SLEEP1_i),
        .PROTECT_i(PROTECT1_i),
        .INIT_t_i(INIT_i[0*18432+:18432])
    )u1(
        .RMODE_A_i(ram_rmode_a1),
        .RMODE_B_i(ram_rmode_b1),
        .WMODE_A_i(ram_wmode_a1),
        .WMODE_B_i(ram_wmode_b1),
        .WEN_A_i(ram_wen_a1),
        .WEN_B_i(ram_wen_b1),
        .REN_A_i(ram_ren_a1),
        .REN_B_i(ram_ren_b1),
        .CLK_A_i(sclk_a1),
        .CLK_B_i(sclk_b1),
        .BE_A_i(ram_be_a1),
        .BE_B_i(ram_be_b1),
        .ADDR_A_i(ram_addr_a1),
        .ADDR_B_i(ram_addr_b1),
        .WDATA_A_i(ram_wdata_a1),
        .WDATA_B_i(ram_wdata_b1),
        .RDATA_A_o(ram_rdata_a1),
        .RDATA_B_o(ram_rdata_b1),
        .EMPTY_o(EMPTY1),
        .EPO_o(EPO1),
        .EWM_o(EWM1),
        .UNDERRUN_o(UNDERRUN1),
        .FULL_o(FULL1),
        .FMO_o(FMO1),
        .FWM_o(FWM1),
        .OVERRUN_o(OVERRUN1),
        .FLUSH_ni(flush1),
        .FMODE_i(ram_fmode1)
    );
    TDP18K_FIFO #(
        .UPAF_i(UPAF2_i),
        .UPAE_i(UPAE2_i),
        .SYNC_FIFO_i(SYNC_FIFO2_i),
        .POWERDN_i(POWERDN2_i),
        .SLEEP_i(SLEEP2_i),
        .PROTECT_i(PROTECT2_i),
        .INIT_t_i(INIT_i[1*18432+:18432])
    )u2(
        .RMODE_A_i(ram_rmode_a2),
        .RMODE_B_i(ram_rmode_b2),
        .WMODE_A_i(ram_wmode_a2),
        .WMODE_B_i(ram_wmode_b2),
        .WEN_A_i(ram_wen_a2),
        .WEN_B_i(ram_wen_b2),
        .REN_A_i(ram_ren_a2),
        .REN_B_i(ram_ren_b2),
        .CLK_A_i(sclk_a2),
        .CLK_B_i(sclk_b2),
        .BE_A_i(ram_be_a2),
        .BE_B_i(ram_be_b2),
        .ADDR_A_i(ram_addr_a2),
        .ADDR_B_i(ram_addr_b2),
        .WDATA_A_i(ram_wdata_a2),
        .WDATA_B_i(ram_wdata_b2),
        .RDATA_A_o(ram_rdata_a2),
        .RDATA_B_o(ram_rdata_b2),
        .EMPTY_o(EMPTY2),
        .EPO_o(EPO2),
        .EWM_o(EWM2),
        .UNDERRUN_o(UNDERRUN2),
        .FULL_o(FULL2),
        .FMO_o(FMO2),
        .FWM_o(FWM2),
        .OVERRUN_o(OVERRUN2),
        .FLUSH_ni(flush2),
        .FMODE_i(ram_fmode2)
    );
endmodule
