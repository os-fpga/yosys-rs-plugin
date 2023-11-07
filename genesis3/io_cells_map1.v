 //---------------------------------------- 
// 
//   Copyright (c) 2023 Rapid Silicon 
//   All Right Reserved.
//   ------------------------------------- 


module rs__CLK_BUF (
    input   I,             
    output  O              
    );
  
    CLK_BUF CLK_BUF_inst (.I(I), .O(O));
  
  endmodule 
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 
  

  module rs__I_BUF #(
    parameter WEAK_KEEPER = "NONE" // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
  )(
    input  I,
    input  EN,
    output  O        
  );
  
  I_BUF #(.WEAK_KEEPER(WEAK_KEEPER)) ibuf_inst (.I(I),.EN(EN),.O(O));
    

endmodule 

// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//   ------------------------------------ 

module rs__O_BUF (
  input I, // Data input
  output O // Data output (connect to top-level port)
);

  O_BUF obuf_inst (.I(I),.O(O));

endmodule 
//--------------------------------------- 
// 
//    Copyright (c) 2023 Rapid Silicon 
//    All Right Reserved.
//--------------------------------------- 
module rs__IO_BUF
  (
    input   I,     
    input   T,
    inout   IO,
    output  O
  );
  
  //IO_BUF iobuf_inst (.I(I),.IO(IO),.T(T),.O(O));
  
endmodule 
