--
-- Copyright (C) 2022 RapidSilicon
--
-- genesis adder_carry,lut, shr,  DFFs and LATCHes
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity adder_carry is
  port (
    sumout : out std_logic;
    cout : out std_logic;
    p : in std_logic;
    g : in std_logic; 
    cin : in std_logic
  );
end adder_carry;

architecture RTL of adder_carry is
begin
  sumout <= p xor cin;
  cout <= cin when p else g;

end RTL;


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dffsre is
   port(
      c: in std_logic;
      r: in std_logic;
      s: in std_logic;
      e: in std_logic;
      d: in std_logic;
      q: out std_logic
   );
end dffsre;

architecture arch of dffsre is
begin
   process(c,r,s)
   begin
      if (r='0') then
         q <='0';
      elsif (s='0') then
         q <='1';
      elsif (c'event and c='1') then
         if (e='1') then
            q <= d;
         end if;
      end if;
   end process;
end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dffnsre is
   port(
      c: in std_logic;
      r: in std_logic;
      s: in std_logic;
      e: in std_logic;
      d: in std_logic;
      q: out std_logic
   );
end dffnsre;

architecture arch of dffnsre is
begin
   process(c,r,s)
   begin
      if (r='0') then
         q <='0';
      elsif (s='0') then
         q <='1';
      elsif (c'event and c='0') then
         if (e='1') then
            q <= d;
         end if;
      end if;
   end process;
end arch;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchsre is
  port (
    Q : out std_logic;
    S : in std_logic;
    R : in std_logic;
    D : in std_logic;
    G : in std_logic; 
    E : in std_logic
  );
end latchsre;

architecture RTL of latchsre is
  constant INIT : std_logic := '0';
begin

  processing_0 : process
  begin
    Q <= INIT;
  end process;

  processing_1 : process
  begin
    if (not R) then
      Q <= '0';
    elsif (not S) then
      Q <= '1';
    elsif (E and G) then
      Q <= D;
    end if;
  end process;
end RTL;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
