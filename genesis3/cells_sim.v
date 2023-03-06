//
// Copyright (C) 2022 RapidSilicon
//
// genesis3 DFFs and LATChes
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-Low asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
module dffre(
    input D,
    input R,
    input E,
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
// Positive level-sensitive latch
//------------------------------------------------------------------------------
module latch(
    input D,
    input G,
    output reg Q
);
`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @*
        if (G == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch
//------------------------------------------------------------------------------
module latchn(
    input D,
    input G,
    output reg Q
);
`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @*
        if (G == 1'b0)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Positive level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
module latchr(
    input D,
    input G,
    input R,
    output reg Q
);
`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @*
        if (R == 1'b1)
            Q <= 1'b0;
        else if (G == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Negative level-sensitive latch with active-high asyncronous reset
//------------------------------------------------------------------------------
module latchnr(
    input D,
    input G,
    input R,
    output reg Q
);

`ifndef VCS_MODE
parameter INIT_VALUE = 1'b0;
initial begin
    Q = INIT_VALUE;
end
`endif
    always @*
        if (R == 1'b1)
            Q <= 1'b0;
        else if (G == 1'b0)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// 1 bit adder_carry
//------------------------------------------------------------------------------
module adder_carry (p, g, cin, sumout, cout);
    input p;
    input g;
    input cin;
    output sumout;
    output cout;

    assign {cout, sumout} = {p ? cin : g, p ^ cin};
endmodule
