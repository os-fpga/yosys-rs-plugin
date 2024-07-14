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

parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTACC
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100={ACCUMULATOR, ADDER, OUTPUT_REG};






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
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]), 
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

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};






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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]), 
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]), 
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

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULT_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b000={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;





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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULT_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b001;={ACCUMULATOR, ADDER, OUTPUT_REG};






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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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

(* clkbuf_sink *)
input  wire       clk;
input  wire       lreset;

input  wire [2:0] feedback;
input  wire       unsigned_a;
input  wire       unsigned_b;



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULT_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;


//localparam [0:2] output_select = 3'b001={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;





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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTADD
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};






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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(dly_b[8:0]),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(dly_b[17:9]),
    .Z2(z[37:19]), 
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTADD_REGIN
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h0;

 //localparam [0:2] output_select = 3'b010;={ACCUMULATOR, ADDER, OUTPUT_REG};
 localparam register_inputs = 1'b1;




 
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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(dly_b[8:0]),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(dly_b[17:9]),
    .Z2(z[37:19]),
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


parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTADD_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};






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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(dly_b[8:0]),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(dly_b[17:9]),
    .Z2(z[37:19]),
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTADD_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h0;
localparam        ADDER       = 1'h1;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b011;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;





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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(dly_b[8:0]),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(dly_b[17:9]),
    .Z2(z[37:19]),
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTACC_REGIN
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h0;

//localparam [0:2] output_select = 3'b100;={ACCUMULATOR, ADDER, OUTPUT_REG};
localparam register_inputs = 1'b1;





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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTACC_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;

//localparam [0:2] output_select = 3'b101;






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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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



parameter [0:79] MODE_BITS = 80'd0;

localparam [0:9] COEFF1_0 = MODE_BITS[70:79];
localparam [0:9] COEFF2_0 = MODE_BITS[60:69];

localparam [0:9] COEFF1_1 = MODE_BITS[50:59];
localparam [0:9] COEFF2_1 = MODE_BITS[40:49];

localparam [0:9] COEFF1_2 = MODE_BITS[30:39];
localparam [0:9] COEFF2_2 = MODE_BITS[20:29];

localparam [0:9] COEFF1_3 = MODE_BITS[10:19];
localparam [0:9] COEFF2_3 = MODE_BITS[0:9];

// RS_DSPX2_MULTACC_REGIN_REGOUT
localparam        ACCUMULATOR = 1'h1;
localparam        ADDER       = 1'h0;
localparam        OUTPUT_REG  = 1'h1;
//localparam [0:2] output_select = 3'b101;
localparam register_inputs = 1'b1;





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
    .A1(a[9:0]), 
    .B1(b[8:0]), 
    .DLY_B1(),
    .Z1(z[18:0]),
    .A2(a[19:10]), 
    .B2(b[17:9]), 
    .DLY_B2(),
    .Z2(z[37:19]),
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

module RS_DSP3 (
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

    parameter [92:0] MODE_BITS = 93'd0;
    parameter DSP_CLK = "";
    parameter DSP_RST = "";
    parameter DSP_RST_POL = "";
    parameter [2:0] OUTPUT_SELECT = MODE_BITS[83:81];
    parameter REGISTER_INPUTS = MODE_BITS[92];
    wire [37:0] z;
    wire [17:0] dly_b;

    RS_DSPX2 # (
        .MODE_BITS({REGISTER_INPUTS,OUTPUT_SELECT,MODE_BITS[79:0]}),  //{83,[82:80],[79:0]}
        .DSP_CLK(DSP_CLK),
        .DSP_RST(DSP_RST),
        .DSP_RST_POL(DSP_RST_POL)
    ) _TECHMAP_REPLACE_ (
        .a                  ({a}),
        .b                  ({b}),
        .acc_fir            (acc_fir),
        .z                  (z),
        .dly_b              (dly_b),

        .clk                (clk),
        .lreset             (reset),
        .feedback           (feedback),
        .load_acc           (load_acc),
        .unsigned_a         (unsigned_a),
        .unsigned_b         (unsigned_b),
        // Here F_mode is by default converted to separate DSP19x2 cell not DSP38 so by default understood it is in f_mode 
        //.f_mode             (MODE_BITS[80]), // Enable fractuation, Use the lower half
        .saturate_enable    (MODE_BITS[84]),
        .shift_right        (MODE_BITS[90:85]),
        .round              (MODE_BITS[91]),
        //.output_select(OUTPUT_SELECT),
        .subtract           (subtract),
        //.register_inputs(REGISTER_INPUTS)
    );

endmodule
