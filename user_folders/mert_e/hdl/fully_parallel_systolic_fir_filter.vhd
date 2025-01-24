-- Company:  FPGA_FROM_ZERO_TO_HERO
-- Engineer: Mert Ecevit
-- 
-- Create Date: 19.01.2025 22:14:16
-- Design Name: 
-- Module Name: fully_transposed_systolic_fir_filter - Behavioral
-- Project Name: FILTER
-- Target Devices: Design will be optimized for Sipeed Tang Primer 20k Dock-Ext board
-- Tool Versions: Gowin EDA
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.03 - Edited generics, coeff_pipe

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fully_parallel_systolic_fir_filter is
   generic (
      taps         : integer := 4;
      input_width  : natural := 16;
      coeff_width  : natural := 16;
      output_width : natural := 32;
    );
   port (
      clk    : in  std_logic;
      rst    : in  std_logic;
      enable : in  std_logic;
      data_i : in  std_logic_vector(input_width-1 downto 0);
      data_o : out std_logic_vector(output_width-1 downto 0)
   );
end fully_parallel_systolic_fir_filter;

architecture behavioral of fully_parallel_systolic_fir_filter is

   -- Constant for the multiplication width
   constant mac_width : integer := input_width + coeff_width;

   -- Type definitions for systolic pipeline stages
   type pipeline_data is array (0 to taps-1) of signed(input_width-1 downto 0);
   signal data_pipe : pipeline_data := (others => (others => '0'));

   type pipeline_coeffs is array (0 to taps-1) of signed(coeff_width-1 downto 0);
      constant coeff_pipe : pipeline_coeffs := (
      x"0001", x"0002", x"0003", x"0004"
   );

   type pipeline_products is array (0 to taps-1) of signed(mac_width-1 downto 0);
   signal product_pipe : pipeline_products := (others => (others => '0'));

   type pipeline_sums is array (0 to taps-1) of signed(output_width-1 downto 0);
   signal sum_pipe : pipeline_sums := (others => (others => '0'));

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data_pipe <= (others => (others => '0'));
                product_pipe <= (others => (others => '0'));
                sum_pipe <= (others => (others => '0'));
            elsif enable = '1' then
                for i in taps-1 downto 1 loop
                    data_pipe(i) <= data_pipe(i-1);
                end loop;
                data_pipe(0) <= signed(data_i);
                -- Performing of multiplications and accumulations
                for i in 0 to taps-1 loop
                    product_pipe(i) <= data_pipe(i) * coeff_pipe(i);
                    if i = 0 then
                        sum_pipe(i) <= resize(product_pipe(i), output_width);
                    else
                        sum_pipe(i) <= sum_pipe(i-1) + resize(product_pipe(i), output_width);
                    end if;
                end loop;
            end if;
        end if;
    end process;
    data_o <= std_logic_vector(sum_pipe(taps-1));

end behavioral;
