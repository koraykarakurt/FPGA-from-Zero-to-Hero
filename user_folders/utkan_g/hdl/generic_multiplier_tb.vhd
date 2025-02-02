library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_multiplier_tb is
end entity;

architecture testbench of generic_multiplier_tb is
    -- 8-bit unsigned multiplier signals
    signal mult_1_8bit_u    : std_logic_vector(7 downto 0);
    signal mult_2_8bit_u    : std_logic_vector(7 downto 0);
    signal mult_out_8bit_u    : std_logic_vector(15 downto 0);
    
    -- 8-bit signed multiplier signals
    signal mult_1_8bit_s    : std_logic_vector(7 downto 0);
    signal mult_2_8bit_s    : std_logic_vector(7 downto 0);
    signal mult_out_8bit_s    : std_logic_vector(15 downto 0);
    
    -- 16-bit unsigned multiplier signals
    signal mult_1_16bit_u   : std_logic_vector(15 downto 0);
    signal mult_2_16bit_u   : std_logic_vector(15 downto 0);
    signal mult_out_16bit_u   : std_logic_vector(31 downto 0);

begin
    -- 8-bit unsigned multiplier instance
    mult_8bit_unsigned: entity work.generic_multiplier
        generic map (
            MULTIPLIER_TYPE => 0,  -- unsigned
            VECTOR_SIZE    => 8
        )
        port map (
            mult_1 => mult_1_8bit_u,
            mult_2 => mult_2_8bit_u,
            mult_out => mult_out_8bit_u
        );

    -- 8-bit signed multiplier instance
    mult_8bit_signed: entity work.generic_multiplier
        generic map (
            MULTIPLIER_TYPE => 1,  -- signed
            VECTOR_SIZE    => 8
        )
        port map (
            mult_1 => mult_1_8bit_s,
            mult_2 => mult_2_8bit_s,
            mult_out => mult_out_8bit_s
        );

    -- 16-bit unsigned multiplier instance
    mult_16bit_unsigned: entity work.generic_multiplier
        generic map (
            MULTIPLIER_TYPE => 0,  -- unsigned
            VECTOR_SIZE    => 16
        )
        port map (
            mult_1 => mult_1_16bit_u,
            mult_2 => mult_2_16bit_u,
            mult_out => mult_out_16bit_u
        );

    -- Test process
    test_proc: process
    begin
    
        -- 8-bit unsigned test
        mult_1_8bit_u <= x"0A";  -- 10
        mult_2_8bit_u <= x"0B";  -- 11
        wait for 10 ns;
        if unsigned(mult_out_8bit_u) = 110 then
            report "PASS: 8-bit unsigned test";
        else
            assert false report "FAIL: 8-bit unsigned test failed" severity error;
        end if;


        -- 8-bit signed test
        mult_1_8bit_s <= x"FA";  -- -6
        mult_2_8bit_s <= x"03";  -- 3
        wait for 10 ns;
         if signed(mult_out_8bit_s) = -18 then
            report "PASS: 8-bit signed test";
        else
            assert false report "FAIL: 8-bit signed test failed" severity error;
        end if;

        -- 16-bit unsigned test
        mult_1_16bit_u <= x"00FF";  -- 255
        mult_2_16bit_u <= x"0002";  -- 2
        wait for 10 ns;
        if unsigned(mult_out_16bit_u) = 511 then
            report "PASS: 16-bit unsigned test";
        else
            assert false report "FAIL: 16-bit unsigned test failed" severity error;
        end if;

        report "All tests completed.";
        wait;
    end process;

end architecture;
