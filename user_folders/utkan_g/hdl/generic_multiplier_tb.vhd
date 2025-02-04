library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_multiplier_tb is
end entity;

architecture testbench of generic_multiplier_tb is
    -- 8-bit unsigned multiplier signals
    signal mult_1_8bit_u    : std_logic_vector(7 downto 0) := (others => '0');
    signal mult_2_8bit_u    : std_logic_vector(7 downto 0) := (others => '0');
    signal mult_out_8bit_u    : std_logic_vector(15 downto 0);
    
    -- 8-bit signed multiplier signals
    signal mult_1_8bit_s    : std_logic_vector(7 downto 0) := (others => '0');
    signal mult_2_8bit_s    : std_logic_vector(7 downto 0) := (others => '0');
    signal mult_out_8bit_s    : std_logic_vector(15 downto 0) := (others => '0');
    
    -- 16-bit unsigned multiplier signals
    signal mult_1_16bit_u   : std_logic_vector(15 downto 0) := (others => '0');
    signal mult_2_16bit_u   : std_logic_vector(15 downto 0) := (others => '0');
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
    -- 8-bit Unsigned Test Process
    test_proc_unsigned: process
    begin
        report "Testing 8-bit unsigned multiplier...";
        mult_1_8bit_u <= x"0A";
        mult_2_8bit_u <= x"0B";
        wait for 10 ns;
        assert unsigned(mult_out_8bit_u) = 110
            report "8-bit unsigned test failed"
            severity error;
        report "PASS: 8-bit unsigned multiplier test.";
        wait;
    end process;

    -- 8-bit Signed Test Process
    test_proc_signed: process
    begin
        report "Testing 8-bit signed multiplier...";
        mult_1_8bit_s <= x"FA";
        mult_2_8bit_s <= x"03";
        wait for 10 ns;
        assert signed(mult_out_8bit_s) = -18
            report "8-bit signed test failed"
            severity error;
        report "PASS: 8-bit signed multiplier test.";
        wait;
    end process;
    
    -- 16-bit Unsigned Test Process
    test_proc_16unsigned: process
    begin
        report "Testing 16-bit unsigned multiplier...";
        mult_1_16bit_u <= x"00FF";
        mult_2_16bit_u <= x"0002";
        wait for 10 ns;
        assert unsigned(mult_out_16bit_u) = 510
            report "16-bit unsigned test failed"
            severity error;
        report "PASS: 16-bit unsigned multiplier test.";
        wait;
    end process;

end architecture;
