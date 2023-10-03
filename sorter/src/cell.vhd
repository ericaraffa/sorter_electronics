library ieee;
use ieee.std_logic_1164.all;


entity cell is
  generic (
    N_cell : natural := 8 -- Dim symbol
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
end entity;

architecture behavioral of cell is
    --------------------------
    --Signals
    --------------------------
    signal curr_data     : std_logic_vector (N_cell - 1 downto 0);
    signal occupied      : boolean;

  begin

    sort_proc: process(clk, reset) 
    begin

      if(reset = '0') then
        read_out <= (others => '0');
        write_out <= (others => '0');
        occupied <= false;
        push_out <= false;
        curr_data  <= (others => '0'); -- Set all bits to 0

      elsif (rising_edge(clk)) then
        push_out  <= false;

        --------------------------------------------------------------------
        -- Reading flow:
        -- The cells forward the current value to the next cell, until all
        -- of them become empty.
        -- The read operation has the priority over the write operation
        --------------------------------------------------------------------
        if(read_en = '1') then 

            read_out <= read_in;            -- The cell passes his value to the previous cell and it reads the next value.
            curr_data <= read_in;           -- In this way, at the end of the reading phase all the cells value is 0
            write_out <= read_in; 

            if(read_in = x"00") then
              occupied <= false;
            end if;        

            push_out  <= false;

        --------------------------------------------------------------------
        -- Writing flow:
        -- The new value is sorted during the insertion. The cell checks the 
        -- new value and if it's bigger than the current one it's forwarded
        -- to the next cell. Otherwise, it's stored.
        --------------------------------------------------------------------     
        elsif(read_en = '0' and write_en = '1' and push_in = true) then
        
            if (not occupied) then
              occupied <= true;                    -- The cell writes the new value
              curr_data <= write_in;
              read_out <= curr_data;               -- Also, the cell prepares the value for the read operation

            elsif (write_in < curr_data) then      -- The cell writes the new value and forwards his current one to the next cell
              push_out <= true;
              curr_data <= write_in;
              write_out <= curr_data;
              read_out <= curr_data;              -- Also, the cell prepares the value for the read operation

            else                                  -- Forward the new value to the next cell
              push_out <= true;
              write_out <= write_in;
              read_out <= curr_data;              -- Also, the cell prepares the value for the read operation
              
            end if;

        end if;  

      end if;
    
    end process;

end architecture;

