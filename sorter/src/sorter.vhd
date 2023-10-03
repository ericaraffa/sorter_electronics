library ieee;
use ieee.std_logic_1164.all;

entity sorter is
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
end entity;

architecture struct of sorter is
  --------------------------
  -- Signals
  --------------------------
  type data_array is array (0 to LEN_SORTER - 1) of std_logic_vector (DIM_SYMBOL - 1 downto 0);
  type bool_array is array (0 to LEN_SORTER - 2) of boolean;

  signal cell_data_write  : data_array;
  signal cell_data_read   : data_array;
  signal push_array       : bool_array;

  --------------------------
  -- Components
  --------------------------
  component cell is
    generic(N_cell : natural := 8);
    port (
      clk         : in std_logic;
      write_en    : in std_logic;
      read_en     : in std_logic;
      reset       : in std_logic;
      read_in     : in std_logic_vector(N_cell - 1 downto 0);  -- Receive symbol to be read
      read_out    : out std_logic_vector(N_cell - 1 downto 0); -- Forward symbol to be read
      write_in    : in std_logic_vector(N_cell - 1 downto 0);  -- New symbol to be sorted
      write_out   : out std_logic_vector(N_cell - 1 downto 0); -- Forward symbol to be sorted
      push_in     : in boolean; -- Symbol incoming
      push_out    : out boolean -- Pushing-out symbol
    );
    end component;

begin

  GEN: for i in 0 to LEN_SORTER - 1 generate

    FIRST: if i = 0 generate
      CELL_HEAD: cell
        generic map(N_cell => DIM_SYMBOL)
        port map(
          clk        => clk,
          write_en   => write_enable,
          read_en    => read_symbols,
          reset      => reset,
          read_in    => cell_data_read(i + 1),
          read_out   => cell_data_read(i),
          write_in   => symbol_in,
          write_out  => cell_data_write(i),
          push_in    => true,
          push_out   => push_array(i)
        );
    end generate;

    MIDDLE: if i > 0 and i < LEN_SORTER - 1 generate
      CELL_MID: cell
        generic map(N_cell => DIM_SYMBOL)
        port map(
          clk        => clk,
          write_en   => write_enable,
          read_en    => read_symbols,
          reset      => reset,
          read_in    => cell_data_read(i + 1),
          read_out   => cell_data_read(i),
          write_in   => cell_data_write(i - 1),
          write_out  => cell_data_write(i),
          push_in    => push_array(i - 1),
          push_out   => push_array(i)
        );
    end generate;

    LAST: if i = LEN_SORTER - 1 generate
      CELL_TAIL: cell
        generic map(N_cell => DIM_SYMBOL)
        port map(
          clk        => clk,
          write_en   => write_enable,
          read_en    => read_symbols,
          reset      => reset,
          read_in    => (others => '0'),
          read_out   => cell_data_read(i),
          write_in   => cell_data_write(i - 1),
          write_out  => cell_data_write(i),
          push_in    => push_array(i - 1),
          push_out   => open
        );
    end generate;

  end generate;

  -- Connect output of the sorter to the FIRST cell.
    symbol_out <= cell_data_read(0);

end architecture;