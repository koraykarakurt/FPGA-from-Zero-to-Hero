library IEEE;
use IEEE.std_logic_1164.all;

package multiplier_constants_pkg is
    -- Test configuration constants
    constant MULT_LEN      : integer := 16;    -- Multiplier length
    constant CLK_PERIOD    : time := 10 ns;    -- Clock period
    constant NUM_TESTS     : integer := 100;   -- Number of test iterations
    
    -- Error injection constants
    constant DEFAULT_ERROR_TEST    : integer := 50;
    constant ERROR_TYPE_SIGNED     : integer := 0;
    constant ERROR_TYPE_UNSIGNED   : integer := 1;
end package multiplier_constants_pkg; 