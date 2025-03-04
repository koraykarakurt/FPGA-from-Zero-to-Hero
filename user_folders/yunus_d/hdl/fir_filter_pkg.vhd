library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fir_filter_pkg is

-- Constants
constant CLK_PERIOD     : time := 10 ns;
constant INPUT_WIDTH    : natural := 25;
constant OUTPUT_WIDTH   : natural := 48;
constant COEFF_WIDTH    : natural := 18;
constant NUMBER_OF_TAPS : natural := 5;

type COEFS_TYPE is array (0 to NUMBER_OF_TAPS - 1) of signed(COEFF_WIDTH-1 downto 0);

constant COEFFICIENTS: COEFS_TYPE := (
    to_signed(2, COEFF_WIDTH),
    to_signed(3, COEFF_WIDTH),
    to_signed(5, COEFF_WIDTH),
    to_signed(3, COEFF_WIDTH),
    to_signed(2, COEFF_WIDTH)
);

end package;