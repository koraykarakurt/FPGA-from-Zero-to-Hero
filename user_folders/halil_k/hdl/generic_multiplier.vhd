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

entity firf_1 is
   Generic (    
      SWITCHER        :       boolean                 := true;
      MULT_LEN        :       integer range 1 to 64   := 16
   );
   Port (    
      mult_in_1       :       in      std_logic_vector(MULT_LEN downto 0);      
      mult_in_2       :       in      std_logic_vector(MULT_LEN downto 0);     
      mult_out        :       out     std_logic_vector(2*(MULT_LEN-1) downto 0)     
   );
end firf_1;
architecture Behavioral of firf_1 is
begin
   process(mult_in_1, mult_in_2)
   begin
      if SWITCHER = true then
          mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
      else
          mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
      end if;
   end process;
end Behavioral;