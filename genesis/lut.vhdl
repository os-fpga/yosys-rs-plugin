-- Copyright (C) 2022 RapidSilicon
--
-- LUT VHDL implementation with shift right
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts

entity lut is
   generic ( 
        A_SIGNED : INTEGER := 0;
        B_SIGNED : INTEGER := 0;
        A_WIDTH : INTEGER := 0;
	B_WIDTH : INTEGER := 0;
	Y_WIDTH : INTEGER := 0);
   port (
     A:  in std_logic_vector(A_WIDTH-1 downto 0) ; 
     B:  in std_logic_vector(B_WIDTH-1 downto 0) ; 
     Y: out std_logic       
   );
end lut;
 
architecture behave of lut is
   
  signal S : std_logic_vector(Y_WIDTH-1 downto 0);

begin
 
  process (A, B) is
  begin
    -- Right Shift
    S <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));
    Y <= S(0);
 
  end process;
end architecture behave;
