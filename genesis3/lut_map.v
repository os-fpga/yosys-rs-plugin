//
// Copyright (C) 2022 RapidSilicon
// LUT Techmap
//
//
//------------------------------------------------------------------------------
module \$lut (...);

parameter WIDTH = 0;
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
            wire _TECHMAP_FAIL_;
        end

    endcase

endmodule