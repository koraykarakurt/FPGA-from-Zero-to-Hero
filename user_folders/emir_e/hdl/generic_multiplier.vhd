----------------------------------------------------------------------------------
-- Company: FalsePaths
-- Engineer: Emir EROL
-- 
-- Create Date: 01/23/2025 04:54:56 PM
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
    	sign : integer := 0;  -- 0: unsigned, 1: signed
        size : integer := 8);
    
    port(	
    	mult_1 : in  std_logic_vector(size-1 downto 0);
        mult_2 : in  std_logic_vector(size-1 downto 0);
        mult_o : out std_logic_vector(2*size-1 downto 0));
            
end generic_multiplier;


architecture behavioral_rtl of generic_multiplier is
begin

	process(mult_1, mult_2)
    begin
    
    	if sign = 1 then
    		mult_o <= std_logic_vector(signed(mult_1) * signed(mult_2));
        
    	else
    		mult_o <= std_logic_vector(unsigned(mult_1) * unsigned(mult_2));
        
        end if;
	end process;        
end behavioral_rtl;
