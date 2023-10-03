library IEEE;
use IEEE.std_logic_1164.all;

entity sorter_wrapper is
  generic (
    DIM_SYMBOL : natural := 8
  );
  port (
    clk              : in std_logic;  -- clock of the system
    reset            : in std_logic;  -- Asynchronous reset - active low
    write_enable_w   : in std_logic;
    read_symbols_w   : in std_logic;
    symbol_in_w      : in std_logic_vector(DIM_SYMBOL - 1 downto 0); -- New symbol to be sorted
    symbol_out_w     : out std_logic_vector(DIM_SYMBOL - 1 downto 0) -- Output symbol
  );
end entity;

architecture struct of sorter_wrapper is
  -------------------------------------------------------------------------------------
  -- Signals
  -------------------------------------------------------------------------------------

  -- Input of the sorter
  signal symbol_in_internal : std_logic_vector(DIM_SYMBOL - 1 downto 0);
  -- Output of the sorter
  signal symbol_out_internal : std_logic_vector(DIM_SYMBOL - 1 downto 0);
  

  -------------------------------------------------------------------------------------
  -- Internal Component
  -------------------------------------------------------------------------------------
  component sorter is
    generic (
      DIM_SYMBOL : natural := 8
    );
    port (
        clk           : in std_logic;  -- clock of the system
        reset         : in std_logic;  -- Asynchronous reset - active low
        write_enable  : in std_logic;
        read_symbols  : in std_logic;
        symbol_in     : in std_logic_vector(DIM_SYMBOL - 1 downto 0); -- New symbol to be sorted
        symbol_out    : out std_logic_vector(DIM_SYMBOL - 1 downto 0) -- Output symbol
    );
  end component;

begin

    sorter_i: sorter
      port map (
        clk   => clk,
        reset => reset,
        write_enable => write_enable_w,
        read_symbols => read_symbols_w,
        symbol_in => symbol_in_internal,
        symbol_out => symbol_out_internal
      );

    -- Mapping input and output
    symbol_in_internal <= symbol_in_w;
    symbol_out_w <= symbol_out_internal;

end architecture;
