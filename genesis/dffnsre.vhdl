-- Copyright (C) 2022 RapidSilicon
--
-- dffnsre VHDL model
--
library ieee;
use ieee.std_logic_1164.all;

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
