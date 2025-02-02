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
    GEN_UNSIGNED: if MULTIPLIER_TYPE = 0 generate
        signal result_u : unsigned(2*VECTOR_SIZE-1 downto 0);
    begin
        result_u <= resize(unsigned(mult_1) * unsigned(mult_2), 2*VECTOR_SIZE);
        mult_out <= std_logic_vector(result_u);
    end generate;

    GEN_SIGNED: if MULTIPLIER_TYPE /= 0 generate
        signal result_s : signed(2*VECTOR_SIZE-1 downto 0);
    begin
        result_s <= resize(signed(mult_1) * signed(mult_2), 2*VECTOR_SIZE);
        mult_out <= std_logic_vector(result_s);
    end generate;
end architecture;
