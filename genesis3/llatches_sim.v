//
// Copyright (C) 2023 RapidSilicon
//
// genesis3 LLATChes
//

//------------------------------------------------------------------------------
// Positive level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatch(
//    input D,
//    input G,
//    output reg Q
//);
//
//    always @*
//        if (G == 1'b1)
//            Q <= D;
//endmodule
module LATCH(D, G, Q);
  input D;
  input G;
  output Q;
  wire D;
  wire G;
  wire Q;
  \$lut  #(
    .LUT(8'b10101100),
    .WIDTH(32'd3)
  ) _0_ (
    .A({ G, Q, D }),
    .Y(Q)
  );
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchn(
//    input D,
//    input G,
//    output reg Q
//);
//    always @*
//        if (G == 1'b0)
//            Q <= D;
//endmodule
module LATCHN(D, G, Q);
  input D;
  input G;
  output Q;
  wire D;
  wire G;
  wire Q;
  \$lut  #(
    .LUT(8'b10101100),
    .WIDTH(32'd3)
  ) _0_ (
    .A({ G, D, Q }),
    .Y(Q)
  );
endmodule


//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchr(
//    input D,
//    input G,
//    input R,
//    output reg Q
//);
//    always @*
//        if (R == 1'b1)
//            Q <= 1'b0;
//        else if (G == 1'b1)
//            Q <= D;
//endmodule
module LATCHR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;
  wire D;
  wire G;
  wire Q;
  wire R;
  \$lut  #(
    .LUT(16'b0000101000001100),
    .WIDTH(32'd4)
  ) _0_ (
    .A({ G, R, Q, D }),
    .Y(Q)
  );
endmodule

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchs(
//    input D,
//    input G,
//    input R,
//    output reg Q
//);
//    always @*
//        if (R == 1'b1)
//            Q <= 1'b1;
//        else if (G == 1'b1)
//            Q <= D;
//endmodule
module LATCHS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;
  wire D;
  wire G;
  wire Q;
  wire R;
  \$lut  #(
    .LUT(16'b1111101011111100),
    .WIDTH(32'd4)
  ) _0_ (
    .A({ G, R, Q, D }),
    .Y(Q)
  );
endmodule


//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchnr(
//    input D,
//    input G,
//    input R,
//    output reg Q
//);
//    always @*
//        if (R == 1'b1)
//            Q <= 1'b0;
//        else if (G == 1'b0)
//            Q <= D;
//endmodule
module LATCHNR(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;
  wire D;
  wire G;
  wire Q;
  wire R;
  \$lut  #(
    .LUT(16'b0000101000001100),
    .WIDTH(32'd4)
  ) _0_ (
    .A({ G, R, D, Q }),
    .Y(Q)
  );
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous set
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchns(
//    input D,
//    input G,
//    input R,
//    output reg Q
//);
//    always @*
//        if (R == 1'b1)
//            Q <= 1'b1;
//        else if (G == 1'b0)
//            Q <= D;
//endmodule
module LATCHNS(D, G, R, Q);
  input D;
  input G;
  output Q;
  input R;
  wire D;
  wire G;
  wire Q;
  wire R;
  \$lut  #(
    .LUT(16'b1111101011111100),
    .WIDTH(32'd4)
  ) _0_ (
    .A({ G, R, D, Q }),
    .Y(Q)
  );
endmodule


//------------------------------------------------------------------------------
// general positive level-sensitive latch with reset, set and enable
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchsre (
//    output reg Q,
//    input S,
//    input R,
//    input D,
//    input G,
//    input E
//);
//    always @*
//        if (!R)
//            Q <= 1'b0;
//        else if (!S)
//            Q <= 1'b1;
//        else if (E && G)
//            Q <= D;
//endmodule
module LATCHSRE(Q, S, R, D, G, E);
  input D;
  input E;
  input G;
  output Q;
  input R;
  input S;
  wire D;
  wire E;
  wire G;
  wire Q;
  wire R;
  wire S;
  \$lut  #(
    .LUT(64'b1011101111110011111100111111001100000000000000000000000000000000),
    .WIDTH(32'd6)
  ) _0_ (
    .A({ R, G, E, Q, S, D }),
    .Y(Q)
  );
endmodule

//------------------------------------------------------------------------------
// general negative level-sensitive latch with reset, set and enable
// implemented with feed-back loop LUT
//------------------------------------------------------------------------------
//module llatchnsre (
//    output reg Q,
//    input S,
//    input R,
//    input D,
//    input G,
//    input E
//);
//    always @*
//        if (!R)
//            Q <= 1'b0;
//        else if (!S)
//            Q <= 1'b1;
//        else if (E && !G)
//            Q <= D;
//endmodule
module LATCHNSRE(Q, S, R, D, G, E);
  input D;
  input E;
  input G;
  output Q;
  input R;
  input S;
  wire D;
  wire E;
  wire G;
  wire Q;
  wire R;
  wire S;
  \$lut  #(
    .LUT(64'b1111001110111011111100111111001100000000000000000000000000000000),
    .WIDTH(32'd6)
  ) _0_ (
    .A({ R, E, G, Q, S, D }),
    .Y(Q)
  );
endmodule

