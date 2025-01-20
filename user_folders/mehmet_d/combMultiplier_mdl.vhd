--------------------------------------------------------------------------------------------------
-- Company: False Paths --> https://www.youtube.com/@falsepaths
-- Project: Generic FIR Filter Design and Verification
-- Engineer: Mehmet Demir
-- 
-- Design Name: Combinational Multiplier
-- VHDL Revision: VHDL-2002
-- Target Devices: NA
-- Tool Versions: NA
-- Dependencies: NA
-- Description: Combinational multiplier module with signed/unsigned and bit length generics.
-- 
-- Revision --> 01v00; Date --> 20.01.25; JIRA No --> FIRF-9; Reason --> First Release
-- 
--------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all; -- for arithmetic operations

entity combMultiplier_mdl is
  generic (
    selectSign_g : std_logic              := '0'; -- '0': unsigned, '1': signed
    bitLength_g  : integer range 0 to 255 := 8 -- define bit length for both inputs as same, the output length will be sum of the input lengths
  );
  port (
    mult_1_i   : in std_logic_vector(bitLength_g - 1 downto 0);
    mult_2_i   : in std_logic_vector(bitLength_g - 1 downto 0);
    multRslt_o : out std_logic_vector((bitLength_g + bitLength_g) - 1 downto 0)
  );
end combMultiplier_mdl;

architecture behavioral_rtl of combMultiplier_mdl is

begin

  unsigned_ifGnrt : if selectSign_g = '0' generate -- unsigned
    multRslt_o <= std_logic_vector((unsigned(mult_1_i) * unsigned(mult_2_i)));
  end generate unsigned_ifGnrt;

  signed_ifGnrt : if selectSign_g = '1' generate -- signed
    multRslt_o <= std_logic_vector((signed(mult_1_i) * signed(mult_2_i)));
  end generate signed_ifGnrt;

end behavioral_rtl;
