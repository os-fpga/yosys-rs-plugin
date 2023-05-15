//
// Copyright (C) 2022 RapidSilicon
// DSP Primitives
//
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-high asynchronous reset 
//------------------------------------------------------------------------------

module DSP38 (A, B, ACC_FIR, Z, CLK, LRESET, FEEDBACK, LOAD_ACC, DLY_B,
        UNSIGNED_A, UNSIGNED_B, SATURATE_ENABLE, SHIFT_RIGHT, ROUND, SUBTRACT);

    input  wire [19:0] A;
    input  wire [17:0] B;
    input  wire [ 5:0] ACC_FIR;
    output wire [37:0] Z;
    output wire [17:0] DLY_B;

    input wire       CLK;
    input wire       LRESET;
    input wire [2:0] FEEDBACK;
    input wire       LOAD_ACC;
    input wire       UNSIGNED_A;
    input wire       UNSIGNED_B;
    input wire       SATURATE_ENABLE;
    input wire [5:0] SHIFT_RIGHT;
    input wire       ROUND;
    input wire       SUBTRACT;

    parameter [0:19] COEFF_0     = 20'h0;
    parameter [0:19] COEFF_1     = 20'h0;
    parameter [0:19] COEFF_2     = 20'h0;
    parameter [0:19] COEFF_3     = 20'h0;
    parameter        OUTPUT_REG  = 1'h0;
    parameter        INPUT_REG   = 1'h0;
    parameter        ACCUMULATOR = 1'h0;
    parameter        ADDER       = 1'h0;

    localparam [0:2] output_select = {ACCUMULATOR, ADDER, OUTPUT_REG};
    generate
        if (output_select == 3'b000 && INPUT_REG == 1'b1) begin
            RS_DSP_MULT_REGIN # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULT_REGIN (
                .a(A), 
                .b(B), 
                .z(Z), 
                .dly_b(DLY_B), 
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET)
            );
        end
        else if (output_select == 3'b001 && INPUT_REG == 1'b0) begin
            RS_DSP_MULT_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULT_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET)
            );
        end
        else if (output_select == 3'b001 && INPUT_REG == 1'b1) begin
            RS_DSP_MULT_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULT_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET)
            );
        end
        else if (output_select == 3'b010 && INPUT_REG == 1'b0) begin
            RS_DSP_MULTADD # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTADD (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b010 && INPUT_REG == 1'b1) begin
            RS_DSP_MULTADD_REGIN # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTADD_REGIN (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b011 && INPUT_REG == 1'b0) begin
            RS_DSP_MULTADD_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTADD_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b011 && INPUT_REG == 1'b1) begin
            RS_DSP_MULTADD_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTADD_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET), 
                .acc_fir(ACC_FIR), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b100 && INPUT_REG == 1'b0) begin
            RS_DSP_MULTACC # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTACC (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET), 
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b100 && INPUT_REG == 1'b1) begin
            RS_DSP_MULTACC_REGIN # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTACC_REGIN (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET),  
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b101 && INPUT_REG == 1'b0) begin
            RS_DSP_MULTACC_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTACC_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET),  
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else if (output_select == 3'b101 && INPUT_REG == 1'b1) begin
            RS_DSP_MULTACC_REGIN_REGOUT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULTACC_REGIN_REGOUT (
                .a(A), 
                .b(B), 
                .z(Z),  
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B),
                .clk(CLK), 
                .lreset(LRESET),
                .load_acc(LOAD_ACC), 
                .saturate_enable(SATURATE_ENABLE),
                .shift_right(SHIFT_RIGHT), 
                .round(ROUND), 
                .subtract(SUBTRACT)
            );
        end
        else begin
            RS_DSP_MULT # (
                .MODE_BITS({COEFF_0, COEFF_1, COEFF_2, COEFF_3, output_select, INPUT_REG})
            ) RS_DSP_MULT (
                .a(A), 
                .b(B), 
                .z(Z), 
                .dly_b(DLY_B),
                .feedback(FEEDBACK), 
                .unsigned_a(UNSIGNED_A), 
                .unsigned_b(UNSIGNED_B)
            );
        end
    endgenerate

endmodule