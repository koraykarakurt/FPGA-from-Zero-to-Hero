----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02.02.2025 09:52:05
-- Design Name: 
-- Module Name: firf_1 - Behavioral
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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity firf_1 is
    Generic (
    
        switcher        :       boolean                 := true;
        mult_len        :       integer range 0 to 31   := 31
    
    );

    Port (
    
        mult_in_1       :       in      std_logic_vector((mult_len-1)/2 downto 0);      
        mult_in_2       :       in      std_logic_vector((mult_len-1)/2 downto 0);     
        mult_out        :       out     std_logic_vector(mult_len downto 0) 
    
    );
end firf_1;

architecture Behavioral of firf_1 is

begin
    process(mult_in_1, mult_in_2)
    begin
        if switcher = true then
            mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
        else
            mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
        end if;
    end process;
end Behavioral;
