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
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- for arithmetic operations

entity comb_multiplier_mdl is
  generic (
    selectsign_g : std_logic              := '0'; -- '0': unsigned, '1': signed
    bitlength_g  : integer range 0 to 255 := 8 -- define bit length for both inputs as same, the output length will be sum of the input lengths
  );
  port (
    mult_1_i   : in std_logic_vector(bitlength_g - 1 downto 0);
    mult_2_i   : in std_logic_vector(bitlength_g - 1 downto 0);
    multrslt_o : out std_logic_vector((bitlength_g + bitlength_g) - 1 downto 0)
  );
end comb_multiplier_mdl;

architecture behavioral_rtl of comb_multiplier_mdl is

begin

  unsigned_ifgnrt : if selectsign_g = '0' generate -- unsigned
    multrslt_o <= std_logic_vector((unsigned(mult_1_i) * unsigned(mult_2_i)));
  end generate unsigned_ifgnrt;

  signed_ifgnrt : if selectsign_g = '1' generate -- signed
    multrslt_o <= std_logic_vector((signed(mult_1_i) * signed(mult_2_i)));
  end generate signed_ifgnrt;

end behavioral_rtl;
