//
// Copyright (C) 2022 RapidSilicon
//
//------------------------------------------------------------------------------
// 1 bit ADDER_CARRY
//------------------------------------------------------------------------------
module ADDER_CARRY (p, g, cin, sumout, cout);
    input p;
    input g;
    input cin;
    output sumout;
    output cout;

    assign {cout, sumout} = {p ? cin : g, p ^ cin};
endmodule
