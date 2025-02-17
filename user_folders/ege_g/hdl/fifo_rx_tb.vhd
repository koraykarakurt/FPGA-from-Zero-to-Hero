---------------------------------------------------------------------------------------------------
-- Author : Ege ömer Göksu
-- Description : Example code testbench.
-- FIFO generic length, each element is one byte
--   
--   
-- More information (optional) :
--
--    
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use std.env.all; --to stop the simulation

entity fifo_rx_tb is
end fifo_rx_tb;

architecture sim of fifo_rx_tb is

--You cannot pass a signal to an inout variable parameter
procedure check (	expected : in std_logic_vector; 
					actual : in std_logic_vector;
					error_flag : inout std_logic) is
begin
	if (actual /= expected) then
		error_flag := '1';
		report "MISMATCH! expected: " & integer'image(to_integer(unsigned(expected))) 
		& " actual: " & integer'image(to_integer(unsigned(actual))) severity error;
	end if;
end procedure check;

component fifo_rx is
generic(
	fifo_length : integer := 8
);
port(
	clk 		: in std_logic;
	reset 		: in std_logic; --active low
	data_in		: in std_logic_vector(7 downto 0);
	write_en	: in std_logic := '0';
	read_en		: in std_logic := '0';
	full		: out std_logic;
	empty		: out std_logic;
	data_out	: out std_logic_vector (7 downto 0)
);
end component;

signal clk 		: std_logic;
signal reset 	: std_logic; --active low
signal data_in	: std_logic_vector(7 downto 0);
signal write_en	: std_logic;
signal read_en	: std_logic;
signal full		: std_logic;
signal empty	: std_logic;
signal data_out	: std_logic_vector (7 downto 0);
signal error_R	: std_logic := '0'; --Read mismatch error
constant CLK_PERIOD 	: time := 10 ns;
constant FIFO_LENGTH 	: integer := 16;


begin

DUT : fifo_rx 
	generic map(
		fifo_length => FIFO_LENGTH
	)
	port map(
		clk 		=> clk 		,
		reset 	    => reset 	,
		data_in	    => data_in	,
		write_en	=> write_en	,
		read_en	    => read_en	,
		full		=> full		,
		empty	    => empty	,
		data_out	=> data_out	
	);
	
clk_process : process begin
	clk <= '0';
	wait for CLK_PERIOD/2;
	clk <= '1';
	wait for CLK_PERIOD/2;	
end process clk_process;

reset_process : process begin
	reset <= '1';
	wait for 10*CLK_PERIOD;
	reset <= '0';
	wait;
end process reset_process;

write_process : process begin
	data_in <= x"00";
	wait until reset = '0';
	wait until rising_edge(clk);
	for i in 1 to FIFO_LENGTH loop
		write_en 	<= '1';
		data_in 	<= std_logic_vector(to_unsigned(i,8));
		wait until rising_edge(clk);
	end loop;
	write_en 	<= '0'; --write operation is over
	wait;
end process write_process;

read_process : process 
	variable expected	: std_logic_vector(7 downto 0);
	variable error_v	: std_logic := '0';
begin
	wait until reset = '0';
	wait for 5*CLK_PERIOD; --wait a little bit
	read_en 	<= '1';
	wait until rising_edge(clk);
	for i in 1 to FIFO_LENGTH loop
		expected := std_logic_vector(to_unsigned(i,8));
		wait until rising_edge(clk);
		check(expected, data_out, error_v);
	end loop;
	error_R <= error_v;
	read_en <= '0';
	wait until rising_edge(clk);
	assert empty = '1' report "ERROR : FIFO should have been empty!" severity error;
	wait;
end process;

simulation_control : process
begin
	wait for 1000 ns;
	report "Simulation finished after 1000 ns";
	std.env.stop;
	wait;
end process simulation_control;

end sim;