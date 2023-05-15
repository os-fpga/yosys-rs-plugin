//
// Copyright (C) 2022 RapidSilicon
// CARRY CHAIN Techmap
//
//
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
// 1 bit adder_carry
//------------------------------------------------------------------------------
module adder_carry (...);
input p;
input g;
input cin;
output sumout;
output cout;

CARRY_CHAIN _TECHMAP_REPLACE_(.P(p), .G(g), .CIN(cin), .SUMOUT(sumout), .COUT(cout));
endmodule