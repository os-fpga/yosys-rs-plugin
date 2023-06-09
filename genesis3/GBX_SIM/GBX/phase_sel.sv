
// ---------------------------------------- 
//
// Phase Select
// Simulation Model 
//
// ---------------------------------------


module phase_select (
  input [1:0] control,
  input [3:0] phases,
  output reg phase_out
);

always @(control) begin
  case(control)
    2'b00: phase_out <= phases[0];
    2'b01: phase_out <= phases[1];
    2'b10: phase_out <= phases[2];
    2'b11: phase_out <= phases[3];
  endcase
end

endmodule