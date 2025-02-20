library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_filter_wrapper is
generic(
	INPUT_WIDTH    : natural := 25;
	OUTPUT_WIDTH   : natural := 48
);
Port(
	clk      	: in std_logic;
	rst        : in std_logic;
	valid_in   : in std_logic;
	data_in    : in std_logic_vector(INPUT_WIDTH-1 downto 0);
	data_out   : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
	valid_out	: out std_logic
);
end fir_filter_wrapper;

architecture Behavioral of fir_filter_wrapper is
component fir_filter is
	generic(
		INPUT_WIDTH    : natural := 25;
		OUTPUT_WIDTH   : natural := 48
	);
	Port(
		clk         : in std_logic;
		rst         : in std_logic;
		valid_in    : in std_logic;
		data_in     : in std_logic_vector(INPUT_WIDTH-1 downto 0);
		data_out    : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
		valid_out   : out std_logic
	);
end component;

signal rst_wr 		: std_logic := '0';
signal data_in_wr 	: std_logic_vector(INPUT_WIDTH-1 downto 0) := (others=>'0');
signal valid_in_wr 	: std_logic := '0';
signal data_out_wr	: std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others=>'0');
signal valid_out_wr 	: std_logic := '0';

begin
data_out <= data_out_wr;
valid_out <= valid_out_wr;

	process(clk) begin
		if(rising_edge(clk)) then
			rst_wr <= rst;
			data_in_wr <= data_in;
			valid_in_wr <= valid_in;
		end if;
	end process;

	wrapper: fir_filter
	generic map (
		INPUT_WIDTH    => INPUT_WIDTH,
		OUTPUT_WIDTH   => OUTPUT_WIDTH
	)
	port map (
		clk         => clk,
		rst         => rst_wr,
		valid_in    => valid_in_wr,
		data_in     => data_in_wr,
		data_out    => data_out_wr,
		valid_out   => valid_out_wr
	);


end Behavioral;