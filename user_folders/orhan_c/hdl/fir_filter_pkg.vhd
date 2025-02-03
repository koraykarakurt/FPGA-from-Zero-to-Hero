library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fir_filter_pkg is
	
	type coefficients is array (16-1 downto 0) of signed(16-1 downto 0);
	constant coeff : coefficients := (
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001"
												);


end fir_filter_pkg;