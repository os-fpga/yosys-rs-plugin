
// ---------------------------------------- 
//
// Delay Tap 
// Simulation Model 
//
// ---------------------------------------- 

module delay_tap (
    input [5:0] sel,  
    input in,    
    output  reg out  
);

    always @(in,sel) begin
      #((14.6+(14.6 * sel)) * 1ps) out <= in; 
    end
    
endmodule
