//
// Copyright (C) 2022 RapidSilicon
// CARRY CHAIN Primitive
//
//
//------------------------------------------------------------------------------
module CARRY_CHAIN(P, G, CIN, SUMOUT, COUT);
    input wire  P, G, CIN;
    output wire SUMOUT, COUT;
    adder_carry my(.p(P), .g(G), .cin(CIN), .sumout(SUMOUT), .cout(COUT));
endmodule