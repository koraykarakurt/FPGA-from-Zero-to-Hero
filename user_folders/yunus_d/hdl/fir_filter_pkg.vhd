library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package fir_filter_pkg is
constant COEFF_WIDTH    : natural := 18;
constant NUMBER_OF_TAP  : integer := 5;
type coefficients is array (0 to NUMBER_OF_TAP - 1) of signed(COEFF_WIDTH-1 downto 0);
constant coefs: coefficients := (
    to_signed(2, COEFF_WIDTH),
    to_signed(3, COEFF_WIDTH),
    to_signed(5, COEFF_WIDTH),
    to_signed(3, COEFF_WIDTH),
    to_signed(2, COEFF_WIDTH)
);
end package;
