library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fir_filter_coeff is

  -- Generic Parameters
  constant number_of_taps : integer := 16;    -- Number of filter taps
  constant coeff_width    : integer := 18;   -- Coefficient width (including sign)

  -- Coefficient Type
  type pipeline_coeffs is array (0 to number_of_taps-1) of signed(coeff_width-1 downto 0);
  
  -- Coefficient Values
--  constant coeff_pipe : pipeline_coeffs := (
--    "00" & x"0001", 
--    "00" & x"0002", 
--    "00" & x"0003", 
--    "00" & x"0004",
--    "00" & x"0005",
--    "00" & x"0006",
--    "00" & x"0007",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003",
--    "00" & x"0003"
--  );

end fir_filter_coeff;
