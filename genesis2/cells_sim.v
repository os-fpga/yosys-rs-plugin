//
// Copyright (C) 2022 RapidSilicon
//
// genesis2 DFFs and LATChes
//
//------------------------------------------------------------------------------
// Rising-edge D-flip-flop
//------------------------------------------------------------------------------
module dff(
    input D,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(posedge C)
        Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop
//------------------------------------------------------------------------------
module dffn(
    input D,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C)
        Q <= D;
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high synchronous reset
//------------------------------------------------------------------------------
module sdff(
    input D,
    input R,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(posedge C)
        if (R == 1'b1)
            Q <= 1'b0;
        else
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high synchronous reset
//------------------------------------------------------------------------------
module sdffn(
    input D,
    input R,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C)
        if (R == 1'b1)
            Q <= 1'b0;
        else
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high asynchronous reset
//------------------------------------------------------------------------------
module dffr(
    input D,
    input R,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(posedge C or posedge R)
        if (R == 1'b1)
            Q <= 1'b0;
        else
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high asynchronous reset
//------------------------------------------------------------------------------
module dffnr(
    input D,
    input R,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C or posedge R)
        if (R == 1'b1)
            Q <= 1'b0;
        else
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with active-high enable
//------------------------------------------------------------------------------
module dffe(
    input D,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(posedge C)
        if (E == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with active-high enable
//------------------------------------------------------------------------------
module dffne(
    input D,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C)
        if (E == 1'b1)
            Q <= D;
endmodule


//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
//  active-high synchronous reset
//  active-high enable
//------------------------------------------------------------------------------
module sdffre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
initial begin
    Q = 0;
end
    always @(posedge C)
        if (R == 1'b1)
            Q <= 1'b0;
        else if (E == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-high synchronous reset
// active-high enable
//------------------------------------------------------------------------------
module sdffnre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C)
        if (R == 1'b1)
            Q <= 1'b0;
        else if (E == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Rising-edge D-flip-flop with
// active-high asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
module dffre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(posedge C or posedge R)
        if (R == 1'b1)
            Q <= 1'b0;
        else if (E == 1'b1)
            Q <= D;
endmodule

//------------------------------------------------------------------------------
// Falling-edge D-flip-flop with
// active-high asynchronous reset and
// active-high enable
//------------------------------------------------------------------------------
module dffnre(
    input D,
    input R,
    input E,
    input C,
    output reg Q
);
initial begin
    Q = 0;
end
    always @(negedge C or posedge R)
        if (R == 1'b1)
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
initial begin
    Q = 0;
end
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
initial begin
    Q = 0;
end
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
initial begin
    Q = 0;
end
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
    output reg Q
);
initial begin
    Q = 0;
end
    always @*
        if (R == 1'b1)
            Q <= 1'b0;
        else if (G == 1'b0)
            Q <= D;
endmodule
