//Copyright (C) 2022 RapidSilicon
//

module \$__RS_MUL20X18 (input [19:0] A, input [17:0] B, output [37:0] Y);
    parameter A_SIGNED = 0;
    parameter B_SIGNED = 0;
    parameter A_WIDTH = 0;
    parameter B_WIDTH = 0;
    parameter Y_WIDTH = 0;
    parameter REG_OUT = 0;
    parameter DSP_CLK = "";
    parameter DSP_RST = "";
    parameter DSP_RST_POL = "";

    wire [19:0] a;
    wire [17:0] b;
    wire [37:0] z;

    assign a = (A_WIDTH == 20) ? A :
               (A_SIGNED) ? {{(20 - A_WIDTH){A[A_WIDTH-1]}}, A} :
                            {{(20 - A_WIDTH){1'b0}},         A};

    assign b = (B_WIDTH == 18) ? B :
               (B_SIGNED) ? {{(18 - B_WIDTH){B[B_WIDTH-1]}}, B} :
                            {{(18 - B_WIDTH){1'b0}},         B};

    (* is_inferred=1 *)
    dsp_t1_20x18x64_cfg_ports #(
        .COEFF_0(20'd0),
        .COEFF_1(20'd0),
        .COEFF_2(20'd0),
        .COEFF_3(20'd0),
        .OUTPUT_SELECT({2'b0,REG_OUT[0]}),
        .REGISTER_INPUTS(1'b0),
        .DSP_CLK(DSP_CLK),
        .DSP_RST(DSP_RST),
        .DSP_RST_POL(REG_OUT)
    ) _TECHMAP_REPLACE_ (
        .a_i                (a),
        .b_i                (b),
        .acc_fir_i          (6'd0),
        .z_o                (z),

        .feedback_i         (3'd0),
        .load_acc_i         (1'b0),
        .unsigned_a_i       (!A_SIGNED),
        .unsigned_b_i       (!B_SIGNED),

        .saturate_enable_i  (1'b0),
        .shift_right_i      (6'd0),
        .round_i            (1'b0),
        .subtract_i         (1'b0)
    );

    assign Y = z;

endmodule
/*
module \$__RS_MUL10X9 (input [9:0] A, input [8:0] B, output [18:0] Y);
    parameter A_SIGNED = 0;
    parameter B_SIGNED = 0;
    parameter A_WIDTH = 0;
    parameter B_WIDTH = 0;
    parameter Y_WIDTH = 0;
    parameter REG_OUT = 0;
    parameter DSP_CLK = "";
    parameter DSP_RST = "";
    parameter DSP_RST_POL = "";

    wire [ 9:0] a;
    wire [ 8:0] b;
    wire [18:0] z;

    assign a = (A_WIDTH == 10) ? A :
               (A_SIGNED) ? {{(10 - A_WIDTH){A[A_WIDTH-1]}}, A} :
                            {{(10 - A_WIDTH){1'b0}},         A};

    assign b = (B_WIDTH ==  9) ? B :
               (B_SIGNED) ? {{( 9 - B_WIDTH){B[B_WIDTH-1]}}, B} :
                            {{( 9 - B_WIDTH){1'b0}},         B};

    
        (* is_inferred=1 *)
        dsp_t1_10x9x32_cfg_ports #(
            .COEFF_0(10'd0),
            .COEFF_1(10'd0),
            .COEFF_2(10'd0),
            .COEFF_3(10'd0),
            .OUTPUT_SELECT({2'b0,REG_OUT[0]}),
            .REGISTER_INPUTS(1'b0),
            .DSP_CLK(DSP_CLK),
            .DSP_RST(DSP_RST),
            .DSP_RST_POL(REG_OUT)
        ) _TECHMAP_REPLACE_ (
            .a_i                (a),
            .b_i                (b),
            .acc_fir_i          (6'd0),
            .z_o                (z),

            .feedback_i         (3'd0),
            .load_acc_i         (1'b0),
            .unsigned_a_i       (!A_SIGNED),
            .unsigned_b_i       (!B_SIGNED),

            .output_select_i    (3'd0),
            .saturate_enable_i  (1'b0),
            .shift_right_i      (6'd0),
            .round_i            (1'b0),
            .subtract_i         (1'b0),
            .register_inputs_i  (1'b0)
        );

    assign Y = z;

endmodule
*/
module \$__RS_MUL10X9 (input [9:0] A, input [8:0] B, output [18:0] Y);
    parameter A_SIGNED = 0;
    parameter B_SIGNED = 0;
    parameter A_WIDTH = 0;
    parameter B_WIDTH = 0;
    parameter Y_WIDTH = 0;
    parameter REG_OUT = 0;
    parameter DSP_CLK = "";
    parameter DSP_RST = "";
    parameter DSP_RST_POL = "";

    wire [ 9:0] a;
    wire [ 8:0] b;
    wire [18:0] z;

    assign a = (A_WIDTH == 10) ? A :
               (A_SIGNED) ? {{(10 - A_WIDTH){A[A_WIDTH-1]}}, A} :
                            {{(10 - A_WIDTH){1'b0}},         A};

    assign b = (B_WIDTH ==  9) ? B :
               (B_SIGNED) ? {{( 9 - B_WIDTH){B[B_WIDTH-1]}}, B} :
                            {{( 9 - B_WIDTH){1'b0}},         B};

        (* is_inferred=1 *)
        dsp_t1_10x9x32_cfg_params #(
            .OUTPUT_SELECT      ({2'b0,REG_OUT[0]}),
            .SATURATE_ENABLE    (1'b0),
            .SHIFT_RIGHT        (6'd0),
            .ROUND              (1'b0),
            .REGISTER_INPUTS    (1'b0),
            .COEFF_0(10'd0),
            .COEFF_1(10'd0),
            .COEFF_2(10'd0),
            .COEFF_3(10'd0),
            .DSP_CLK(DSP_CLK),
            .DSP_RST(DSP_RST),
            .DSP_RST_POL(REG_OUT)
        ) _TECHMAP_REPLACE_ (
            .a_i                (a),
            .b_i                (b),
            .acc_fir_i          (6'd0),
            .z_o                (z),

            .feedback_i         (3'd0),
            .load_acc_i         (1'b0),
            .unsigned_a_i       (!A_SIGNED),
            .unsigned_b_i       (!B_SIGNED),

            .subtract_i         (1'b0)
        );


    assign Y = z;

endmodule
