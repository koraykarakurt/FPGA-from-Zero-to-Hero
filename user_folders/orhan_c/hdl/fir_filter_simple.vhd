----------------------------------------------------------------------------------------------------------------------------
-- Author : Orhan Çalışkan
-- Description : 
-- 
-- 
-- 
-- 
-- More information (optional) :
-- 
--  
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity direct_form_fir_filter is

	generic
	(
      filter_taps 	: natural 					:= 16	;
		data_width		: natural 					:= 16	;
		coeff_width		: natural 					:= 16	
	);
   
	port
	(
	  	clk 					: in std_logic;
		rst 					: in std_logic;
		
		data_in 				: in std_logic_vector(data_width-1 downto 0);
		valid_in				: in std_logic;
		
		data_out			 	: out std_logic_vector(data_width + coeff_width-1 downto 0);
		valid_out			: out std_logic
	);

end entity;

