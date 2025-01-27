--------------------------------------------------------------------------------------------------
-- Company  : False Paths --> https://www.youtube.com/@falsepaths
-- Project  : Generic FIR Filter Design and Verification
-- Engineer : Mehmet Demir
-- 
-- Design Name    : Combinational Multiplier
-- VHDL Revision  : VHDL-2002
-- Target Devices : NA
-- Tool Versions  : NA
-- Dependencies   : NA
-- Description    : Combinational multiplier module with signed/unsigned and bit length generics.
-- 
-- Revision --> 01v00; Date --> 28.01.25; JIRA No --> FIRF-9; Reason --> First Release
-- 
--------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- for arithmetic operations

entity comb_multiplier is
   generic (
      select_sign : std_logic              := '0'; -- '0': unsigned, '1': signed
      bit_length  : natural range 2 to 255 := 8 -- define bit length for both inputs as same, the output length will be sum of the input lengths. Min value must be 2.
   );
   port (
      mult_1    : in std_logic_vector(bit_length - 1 downto 0)                 := (others => '0');
      mult_2    : in std_logic_vector(bit_length - 1 downto 0)                 := (others => '0');
      mult_rslt : out std_logic_vector((bit_length + bit_length) - 1 downto 0) := (others => '0')
   );
end comb_multiplier;

architecture behavioral_rtl of comb_multiplier is

begin

   unsigned_if_gnrt : if select_sign = '0' generate -- unsigned
      mult_rslt <= std_logic_vector((unsigned(mult_1) * unsigned(mult_2)));
   end generate unsigned_if_gnrt;

   signed_if_gnrt : if select_sign = '1' generate -- signed
      mult_rslt <= std_logic_vector((signed(mult_1) * signed(mult_2)));
   end generate signed_if_gnrt;

end behavioral_rtl;
-- /* The End */ --