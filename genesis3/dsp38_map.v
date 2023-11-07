//
// Copyright (C) 2022 RapidSilicon
// DSP Primitives TECHMAP
//
//
//------------------------------------------------------------------------------
module RS_DSP_MULTACC (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire        load_acc;
input  wire [ 2:0] feedback;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;

parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTACC
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);
endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(), 
    .RESET(), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULT_REGIN (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULT_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);


endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULT_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULT_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b001;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULT_REGIN_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULT_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;


//localparam [0:2] output_select = 3'b001={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule

//------------------------------------------------------------------------------
module RS_DSP_MULTADD (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

input  wire       clk;
input  wire       lreset;

input  wire [ 2:0] feedback;
input  wire [ 5:0] acc_fir;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTADD
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULTADD_REGIN (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire [ 5:0] acc_fir;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTADD_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

 //localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};
 localparam register_inputs = 1'b1;
 
DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULTADD_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire [ 5:0] acc_fir;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;


parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTADD_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULTADD_REGIN_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire [ 5:0] acc_fir;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTADD_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSP_MULTACC_REGIN (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTACC_REGIN
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------

module RS_DSP_MULTACC_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTACC_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b101;
localparam register_inputs = 1'b0;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule

//------------------------------------------------------------------------------
module RS_DSP_MULTACC_REGIN_REGOUT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

(* clkbuf_sink *)
input  wire        clk;
input  wire        lreset;

input  wire [ 2:0] feedback;
input  wire        load_acc;
input  wire        unsigned_a;
input  wire        unsigned_b;

input  wire        saturate_enable;
input  wire [ 5:0] shift_right;
input  wire        round;
input  wire        subtract;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:19] COEFF_0 = MODE_BITS[0:19];
localparam [0:19] COEFF_1 = MODE_BITS[20:39];
localparam [0:19] COEFF_2 = MODE_BITS[40:59];
localparam [0:19] COEFF_3 = MODE_BITS[60:79];

// RS_DSP_MULTACC_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b101;
localparam register_inputs = 1'b1;

DSP38 #(
    .COEFF_0(COEFF_0), 
    .COEFF_1(COEFF_1), 
    .COEFF_2(COEFF_2), 
    .COEFF_3(COEFF_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A(a), 
    .B(b), 
    .DLY_B(dly_b),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .Z(z), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule 
