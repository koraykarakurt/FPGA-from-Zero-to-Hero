----------------------------------------------------------------------------------
-- Company: FalsePaths
-- Engineer: Emir EROL
-- 
-- Create Date: 01/23/2025 04:54:56 PM
-- Design Name: 
-- Module Name: tb_generic_multiplier - Behavioral
-- Project Name: Generic Multiplier
-- JIRA No: FIRF-11;
-- Target Devices: Kria KV260
-- Tool Versions: VHDL2002
-- Description: Generic multiplier module
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

entity tb_generic_multiplier is
end tb_generic_multiplier;

architecture testbench of tb_generic_multiplier is

    component generic_multiplier
        generic (
            sign : integer := 0; 
            size : integer := 8);
            
        port (
            mult_1 : in  std_logic_vector(7 downto 0);
            mult_2 : in  std_logic_vector(7 downto 0);
            mult_o : out std_logic_vector(15 downto 0)
        );
    end component;

    signal mult_1 : std_logic_vector(7 downto 0) := "00000101";  -- 5
    signal mult_2 : std_logic_vector(7 downto 0) := "00000011";  -- 3
    signal mult_o : std_logic_vector(15 downto 0);

    constant sign_value : integer := 0; 
    constant size_value : integer := 8;  

begin

    uut: generic_multiplier
        generic map (
            sign => sign_value,
            Size => size_value
        )
        port map (
            mult_1 => mult_1,
            mult_2 => mult_2,
            mult_o => mult_o
        );

    stim_proc: process
    begin
        -- Test 1: unsigned multiplication (5 * 3)
        mult_1 <= "00000101";  -- 5
        mult_2 <= "00000011";  -- 3
        wait for 10 ns;
        
        -- Test 2: signed multiplication (-5 * 3)
        mult_1 <= "11111011";  -- -5 (signed)
        mult_2 <= "00000011";  -- 3
        wait for 10 ns;
        
        -- Test 3: unsigned multiplication (2 * 7)
        mult_1 <= "00000010";  -- 2
        mult_2 <= "00000111";  -- 7
        wait for 10 ns;
        
        -- Test 4: signed multiplication (-2 * -7)
        mult_1 <= "11111110";  -- -2 (signed)
        mult_2 <= "11111001";  -- -7 (signed)
        wait for 10 ns;
        
        -- Test 5: unsigned multiplication (0 * 8)
        mult_1 <= "00000000";  -- 0
        mult_2 <= "00001000";  -- 8
        wait for 10 ns;

        -- Test 6: signed multiplication (-8 * 8)
        mult_1 <= "11111000";  -- -8 (signed)
        mult_2 <= "00001000";  -- 8
        wait for 10 ns;

        -- Test 7: unsigned multiplication (255 * 1)
        mult_1 <= "11111111";  -- 255
        mult_2 <= "00000001";  -- 1
        wait for 10 ns;

        -- Test 8: signed multiplication (-128 * 2)
        mult_1 <= "10000000";  -- -128 (signed)
        mult_2 <= "00000010";  -- 2
        wait for 10 ns;
        
        wait;
    end process stim_proc;

end testbench;