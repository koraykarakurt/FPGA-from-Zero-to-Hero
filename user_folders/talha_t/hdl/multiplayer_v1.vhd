----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.02.2025 14:46:37
-- Design Name: 
-- Module Name: multiplayer_v1 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity multiplayer_v1 is
    generic(
        multi_type : STD_LOGIC := '0';
        sizes_of_multiplier : integer := 8
    );
    Port ( 
        mult_1  : in STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
        mult_2  : in STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
        mult_o  : out STD_LOGIC_VECTOR ((sizes_of_multiplier*2)-1 downto 0)
		
    );
end multiplayer_v1;

architecture Behavioral of multiplayer_v1 is

attribute USE_DSP : string;
attribute USE_DSP of mult_o : signal is "yes"; 
  


begin

    mult_Unsigned_generator: if multi_type = '0' generate
		 mult_o <= STD_LOGIC_VECTOR(Unsigned(mult_1) * Unsigned(mult_2));

    end generate mult_Unsigned_generator;
    
    mult_Signed_generator: if multi_type = '1' generate
         mult_o <= STD_LOGIC_VECTOR(Signed(mult_1) * Signed(mult_2));

	
    end generate mult_Signed_generator;

end Behavioral;
