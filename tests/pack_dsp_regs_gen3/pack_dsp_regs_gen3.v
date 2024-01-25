// Copyright (C) 2022 RapidSilicon
//

module dsp_is_driven_only_by_dffs (clk, reset, A, B, P);
    input clk, reset;
    input signed [19:0] A;
    input signed [17:0] B;
    output wire signed [37:0] P;
    reg signed [19:0] i1;
    reg signed [17:0] i2;
    wire  [37:0] mul;
    wire [63:0] sign_extend;
    reg [63:0] out;
    always @(posedge clk, posedge reset) begin
        if(reset == 1'b1) begin
            i1 <= 0;
            i2 <= 0;
        end
        else begin
            i1 <= A;
            i2 <= B;
        end
    end
    always @(posedge clk , posedge reset) begin
        if (reset ==1 )
            out <= 0;
        else
            out <= sign_extend;
    end
    assign P = out;
    assign mul  = i1 * i2;
    assign sign_extend = {{26{mul[37]}}, mul};
endmodule

module dsp_is_driven_by_different_clk_dffs (clk1, clk2, reset, A, B, P);
    input clk1, clk2, reset;
    input signed [19:0] A;
    input signed [17:0] B;
    output wire signed [37:0] P;
    reg signed [19:0] i1;
    reg signed [17:0] i2;
    wire  [37:0] mul;
    wire [63:0] sign_extend;
    reg [63:0] out;
    always @(posedge clk1, posedge reset) begin
        if(reset == 1'b1) begin
            i1 <= 0;
        end
        else begin
            i1 <= A;
        end
    end
    always @(posedge clk2, posedge reset) begin
        if(reset == 1'b1) begin
            i2 <= 0;
        end
        else begin
            i2 <= B;
        end
    end
    always @(posedge clk1 , posedge reset) begin
        if (reset ==1 )
            out <= 0;
        else
            out <= sign_extend;
    end
    assign P = out;
    assign mul  = i1 * i2;
    assign sign_extend = {{26{mul[37]}}, mul};
endmodule

module dsp_is_driven_only_by_dffs_which_drive_other_cell (clk, reset, A, B, P, P1);
    input clk, reset;
    input signed [19:0] A;
    input signed [17:0] B;
    output wire signed [37:0] P;
    output wire signed [37:0] P1;
    reg signed [19:0] i1;
    reg signed [17:0] i2;
    wire  [37:0] mul;
    wire  [37:0] mul1;
    wire [63:0] sign_extend;
    wire [63:0] sign_extend1;
    reg [63:0] out;
    reg [63:0] out1;
    always @(posedge clk, posedge reset) begin
        if(reset == 1'b1) begin
            i1 <= 0;
            i2 <= 0;
        end
        else begin
            i1 <= A;
            i2 <= B;
        end
    end
    always @(posedge clk , posedge reset) begin
        if (reset ==1 ) begin
            out <= 0;
            out1 <= 0;
        end
        else begin
            out <= sign_extend;
            out1 <= sign_extend1;
        end
    end

    assign P = out;
    assign P1 = out1;

    assign mul  = i1 * i2;
    assign mul1  = i1 + i2;
    assign sign_extend = {{26{mul[37]}}, mul};
    assign sign_extend1 = {{26{mul1[37]}}, mul1};
endmodule

module dsp_is_driven_by_multiple_dffs (clk, reset, A, B, C, P);
    input clk, reset;
    input signed [17:0] A;
    input signed [17:0] B;
    input signed [1:0] C;
    output wire signed [37:0] P;
    reg signed [17:0] i1;
    reg signed [17:0] i2;
    reg signed [1:0] i3;
    wire  [37:0] mul;
    wire [63:0] sign_extend;
    reg [63:0] out;
    always @(posedge clk, posedge reset) begin
        if(reset == 1'b1) begin
            i1 <= 0;
            i2 <= 0;
            i3 <= 0;
        end
        else begin
            i1 <= A;
            i2 <= B;
            i3 <= C;
        end
    end
    always @(posedge clk , posedge reset) begin
        if (reset ==1 )
            out <= 0;
        else
            out <= sign_extend;
    end
    assign P = out;
    assign mul  = {i1,i3} * i2;
    assign sign_extend = {{26{mul[37]}}, mul};
endmodule

module dsp_is_not_driven_only_by_dffs (clk, reset, A, B, C, P, i4);
    input clk, reset;
    input signed [15:0] A;
    input signed [17:0] B;
    input signed [1:0] C;
    output wire signed [37:0] P;
    reg signed [15:0] i1;
    reg signed [17:0] i2;
    reg signed [1:0] i3;
    input signed [1:0] i4;
    wire  [37:0] mul;
    wire [63:0] sign_extend;
    reg [63:0] out;
    always @(posedge clk, posedge reset) begin
        if(reset == 1'b1) begin
            i1 <= 0;
            i2 <= 0;
            i3 <= 0;
        end
        else begin
            i1 <= A;
            i2 <= B;
            i3 <= C;
        end
    end
    always @(posedge clk , posedge reset) begin
        if (reset ==1 )
            out <= 0;
        else
            out <= sign_extend;
    end
    assign P = out;
    assign mul  = {i1,i3,~i4} * i2;
    assign sign_extend = {{26{mul[37]}}, mul};
endmodule
