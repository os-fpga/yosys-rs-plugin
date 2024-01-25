// Copyright (C) 2022 RapidSilicon
//

module latchp (
    input d,
    clk,
    en,
    output reg q
);
  initial q <= 1'b0;
  always @* if (en) q <= d;
endmodule

module my_latchn (
    input d,
    clk,
    en,
    output reg q
);
  always @* if (!en) q <= d;
endmodule

module my_latchsre (
    input d,
    clk,
    en,
    clr,
    pre,
    output reg q
);
  always @*
    if (clr) q <= 1'b0;
    else if (pre) q <= 1'b1;
    else if (en) q <= d;
endmodule
