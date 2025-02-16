---------------------------------------------------------------------------------------------------
-- Author : Ege ömer Göksu
-- Description : Example code requested by Koray Karakurt.
-- FIFO generic length, each element is one byte
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
	fifo_length : integer := 8
);
port(
	clk 		: in std_logic;
	reset 	: in std_logic; --active low
	data_in	: in std_logic_vector(7 downto 0);
	write_en	: in std_logic;
	read_en	: in std_logic;
	full		: out std_logic;
	empty		: out std_logic;
	data_out	: out std_logic_vector (7 downto 0)
);
end fifo_rx;

architecture logic of fifo_rx is

type mem is array (0 to fifo_length-1) of std_logic_vector(7 downto 0);
signal fifo_buffer 	: mem;
signal write_ptr	: integer range 0 to fifo_length-1 := 0;
signal read_ptr		: integer range 0 to fifo_length-1 := 0;
signal full_int		: std_logic := '0';
signal empty_int	: std_logic := '1';

begin

process(clk) begin
	if rising_edge(clk) then
		if (reset = '1') then
			for i in 0 to fifo_length-1 loop
				fifo_buffer(i) 	<= (others => '0');
			end loop;
			write_ptr 	<= 0;
			read_ptr 	<= 0;
			data_out 	<= fifo_buffer(0);
			empty_int 	<= '1';
			full_int 	<= '0';
		else
			if (write_en = '1' and read_en = '1') then
				if (full_int = '0' and empty_int = '0') then
					fifo_buffer(write_ptr) 	<= data_in;
					write_ptr 				<= (write_ptr + 1) mod fifo_length;	
					data_out 				<= fifo_buffer(read_ptr);
					read_ptr 				<= (read_ptr + 1) mod fifo_length;
				elsif (full_int = '0') then --it means empty_int = '1' and we can't do read operation regardless of read_en (fifo is empty)
					fifo_buffer(write_ptr) 	<= data_in;
					write_ptr 				<= (write_ptr + 1) mod fifo_length;	
					empty_int 				<= '0'; --no longer empty since we just did a write operation
					
				elsif (empty_int = '0') then --it means full_int = '1' and we can't do write operation regardless of write_en
					data_out <= fifo_buffer(read_ptr);
					read_ptr <= (read_ptr + 1) mod fifo_length;
					full_int <= '0';
				end if;
				
			elsif (write_en = '1' and full_int = '0') then --it means read_en = '0' and the fifo is not full
				fifo_buffer(write_ptr) 	<= data_in;
				write_ptr 				<= (write_ptr + 1) mod fifo_length;	
				empty_int 				<= '0';
				if (((write_ptr + 1) mod fifo_length) = read_ptr) then --it is full when write_ptr catches up with read_ptr
					full_int <= '1';
				end if;
			elsif (read_en = '1' and empty_int = '0') then --it means write_en = '0' and the fifo is not empty
				data_out <= fifo_buffer(read_ptr);
				read_ptr <= (read_ptr + 1) mod fifo_length;
				full_int <= '0';
				if (((read_ptr + 1) mod fifo_length) = write_ptr) then --it is empty when read_ptr catches up with write_ptr
					empty_int <= '1';
				end if;
			end if;
			
		end if;
	end if;
end process;

full 	<= full_int;
empty 	<= empty_int;

end logic;