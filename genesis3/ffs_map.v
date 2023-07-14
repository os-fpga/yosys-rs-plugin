// Copyright (C) 2022 RapidSilicon
//

// Geneis3 using only dffre

module \$_DFF_P_ (D, C, Q);
    input D;
    input C;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(1'b1));
endmodule

// Async reset
module \$_DFF_PP0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R));
endmodule

// Async reset
module \$_DFF_PN0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R));
endmodule

// Async set
module \$_DFF_PP1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(1'b1), .R(!R));
endmodule

// Async set
module \$_DFF_PN1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(1'b1), .R(R));
endmodule

module  \$_DFFE_PP_ (D, C, E, Q);
    input D;
    input C;
    input E;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(1'b1));
endmodule

module  \$_DFFE_PN_ (D, C, E, Q);
    input D;
    input C;
    input E;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(1'b1));
endmodule

// Async reset, enable
module  \$_DFFE_PP0P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(!R));
endmodule

module  \$_DFFE_PP0N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(!R));
endmodule

module  \$_DFFE_PN0P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(R));
endmodule

module  \$_DFFE_PN0N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(R));
endmodule

// Async set, enable

module  \$_DFFE_PP1P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(E), .R(!R));
endmodule

module  \$_DFFE_PP1N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(!E), .R(!R));
endmodule

module  \$_DFFE_PN1P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(E), .R(R));
endmodule

module  \$_DFFE_PN1N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(!E), .R(R));
endmodule

// Async set & reset
//module \$_DFFSR_PPP_ (D, C, R, S, Q);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R), .S(!S));
//endmodule

//module \$_DFFSR_PNP_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R), .S(S));
//endmodule

//module \$_DFFSR_PNN_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R), .S(S));
//endmodule

//module \$_DFFSR_PPN_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R), .S(!S));
//endmodule

//module \$_DFFSR_NPP_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffnsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R), .S(!S));
//endmodule

//module \$_DFFSR_NNP_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffnsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R), .S(S));
//endmodule

//module \$_DFFSR_NNN_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffnsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R), .S(S));
//endmodule

//module \$_DFFSR_NPN_ (D, Q, C, R, S);
//    input D;
//    input C;
//    input R;
//    input S;
//    output Q;
//    dffnsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R), .S(!S));
//endmodule

// Async set, reset & enable

//module \$_DFFSRE_PPPP_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(!R), .S(!S));
//endmodule

//module \$_DFFSRE_PNPP_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(!R), .S(S));
//endmodule

//module \$_DFFSRE_PPNP_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(R), .S(!S));
//endmodule

//module \$_DFFSRE_PNNP_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(R), .S(S));
//endmodule

//module \$_DFFSRE_PPPN_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(!R), .S(!S));
//endmodule

//module \$_DFFSRE_PNPN_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(!R), .S(S));
//endmodule

//module \$_DFFSRE_PPNN_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(R), .S(!S));
//endmodule

//module \$_DFFSRE_PNNN_ (D, Q, C, E, R, S);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//    dffsre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(R), .S(S));
//endmodule

// Latch with async set and reset
//module  \$_DLATCHSR_PPP_ (input E, S, R, D, output Q);
//    latchsre _TECHMAP_REPLACE_ (.D(D), .Q(Q), .E(1'b1), .G(E),  .R(!R), .S(!S));
//endmodule

//module  \$_DLATCHSR_NPP_ (input E, S, R, D, output Q);
//    latchnsre _TECHMAP_REPLACE_ (.D(D), .Q(Q), .E(1'b1), .G(E),  .R(!R), .S(!S));
//endmodule

module \$_DFF_N_ (D, C, Q);
    input D;
    input C;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(1'b1), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_DFF_NP0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(1'b1), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(!R));
endmodule

module \$_DFF_NN0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(1'b1), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(1'b1), .R(R));
endmodule

module \$_DFF_NP1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(1'b1), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(1'b1), .R(!R));
endmodule

module \$_DFF_NN1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(1'b1), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(1'b1), .R(R));
endmodule

module  \$_DFFE_NP_ (D, C, E, Q);
    input D;
    input C;
    input E;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(E), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(1'b1));
endmodule

module  \$_DFFE_NN_ (D, C, E, Q);
    input D;
    input C;
    input E;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(!E), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(1'b1));
endmodule

module  \$_DFFE_NP0P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(E), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(!R));
endmodule

module  \$_DFFE_NP0N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(!E), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(!R));
endmodule

module  \$_DFFE_NN0P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(E), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(E), .R(R));
endmodule

module  \$_DFFE_NN0N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(!C), .E(!E), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(D), .C(C), .E(!E), .R(R));
endmodule

module  \$_DFFE_NP1P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(E), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(E), .R(!R));
endmodule

module  \$_DFFE_NP1N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(!E), .R(!R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(!E), .R(!R));
endmodule

module  \$_DFFE_NN1P_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(E), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(E), .R(R));
endmodule

module  \$_DFFE_NN1N_ (D, C, E, R, Q);
    input D;
    input C;
    input E;
    input R;
    output Q;

    wire q;
    assign Q = !q;

    //dffre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(!C), .E(!E), .R(R));
    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(!E), .R(R));
endmodule

//module \$_DFFSRE_NPPP_ (D, C, E, R, S, Q);
//    input D;
//    input C;
//    input E;
//    input R;
//    input S;
//    output Q;
//
//    wire q;
//    assign Q = !q;

//    dffnre _TECHMAP_REPLACE_ (.Q(q), .D(!D), .C(C), .E(E), .R(!R), .S(!S));
//endmodule


module \$__SHREG_DFF_P_ (D, Q, C);
    input D;
    input C;
    output Q;

    parameter DEPTH = 2;
    reg [DEPTH-2:0] q;
    genvar i;
    generate for (i = 0; i < DEPTH; i = i + 1) begin: slice


        // First in chain
        generate if (i == 0) begin
                 sh_dff #() shreg_beg (
                    .Q(q[i]),
                    .D(D),
                    .C(C)
                );
        end endgenerate
        // Middle in chain
        generate if (i > 0 && i != DEPTH-1) begin
                 sh_dff #() shreg_mid (
                    .Q(q[i]),
                    .D(q[i-1]),
                    .C(C)
                );
        end endgenerate
        // Last in chain
        generate if (i == DEPTH-1) begin
                 sh_dff #() shreg_end (
                    .Q(Q),
                    .D(q[i-1]),
                    .C(C)
                );
        end endgenerate
   end: slice
   endgenerate

endmodule

// Sync reset
module \$_SDFF_PP0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? 1'b0 : D);
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_PN0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? D : 1'b0);
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_NP0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? 1'b0 : D);
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(!C), .E(1'b1), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_NN0_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? D : 1'b0);
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(!C), .E(1'b1), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

// Sync set
module \$_SDFF_PP1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? 1'b1 : D);
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_PN1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? D : 1'b1);
    dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_NP1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? 1'b1 : D);
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(!C), .E(1'b1), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

module \$_SDFF_NN1_ (D, C, R, Q);
    input D;
    input C;
    input R;
    output Q;
    wire d;
    assign d = (R ? D : 1'b1);
    //dffre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(!C), .E(1'b1), .R(1'b1));
    dffnre _TECHMAP_REPLACE_ (.Q(Q), .D(d), .C(C), .E(1'b1), .R(1'b1));
endmodule

// simple latch
//
module \$_DLATCH_P_ (D, E, Q);
    input D;
    input E;
    output Q;

    llatch _TECHMAP_REPLACE_ (.Q(Q), .D(D), .G(E));
endmodule

module \$_DLATCH_N_ (D, E, Q);
    input D;
    input E;
    output Q;

    llatchn _TECHMAP_REPLACE_ (.Q(Q), .D(D), .G(E));
endmodule

// latch with reset
//
module \$_DLATCH_PP0_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(R), .G(E));
endmodule

module \$_DLATCH_PN0_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(!R), .G(E));
endmodule

module \$_DLATCH_NP0_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchnr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(R), .G(E));
endmodule

module \$_DLATCH_NN0_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchnr _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(!R), .G(E));
endmodule

// latch with set 
//
module \$_DLATCH_PP1_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchs _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(R), .G(E));
endmodule

module \$_DLATCH_PN1_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchs _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(!R), .G(E));
endmodule

module \$_DLATCH_NP1_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchns _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(R), .G(E));
endmodule

module \$_DLATCH_NN1_ (D, R, E, Q);
    input D;
    input E;
    input R;
    output Q;

    llatchns _TECHMAP_REPLACE_ (.Q(Q), .D(D), .R(!R), .G(E));
endmodule

// Do not support complex Latch for now
//
//module  \$_DLATCHSR_PPP_ (input E, S, R, D, output Q);

//    llatchsre _TECHMAP_REPLACE_ (.D(D), .Q(Q), .E(1'b1), .G(E),  .R(!R), .S(!S));
//endmodule

//module  \$_DLATCHSR_NPP_ (input E, S, R, D, output Q);

//    llatchnsre _TECHMAP_REPLACE_ (.D(D), .Q(Q), .E(1'b1), .G(E),  .R(!R), .S(!S));
//endmodule

