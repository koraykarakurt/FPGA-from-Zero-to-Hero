-- to have 2 generics, 1st generic (std_logic if '0' unsigned else signed) is for signed or unsigned multiplication, 2nd generic is for vector sizes of multipliers (mult_1, mult_2 both are std_logic_vectors)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier is
    generic (
        is_signed : std_logic := '0'; 
        data_width : integer := 32    
    );
    port (
        mult_1       : in  std_logic_vector(data_width-1 downto 0);
        mult_2       : in  std_logic_vector(data_width-1 downto 0);
        output_mult  : out std_logic_vector(2*data_width-1 downto 0)
    );
end entity generic_multiplier;

architecture behavioral of generic_multiplier is
    signal mult_internal : signed(2*data_width-1 downto 0);
begin
    process(mult_1, mult_2)
    begin
        if is_signed = '1' then
            -- Signed multiplication
            mult_internal <= signed(resize(signed(mult_1), 2*data_width)) * 
                             signed(resize(signed(mult_2), 2*data_width));
        else
            -- Unsigned multiplication
            mult_internal <= signed(resize(unsigned(mult_1), 2*data_width)) * 
                             signed(resize(unsigned(mult_2), 2*data_width));
        end if;
        -- Convert back to std_logic_vector
        output_mult <= std_logic_vector(mult_internal);
    end process;
end architecture behavioral;
