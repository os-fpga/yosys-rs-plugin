-- Copyright (C) 2022 RapidSilicon
--
-- latchsre VHDL model converted from latchsre.v
--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchsre is
  port (
    Q : out std_logic;
    S : in std_logic;
    R : in std_logic;
    D : in std_logic;
    G : in std_logic 
    E : in std_logic
  );
end latchsre;

architecture RTL of latchsre is
  constant INIT : std_logic_vector(0 downto 0) := '0';
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
