//Copyright (C) 2022 RapidSilicon
//
// In Genesis3, parameters MODE_BITS vectors have been reversed
// in order to match big endian behavior used by the fabric
// primitives DSP/BRAM (CASTORIP-121)

module dsp_t1_20x18x64_cfg_ports (
    input  [19:0] a_i,
    input  [17:0] b_i,
    input  [ 5:0] acc_fir_i,
    output [37:0] z_o,
    output [17:0] dly_b_o,

    input         clock_i,
    input         reset_i,

    input  [2:0]  feedback_i,
    input         load_acc_i,
    input         unsigned_a_i,
    input         unsigned_b_i,

    input         saturate_enable_i,
    input  [5:0]  shift_right_i,
    input         round_i,
    input         subtract_i
);

    parameter [19:0] COEFF_0 = 20'd0;
    parameter [19:0] COEFF_1 = 20'd0;
    parameter [19:0] COEFF_2 = 20'd0;
    parameter [19:0] COEFF_3 = 20'd0;
    parameter [2:0] OUTPUT_SELECT = 3'b000;
    parameter REGISTER_INPUTS = 1'b0;

    RS_DSP # (
        .MODE_BITS          ({REGISTER_INPUTS,
                              OUTPUT_SELECT,
                              COEFF_3,
                              COEFF_2,
                              COEFF_1,
                              COEFF_0})
    ) _TECHMAP_REPLACE_ (
        .a                  (a_i),
        .b                  (b_i),
        .acc_fir            (acc_fir_i),
        .z                  (z_o),
        .dly_b              (dly_b_o),

        .clk                (clock_i),
        .lreset             (reset_i),

        .feedback           (feedback_i),
        .load_acc           (load_acc_i),
        .unsigned_a         (unsigned_a_i),
        .unsigned_b         (unsigned_b_i),

        .saturate_enable    (saturate_enable_i),
        .shift_right        (shift_right_i),
        .round              (round_i),
        .subtract           (subtract_i)
    );

endmodule
