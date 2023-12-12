//
// Copyright (C) 2022 RapidSilicon
// DSP Primitives TECHMAP
//
//
//------------------------------------------------------------------------------
module RS_DSPX2_MULTACC (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTACC
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(dly_b[8:0]),
    .Z1(z[18:0]),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2), 
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);
endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULT (...);
input  wire [19:0] a;
input  wire [17:0] b;
output wire [37:0] z;
output wire [17:0] dly_b;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:83] MODE_BITS = 84'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(), 
    .RESET(), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z), 
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2), 
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 

    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULT_REGIN (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULT_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
     
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);


endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULT_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULT_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b001;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
     
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULT_REGIN_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULT_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;


//localparam [0:2] output_select = 3'b001={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
     
    .FEEDBACK(feedback),
    .LOAD_ACC(), 
    .SATURATE(), 
    .SHIFT_RIGHT(), 
    .ROUND(), 
    .SUBTRACT()
);

endmodule

//------------------------------------------------------------------------------
module RS_DSPX2_MULTADD (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTADD
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2), 
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 

    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULTADD_REGIN (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTADD_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

 //localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};
 localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 
 
DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
     
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULTADD_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTADD_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
     
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULTADD_REGIN_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTADD_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ADD_SUB")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(acc_fir), 
 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------
module RS_DSPX2_MULTACC_REGIN (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTACC_REGIN
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("FALSE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule
//------------------------------------------------------------------------------

module RS_DSPX2_MULTACC_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTACC_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b101;
localparam register_inputs = 1'b0;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("FALSE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule

//------------------------------------------------------------------------------
module RS_DSPX2_MULTACC_REGIN_REGOUT (...);
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

localparam [0:9] COEFF1_0 = MODE_BITS[0:9];
localparam [0:9] COEFF2_0 = MODE_BITS[10:19];

localparam [0:9] COEFF1_1 = MODE_BITS[20:29];
localparam [0:9] COEFF2_1 = MODE_BITS[30:39];

localparam [0:9] COEFF1_2 = MODE_BITS[40:49];
localparam [0:9] COEFF2_2 = MODE_BITS[50:59];

localparam [0:9] COEFF1_3 = MODE_BITS[60:69];
localparam [0:9] COEFF2_3 = MODE_BITS[70:79];

// RS_DSPX2_MULTACC_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b101;
localparam register_inputs = 1'b1;
wire [9:0] a2 = 10'hx;
wire [8:0] b2 = 9'hx;
wire [8:0] dly_b2;
wire [18:0] z2; 

DSP19X2 #(
    .COEFF1_0(COEFF1_0), 
    .COEFF1_1(COEFF1_1), 
    .COEFF1_2(COEFF1_2), 
    .COEFF1_3(COEFF1_3),
    .COEFF2_0(COEFF2_0), 
    .COEFF2_1(COEFF2_1), 
    .COEFF2_2(COEFF2_2), 
    .COEFF2_3(COEFF2_3),
    .OUTPUT_REG_EN("TRUE"), 
    .INPUT_REG_EN("TRUE"), 
    .DSP_MODE("MULTIPLY_ACCUMULATE")
)
_TECHMAP_REPLACE_ (
    .CLK(clk), 
    .RESET(lreset), 
    .A1(a), 
    .B1(b), 
    .DLY_B1(dly_b),
    .Z1(z),
    .A2(a2), 
    .B2(b2), 
    .DLY_B2(dly_b2),
    .Z2(z2),
    .UNSIGNED_A(unsigned_a),
    .UNSIGNED_B(unsigned_b),
    .ACC_FIR(), 
 
    .FEEDBACK(feedback),
    .LOAD_ACC(load_acc), 
    .SATURATE(saturate_enable), 
    .SHIFT_RIGHT(shift_right), 
    .ROUND(round), 
    .SUBTRACT(subtract)
);

endmodule 
