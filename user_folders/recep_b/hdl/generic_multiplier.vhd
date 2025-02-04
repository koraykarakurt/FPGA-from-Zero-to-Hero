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

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity generic_multiplier is
    generic(
        signed_flag : boolen  := true;  -- false for unsigned, true for signed multiplication
        data_width  : natural := 8   
    );
    port(
        mult_in_1 : in std_logic_vector(vector_size - 1 downto 0);
        mult_in_2 : in std_logic_vector(vector_size - 1 downto 0);
        mult_out  : out std_logic_vector(2 * vector_size - 1 downto 0)
    );
end generic_multiplier;

architecture behavioral of generic_multiplier is
begin
   -- review note, koray_k: use if generate statements
   -- using if-else statement 
   process(mult_in_1, mult_in_2)
   begin
      if signed_flag = 0 then
         -- unsigned multiplication
         mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
      else
         -- signed multiplication
         mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
     end if;
   end process;
end behavioral;