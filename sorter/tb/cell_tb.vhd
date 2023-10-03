library ieee;
use ieee.std_logic_1164.all;

entity cell_tb is
end entity;

architecture behavioral of cell_tb is -- Testbench architecture declaration
  -----------------------------------------------------------------------------------
  -- Testbench constants
  -----------------------------------------------------------------------------------
  constant T_CLK      : time    := 10 ns;  -- Clock period
  constant T_RESET    : time    := 25 ns;  -- Period before the reset deassertion
  constant N_cell     : natural := 8;

  -----------------------------------------------------------------------------------
  -- Testbench signals
  -----------------------------------------------------------------------------------
  signal clk_tb           : std_logic := '0';  -- clock signal, intialized to '0'
  signal a_rst_n          : std_logic := '0';  -- reset signal
  signal write_en_ext     : std_logic := '0';
  signal read_en_ext      : std_logic := '0';
  signal read_in_ext      : std_logic_vector(N_cell - 1 downto 0) := (others => '0');
  signal read_out_ext     : std_logic_vector(N_cell - 1 downto 0) := (others => '0');
  signal write_in_ext     : std_logic_vector(N_cell - 1 downto 0) := (others => '0');
  signal write_out_ext    : std_logic_vector(N_cell - 1 downto 0) := (others => '0');
  signal push_in_ext      : boolean := false;
  signal push_out_ext     : boolean := false;
  signal end_sim          : std_logic := '1';

  -----------------------------------------------------------------------------------
  -- Component to test (DUT) declaration
  -----------------------------------------------------------------------------------
  component cell is
   generic (
    N_cell : natural := 8
   );
   port (
    clk         : in std_logic;
    write_en    : in std_logic;
    read_en     : in std_logic;
    reset       : in std_logic;
    read_in     : in std_logic_vector(N_cell - 1 downto 0);  -- Receive symbol to be read
    read_out    : out std_logic_vector(N_cell - 1 downto 0); -- Forward symbol to be read
    write_in    : in std_logic_vector(N_cell - 1 downto 0);  -- New symbol to be sorted
    write_out   : out std_logic_vector(N_cell - 1 downto 0); -- Forward symbol to be sorted
    push_in     : in boolean;
    push_out    : out boolean
  );
  end component;

begin

  clk_tb <= (not(clk_tb) and end_sim) after T_CLK / 2;  -- The clock toggles after T_CLK / 2 when end_sim is high. When end_sim is forced low, the clock stops toggling and the simulation ends.
  a_rst_n <= '1' after T_RESET;  -- Deasserting the reset after T_RESET nanosecods (remember: the reset is active low).

  DUT: cell
    generic map (
      N_cell => N_cell
    )
    port map (
      clk            => clk_tb,
      write_en       => write_en_ext,
      read_en        => read_en_ext,
      reset          => a_rst_n,
      read_in        => read_in_ext,
      read_out       => read_out_ext,
      write_in       => write_in_ext,
      write_out      => write_out_ext,
      push_in        => push_in_ext,
      push_out       => push_out_ext
    );

  STIMULI: process(clk_tb, a_rst_n)  -- process used to make the testbench signals change synchronously with the rising edge of the clock
    variable t : integer := 0;  -- variable used to count the clock cycle after the reset
  begin
    if(a_rst_n = '0') then
      read_in_ext <= (others => '0');
      write_in_ext <= (others => '0');
      write_en_ext <= '0';
      read_en_ext <= '0';
      t := 0;
    elsif(rising_edge(clk_tb)) then
      case(t) is
        when 1  => write_en_ext <= '1';
                   write_in_ext    <= "00000001";
        when 2  => write_in_ext    <= "00000010";
        when 3  => write_in_ext    <= "00000011";
        when 4  => write_in_ext    <= x"01";
        when 5  => write_in_ext    <= x"02";
        when 6  => write_in_ext    <= x"03";
        when 7  => write_in_ext    <= x"04";
        when 8  => write_in_ext    <= x"05";
        when 9  => write_in_ext    <= x"06";
        when 15 => end_sim <= '0';  -- This command stops the simulation when t = 15
        when others => null;        -- Specifying that nothing happens in the other cases
      end case;

      t := t + 1;  -- the variable is updated exactly here (try to move this statement before the "case(t) is" one and watch the difference in the simulation)
    end if;
  end process;

end architecture;
