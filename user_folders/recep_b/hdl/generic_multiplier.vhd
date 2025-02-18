----------------------------------------------------------------------------------
-- Author : Recep Buyuktuncer
-- Description : Generic Multiplier 2x1 Design
--
--
--
-- More information (optional) :
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity generic_multiplier is
    generic(
        SIGNED_FLAG : boolean := true;  -- false for unsigned, true for signed multiplication
        DATA_WIDTH  : natural := 8      -- input bit width
    );
    port(
        mult_in_1 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        mult_in_2 : in std_logic_vector(DATA_WIDTH - 1 downto 0);
        mult_out  : out std_logic_vector(2 * DATA_WIDTH - 1 downto 0)
    );
end generic_multiplier;

architecture behavioral of generic_multiplier is
 -- review note, koray_k: use if generate statements
begin
    -- Generate block for unsigned multiplication
    unsigned_if_gnrt : if SIGNED_FLAG = false generate
        mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
    end generate unsigned_if_gnrt;

    -- Generate block for signed multiplication
    signed_if_gnrt : if SIGNED_FLAG = true generate
        mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
    end generate signed_if_gnrt;

end behavioral;
