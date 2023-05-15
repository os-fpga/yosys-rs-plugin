//
// Copyright (C) 2022 RapidSilicon
// LUT Primitives
//
//
//------------------------------------------------------------------------------
module LUT1 (A, Y);
    parameter INIT_VALUE = 2'h0;
    input wire A;
    output wire Y;
    \$lut #(.WIDTH(1), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule


module LUT2 (A, Y);
    parameter INIT_VALUE = 4'h0;
    input wire [1:0] A;
    output wire Y;
    \$lut #(.WIDTH(2), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule


module LUT3 (A, Y);
    parameter INIT_VALUE = 8'h0;
    input wire [2:0] A;
    output wire Y;
    \$lut #(.WIDTH(3), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule


module LUT4 (A, Y);
    parameter INIT_VALUE = 16'h0;
    input wire [3:0] A;
    output wire Y;
    \$lut #(.WIDTH(4), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule


module LUT5 (A, Y);
    parameter INIT_VALUE = 32'h0;
    input wire [4:0] A;
    output wire Y;
    \$lut #(.WIDTH(5), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule


module LUT6 (A, Y);
    parameter INIT_VALUE = 64'h0;
    input wire [5:0] A;
    output wire Y;
    \$lut #(.WIDTH(6), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));
endmodule