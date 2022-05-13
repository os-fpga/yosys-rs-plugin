// Copyright (C) 2022 RapidSilicon
//

//(* abc9_flop, lib_whitebox *)
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

(* abc9_flop, lib_whitebox *)
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

(* abc9_flop, lib_whitebox *)
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

(* abc9_flop, lib_whitebox *)
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

(* abc9_flop, lib_whitebox *)
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

(* abc9_box, lib_blackbox *)
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

(* blackbox *)
module RS_DSP1 (
    input  [19:0] a,
    input  [17:0] b,
    (* clkbuf_sink *)
    input  clk0,
    (* clkbuf_sink *)
    input  clk1,
    input  [ 1:0] feedback0,
    input  [ 1:0] feedback1,
    input  load_acc0,
    input  load_acc1,
    input  reset0,
    input  reset1,
    output reg [37:0] z
);
    parameter MODE_BITS = 27'b00000000000000000000000000;
endmodule  /* RS_DSP1 */

module RS_DSP2 ( // TODO: Name subject to change
      input  [19:0] a,
      input  [17:0] b,
      input  [ 5:0] acc_fir,
      output [37:0] z,
      output [17:0] dly_b,

    (* clkbuf_sink *)
    input         clk,
    input         reset,

    input  [2:0]  feedback,
    input         load_acc,
    input         unsigned_a,
    input         unsigned_b,

    input         f_mode,
    input  [2:0]  output_select,
    input         saturate_enable,
    input  [5:0]  shift_right,
    input         round,
    input         subtract,
    input         register_inputs
);

    parameter [79:0] MODE_BITS = 80'd0;

    localparam [19:0] COEFF_0 = MODE_BITS[19:0];
    localparam [19:0] COEFF_1 = MODE_BITS[39:20];
    localparam [19:0] COEFF_2 = MODE_BITS[59:40];
    localparam [19:0] COEFF_3 = MODE_BITS[79:60];

      localparam NBITS_ACC = 64;
      localparam NBITS_A = 20;
      localparam NBITS_B = 18;
      localparam NBITS_Z = 38;

      wire [NBITS_Z-1:0] dsp_full_z;
      wire [(NBITS_Z/2)-1:0] dsp_frac0_z;
      wire [(NBITS_Z/2)-1:0] dsp_frac1_z;

      wire [NBITS_B-1:0] dsp_full_dly_b;
      wire [(NBITS_B/2)-1:0] dsp_frac0_dly_b;
      wire [(NBITS_B/2)-1:0] dsp_frac1_dly_b;

      assign z = f_mode ? {dsp_frac1_z, dsp_frac0_z} : dsp_full_z;
      assign dly_b = f_mode ? {dsp_frac1_dly_b, dsp_frac0_dly_b} : dsp_full_dly_b;

    // Output used when fmode == 1
        dsp_t1_sim #(
        .NBITS_A(NBITS_A/2),
            .NBITS_B(NBITS_B/2),
            .NBITS_ACC(NBITS_ACC/2),
            .NBITS_Z(NBITS_Z/2)
        ) dsp_frac0 (
            .a_i(a[(NBITS_A/2)-1:0]),
            .b_i(b[(NBITS_B/2)-1:0]),
            .z_o(dsp_frac0_z),
            .dly_b_o(dsp_frac0_dly_b),

            .acc_fir_i(acc_fir),
            .feedback_i(feedback),
            .load_acc_i(load_acc),

            .unsigned_a_i(unsigned_a),
            .unsigned_b_i(unsigned_b),

            .clock_i(clk),
            .s_reset(reset),

            .saturate_enable_i(saturate_enable),
            .output_select_i(output_select),
            .round_i(round),
            .shift_right_i(shift_right),
            .subtract_i(subtract),
            .register_inputs_i(register_inputs),
            .coef_0_i(COEFF_0[(NBITS_A/2)-1:0]),
            .coef_1_i(COEFF_1[(NBITS_A/2)-1:0]),
            .coef_2_i(COEFF_2[(NBITS_A/2)-1:0]),
            .coef_3_i(COEFF_3[(NBITS_A/2)-1:0])
        );

    // Output used when fmode == 1
        dsp_t1_sim #(
        .NBITS_A(NBITS_A/2),
            .NBITS_B(NBITS_B/2),
            .NBITS_ACC(NBITS_ACC/2),
            .NBITS_Z(NBITS_Z/2)
        ) dsp_frac1 (
            .a_i(a[NBITS_A-1:NBITS_A/2]),
            .b_i(b[NBITS_B-1:NBITS_B/2]),
            .z_o(dsp_frac1_z),
            .dly_b_o(dsp_frac1_dly_b),

            .acc_fir_i(acc_fir),
            .feedback_i(feedback),
            .load_acc_i(load_acc),

            .unsigned_a_i(unsigned_a),
            .unsigned_b_i(unsigned_b),

            .clock_i(clk),
            .s_reset(reset),

            .saturate_enable_i(saturate_enable),
            .output_select_i(output_select),
            .round_i(round),
            .shift_right_i(shift_right),
            .subtract_i(subtract),
            .register_inputs_i(register_inputs),
            .coef_0_i(COEFF_0[NBITS_A-1:NBITS_A/2]),
            .coef_1_i(COEFF_1[NBITS_A-1:NBITS_A/2]),
            .coef_2_i(COEFF_2[NBITS_A-1:NBITS_A/2]),
            .coef_3_i(COEFF_3[NBITS_A-1:NBITS_A/2])
        );

    // Output used when fmode == 0
        dsp_t1_sim #(
             .NBITS_A(NBITS_A),
             .NBITS_B(NBITS_B),
             .NBITS_ACC(NBITS_ACC),
             .NBITS_Z(NBITS_Z)
        ) dsp_full (
            .a_i(a),
            .b_i(b),
            .z_o(dsp_full_z),
            .dly_b_o(dsp_full_dly_b),

            .acc_fir_i(acc_fir),
            .feedback_i(feedback),
            .load_acc_i(load_acc),

            .unsigned_a_i(unsigned_a),
            .unsigned_b_i(unsigned_b),

            .clock_i(clk),
            .s_reset(reset),

            .saturate_enable_i(saturate_enable),
            .output_select_i(output_select),
            .round_i(round),
            .shift_right_i(shift_right),
            .subtract_i(subtract),
            .register_inputs_i(register_inputs),
            .coef_0_i(COEFF_0),
            .coef_1_i(COEFF_1),
            .coef_2_i(COEFF_2),
            .coef_3_i(COEFF_3)
        );
endmodule

module dsp_t1_sim # (
    parameter NBITS_ACC  = 64,
    parameter NBITS_A    = 20,
    parameter NBITS_B    = 18,
    parameter NBITS_Z    = 38
)(
    input [NBITS_A-1:0] a_i,
    input [NBITS_B-1:0] b_i,
    output [NBITS_Z-1:0] z_o,
    output reg [NBITS_B-1:0] dly_b_o,

    input [5:0] acc_fir_i,
    input [2:0] feedback_i,
    input load_acc_i,

    input unsigned_a_i,
    input unsigned_b_i,

    input clock_i,
    input s_reset,

    input saturate_enable_i,
    input [2:0] output_select_i,
    input round_i,
    input [5:0] shift_right_i,
    input subtract_i,
    input register_inputs_i,
    input [NBITS_A-1:0] coef_0_i,
    input [NBITS_A-1:0] coef_1_i,
    input [NBITS_A-1:0] coef_2_i,
    input [NBITS_A-1:0] coef_3_i
);

// FIXME: The version of Icarus Verilog from Conda seems not to recognize the
// $error macro. Disable this sanity check for now because of that.
`ifndef __ICARUS__
    if (NBITS_ACC < NBITS_A + NBITS_B)
        $error("NBITS_ACC must be > NBITS_A + NBITS_B");
`endif

    // Input registers
    reg  [NBITS_A-1:0]  r_a;
    reg  [NBITS_B-1:0]  r_b;
    reg  [5:0]          r_acc_fir;
    reg                 r_unsigned_a;
    reg                 r_unsigned_b;
    reg                 r_load_acc;
    reg  [2:0]          r_feedback;
    reg  [5:0]          r_shift_d1;
    reg  [5:0]          r_shift_d2;
    reg         r_subtract;
    reg         r_sat;
    reg         r_rnd;
    reg [NBITS_ACC-1:0] acc;

    initial begin
        r_a          <= 0;
        r_b          <= 0;

        r_acc_fir    <= 0;
        r_unsigned_a <= 0;
        r_unsigned_b <= 0;
        r_feedback   <= 0;
        r_shift_d1   <= 0;
        r_shift_d2   <= 0;
        r_subtract   <= 0;
        r_load_acc   <= 0;
        r_sat        <= 0;
        r_rnd        <= 0;
    end

    always @(posedge clock_i or posedge s_reset) begin
        if (s_reset) begin

            r_a <= 'h0;
            r_b <= 'h0;

        r_acc_fir    <= 0;
            r_unsigned_a <= 0;
            r_unsigned_b <= 0;
            r_feedback   <= 0;
            r_shift_d1   <= 0;
            r_shift_d2   <= 0;
        r_subtract   <= 0;
            r_load_acc   <= 0;
            r_sat    <= 0;
            r_rnd    <= 0;

        end else begin

            r_a <= a_i;
            r_b <= b_i;

        r_acc_fir    <= acc_fir_i;
            r_unsigned_a <= unsigned_a_i;
            r_unsigned_b <= unsigned_b_i;
            r_feedback   <= feedback_i;
            r_shift_d1   <= shift_right_i;
            r_shift_d2   <= r_shift_d1;
        r_subtract   <= subtract_i;
            r_load_acc   <= load_acc_i;
            r_sat    <= r_sat;
            r_rnd    <= r_rnd;

        end
    end

    // Registered / non-registered input path select
    wire [NBITS_A-1:0]  a = register_inputs_i ? r_a : a_i;
    wire [NBITS_B-1:0]  b = register_inputs_i ? r_b : b_i;

    wire [5:0] acc_fir = register_inputs_i ? r_acc_fir : acc_fir_i;
    wire       unsigned_a = register_inputs_i ? r_unsigned_a : unsigned_a_i;
    wire       unsigned_b = register_inputs_i ? r_unsigned_b : unsigned_b_i;
    wire [2:0] feedback   = register_inputs_i ? r_feedback   : feedback_i;
    wire       load_acc   = register_inputs_i ? r_load_acc   : load_acc_i;
    wire       subtract   = register_inputs_i ? r_subtract   : subtract_i;
    wire       sat    = register_inputs_i ? r_sat : saturate_enable_i;
    wire       rnd    = register_inputs_i ? r_rnd : round_i;

    // Shift right control
    wire [5:0] shift_d1 = register_inputs_i ? r_shift_d1 : shift_right_i;
    wire [5:0] shift_d2 = output_select_i[1] ? shift_d1 : r_shift_d2;

    // Multiplier
    wire unsigned_mode = unsigned_a & unsigned_b;
    wire [NBITS_A-1:0] mult_a;
    assign mult_a = (feedback == 3'h0) ?   a :
                    (feedback == 3'h1) ?   a :
                    (feedback == 3'h2) ?   a :
                    (feedback == 3'h3) ?   acc[NBITS_A-1:0] :
                    (feedback == 3'h4) ?   coef_0_i :
                    (feedback == 3'h5) ?   coef_1_i :
                    (feedback == 3'h6) ?   coef_2_i :
                       coef_3_i;    // if feedback == 3'h7

    wire [NBITS_B-1:0] mult_b = (feedback == 2'h2) ? {NBITS_B{1'b0}}  : b;

    wire [NBITS_A-1:0] mult_sgn_a = mult_a[NBITS_A-1];
    wire [NBITS_A-1:0] mult_mag_a = (mult_sgn_a && !unsigned_a) ? (~mult_a + 1) : mult_a;
    wire [NBITS_B-1:0] mult_sgn_b = mult_b[NBITS_B-1];
    wire [NBITS_B-1:0] mult_mag_b = (mult_sgn_b && !unsigned_b) ? (~mult_b + 1) : mult_b;

    wire [NBITS_A+NBITS_B-1:0] mult_mag = mult_mag_a * mult_mag_b;
    wire mult_sgn = (mult_sgn_a && !unsigned_a) ^ (mult_sgn_b && !unsigned_b);

    wire [NBITS_A+NBITS_B-1:0] mult = (unsigned_a && unsigned_b) ?
        (mult_a * mult_b) : (mult_sgn ? (~mult_mag + 1) : mult_mag);

    // Sign extension
    wire [NBITS_ACC-1:0] mult_xtnd = unsigned_mode ?
        {{(NBITS_ACC-NBITS_A-NBITS_B){1'b0}},                    mult[NBITS_A+NBITS_B-1:0]} :
        {{(NBITS_ACC-NBITS_A-NBITS_B){mult[NBITS_A+NBITS_B-1]}}, mult[NBITS_A+NBITS_B-1:0]};

    // Adder
    wire [NBITS_ACC-1:0] acc_fir_int = unsigned_a ? {{(NBITS_ACC-NBITS_A){1'b0}},         a} :
                                                    {{(NBITS_ACC-NBITS_A){a[NBITS_A-1]}}, a} ;

    wire [NBITS_ACC-1:0] add_a = (subtract) ? (~mult_xtnd + 1) : mult_xtnd;
    wire [NBITS_ACC-1:0] add_b = (feedback_i == 3'h0) ? acc :
                                 (feedback_i == 3'h1) ? {{NBITS_ACC}{1'b0}} : (acc_fir_int << acc_fir);

    wire [NBITS_ACC-1:0] add_o = add_a + add_b;

    // Accumulator
    initial acc <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset) acc <= 'h0;
        else begin
            if (load_acc)
                acc <= add_o;
            else
                acc <= acc;
        end

    // Adder/accumulator output selection
    wire [NBITS_ACC-1:0] acc_out = (output_select_i[1]) ? add_o : acc;

    // Round, shift, saturate
    wire [NBITS_ACC-1:0] acc_rnd = (rnd && (shift_right_i != 0)) ? (acc_out + ({{(NBITS_ACC-1){1'b0}}, 1'b1} << (shift_right_i - 1))) :
                                                                    acc_out;

    wire [NBITS_ACC-1:0] acc_shr = (unsigned_mode) ? (acc_rnd  >> shift_right_i) :
                                                     (acc_rnd >>> shift_right_i);

    wire [NBITS_ACC-1:0] acc_sat_u = (acc_shr[NBITS_ACC-1:NBITS_Z] != 0) ? {{(NBITS_ACC-NBITS_Z){1'b0}},{NBITS_Z{1'b1}}} :
                                                                           {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_Z-1:0]}};

    wire [NBITS_ACC-1:0] acc_sat_s = ((|acc_shr[NBITS_ACC-1:NBITS_Z-1] == 1'b0) ||
                                      (&acc_shr[NBITS_ACC-1:NBITS_Z-1] == 1'b1)) ? {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_Z-1:0]}} :
                                                                                   {{(NBITS_ACC-NBITS_Z){1'b0}},{acc_shr[NBITS_ACC-1],{NBITS_Z-1{~acc_shr[NBITS_ACC-1]}}}};

    wire [NBITS_ACC-1:0] acc_sat = (sat) ? ((unsigned_mode) ? acc_sat_u : acc_sat_s) : acc_shr;

    // Output signals
    wire [NBITS_Z-1:0]  z0;
    reg  [NBITS_Z-1:0]  z1;
    wire [NBITS_Z-1:0]  z2;

    assign z0 = mult_xtnd[NBITS_Z-1:0];
    assign z2 = acc_sat[NBITS_Z-1:0];

    initial z1 <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset)
            z1 <= 0;
        else begin
            z1 <= (output_select_i == 3'b100) ? z0 : z2;
        end

    // Output mux
    assign z_o = (output_select_i == 3'h0) ?   z0 :
                 (output_select_i == 3'h1) ?   z2 :
                 (output_select_i == 3'h2) ?   z2 :
                 (output_select_i == 3'h3) ?   z2 :
                 (output_select_i == 3'h4) ?   z1 :
                 (output_select_i == 3'h5) ?   z1 :
                 (output_select_i == 3'h6) ?   z1 :
                           z1;  // if output_select_i == 3'h7

    // B input delayed passthrough
    initial dly_b_o <= 0;

    always @(posedge clock_i or posedge s_reset)
        if (s_reset)
            dly_b_o <= 0;
        else
            dly_b_o <= b_i;

endmodule

module dsp_t1_20x18x64 (
    input  [19:0] a_i,
    input  [17:0] b_i,
    input  [ 5:0] acc_fir_i,
    output [37:0] z_o,
    output [17:0] dly_b_o,

    (* clkbuf_sink *)
    input         clock_i,
    input         reset_i,

    input  [2:0]  feedback_i,
    input         load_acc_i,
    input         unsigned_a_i,
    input         unsigned_b_i,

    input  [2:0]  output_select_i,
    input         saturate_enable_i,
    input  [5:0]  shift_right_i,
    input         round_i,
    input         subtract_i,
    input         register_inputs_i
);

    parameter [19:0] COEFF_0 = 20'd0;
    parameter [19:0] COEFF_1 = 20'd0;
    parameter [19:0] COEFF_2 = 20'd0;
    parameter [19:0] COEFF_3 = 20'd0;

   RS_DSP2 #(
    .MODE_BITS({COEFF_3, COEFF_2, COEFF_1, COEFF_0})
   ) dsp (
    .a(a_i),
    .b(b_i),
    .z(z_o),
    .dly_b(dly_b_o),

    .f_mode(1'b0),  // 20x18x64 DSP

    .acc_fir(acc_fir_i),
    .feedback(feedback_i),
    .load_acc(load_acc_i),

    .unsigned_a(unsigned_a_i),
    .unsigned_b(unsigned_b_i),

    .clk(clock_i),
    .reset(reset_i),

    .saturate_enable(saturate_enable_i),
    .output_select(output_select_i),
    .round(round_i),
    .shift_right(shift_right_i),
    .subtract(subtract_i),
    .register_inputs(register_inputs_i)
    );
endmodule

module dsp_t1_10x9x32 (
    input  [ 9:0] a_i,
    input  [ 8:0] b_i,
    input  [ 5:0] acc_fir_i,
    output [18:0] z_o,
    output [ 8:0] dly_b_o,

    (* clkbuf_sink *)
    input         clock_i,
    input         reset_i,

    input  [2:0]  feedback_i,
    input         load_acc_i,
    input         unsigned_a_i,
    input         unsigned_b_i,

    input  [2:0]  output_select_i,
    input         saturate_enable_i,
    input  [5:0]  shift_right_i,
    input         round_i,
    input         subtract_i,
    input         register_inputs_i
);

    parameter [9:0] COEFF_0 = 10'd0;
    parameter [9:0] COEFF_1 = 10'd0;
    parameter [9:0] COEFF_2 = 10'd0;
    parameter [9:0] COEFF_3 = 10'd0;

    wire [18:0] z_rem;
    wire [8:0] dly_b_rem;

    RS_DSP2 #(
    .MODE_BITS({10'd0, COEFF_3,
                10'd0, COEFF_2,
                10'd0, COEFF_1,
                10'd0, COEFF_0})
   ) dsp (
    .a({10'd0, a_i}),
    .b({9'd0, b_i}),
    .z({z_rem, z_o}),
    .dly_b({dly_b_rem, dly_b_o}),

    .f_mode(1'b1),  // 10x9x32 DSP

    .acc_fir(acc_fir_i),
    .feedback(feedback_i),
    .load_acc(load_acc_i),

    .unsigned_a(unsigned_a_i),
    .unsigned_b(unsigned_b_i),

    .clk(clock_i),
    .reset(reset_i),

    .saturate_enable(saturate_enable_i),
    .output_select(output_select_i),
    .round(round_i),
    .shift_right(shift_right_i),
    .subtract(subtract_i),
    .register_inputs(register_inputs_i)
    );
endmodule
