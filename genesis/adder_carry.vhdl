-- Copyright (C) 2022 RapidSilicon
--
-- adder carry VHDL description converted from adder_carry.v
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
