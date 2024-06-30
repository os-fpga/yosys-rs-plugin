--
-- Copyright (C) 2022 RapidSilicon
--
-- genesis3 DFFs and LATCHes
--

------------------------------------------------------------------------------
-- Rising-edge D-flip-flop with
--   active-Low asynchronous reset
--   active-high enable
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DFFRE is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean := false
           );
   port(
      c: in std_logic;
      r: in std_logic;
      e: in std_logic;
      d: in std_logic;
      q: out std_logic
   );
end DFFRE;

architecture arch of DFFRE is
begin
   process_init : process
   begin
   if (not VCS_MODE) then
           q <= INIT_VALUE;
   end if;
   wait;
   end process;
   process(c, r)
   begin
      if (r='0') then
         q <='0';
      elsif (c'event and c='1') then
         if (e='1') then
            q <= d;
         end if;
      end if;
   end process;
end arch;

------------------------------------------------------------------------------
-- Falling-edge D-flip-flop with
--   active-Low asynchronous reset
--   active-high enable
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DFFNRE is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean := false
           );
   port(
      c: in std_logic;
      r: in std_logic;
      e: in std_logic;
      d: in std_logic;
      q: out std_logic
   );
end DFFNRE;

architecture arch of DFFNRE is
begin
   process_init : process
   begin
   if (not VCS_MODE) then
           q <= INIT_VALUE;
   end if;
   wait;
   end process;
   process(c, r)
   begin
      if (r='0') then
         q <='0';
      elsif (c'event and c='0') then
         if (e='1') then
            q <= d;
         end if;
      end if;
   end process;
end arch;

--------------------------------------------------------------------------------
-- Positive level-sensitive latch
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latch is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean := false
           );
   port (
     q : out std_logic;
     g : in std_logic;
     d : in std_logic
   );
end latch;

architecture arch of latch is
begin
  process_init : process
  begin
  if (not VCS_MODE) then
          q <= INIT_VALUE;
  end if;
  wait;
  end process;
  processing_1 : process(g, d)
  begin
    if (g='1') then
      q <= d;
    end if;
  end process;
end arch;

--------------------------------------------------------------------------------
-- Negative level-sensitive latch
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchn is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean := false
           );
   port (
    q : out std_logic; 
    g : in std_logic;
    d : in std_logic
  );
end latchn;

architecture arch of latchn is
begin
  process_init : process
  begin
  if (not VCS_MODE) then
          q <= INIT_VALUE;
  end if;
  wait;
  end process;
  processing_1 : process(g, d)
  begin
    if (g='0') then
      q <= d;
    end if;
  end process;
end arch;

--------------------------------------------------------------------------------
-- Positive level-sensitive latch with active-high asyncronous reset
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchr is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean :=false
           );
   port (
    q : out std_logic;
    g : in std_logic;
    r : in std_logic;
    d : in std_logic
  );
end latchr;

architecture arch of latchr is
begin
  process_init : process
  begin
  if (not VCS_MODE) then
          q <= INIT_VALUE;
  end if;
  wait;
  end process;
  processing_1 : process(r, g, d)
  begin
    if (r='1') then
      q <= '0';
    elsif (g='1') then
      q <= d;
    end if;
  end process;
end arch;

--------------------------------------------------------------------------------
-- Negative level-sensitive latch with active-high asyncronous reset
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity latchnr is
   generic (
               INIT_VALUE : std_logic := '0';
               VCS_MODE : boolean := false
           );
   port (
    q : out std_logic;
    g : in std_logic;
    r : in std_logic;
    d : in std_logic
  );
end latchnr;

architecture arch of latchnr is
begin
  process_init : process
  begin
  if (not VCS_MODE) then
          q <= INIT_VALUE;
  end if;
  wait;
  end process;
  processing_1 : process(r, g, d)
  begin
    if (r='1') then
      q <= '0';
    elsif (g='0') then
      q <= d;
    end if;
  end process;
end arch;

--------------------------------------------------------------------------------
-- ADDER_CARRY : 1 bit ADDER_CARRY
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ADDER_CARRY is
  port (
    sumout : out std_logic;
    cout : out std_logic;
    p : in std_logic;
    g : in std_logic;
    cin : in std_logic
  );
end ADDER_CARRY;

architecture arch of ADDER_CARRY is
begin
  sumout <= p xor cin;
  cout <= cin when p else g;

end arch;


--------------------------------------------------------------------------------
-- lut 
--------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------
-- BOOT_CLOCK 
--------------------------------------------------------------------------------
entity BOOT_CLOCK is
  generic(
    PERIOD : real := 25.0 -- Clock period for simulation purposes (nS)
  );
  port(
    O : out std_logic := '0' -- Clock output
  );
end entity BOOT_CLOCK;

architecture Behavioral of BOOT_CLOCK is
  constant HALF_PERIOD : real := PERIOD / 2.0;
begin

  process
  begin
    wait for HALF_PERIOD * 1 ns; -- Adjusting for real to time conversion, assuming ns as base unit
    O <= not O;
  end process;
end Behavioral;

--------------------------------------------------------------------------------
-- I_BUF 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity I_BUF is
    generic (
        WEAK_KEEPER: string := "NONE"  -- Specify Pull-up/Pull-down on input (NONE/PULLUP/PULLDOWN)
    );
    port (
        I : in std_logic;  -- Data input (connect to top-level port)
        EN : in std_logic;  -- Enable the input
        O : out std_logic  -- Data output
    );
end entity I_BUF;

architecture Behavioral of I_BUF is
begin
    process(I, EN)
    begin
        if EN = '1' then
            O <= I;
        else
            O <= '0';
        end if;
    end process;

    assert not (WEAK_KEEPER = "NONE" or WEAK_KEEPER = "PULLUP" or WEAK_KEEPER = "PULLDOWN")
        report "Error: I_BUF instance has parameter WEAK_KEEPER set to " & WEAK_KEEPER & ". Valid values are NONE, PULLUP, PULLDOWN"
        severity error;

end architecture Behavioral;

--------------------------------------------------------------------------------
-- CLK_BUF 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CLK_BUF is
    Port ( I : in std_logic;
           O : out std_logic);
end CLK_BUF;

architecture Behavioral of CLK_BUF is
begin
    O <= I;
end Behavioral;

--------------------------------------------------------------------------------
-- FCLK_BUF 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity FCLK_BUF is
    Port ( I : in std_logic;
           O : out std_logic);
end FCLK_BUF;

architecture Behavioral of FCLK_BUF is
begin
    O <= I;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- I_DELAY
--------------------------------------------------------------------------------
entity I_DELAY is
    generic (
        DELAY : integer := 0  -- TAP delay value (0-63)
    );
    port (
        I : in std_logic;  -- Data Input (Connect to input port or buffer)
        DLY_LOAD : in std_logic;  -- Delay load input
        DLY_ADJ : in std_logic;  -- Delay adjust input
        DLY_INCDEC : in std_logic;  -- Delay increment / decrement input
        DLY_TAP_VALUE : out std_logic_vector(5 downto 0);  -- Delay tap value output
        CLK_IN : in std_logic;  -- Clock input
        O : out std_logic  -- Data output
    );
end entity I_DELAY;

architecture Behavioral of I_DELAY is
    -- Local variables
    signal dly_ld_0, dly_ld_1 : std_logic := '0';
    signal dly_adj_0, dly_adj_1 : std_logic := '0';
    signal dly_tap_val : integer range 0 to 63 := 0;
    signal dly_ld_p, dly_adj_p : std_logic;
begin

    -- Detecting 0 to 1 transition
    dly_ld_p <= dly_ld_0 and not dly_ld_1;
    dly_adj_p <= dly_adj_0 and not dly_adj_1;

    process(CLK_IN)
    begin
        if rising_edge(CLK_IN) then
            dly_ld_0 <= DLY_LOAD;
            dly_ld_1 <= dly_ld_0;
            dly_adj_0 <= DLY_ADJ;
            dly_adj_1 <= dly_adj_0;

            if dly_ld_p = '1' then
                dly_tap_val <= DELAY;
            elsif dly_adj_p = '1' and DLY_INCDEC = '1' and dly_tap_val /= 63 then
                dly_tap_val <= dly_tap_val + 1;
            elsif dly_adj_p = '1' and DLY_INCDEC = '0' and dly_tap_val /= 0 then
                dly_tap_val <= dly_tap_val - 1;
            end if;
        end if;
    end process;

    DLY_TAP_VALUE <= std_logic_vector(to_unsigned(dly_tap_val, 6));

    O <= I after 30.0 ps + 21.56 ps * dly_tap_val;  -- Adjusted Delay for TT corner

    -- Initial block equivalent in VHDL
    process
    begin
        if (DELAY < 0 or DELAY > 63) then
            assert false report "I_DELAY instance DELAY set to incorrect value. Values must be between 0 and 63." severity failure;
        end if;
    end process;
end architecture Behavioral;

--------------------------------------------------------------------------------
-- O_BUF_DS
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity O_BUF_DS is
    Port (
        I : in std_logic; -- Data input
        O_P : out std_logic; -- Data positive output (connect to top-level port)
        O_N : out std_logic -- Data negative output (connect to top-level port)
    );
end O_BUF_DS;

architecture Behavioral of O_BUF_DS is
begin
    O_P <= I;
    O_N <= not I;
end Behavioral;

--------------------------------------------------------------------------------
-- O_BUF
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity O_BUF is
    Port (
        I : in std_logic;
        O : out std_logic
    );
end O_BUF;

architecture Behavioral of O_BUF is
begin
    O <= I;
end Behavioral;

--------------------------------------------------------------------------------
-- O_BUFT_DS
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity O_BUFT_DS is
    generic (
        WEAK_KEEPER : string := "NONE"  -- Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
    );
    port (
        I   : in  std_logic;  -- Data input
        T   : in  std_logic;  -- Tri-state control input
        O_P : out std_logic;  -- Data positive output (connect to top-level port)
        O_N : out std_logic    -- Data negative output (connect to top-level port)
    );
end entity O_BUFT_DS;

architecture Behavioral of O_BUFT_DS is
begin
    O_P <= 'Z' when T = '0' else
           I when T = '1' else
           'X';  -- Undefined state, should never occur

    O_N <= 'Z' when T = '0' else
           not I when T = '1' else
           'X';  -- Undefined state, should never occur
    process
    begin
        if WEAK_KEEPER /= "NONE" and WEAK_KEEPER /= "PULLUP" and WEAK_KEEPER /= "PULLDOWN" then
            report "\nError: O_BUFT_DS instance has parameter WEAK_KEEPER set to " & WEAK_KEEPER & ". Valid values are NONE, PULLUP, PULLDOWN\n" severity failure;
        end if;
    end process;

end Behavioral;

--------------------------------------------------------------------------------
-- O_BUFT
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity O_BUFT is
    generic (
        WEAK_KEEPER : string := "NONE" -- Enable pull-up/pull-down on output (NONE/PULLUP/PULLDOWN)
    );
    port (
        I : in std_logic; -- Data input
        T : in std_logic; -- Tri-state control input
        O : out std_logic -- Data output (connect to top-level port)
    );
end entity O_BUFT;

architecture Behavioral of O_BUFT is
begin
    process(I, T)
    begin
        if T = '1' then
            O <= I;
        else
            O <= 'Z';
        end if;
    end process;
process
begin
    assert not (WEAK_KEEPER /= "NONE" and WEAK_KEEPER /= "PULLUP" and WEAK_KEEPER /= "PULLDOWN")
    report "\nError: O_BUFT instance has parameter WEAK_KEEPER set to " & WEAK_KEEPER & ".  Valid values are NONE, PULLUP, PULLDOWN\n"
    severity failure;
end process;

end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--------------------------------------------------------------------------------
-- O_DELAY
--------------------------------------------------------------------------------
entity O_DELAY is
  generic (
    DELAY : integer := 0 -- TAP delay value (0-63)
  );
  port (
    I : in std_logic; -- Data input
    DLY_LOAD : in std_logic; -- Delay load input
    DLY_ADJ : in std_logic; -- Delay adjust input
    DLY_INCDEC : in std_logic; -- Delay increment / decrement input
    DLY_TAP_VALUE : out std_logic_vector(5 downto 0); -- Delay tap value output
    CLK_IN : in std_logic; -- Clock input
    O : out std_logic -- Data output
  );
end entity O_DELAY;

architecture Behavioral of O_DELAY is

  signal dly_ld_0, dly_ld_1 : std_logic := '0';
  signal dly_adj_0, dly_adj_1 : std_logic := '0';
  signal dly_ld_p, dly_adj_p : std_logic;
  signal dly_tap_val : std_logic_vector(5 downto 0) := (others => '0');

begin

  process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      dly_ld_0 <= DLY_LOAD;
      dly_ld_1 <= dly_ld_0;
      
      dly_adj_0 <= DLY_ADJ;
      dly_adj_1 <= dly_adj_0;
    end if;
  end process;

  -- Detecting 0 to 1 transition
  dly_ld_p <= dly_ld_0 and not dly_ld_1;
  dly_adj_p <= dly_adj_0 and not dly_adj_1;

  process(CLK_IN)
  begin
    if rising_edge(CLK_IN) then
      if dly_ld_p = '1' then
        dly_tap_val <= std_logic_vector(to_unsigned(DELAY, 6));
      elsif dly_adj_p = '1' and DLY_INCDEC = '1' and dly_tap_val /= "111111" then
        dly_tap_val <= std_logic_vector(unsigned(dly_tap_val) + 1);
      elsif dly_adj_p = '1' and DLY_INCDEC = '0' and dly_tap_val /= "000000" then
        dly_tap_val <= std_logic_vector(unsigned(dly_tap_val) - 1);
      end if;
    end if;
  end process;

  DLY_TAP_VALUE <= dly_tap_val;

  O <= I after 30.0 ps + (21.56 ps * to_integer(unsigned(dly_tap_val)));

  -- Check for DELAY value correctness on initialization
  assert (DELAY >= 0 and DELAY <= 63)
  report "O_DELAY instance DELAY set to incorrect value. Values must be between 0 and 63."
  severity failure;

end Behavioral;

--------------------------------------------------------------------------------
-- O_SERDES_CLK
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity O_SERDES_CLK is
  generic(
    DATA_RATE : string := "SDR"; -- Single or double data rate (SDR/DDR)
    CLOCK_PHASE : integer := 0 -- Clock phase (0,90,180,270)
  );
  port(
    CLK_EN : in std_logic; -- Gates output OUTPUT_CLK
    OUTPUT_CLK : out std_logic := '0'; -- Clock output (Connect to output port, buffer or O_DELAY)
    PLL_LOCK : in std_logic; -- PLL lock input
    PLL_CLK : in std_logic -- PLL clock input
  );
end entity O_SERDES_CLK;
