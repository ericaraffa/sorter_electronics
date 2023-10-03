library ieee;
use ieee.std_logic_1164.all;

entity sorter_wrapper_tb is
end entity;

architecture behavioral of sorter_wrapper_tb is -- Testbench architecture declaration
  -----------------------------------------------------------------------------------
  -- Testbench constants
  -----------------------------------------------------------------------------------
  constant T_CLK      : time    := 10 ns;  -- Clock period
  constant T_RESET    : time    := 25 ns;  -- Period before the reset deassertion
  constant DIM_SYMBOL : natural := 8;
  constant LEN_SORTER : natural := 4;

  -----------------------------------------------------------------------------------
  -- Testbench signals
  -----------------------------------------------------------------------------------
  signal clk_tb           : std_logic := '0';  -- clock signal, intialized to '0'
  signal a_rst_n          : std_logic := '0';  -- reset signal
  signal write_enable_ext : std_logic;
  signal read_symbols_ext : std_logic;
  signal symbol_in_ext    : std_logic_vector(DIM_SYMBOL - 1 downto 0) := (others => '0');
  signal symbol_out_ext   : std_logic_vector(DIM_SYMBOL - 1 downto 0);
  signal end_sim          : std_logic := '1';

  -----------------------------------------------------------------------------------
  -- Component to test (DUT) declaration
  -----------------------------------------------------------------------------------
  component sorter_wrapper is
   generic (
    DIM_SYMBOL : natural := 8
   );
   port(
    clk            : in std_logic;
    reset          : in std_logic;
    write_enable_w : in std_logic;
    read_symbols_w : in std_logic;
    symbol_in_w    : in std_logic_vector(DIM_SYMBOL - 1 downto 0); -- New symbol to be sorted
    symbol_out_w   : out std_logic_vector(DIM_SYMBOL - 1 downto 0) -- Output symbol
   );
  end component;

begin

  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
  a_rst_n <= '1' after T_RESET;  -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).

  DUT: sorter_wrapper
    generic map (
      DIM_SYMBOL  => DIM_SYMBOL
    )
    port map (
      clk              => clk_tb,
      reset            => a_rst_n,
      write_enable_w   => write_enable_ext,
      read_symbols_w   => read_symbols_ext,
      symbol_in_w      => symbol_in_ext,
      symbol_out_w     => symbol_out_ext
    );

  STIMULI: process(clk_tb, a_rst_n)  -- process used to make the testbench signals change synchronously with the rising edge of the clock
    variable t : integer := 0;  -- variable used to count the clock cycle after the reset
  begin
    if(a_rst_n = '0') then
      symbol_in_ext <= (others => '0');
      write_enable_ext <= '0';
      read_symbols_ext <= '0';
      t := 0;
    elsif(rising_edge(clk_tb)) then
      case(t) is
        when 1  => write_enable_ext <= '1';           -- Write operation
                   symbol_in_ext    <= x"09";
        when 2  => symbol_in_ext    <= x"08";
        when 3  => symbol_in_ext    <= x"07";
        when 4  => symbol_in_ext    <= x"06";
        when 5  => symbol_in_ext    <= x"05";

        when 6  => symbol_in_ext    <= x"04";         -- In case of sorter overflow, the greater symbol is discarded 
        when 7  => symbol_in_ext    <= x"03";
        when 8  => symbol_in_ext    <= x"02";
        when 9  => symbol_in_ext    <= x"01";

        when 10 => read_symbols_ext <= '1';           -- Reading operation. In case of simultaneous reading and writing, reading operation is performed
                                                      -- A read request without any element in the sorter returns 0      
        when 21 => read_symbols_ext <= '0';
                   symbol_in_ext    <= x"01";
        when 22 => symbol_in_ext    <= x"02";
        when 23 => symbol_in_ext    <= x"03";
        when 24 => symbol_in_ext    <= x"04";
        when 25 => symbol_in_ext    <= x"05";
        when 26 => symbol_in_ext    <= x"06";
        when 27 => symbol_in_ext    <= x"07";
        when 28 => symbol_in_ext    <= x"08";
        when 29 => symbol_in_ext    <= x"09";
        when 30 => symbol_in_ext    <= x"10";
        when 31 => read_symbols_ext <= '1';

        when 41 => read_symbols_ext <= '0';           -- Possible error situation:
                   symbol_in_ext    <= x"01";         -- write operation with multiple 0s and some other symbol;
        when 42 => symbol_in_ext    <= x"02";         -- the successive reading operation could leave the sorter in a non-consistent state
        when 43 => symbol_in_ext    <= x"00";
        when 44 => symbol_in_ext    <= x"00";
        when 45 => read_symbols_ext <= '1';
        when 46 => read_symbols_ext <= '0';
                   write_enable_ext <= '0';
        when 47 => end_sim <= '0';                   -- Stop the simulation
        when others => null;                         -- Nothing happens in the other cases
      end case;

      t := t + 1;
    end if;
  end process;

end architecture;
