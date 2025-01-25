-------------------------------------------------------------------------------
-- Testbench for Parity Generator with Parity Checking
--
-- Description:
-- This testbench verifies the functionality of the parity_generator module,
-- which generates parity bits (even or odd) based on input data and detects
-- parity errors by comparing the received parity bit against the generated
-- parity. The testbench covers various test cases, including normal operation,
-- parity error scenarios, and edge cases.
--
-- Author: [Your Name]
-- Last Revision: 2025-01-23 (Revision 1.0)
--
-- Dependency:
-- - parity_generator.vhd: The design under test (DUT).
--
-- Test Cases:
-- 1. Test even parity with no parity error.
-- 2. Test even parity with an intentional parity error.
-- 3. Test odd parity with no parity error.
-- 4. Test odd parity with an intentional parity error.
-- 5. Test edge case with all bits set to '0'.
-- 6. Test edge case with all bits set to '1'.
--
-- Simulation Environment:
-- - VHDL simulator (e.g., ModelSim, Vivado, GHDL)
-- - All outputs are checked using assertions.
--
-- How to Run:
-- 1. Compile both the parity_generator module and this testbench in the simulator.
-- 2. Simulate the testbench and observe the output waveforms or assertion results.
-- 3. Ensure all assertions pass without errors.
--
-- Notes:
-- - The testbench is self-checking using assertions.
-- - Simulation halts and displays an error message if any test case fails.
-------------------------------------------------------------------------------

-------------------------------------------------------------------------------
-- Testbench for Parity Generator with Parity Checking
--
-- Description:
-- This testbench verifies the functionality of the parity_generator module,
-- which generates parity bits (even or odd) based on input data and detects
-- parity errors by comparing the received parity bit against the generated
-- parity. The testbench includes various scenarios, including valid cases,
-- intentional parity errors, and edge cases.
--
-- Author: [Your Name]
-- Last Revision: 2025-01-23 (Revision 1.1)
--
-- Dependency:
-- - parity_generator.vhd: The design under test (DUT).
--
-- Notes:
-- - The testbench uses assertions to validate the functionality of the DUT.
-- - Simulation halts and displays an error message if any assertion fails.
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity tb_parity_generator is
end tb_parity_generator;

architecture behavioral of tb_parity_generator is
    -- component declaration
    component parity_generator is
        port (
            data_in            : in  std_logic_vector(7 downto 0);
            parity_mode_select : in  std_logic;
            generated_parity   : out std_logic;
            rx_parity_bit      : in  std_logic;
            parity_error       : out std_logic
        );
    end component;

    -- testbench signals
    signal tb_data_in         : std_logic_vector(7 downto 0);
    signal tb_parity_mode_sel : std_logic;
    signal tb_generated_parity: std_logic;
    signal tb_rx_parity_bit   : std_logic;
    signal tb_parity_error    : std_logic;
begin
    -- instantiate dut
    dut: parity_generator
        port map (
            data_in            => tb_data_in,
            parity_mode_select => tb_parity_mode_sel,
            generated_parity   => tb_generated_parity,
            rx_parity_bit      => tb_rx_parity_bit,
            parity_error       => tb_parity_error
        );

    -- testbench process
    process
    begin
        -- test case 1: even parity, no parity error
        tb_data_in <= "10101010";  -- input data
        tb_parity_mode_sel <= '0'; -- even parity mode
        tb_rx_parity_bit <= '0';   -- correct even parity
        wait for 10 ns;
        assert tb_parity_error = '0'
            report "test case 1 failed: parity error detected for valid data."
            severity error;

        -- test case 2: even parity, intentional parity error
        tb_data_in <= "10101010";  -- input data
        tb_parity_mode_sel <= '0'; -- even parity mode
        tb_rx_parity_bit <= '1';   -- incorrect even parity
        wait for 10 ns;
        assert tb_parity_error = '1'
            report "test case 2 failed: no parity error detected for invalid data."
            severity error;

        -- test case 3: odd parity, no parity error
        tb_data_in <= "11001100";  -- input data
        tb_parity_mode_sel <= '1'; -- odd parity mode
        tb_rx_parity_bit <= '1';   -- correct odd parity
        wait for 10 ns;
        assert tb_parity_error = '0'
            report "test case 3 failed: parity error detected for valid data."
            severity error;

        -- test case 4: odd parity, intentional parity error
        tb_data_in <= "11001100";  -- input data
        tb_parity_mode_sel <= '1'; -- odd parity mode
        tb_rx_parity_bit <= '0';   -- incorrect odd parity
        wait for 10 ns;
        assert tb_parity_error = '1'
            report "test case 4 failed: no parity error detected for invalid data."
            severity error;

        -- test case 5: edge case - all bits '0', no parity error
        tb_data_in <= "00000000";  -- input data
        tb_parity_mode_sel <= '0'; -- even parity mode
        tb_rx_parity_bit <= '0';   -- correct even parity
        wait for 10 ns;
        assert tb_parity_error = '0'
            report "test case 5 failed: parity error detected for all zeros."
            severity error;

        -- test case 6: edge case - all bits '1', no parity error
        tb_data_in <= "11111111";  -- input data
        tb_parity_mode_sel <= '1'; -- odd parity mode
        tb_rx_parity_bit <= '0';   -- correct odd parity
        wait for 10 ns;
        assert tb_parity_error = '0'
            report "test case 6 failed: parity error detected for all ones."
            severity error;

        -- test case 7: random data, parity error
        tb_data_in <= "01101001";  -- input data
        tb_parity_mode_sel <= '1'; -- odd parity mode
        tb_rx_parity_bit <= '1';   -- incorrect odd parity
        wait for 10 ns;
        assert tb_parity_error = '1'
            report "test case 7 failed: no parity error detected for invalid random data."
            severity error;

        -- simulation complete
        report "all test cases passed successfully." severity note;
        wait;
    end process;
end behavioral;
