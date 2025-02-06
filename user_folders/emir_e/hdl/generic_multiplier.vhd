----------------------------------------------------------------------------------
-- Company: FalsePaths
-- Engineer: Emir EROL
-- 
-- Create Date: 02/03/2025
-- Design Name: 
-- Module Name: generic_multiplier - Behavioral_rtl
-- Project Name: Generic Multiplier
-- JIRA No: FIRF-11;
-- Target Devices: Kria KV260
-- Tool Versions: VHDL2002
-- Description: Generic multiplier module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier is

	generic(
    	sign : boolean := false; 
        size : integer := 8);
    
    port(	
    	mult_1 : in  std_logic_vector(size-1 downto 0);
        mult_2 : in  std_logic_vector(size-1 downto 0);
        mult_o : out std_logic_vector(2*size-1 downto 0));
            
end generic_multiplier;


architecture behavioral_rtl of generic_multiplier is
begin

	signed_gen : if(sign) generate
    		mult_o <= std_logic_vector(signed(mult_1) * signed(mult_2));
	end generate;
			
    unsigned_gen : if(not sign) generate
    		mult_o <= std_logic_vector(unsigned(mult_1) * unsigned(mult_2));
	end generate;    
          
end behavioral_rtl;
