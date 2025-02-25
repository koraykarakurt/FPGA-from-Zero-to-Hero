---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : Transposed FIR Filter package file that contains filter coefficients
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

package gfir_transposed_pkg is 

   -- constants 
   constant filter_taps   : integer range 0 to 20 :=  5; -- filter order
   constant coeff_len     : integer range 0 to 18 := 16; -- filter coefficient length 
   
   -- types
   -- Transposed FIR Filter coeff. type decleration
   type coefficients      is array (0 to filter_taps - 1) of signed(coeff_len - 1             downto 0);

   -- type related constants
   -- Transposed FIR Filter coeff. 
   constant filter_coeff : coefficients := (
      x"0001", x"0002", x"0003", x"0004", x"0005" 
   );

end package gfir_transposed_pkg;