----------------------------------------------------------------------------------
-- Company: FPGA Zero-to-Hero
-- Engineer: Recep Büyüktuncer
-- 
-- Create Date: 01/31/2025 08:16:06 PM
-- Design Name: 
-- Module Name: multiplier - Behavioral
-- Project Name: Multiplier 2x1 Design
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

entity generic_multiplier is
    generic(
        signed_flag : boolean := true;  -- false for unsigned, true for signed multiplication
        data_width  : natural := 8      -- input bit width
    );
    port(
        mult_in_1 : in std_logic_vector(data_width - 1 downto 0);
        mult_in_2 : in std_logic_vector(data_width - 1 downto 0);
        mult_out  : out std_logic_vector(2 * data_width - 1 downto 0)
    );
end generic_multiplier;

architecture behavioral of generic_multiplier is
 -- review note, koray_k: use if generate statements
begin
    -- Generate block for unsigned multiplication
    unsigned_if_gnrt : if signed_flag = false generate
        mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
    end generate unsigned_if_gnrt;

    -- Generate block for signed multiplication
    signed_if_gnrt : if signed_flag = true generate
        mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
    end generate signed_if_gnrt;

end behavioral;
