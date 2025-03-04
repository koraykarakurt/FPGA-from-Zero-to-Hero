---------------------------------------------------------------------------------------------------
-- Author : Yunus Dag	
-- Description : Transposed FIR filter testbench
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.fir_filter_pkg.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture Behavioral of fir_filter_tb is

-- Signals
signal clk       	: std_logic := '0';
signal rst       	: std_logic := '1'; -- Start with reset active

signal data_out  	: std_logic_vector(OUTPUT_WIDTH -1 downto 0);
signal valid_in  	: std_logic := '0';
signal valid_out 	: std_logic;
signal data_in    : std_logic_vector(INPUT_WIDTH-1 downto 0);

begin
-- Clock Process
clk_process: process
begin
	clk <= '0';
	wait for CLK_PERIOD / 2;
	clk <= '1';
	wait for CLK_PERIOD / 2;
end process;

-- Process to Feed Inputs and Check Result
process begin

	rst <= '1';
	wait for 2 * CLK_PERIOD;
	rst <= '0';
	wait for 2 * CLK_PERIOD;
	
	valid_in <= '1';
	for i in 0 to NUMBER_OF_TAPS -1 loop
		data_in <= std_logic_vector(to_signed((i+1)*2, INPUT_WIDTH));
		wait for CLK_PERIOD;
	end loop;
	valid_in <= '0';
	wait for 5 * CLK_PERIOD;
	report "Simulation Successful!" severity failure;
	
end process;

-- Instantiate the FIR filter
uut: entity workfir_filter_wrapper
   generic map (
      INPUT_WIDTH    => INPUT_WIDTH,
      OUTPUT_WIDTH   => OUTPUT_WIDTH,
      COEFF_WIDTH    => COEFF_WIDTH,
      NUMBER_OF_TAPS => NUMBER_OF_TAPS
   )
port map (
	clk         => clk,
	rst         => rst,
	valid_in    => valid_in,
	data_in     => data_in,
	data_out    => data_out,
	valid_out   => valid_out
);

end behavioral;