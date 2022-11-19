// Copyright (C) 2022 RapidSilicon
//

module \$bmux (A, S, Y);

parameter WIDTH = 0;
parameter S_WIDTH = 0;

input [(WIDTH << S_WIDTH)-1:0] A;
input [S_WIDTH-1:0] S;
output [WIDTH-1:0] Y;

wire [WIDTH-1:0] bm0_out, bm1_out;

generate
	if (S_WIDTH > 1) begin:muxlogic
		\$bmux #(.WIDTH(WIDTH), .S_WIDTH(S_WIDTH-1)) bm0 (.A(A), .S(S[S_WIDTH-2:0]), .Y(bm0_out));
		\$bmux #(.WIDTH(WIDTH), .S_WIDTH(S_WIDTH-1)) bm1 (.A(A[(WIDTH << S_WIDTH)-1:WIDTH << (S_WIDTH - 1)]), .S(S[S_WIDTH-2:0]), .Y(bm1_out));
		assign Y = S[S_WIDTH-1] ? bm1_out : bm0_out;
	end else if (S_WIDTH == 1) begin:simple
		assign Y = S ? A[1] : A[0];
	end else begin:passthru
		assign Y = A;
	end
endgenerate

endmodule

// --------------------------------------------------------
module \$lut (A, Y);

parameter WIDTH = 0;
parameter LUT = 0;

input [WIDTH-1:0] A;
output Y;

\$bmux #(.WIDTH(1), .S_WIDTH(WIDTH)) mux(.A(LUT), .S(A), .Y(Y));

endmodule
