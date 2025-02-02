library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_multiplier is
    generic (
        MULTIPLIER_TYPE : integer range 0 to 1 := 0; -- 0 for unsigned, 1 for signed
        VECTOR_SIZE     : integer range 1 to 64 := 8  -- Width of the inputs
    );
    port (
        mult_1 : in  std_logic_vector(VECTOR_SIZE-1 downto 0);
        mult_2 : in  std_logic_vector(VECTOR_SIZE-1 downto 0);
        mult_out : out std_logic_vector(2*VECTOR_SIZE-1 downto 0)
    );
end entity;

architecture behavioral of generic_multiplier is
begin
    process(mult_1, mult_2)
        variable signed_result : signed(2*VECTOR_SIZE-1 downto 0);
        variable unsigned_result : unsigned(2*VECTOR_SIZE-1 downto 0);
    begin
        if MULTIPLIER_TYPE = 0 then
            unsigned_result := resize(unsigned(mult_1) * unsigned(mult_2), 2*VECTOR_SIZE);
            mult_out <= std_logic_vector(unsigned_result);
        else
            signed_result := resize(signed(mult_1) * signed(mult_2), 2*VECTOR_SIZE);
            mult_out <= std_logic_vector(signed_result);
        end if;
    end process;
end architecture;
