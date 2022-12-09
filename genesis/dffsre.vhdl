-- Copyright (C) 2022 RapidSilicon
-- dffsre VHDL model
--
library ieee;
use ieee.std_logic_1164.all;

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
