--------------------------------------------------------------------------------
-- Entity Name: parity_generator
-- Description: 
--   This module generates an even or odd parity bit for an 8-bit input data 
--   based on the selected parity mode (even or odd). Additionally, it checks 
--   the received parity bit for correctness by comparing it with the internally 
--   generated parity bit and outputs a parity error signal.
-- 
-- Ports:
--   - data_in: 8-bit input data for which the parity bit is generated.
--   - parity_mode_select: Parity mode selection bit (0: even parity, 1: odd parity).
--   - generated_parity: Generated parity bit for the selected parity mode.
--   - rx_parity_bit: Received parity bit from UART.
--   - parity_error: Indicates if a parity mismatch has been detected (1: error).
-- 
-- Author: Mustafa YETIS
-- Last Revision: 
--   Date: 23.01.2025 / 18:30
--   Revision: initial
-- 
-- Dependencies:
--   - IEEE.STD_LOGIC_1164 library for logical and signal operations.
-- 
-- Functionality:
--   - Calculates even and odd parity for 8-bit input data.
--   - Generates a parity bit based on the parity mode selection.
--   - Compares the received parity bit with the internally generated parity bit.
--   - Outputs a parity error signal if the parity bits do not match.
-- 
-- Recommended Synthesis Constraints:
--   - Ensure timing constraints are met for combinational logic.
--   - Verify the module in simulation before hardware implementation.
-- 
-- License: GPL
-- 
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity parity_generator is
    port (
        data_in            : in  std_logic_vector(7 downto 0);  -- 8-bit input data
        parity_mode_select : in  std_logic;  -- 0: Even parity, 1: Odd parity
        generated_parity   : out std_logic;  -- Generated parity bit
        rx_parity_bit      : in  std_logic;  -- Received parity bit
        parity_error       : out std_logic   -- Error signal (1 if mismatch)
    );
end parity_generator;

architecture behavioral of parity_generator is
begin
    process (data_in, parity_mode_select, rx_parity_bit)
        variable parity : std_logic;
    begin
        -- Compute even parity
        parity := data_in(0);
        for i in 1 to 7 loop
            parity := parity xor data_in(i);
        end loop;

        -- Adjust for odd parity if selected
        if parity_mode_select = '1' then
            parity := not parity;
        end if;

        -- Assign outputs
        generated_parity <= parity;
        parity_error <= rx_parity_bit xor parity;
    end process;
end behavioral;