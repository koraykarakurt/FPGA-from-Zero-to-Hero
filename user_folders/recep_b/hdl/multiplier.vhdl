----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Recep Büyüktuncer
-- 
-- Create Date: 01/31/2025 08:16:06 PM
-- Design Name: 
-- Module Name: multiplier - Behavioral
-- Project Name: Multiplier 2x1 Design
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


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity generic_multiplier is
    generic(
        signed_flag  : integer := 0;  -- 0 for unsigned, 1 for signed multiplication
        vector_size  : integer := 8   
    );
    port(
        mult_1  : in std_logic_vector(vector_size - 1 downto 0);
        mult_2  : in std_logic_vector(vector_size - 1 downto 0);
        mult_o  : out std_logic_vector(2 * vector_size - 1 downto 0)
    );
end generic_multiplier;

architecture behavioral of generic_multiplier is
begin
    -- Using if-else statement 
    process(mult_1, mult_2)
    begin
        if signed_flag = 0 then
            -- Unsigned multiplication
            mult_o <= std_logic_vector(unsigned(mult_1) * unsigned(mult_2));
        else
            -- Signed multiplication
            mult_o <= std_logic_vector(signed(mult_1) * signed(mult_2));
        end if;
    end process;
end behavioral;