// Copyright (C) 2022 RapidSilicon
//

module dff(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @(posedge C)
        Q <= D;
endmodule

module dffn(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @(negedge C)
        Q <= D;
endmodule

module dffsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge C or negedge S or negedge R)
        if (!R)
            Q <= 1'b0;
        else if (!S)
            Q <= 1'b1;
        else if (E)
            Q <= D;
        
endmodule

module dffnsre(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C,
    input E,
    input R,
    input S
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(negedge C or negedge S or negedge R)
        if (!R)
            Q <= 1'b0;
        else if (!S)
            Q <= 1'b1;
        else if (E)
            Q <= D;
        
endmodule

module latchsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @*
        if (!R) 
            Q <= 1'b0;
        else if (!S) 
            Q <= 1'b1;
        else if (E && G) 
            Q <= D;
endmodule

module latchnsre (
    output reg Q,
    input S,
    input R,
    input D,
    input G,
    input E
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    always @*
        if (!R) 
            Q <= 1'b0;
        else if (!S) 
            Q <= 1'b1;
        else if (E && !G) 
            Q <= D;
endmodule

module io_scff(
    output reg Q,
    input D,
    input SI,
    input R,
    input clk
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge C or negedge R)
        if (!R)
            Q <= SI;
        else 
            Q <= D;
            
endmodule

module scff(
    output reg Q,
    output reg SO,
    input D,
    input SI,
    input S,
    input R,
    input E,
    input clk
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;
    initial SO = INIT;
    wire out_w;

    assign out_w = E ? SI : D;

    always @(posedge clk or negedge S or negedge R)
        if (!R) begin
            Q <= 1'b0;
            SO <= 1'b1;
        end
        else if (!S) begin
            Q <= 1'b1;
            SO <= 1'b0;
        end
        else begin
            Q <= out_w;
            SO <= ~out_w;
        end
            
endmodule

module sh_dff(
    output reg Q,
    input D,
    (* clkbuf_sink *)
    input C
);
    parameter [0:0] INIT = 1'b0;
    initial Q = INIT;

    always @(posedge C)
        Q <= D;
endmodule
