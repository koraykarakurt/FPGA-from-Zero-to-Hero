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
--   Date: 27.01.2025 / 18:30
--   Revision: 	"corrected signal initializations "
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

entity parity_generator is
    port (
        data_in             : in  std_logic_vector(7 downto 0); -- 8-bit input data
        parity_mode_select  : in  std_logic;                   -- parity mode selection bit (0: even parity, 1: odd parity)
        generated_parity    : out std_logic;                  -- generated parity bit for the selected parity mode
        rx_parity_bit       : in  std_logic;                  -- received parity bit from uart
        parity_error        : out std_logic                   -- parity error signal (1 if mismatch)
    );
end parity_generator;

architecture behavioral of parity_generator is
    signal even_parity : std_logic := '0'; -- generated even parity
    signal odd_parity  : std_logic := '0'; -- generated odd parity
    signal gen_parity  : std_logic := '0'; -- generated parity
begin
    process(data_in, parity_mode_select)
    begin
        -- calculate even parity
        even_parity <= (data_in(0) xor data_in(1) xor data_in(2) xor data_in(3) xor 
                        data_in(4) xor data_in(5) xor data_in(6) xor data_in(7));

        -- calculate odd parity
        odd_parity <= not(even_parity);
        
        -- mux for output with respect to parity_mode_select
        --generated_parity <= even_parity when (parity_mode_select = '0') else odd_parity;
        if parity_mode_select = '0' then
            gen_parity <= even_parity;
        else 
            gen_parity <= odd_parity;
        end if;
    end process;

    -- parity error is calculated as xor between rx_parity_bit and generated_parity
    parity_error <= rx_parity_bit xor gen_parity;
    generated_parity <= gen_parity;
end behavioral;
