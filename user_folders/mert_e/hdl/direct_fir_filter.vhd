-- Company:  FPGA_FROM_ZERO_TO_HERO
-- Engineer: Mert Ecevit
-- 
-- Create Date: 19.01.2025 22:14:16
-- Design Name: 
-- Module Name: direct_fir_filter - behavioral
-- Project Name: FILTER
-- Target Devices: Design will be optimized for Sipeed Tang Primer 20k Dock-Ext board
-- Tool Versions: Gowin EDA
-- Description: Direct Form FIR Filter using FIR Filter Package
-- 
-- Dependencies: fir_filter_coeffs.vhd
-- 
-- Revision:
-- Revision 0.06 - Edit of process loop

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.fir_filter_coeff.all;



entity direct_fir_filter is
   generic (
      number_of_taps        : integer := 4; 
      input_width           : natural := 18;
      coeff_width           : natural := 18;
      output_width          : natural := 54 -- guard_bits = 54 - 18 - 18 = 18
    );
   port (
      clk                   : in  std_logic;
      rst                   : in  std_logic;
      valid_in              : in  std_logic;
      data_in               : in  std_logic_vector(input_width-1 downto 0);
      coeff_pipe            : in  pipeline_coeffs;
      data_out              : out std_logic_vector(output_width-1 downto 0);
      valid_out             : out std_logic
   );
   attribute syn_dspstyle: string;
   attribute syn_dspstyle of data_out: signal is "logic";
end direct_fir_filter;

architecture behavioral of direct_fir_filter is

   -- Constant for the multiplication width
   constant mac_width       : integer := output_width;

   -- Type definitions for systolic pipeline stages
   type pipeline_data is array (0 to number_of_taps-1) of signed(input_width-1 downto 0);
   signal data_pipe         : pipeline_data := (others => (others => '0'));
   signal valid_pipe        : std_logic_vector(number_of_taps-1 downto 0) := (others => '0');

   -- Use Coefficients from fir_filter_coeffs
  -- signal coeff_pipe : pipeline_coeffs := coeff_pipe;

   type pipeline_products is array (0 to number_of_taps-1) of signed(input_width+coeff_width-1 downto 0);
   signal product_pipe      : pipeline_products := (others => (others => '0'));

   type pipeline_sums is array (0 to number_of_taps-1) of signed(output_width-1 downto 0);
   signal sum_pipe          : pipeline_sums := (others => (others => '0'));

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                data_pipe           <= (others => (others => '0'));
                product_pipe        <= (others => (others => '0'));
                sum_pipe            <= (others => (others => '0'));
                valid_pipe          <= (others => '0');
                valid_out           <= '0';
            elsif valid_in = '1' then
                -- Data pipeline shifting
                for idx in number_of_taps-1 downto 1 loop
                    data_pipe(idx) <= data_pipe(idx-1);
                end loop;
                data_pipe(0) <= signed(data_in);
                -- Performing multiplications
                for idx in 0 to number_of_taps-1 loop
                    
                    if idx = 0 then
                        sum_pipe(idx) <= resize(product_pipe(idx), output_width);
                        
                    else
                        sum_pipe(idx) <= sum_pipe(idx-1) + resize(data_pipe(idx) * coeff_pipe(idx), output_width);
                    end if;
                end loop;
                -- Valid pipeline shifting
                valid_pipe(0) <= valid_in;
                for idx in 1 to number_of_taps-1 loop
                    valid_pipe(idx) <= valid_pipe(idx-1);
                end loop;
                valid_out <= valid_pipe(number_of_taps-1);
            end if;
        end if;
    end process;
    data_out <= std_logic_vector(sum_pipe(number_of_taps-1));

end behavioral;
