//
// Copyright (C) 2022 RapidSilicon
// LUT Techmap
//
//
//------------------------------------------------------------------------------
module \$lut (...);

parameter WIDTH = 1;
parameter LUT = 0;

input wire [WIDTH-1:0]A;
output wire Y;

    case (WIDTH)
        1: begin
            LUT1 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

        2: begin
            LUT2 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

        3: begin
            LUT3 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

        4: begin
            LUT4 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

        5: begin
            LUT5 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

        6: begin
            LUT6 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end
        default: begin
            LUT6 #(.INIT_VALUE(LUT)) _TECHMAP_REPLACE_(.A(A), .Y(Y));
        end

    endcase

endmodule
/*module lut1 (A, Y);
    parameter INIT_VALUE = 2'h0;
    input wire A;
    output wire Y;
    LUT1 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule


module lut2 (A, Y);
    parameter INIT_VALUE = 4'h0;
    input wire [1:0] A;
    output wire Y;
    LUT2 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule


module lut3 (A, Y);
    parameter INIT_VALUE = 8'h0;
    input wire [2:0] A;
    output wire Y;
    LUT3 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule


module lut4 (A, Y);
    parameter INIT_VALUE = 16'h0;
    input wire [3:0] A;
    output wire Y;
    LUT4 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule


module lut5 (A, Y);
    parameter INIT_VALUE = 32'h0;
    input wire [4:0] A;
    output wire Y;
    LUT5 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule


module lut6 (A, Y);
    parameter INIT_VALUE = 64'h0;
    input wire [5:0] A;
    output wire Y;
    LUT6 #(.INIT_VALUE(INIT_VALUE)) TECHMAP_REPLACE_(.A(A), .Y(Y));
endmodule*/