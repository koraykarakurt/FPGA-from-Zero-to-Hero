---------------------------------------------------------------------------------------------------
-- Author :  Halil Furkan KIMKAK
-- Description : Generic Multiplier Project
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

entity generic_multiplier is
   Generic (    
      MULT_TYPE : boolean               := true; -- when it is true multiplication is signed else unsigned
      MULT_LEN  : integer range 2 to 64  := 16    
   );
   Port (    
      mult_in_1 : in std_logic_vector(MULT_LEN-1 downto 0); -- Input 1
      mult_in_2 : in std_logic_vector(MULT_LEN-1 downto 0); -- Input 2
      mult_out  : out std_logic_vector(2*MULT_LEN-1 downto 0) -- Output
   );
end generic_multiplier;

architecture behavioral of generic_multiplier is
begin   
   signed_mult: if MULT_TYPE = true generate
      mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
   end generate signed_mult;
   
   unsigned_mult: if MULT_TYPE = false generate
      mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
   end generate unsigned_mult;
end behavioral;