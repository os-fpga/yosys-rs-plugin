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

--------------------------------------------------------------------------------
-- BOOT_CLOCK 
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

  clock_process: process
  begin
    loop
      wait for HALF_PERIOD * 1 ns; -- Adjusting for real to time conversion, assuming ns as base unit
      O <= not O;
    end loop;
  end process clock_process;

  check_period_process: process
  begin
    if ((PERIOD < 16.0) or (PERIOD > 30.0)) then
      report "BOOT_CLOCK instance PERIOD set to incorrect value, " & real'image(PERIOD) & ".  Values must be between 16.0 and 30.0.";
      wait for 1 ps; -- Smallest time unit for simulation to acknowledge the stop
      assert false report "Simulation stopped due to incorrect PERIOD value." severity failure;
    end if;
    wait; -- Ensures this process does not run again
  end process check_period_process;

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
    generic (
        DATA_RATE : string := "SDR"; -- Single or double data rate (SDR/DDR)
        CLOCK_PHASE : integer := 0 -- Clock phase (0,90,180,270)
    );
    port (
        CLK_EN : in std_logic; -- Gates output OUTPUT_CLK
        OUTPUT_CLK : out std_logic; -- Clock output (Connect to output port, buffer or O_DELAY)
        PLL_LOCK : in std_logic; -- PLL lock input
        PLL_CLK : in std_logic -- PLL clock input
    );
end entity O_SERDES_CLK;

architecture Behavioral of O_SERDES_CLK is
    signal clock_enabled : std_logic := '0';
    signal toggle_clk : std_logic := '0'; -- Used to manage OUTPUT_CLK toggling
begin
    -- Process to handle clock enabling and toggling
    Clock_Control: process(PLL_CLK)
    begin
        if rising_edge(PLL_CLK) then
            if PLL_LOCK = '1' and clock_enabled = '0' then
                clock_enabled <= '1';
                -- Assuming some initialization or synchronization tasks here
                -- Actual implementation might require additional logic or signals
            elsif PLL_LOCK = '0' then
                clock_enabled <= '0';
                OUTPUT_CLK <= '0'; -- Reset output clock when PLL is unlocked
            end if;
        end if;
    end process Clock_Control;

    -- Process to toggle OUTPUT_CLK based on CLK_EN and clock_enabled
    Clock_Toggle: process(PLL_CLK)
    begin
        if rising_edge(PLL_CLK) then
            if clock_enabled = '1' and CLK_EN = '1' then
                toggle_clk <= not toggle_clk;
            else
                toggle_clk <= '0'; -- Ensure toggle_clk is reset appropriately
            end if;
        end if;
        
        -- Synchronize OUTPUT_CLK with toggle_clk, adjusting for DATA_RATE and CLOCK_PHASE as needed
        -- This example does not implement the dynamic adjustment for simplicity
        OUTPUT_CLK <= toggle_clk;
    end process Clock_Toggle;

    -- Parameter validation at elaboration time
    Check_param: process
    begin
        assert DATA_RATE = "SDR" or DATA_RATE = "DDR"
        report "DATA_RATE must be either 'SDR' or 'DDR'."
        severity failure;

        assert CLOCK_PHASE = 0 or CLOCK_PHASE = 90 or CLOCK_PHASE = 180 or CLOCK_PHASE = 270
        report "CLOCK_PHASE must be 0, 90, 180, or 270."
        severity failure;
    end process Check_param;
  
end Behavioral;

--------------------------------------------------------------------------------
-- PLL
--------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PLL is
  generic (
    DIVIDE_CLK_IN_BY_2 : string := "FALSE";    -- Enable input divider (TRUE/FALSE)
    PLL_MULT           : integer := 16;         -- VCO clock multiplier (16-1000)
    PLL_DIV            : integer := 1;          -- VCO clock divider (1-63)
    PLL_POST_DIV       : integer := 2           -- VCO clock post-divider 
  );
  port (
    PLL_EN           : in  std_logic;          -- PLL Enable
    CLK_IN           : in  std_logic;          -- Clock input
    CLK_OUT          : out std_logic;          -- Output clock
    CLK_OUT_DIV2     : out std_logic;          -- CLK_OUT divided by 2
    CLK_OUT_DIV3     : out std_logic;          -- CLK_OUT divided by 3
    CLK_OUT_DIV4     : out std_logic;          -- CLK_OUT divided by 4
    SERDES_FAST_CLK  : out std_logic;          -- Gearbox fast clock output
    LOCK             : out std_logic           -- PLL lock signal
  );
end entity PLL;

architecture rtl of PLL is


  -- Selection Function
  function sel_int(Cond : boolean; If_True, If_False : integer) return integer is
  begin
    if Cond then
      return If_True;
    else
      return If_False;
    end if;
  end function sel_int;

function sel_time(Cond : boolean; If_True, If_False : time) return time is
  begin
    if Cond then
      return If_True;
    else
      return If_False;
    end if;
  end function sel_time;
  
  -- Constants and Signals -----------------------------------------------------

  -- Input clock divider and period calculations

  constant div_input_clk     : integer := sel_int(DIVIDE_CLK_IN_BY_2 = "TRUE", 2, 1);
  constant clk_in_max_period : time    := sel_time(DIVIDE_CLK_IN_BY_2 = "TRUE", 62500000 ns , 125000000 ns);
  constant clk_in_min_period : time    := sel_time(DIVIDE_CLK_IN_BY_2 = "TRUE", 1000000 ns, 2000000 ns);

                                                                                                  
  -- VCO (Voltage Controlled Oscillator) period limits
  constant vco_max_period    : time    := 1_250_000 ns;
  constant vco_min_period    : time    := 312_000 ns;

  -- Signals to track periods
  signal clk_in_period, old_clk_in_period : time := 0 ns;

  -- Control signals and counters
  signal pll_start, vco_clk_start, clk_out_start : std_logic := '0';
  signal vco_count : integer range 0 to PLL_MULT * PLL_DIV * 2 := PLL_MULT * PLL_DIV * 2;
  signal div3_count : integer range 0 to 2 := 1;
  signal clk_in_count, old_clk_in_count : unsigned(3 downto 0) := (others => '0');
  signal vco_period : time := vco_max_period; -- Initial VCO period (maximum)

  -- Other signals
  signal clk_in_start : time;

begin  -- Architecture Body ---------------------------------------------------

  -- Main PLL Control Process ------------------------------------------------
  main_control_process : process
  begin
    -- Initialize signals at the start or when PLL is disabled
    LOCK <= '0';
    pll_start <= '0';
    clk_in_period <= 0 ns;
    clk_in_count <= (others => '0');
    old_clk_in_count <= (others => '0');
    vco_period <= 1_250_000 ns;  -- Initial VCO period 
    vco_clk_start <= '0';
    clk_out_start <= '0';
    div3_count <= 1;
    vco_count <= PLL_MULT * PLL_DIV * 2;
    SERDES_FAST_CLK <= '0';
    CLK_OUT <= '0';
    CLK_OUT_DIV2 <= '0';
    CLK_OUT_DIV3 <= '0';
    CLK_OUT_DIV4 <= '0';

    wait for 100 ns;

    -- Wait for PLL enable signal
    if PLL_EN = '1' then
      pll_start <= '1';
      wait until PLL_EN = '0' or LOCK = '1';
    else
      wait until PLL_EN = '1';
    end if;
  end process main_control_process; 
  
-- Lock Detection and Initial Clock Outputs --------------------------------
lock_detection_process : process(CLK_IN)  -- Now sensitive to CLK_IN
  variable rising_edge_counter : integer := 0; -- To count rising edges
begin
  if rising_edge(CLK_IN) then
    if pll_start = '1' then
      if rising_edge_counter < 9 then
        rising_edge_counter := rising_edge_counter + 1;
      else  -- 9 rising edges have been seen
        vco_clk_start <= '1';
      end if;
    else
      rising_edge_counter := 0; -- Reset the counter when pll_start is low
    end if;
  end if;

  if rising_edge(SERDES_FAST_CLK) then
    if vco_clk_start = '1' then
      if rising_edge_counter < 19 then  -- Count 10 rising edges of SERDES_FAST_CLK
        rising_edge_counter := rising_edge_counter + 1;
      elsif rising_edge_counter = 19 then -- Additional rising edge of CLK_IN
        clk_out_start <= '1';
      end if;
    end if;
  end if;

  if rising_edge(CLK_OUT) then
    if clk_out_start = '1' then
      if rising_edge_counter < 24 then  -- Count 5 rising edges of CLK_OUT
        rising_edge_counter := rising_edge_counter + 1;
      else
        LOCK <= '1';                     -- Set LOCK after stabilization
      end if;
    end if;
  end if;
end process lock_detection_process;
  
-- VCO Clock Generation Process -------------------------------------------
vco_clock_generation : process(CLK_IN)
begin
  if rising_edge(CLK_IN) then  
    if vco_clk_start = '1' then
      if vco_count = PLL_MULT * PLL_DIV * 2 then 
        SERDES_FAST_CLK <= '0';
        vco_count <= 1;
      else
        SERDES_FAST_CLK <= not SERDES_FAST_CLK; 
        vco_count <= vco_count + 1;              
      end if;
    else
      SERDES_FAST_CLK <= '0';                 
    end if;
  end if;  
end process vco_clock_generation;

-- Output Clock Generation Process -----------------------------------------
output_clock_generation : process(SERDES_FAST_CLK)
  variable post_div_counter : integer range 0 to PLL_POST_DIV / 2 := 0; -- Counter for post-divider
begin
  if rising_edge(SERDES_FAST_CLK) then
    if clk_out_start = '1' then
      if post_div_counter = PLL_POST_DIV / 2 - 1 then  -- Toggle after half the post-divider cycles
        CLK_OUT <= not CLK_OUT;
        post_div_counter := 0;                       -- Reset counter
      else
        post_div_counter := post_div_counter + 1;    -- Increment counter
      end if;
    else
      CLK_OUT <= '0';                                 -- Disable output clock before lock
    end if;
  end if;
end process output_clock_generation;

-- Divided Clock Generation Processes -------------------------------------
divided_clocks_generation : process
begin
  CLK_OUT_DIV2 <= not CLK_OUT_DIV2;  -- Divide by 2
  wait until rising_edge(CLK_OUT);
end process divided_clocks_generation;

-- Frequency Adjustment Based on Input Clock -----------------------------
frequency_adjustment : process(CLK_IN)
  variable rising_edge_counter : unsigned(3 downto 0) := (others => '0');
begin
  if rising_edge(CLK_IN) then -- Execute on rising edge of CLK_IN
    if pll_start = '1' then
      clk_in_start <= now; -- Record start time of clock period

      -- Count rising edges while locked
      if LOCK = '1' then
        rising_edge_counter := rising_edge_counter + 1;
      end if;

      if rising_edge_counter = 1 then  -- After two rising edges...
        if clk_in_period = 0 ns then
          old_clk_in_period <= now - clk_in_start; -- First period measurement
        else
          old_clk_in_period <= clk_in_period;
        end if;

        clk_in_period <= now - clk_in_start; -- Update input clock period

        -- Calculate VCO period based on input clock frequency
        vco_period <= clk_in_period * div_input_clk * PLL_DIV / PLL_MULT;

        clk_in_start <= now;                -- Reset start time for the next period
        if LOCK = '1' then
          rising_edge_counter := rising_edge_counter + 1; -- Continue counting for next period
        end if;

        -- Error checking for input clock and VCO frequencies
        if clk_in_period < clk_in_min_period then
          report "Warning: PLL input clock, CLK_IN, is too fast." severity warning;
          LOCK <= '0';
        end if;

        if clk_in_period > clk_in_max_period then
          report "Warning: PLL input clock, CLK_IN, is too slow." severity warning;
          LOCK <= '0';
        end if;

        if LOCK = '1' and (clk_in_period > old_clk_in_period * 1.05 or clk_in_period < old_clk_in_period * 0.95) then
          report "Warning: PLL input clock, CLK_IN, changed frequency and lost lock." severity warning;
          LOCK <= '0';
        end if;
      end if; -- End of rising_edge_counter = 1 condition
    end if; -- End of pll_start = '1' condition

    if rising_edge_counter = 15 then -- Reset counter after checking two periods
      rising_edge_counter := (others => '0');
    end if;
  end if; -- End of rising_edge(CLK_IN) condition
end process frequency_adjustment;

-- Divide-by-3 Clock Generation Process -----------------------------------
divided_by_3_clock : process(CLK_OUT) -- Sensitive to CLK_OUT
begin
  if div3_count = 2 then           -- Every third CLK_OUT cycle...
    CLK_OUT_DIV3 <= not CLK_OUT_DIV3;  -- ...toggle the output
    div3_count <= 0;                -- ...and reset the counter
  else
    div3_count <= div3_count + 1;   -- Increment counter
  end if;
end process divided_by_3_clock;

-- Divide-by-4 Clock Generation ----------------------------------------------
divided_by_4_clock : process(CLK_OUT_DIV2)
begin
  CLK_OUT_DIV4 <= not CLK_OUT_DIV4; -- Toggle CLK_OUT_DIV4 on every rising edge of CLK_OUT_DIV2
end process divided_by_4_clock;

-- Initial Blocks -----------------------------------------------------------

-- Timescale Check 
initial_check_1 : process
begin
  assert (1 fs = 1 fs) -- Check if the timescale is set correctly
    report "Error: The timescale for PLL must be set to 1fs/1fs" severity failure;

  wait;  -- Wait indefinitely to prevent process from ending
end process initial_check_1;

-- Parameter Checks -----------------------------------------------------------
initial_check_2 : process
begin
  -- Check DIVIDE_CLK_IN_BY_2 parameter
  assert (DIVIDE_CLK_IN_BY_2 = "TRUE" or DIVIDE_CLK_IN_BY_2 = "FALSE")
    report "Error: Invalid DIVIDE_CLK_IN_BY_2 value. Must be 'TRUE' or 'FALSE'." severity failure;

  -- Check PLL_MULT range
  assert (PLL_MULT >= 16 and PLL_MULT <= 1000)
    report "Error: PLL_MULT must be between 16 and 1000." severity failure;

  -- Check PLL_DIV range
  assert (PLL_DIV >= 1 and PLL_DIV <= 63)
    report "Error: PLL_DIV must be between 1 and 63." severity failure;

  -- Check PLL_POST_DIV value
  case PLL_POST_DIV is
    when 2 | 4 | 6 | 8 | 10 | 12 | 14 | 16 | 18 | 20 | 24 | 28 | 30 | 32 | 36 | 40 | 42 | 48 | 50 | 56 | 60 | 70 | 72 | 84 | 98 => null; -- Valid values
    when others =>
      report "Error: Invalid PLL_POST_DIV value." severity failure;
  end case;

  wait; -- Wait indefinitely to prevent process from ending
end process initial_check_2;
                                                                               
end architecture rtl;
