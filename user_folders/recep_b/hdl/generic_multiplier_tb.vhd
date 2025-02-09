library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier_tb is
end generic_multiplier_tb;

architecture behavioral of generic_multiplier_tb is
    -- Constants
    constant data_width : natural := 8; -- Input bit width

    -- Signals for the multiplier
    signal mult_in_1_unsigned, mult_in_2_unsigned : std_logic_vector(data_width - 1 downto 0);
    signal mult_out_unsigned : std_logic_vector(2 * data_width - 1 downto 0);

    signal mult_in_1_signed, mult_in_2_signed : std_logic_vector(data_width - 1 downto 0);
    signal mult_out_signed : std_logic_vector(2 * data_width - 1 downto 0);

    -- Error injection signals
    signal inject_error : boolean := false;
    signal expected_unsigned, expected_signed : std_logic_vector(2 * data_width - 1 downto 0);

begin
    -- Instantiate the unsigned multiplier
    uut_unsigned : entity work.generic_multiplier
        generic map (
            signed_flag => false, -- Unsigned multiplication
            data_width  => data_width
        )
        port map (
            mult_in_1 => mult_in_1_unsigned,
            mult_in_2 => mult_in_2_unsigned,
            mult_out  => mult_out_unsigned
        );

    -- Instantiate the signed multiplier
    uut_signed : entity work.generic_multiplier
        generic map (
            signed_flag => true, -- Signed multiplication
            data_width  => data_width
        )
        port map (
            mult_in_1 => mult_in_1_signed,
            mult_in_2 => mult_in_2_signed,
            mult_out  => mult_out_signed
        );

    -- Test process
    process
    begin
        -- Test case 1: Unsigned multiplication
        mult_in_1_unsigned <= std_logic_vector(to_unsigned(10, data_width));
        mult_in_2_unsigned <= std_logic_vector(to_unsigned(5, data_width));
        expected_unsigned <= std_logic_vector(to_unsigned(50, 2 * data_width));
        wait for 10 ns;

        -- Check unsigned result
        assert mult_out_unsigned = expected_unsigned
            report "Unsigned multiplication error: Expected " & to_hstring(expected_unsigned) & ", got " & to_hstring(mult_out_unsigned)
            severity error;

        -- Test case 2: Signed multiplication
        mult_in_1_signed <= std_logic_vector(to_signed(-10, data_width));
        mult_in_2_signed <= std_logic_vector(to_signed(5, data_width));
        expected_signed <= std_logic_vector(to_signed(-50, 2 * data_width));
        wait for 10 ns;

        -- Check signed result
        assert mult_out_signed = expected_signed
            report "Signed multiplication error: Expected " & to_hstring(expected_signed) & ", got " & to_hstring(mult_out_signed)
            severity error;

        -- Test case 3: Error injection (unsigned)
        inject_error <= true;
        mult_in_1_unsigned <= std_logic_vector(to_unsigned(15, data_width));
        mult_in_2_unsigned <= std_logic_vector(to_unsigned(3, data_width));
        expected_unsigned <= std_logic_vector(to_unsigned(45, 2 * data_width));
        wait for 10 ns;

        -- Check unsigned result with error injection
        if inject_error then
            expected_unsigned <= std_logic_vector(to_unsigned(40, 2 * data_width)); -- Incorrect expected value
        end if;

        assert mult_out_unsigned = expected_unsigned
            report "Unsigned multiplication error injection: Expected " & to_hstring(expected_unsigned) & ", got " & to_hstring(mult_out_unsigned)
            severity error;

        -- Test case 4: Error injection (signed)
        mult_in_1_signed <= std_logic_vector(to_signed(-8, data_width));
        mult_in_2_signed <= std_logic_vector(to_signed(4, data_width));
        expected_signed <= std_logic_vector(to_signed(-32, 2 * data_width));
        wait for 10 ns;

        -- Check signed result with error injection
        if inject_error then
            expected_signed <= std_logic_vector(to_signed(-30, 2 * data_width)); -- Incorrect expected value
        end if;

        assert mult_out_signed = expected_signed
            report "Signed multiplication error injection: Expected " & to_hstring(expected_signed) & ", got " & to_hstring(mult_out_signed)
            severity error;

        -- End of simulation
        report "Testbench completed successfully!";
        wait;
    end process;
end behavioral;