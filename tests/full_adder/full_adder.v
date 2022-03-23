// Copyright (C) 2022 RapidSilicon
//

module full_adder (
    input  wire [`WIDTH-1:0] A,
    input  wire [`WIDTH-1:0] B,
    output wire [`WIDTH  :0] S,
);

    // Implicit adder
    assign S = A + B;

endmodule

module subtractor (
    input  wire [`WIDTH-1:0] A,
    input  wire [`WIDTH-1:0] B,
    output wire [`WIDTH  :0] S,
);

    // Implicit subtractor
    assign S = A - B;

endmodule

module comparator (
    input  wire [`WIDTH-1:0] A,
    input  wire [`WIDTH-1:0] B,
    output wire CO,
);
    assign CO = (A <= B) ? 1'b1 : 1'b0;

endmodule
