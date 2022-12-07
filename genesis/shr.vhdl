-- Copyright (C) 2022 RapidSilicon

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;               -- Needed for shifts

entity shr is
   generic ( 
        A_SIGNED : INTEGER := 0;
        B_SIGNED : INTEGER := 0;
        A_WIDTH : INTEGER := 8;
	B_WIDTH : INTEGER := 3;
	Y_WIDTH : INTEGER := 8);
   port (
     A:  in std_logic_vector(A_WIDTH-1 downto 0) ; 
     B:  in std_logic_vector(B_WIDTH-1 downto 0) ; 
     Y: out std_logic_vector(Y_WIDTH-1 downto 0)        
   );
end shr;
 
architecture behave of shr is
   
begin
 
  process (A, B) is
  begin
    -- Right Shift
    Y <= std_logic_vector(shift_right(unsigned(A), to_integer(unsigned(B))));
 
  end process;
end architecture behave;
