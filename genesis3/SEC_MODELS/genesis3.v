module I_BUF #(
      parameter WEAK_KEEPER = "NONE"
) (
  input I, // Data input (connect to top-level port)
  input EN, // Enable the input
  output O // Data output
);
assign O = EN ? I : 1'b0;

endmodule

module O_BUF
(
  input I, // Data input
  output O // Data output (connect to top-level port)
);

   assign O = I ;

endmodule

module CLK_BUF (
  input I, // Clock input
  output O // Clock output
);

   assign O = I ;

endmodule

module LUT1 #(
  parameter [1:0] INIT_VALUE = 2'h0 // 2-bit LUT logic value
) (
  input A, // Data Input
  output Y // Data Output
);

  assign Y = A ? INIT_VALUE[1] : INIT_VALUE[0];


endmodule

module LUT2 #(
  parameter [3:0] INIT_VALUE = 4'h0 // 4-bit LUT logic value
) (
  input [1:0] A, // Data Input
  output Y // Data Output
);

  \$lut #(.WIDTH(2), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));

endmodule

module LUT3 #(
  parameter [7:0] INIT_VALUE = 8'h00 // 8-bit LUT logic value
) (
  input [2:0] A, // Data Input
  output Y // Data Output
);

  \$lut #(.WIDTH(3), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));

endmodule

module LUT4 #(
  parameter [15:0] INIT_VALUE = 16'h0000 // 16-bit LUT logic value
) (
  input [3:0] A, // Data Input
  output Y // Data Output
);

  \$lut #(.WIDTH(4), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));

endmodule

module LUT5 #(
  parameter [31:0] INIT_VALUE = 32'h00000000 // LUT logic value
) (
  input [4:0] A, // Data Input
  output Y // Data Output
);

  \$lut #(.WIDTH(5), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));

endmodule

module LUT6 #(
  parameter [63:0] INIT_VALUE = 64'h0000000000000000 // 64-bit LUT logic value
) (
  input [5:0] A, // Data Input
  output Y // Data Output
);

  \$lut #(.WIDTH(6), .LUT(INIT_VALUE)) lut(.A(A), .Y(Y));

endmodule

