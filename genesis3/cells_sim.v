//
// Copyright (C) 2022 RapidSilicon
//
// genesis3 DFFs
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-Low asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
module DFFRE(
    input D,
    input R,
    input E,
    (* clkbuf_sink *)
    input C,
    output reg Q
);
`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @(posedge C or negedge R)
        if (R == 1'b0)
            Q <= 1'b0;
        else if (E == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-Low asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
module DFFNRE(
    input D,
    input R,
    input E,
    (* clkbuf_sink *)
    input C,
    output reg Q
);
`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @(negedge C or negedge R)
        if (R == 1'b0)
            Q <= 1'b0;
        else if (E == 1'b1)
            Q <= D;
endmodule

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
