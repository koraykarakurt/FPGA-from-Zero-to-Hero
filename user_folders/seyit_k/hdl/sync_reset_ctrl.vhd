---------------------------------------------------------------------------------------------------
-- Author : Seyit Kadir Kocak
-- Description : 
--   This module synchronizes the input data (data_in) with the clock signal (clk) and resets the output data (data_out)
--   based on the state of the discrete_data signal. The discrete_data signal is processed with a 3-clock cycle delay,
--   and when the discrete_clk_d3 signal is '1', the output data is reset to zero. Additionally, the module can be
--   asynchronously reset using a reset signal.
-- More information (optional) :
--    Asynchronous reset: When the reset signal is active, the circuit is reset immediately without waiting for the clock signal.
--    Synchronous reset: The reset signal takes effect only on the rising edge of the clock signal and resets the circuit.
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.ALL;

entity local_reset is	
   port (
	clk     		: in  std_logic;
	discrete_data 	: in  std_logic;
	data_in 		: in  std_logic_vector(7 downto 0);
	data_out 		: out std_logic_vector(7 downto 0)
   );	
end local_reset;
architecture behavioral of local_reset is
   signal discrete_clk_d1	: std_logic;
   signal discrete_clk_d2	: std_logic;
   signal discrete_clk_d3	: std_logic;
   signal data_reg 			: std_logic_vector(7 downto 0);
begin
   process(clk)
   begin          
      if rising_edge(clk) then
		discrete_clk_d1 	<= discrete_data;
		discrete_clk_d2 	<= discrete_clk_d1;
		discrete_clk_d3 	<= discrete_clk_d2;
	  end if;
   end process;
   process(clk)
   begin          
       if rising_edge(clk) then
           if discrete_clk_d3 = '1' then
               data_reg  	<= (others => '0');
           else
               data_reg 	<= data_in;
           end if;
       end if;
   end process;
   data_out 				<= data_reg;
end behavioral;
