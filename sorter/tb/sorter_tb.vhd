library ieee;
use ieee.std_logic_1164.all;

entity sorter_tb is
end entity;

architecture behavioral of sorter_tb is -- Testbench architecture declaration
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
  component sorter is
   generic (
    DIM_SYMBOL : natural := 8;
    LEN_SORTER : natural := 4
   );
   port(
    clk          : in std_logic;
    reset        : in std_logic;
    write_enable : in std_logic;
    read_symbols : in std_logic;
    symbol_in    : in std_logic_vector(DIM_SYMBOL - 1 downto 0); -- New symbol to be sorted
    symbol_out   : out std_logic_vector(DIM_SYMBOL - 1 downto 0) -- Output symbol
   );
  end component;

begin

  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
  a_rst_n <= '1' after T_RESET;  -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).

  DUT: sorter
    generic map (
      DIM_SYMBOL  => DIM_SYMBOL,
      LEN_SORTER  => LEN_SORTER
    )
    port map (
      clk            => clk_tb,
      reset          => a_rst_n,
      write_enable   => write_enable_ext,
      read_symbols   => read_symbols_ext,
      symbol_in      => symbol_in_ext,
      symbol_out     => symbol_out_ext
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
        when 1  => write_enable_ext <= '1';
                   symbol_in_ext    <= x"10";
        when 2  => symbol_in_ext    <= x"09";
        when 3  => symbol_in_ext    <= x"08";
        when 4  => symbol_in_ext    <= x"07";
        when 5  => symbol_in_ext    <= x"06";
        when 6  => symbol_in_ext    <= x"05";
        when 7  => symbol_in_ext    <= x"04";
        when 8  => symbol_in_ext    <= x"03";
        when 9  => symbol_in_ext    <= x"02";
        when 10 => read_symbols_ext <= '1';
        when 15 => end_sim <= '0';  -- This command stops the simulation when t = 15
        when others => null;        -- Specifying that nothing happens in the other cases
      end case;

      t := t + 1;  -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
    end if;
  end process;

end architecture;
