---------------------------------------------------------------------------------------------------
-- Author : Ege ömer Göksu
-- Description : Example code requested by Koray Karakurt.
-- FIFO generic length and data length
--   
--   
-- More information (optional) :
--    
--     
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity fifo_rx is
generic(
	FIFO_LENGTH : integer := 64;
   DATA_LENGTH : integer := 8
);
port(
	clk 		: in std_logic;
	rst 	   : in std_logic; --active high
	data_in	: in std_logic_vector(DATA_LENGTH-1 downto 0);
	write_en	: in std_logic;
	read_en	: in std_logic;
	full		: out std_logic;
	empty		: out std_logic;
	data_out	: out std_logic_vector (DATA_LENGTH-1 downto 0)
);
end fifo_rx;

architecture logic of fifo_rx is
type mem is array (0 to FIFO_LENGTH-1) of std_logic_vector(DATA_LENGTH-1 downto 0);
signal fifo_buffer 	: mem;
signal write_ptr	   : integer range 0 to FIFO_LENGTH-1 := 0;
signal read_ptr		: integer range 0 to FIFO_LENGTH-1 := 0;
signal fifo_count    : integer range 0 to FIFO_LENGTH   := 0;
signal full_int		: std_logic := '0';
signal empty_int	   : std_logic := '1';
signal data_int      : std_logic_vector (DATA_LENGTH-1 downto 0);

begin
process(clk) begin
	if rising_edge(clk) then
      if (rst = '1') then
			write_ptr 	<= 0;
			read_ptr 	<= 0;
         fifo_count  <= 0;
         data_int    <= (others => '0');
		else				
         --fifo counter (capacity)
         if (write_en = '1' and read_en = '1') then
            if (empty_int = '1') then
               fifo_count  <= fifo_count + 1;
            end if;
            if (full_int = '1') then
               fifo_count  <= fifo_count - 1;
            end if;           
         elsif (write_en = '1' and read_en = '0') then
            if (full_int = '0') then
               fifo_count  <= fifo_count + 1;
            end if;
         elsif (write_en = '0' and read_en = '1') then
            if (empty_int = '0') then
               fifo_count  <= fifo_count - 1;
            end if;
         end if;
         
         --write operation
         if (write_en = '1' and full_int = '0') then
				write_ptr   <= (write_ptr + 1) mod FIFO_LENGTH;	
            fifo_buffer(write_ptr) <= data_in;
			end if;
         
         --read operation
			if (read_en = '1' and empty_int = '0') then
				read_ptr    <= (read_ptr + 1) mod FIFO_LENGTH;
            data_int    <= fifo_buffer(read_ptr);
			end if;
		end if;
	end if;
end process;

process(fifo_count) begin
   if (fifo_count = FIFO_LENGTH) then 
      empty_int   <= '0';
      full_int    <= '1';
   elsif (fifo_count = 0) then
      empty_int   <= '1';
      full_int    <= '0';      
   else
      empty_int   <= '0';
      full_int    <= '0';
   end if;
end process;

process(clk) begin
   if rising_edge(clk) then
      full 	   <= full_int;
      empty    <= empty_int;
      data_out <= data_int;
   end if;
end process;
end logic;
