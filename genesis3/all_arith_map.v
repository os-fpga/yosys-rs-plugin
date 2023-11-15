// Copyright (C) 2022 RapidSilicon
//

(* techmap_celltype = "$alu" *)
module _80_rs_alu (A, B, CI, BI, X, Y, CO);
	parameter A_SIGNED = 0;
	parameter B_SIGNED = 0;
	parameter A_WIDTH = 2;
	parameter B_WIDTH = 2;
	parameter Y_WIDTH = 2;
	parameter _TECHMAP_CONSTVAL_CI_ = 0;
	parameter _TECHMAP_CONSTMSK_CI_ = 0;

	(* force_downto *)
	input [A_WIDTH-1:0] A;
	(* force_downto *)
	input [B_WIDTH-1:0] B;
	(* force_downto *)
	output [Y_WIDTH-1:0] X, Y;

	input CI, BI;
	(* force_downto *)
	output [Y_WIDTH-1:0] CO;


	wire _TECHMAP_FAIL_ = Y_WIDTH <= 2 || Y_WIDTH > `MAX_CARRY_CHAIN;

	(* force_downto *)
	wire [Y_WIDTH-1:0] A_buf, B_buf;
	\$pos #(.A_SIGNED(A_SIGNED), .A_WIDTH(A_WIDTH), .Y_WIDTH(Y_WIDTH)) A_conv (.A(A), .Y(A_buf));
	\$pos #(.A_SIGNED(B_SIGNED), .A_WIDTH(B_WIDTH), .Y_WIDTH(Y_WIDTH)) B_conv (.A(B), .Y(B_buf));

	(* force_downto *)
	wire [Y_WIDTH-1:0] AA = A_buf;
	(* force_downto *)
	wire [Y_WIDTH-1:0] BB = BI ? ~B_buf : B_buf;

	genvar i;
	wire co;

	(* force_downto *)
	//wire [Y_WIDTH-1:0] C = {CO, CI};
	wire [Y_WIDTH:0] C;
	(* force_downto *)
	wire [Y_WIDTH-1:0] S  = {AA ^ BB};
	assign CO[Y_WIDTH-1:0] = C[Y_WIDTH:1];
        //assign CO[Y_WIDTH-1] = co;

	generate
	     CARRY intermediate_adder (
	       .CIN     ( ),
	       .COUT    (C[0]),
	       .P       (1'b0),
	       .G       (CI),
	       .O     ()
	     );
	endgenerate
	genvar i;
	generate if (Y_WIDTH > 2) begin
	  for (i = 0; i < Y_WIDTH-2; i = i + 1) begin:slice
		CARRY  my_adder (
			.CIN(C[i]),
			.G(AA[i]),
			.P(S[i]),
			.COUT(C[i+1]),
		    .O(Y[i])
		);
    end
	end endgenerate
	generate
	     CARRY final_adder (
	       .CIN     (C[Y_WIDTH-2]),
	       .COUT    (),
	       .P       (1'b0),
	       .G       (1'b0),
	       .O     (co)
	     );
	endgenerate

	assign Y[Y_WIDTH-2] = S[Y_WIDTH-2] ^ co;
        assign C[Y_WIDTH-1] = S[Y_WIDTH-2] ? co : AA[Y_WIDTH-2];
	assign Y[Y_WIDTH-1] = S[Y_WIDTH-1] ^ C[Y_WIDTH-1];
        assign C[Y_WIDTH] = S[Y_WIDTH-1] ? C[Y_WIDTH-1] : AA[Y_WIDTH-1];

	assign X = S;
endmodule

