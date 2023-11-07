// ---------------------------------------- //
// --------------- IO MODEL --------------- //
// --------------- TECHMAP ---------------- //
// ---------------------------------------- //


// ---------------------------------------- 

module rs__CLK_BUF (...);
    input  I;             
    output O;             
   

    CLK_BUF _TECHMAP_REPLACE_ (.I(I), .O(O));

endmodule


// ---------------------------------------- 

module rs__I_BUF(...);
    parameter WEAK_KEEPER = "NONE"; // Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
    
        input  I;
        input  EN;            
        output O;            


    I_BUF #(.WEAK_KEEPER(WEAK_KEEPER )) _TECHMAP_REPLACE_(.I(I),.EN(1'b1),.O(O));

endmodule 

// ---------------------------------------- 

module rs__O_BUF(...);
  
        input  I;     
        input  C;    
        output O;         
    
      O_BUF _TECHMAP_REPLACE_ (.I(I),.O(O));
endmodule

/*/ ----------------------------------------
module rs__IO_BUF(...);
    input   I;     
    input   T;
    inout  wire  IO;
    output  O;
  
  IO_BUF _TECHMAP_REPLACE_(.I(I),.IO(IO),.T(T),.O(O));
  
endmodule 
*/