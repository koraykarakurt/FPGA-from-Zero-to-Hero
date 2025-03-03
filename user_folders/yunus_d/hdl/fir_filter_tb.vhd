library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture Behavioral of fir_filter_tb is

component fir_filter_wrapper is
generic(
INPUT_WIDTH    : natural := 25;
OUTPUT_WIDTH   : natural := 48
);
Port(
clk		: in std_logic;
rst		: in std_logic;
valid_in : in std_logic;
data_in  : in std_logic_vector(INPUT_WIDTH-1 downto 0);
data_out : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
valid_out: out std_logic
);
end component;

constant clk_period       : time := 10 ns;
constant NUMBER_OF_TAP    : integer := 5;
constant COEFF_WIDTH      : natural := 18;
constant INPUT_WIDTH      : natural := 25;
constant OUTPUT_WIDTH     : natural := 48;

signal clk       	: std_logic := '0';
signal rst       	: std_logic := '1'; 
signal data_out  	: std_logic_vector(OUTPUT_WIDTH -1 downto 0);
signal valid_in  	: std_logic := '0';
signal valid_out 	: std_logic;
signal data_in    : std_logic_vector(INPUT_WIDTH-1 downto 0);
begin

clk_process: process
begin
	clk <= '0';
	wait for clk_period / 2;
	clk <= '1';
	wait for clk_period / 2;
end process;

process begin

	rst <= '1';
	wait for 2 * clk_period;
	rst <= '0';
	wait for 2 * clk_period;
	
	valid_in <= '1';
	for i in 0 to NUMBER_OF_TAP -1 loop
		data_in <= std_logic_vector(to_signed((i+1)*2, INPUT_WIDTH));
		wait for clk_period;
	end loop;
	valid_in <= '0';
	wait for 5 * clk_period;
	report "Simulation Successful!" severity failure;
	
end process;

uut: fir_filter_wrapper
generic map (
	INPUT_WIDTH    => INPUT_WIDTH,
	OUTPUT_WIDTH   => OUTPUT_WIDTH
)
port map (
	clk         => clk,
	rst         => rst,
	valid_in    => valid_in,
	data_in     => data_in,
	data_out    => data_out,
	valid_out   => valid_out
);

end Behavioral;
