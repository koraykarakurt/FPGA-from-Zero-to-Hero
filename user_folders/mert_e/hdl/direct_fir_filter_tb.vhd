-- Company:  FPGA_FROM_ZERO_TO_HERO
-- Engineer: Mert Ecevit
-- 
-- Create Date: 24.01.2025 11:37:01
-- Design Name: 
-- Module Name: direct_fir_filter_tb - behavioral
-- Project Name: FILTER
-- Target Devices: Design will be optimized for Sipeed Tang Primer 20k Dock-Ext board
-- Tool Versions: Gowin EDA
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.02 -Edited errors

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity direct_fir_filter_tb is
end direct_fir_filter_tb;

architecture behavioral of direct_fir_filter_tb is

   constant number_of_taps  : natural := 4;  
   constant input_width     : natural := 18;
   constant coeff_width     : natural := 18;
   constant output_width    : integer := 54;
   
   constant clk_period      : time := 10 ns;
   constant rst_time        : time := 20 ns;
   constant data_in_per     : time := 50 ns;
   constant out_delay       : time := 50 ns;

   ------------------------------------------------------------------------------
   -- Test Data Array
   ------------------------------------------------------------------------------
   type test_data_array is array (number_of_taps-1 downto 0) of signed(input_width-1 downto 0);
   signal test_data_arr1 : test_data_array := (
         to_signed(0, input_width),
         to_signed(0, input_width),
         to_signed(0, input_width),
         to_signed(0, input_width)
   );
   signal test_data_arr2 : test_data_array := (
         to_signed(1, input_width),
         to_signed(1, input_width),
         to_signed(1, input_width),
         to_signed(1, input_width)
   );

   signal clk            : std_logic := '0';
   signal rst            : std_logic := '1';
   signal data_in        : std_logic_vector(input_width-1 downto 0) := (others => '0');
   signal valid_in       : std_logic := '0';
   signal data_out       : std_logic_vector(output_width - 1 downto 0);
   signal valid_out      : std_logic;

begin
   dut : entity work.fully_parallel_systolic_fir_filter
      generic map (
         number_of_taps => number_of_taps,
         input_width    => input_width,
         coeff_width    => coeff_width
      )
      port map (
         clk            => clk,
         rst            => rst,
         data_in        => data_in,
         valid_in       => valid_in,
         data_out       => data_out,
         valid_out      => valid_out
      );

   clk_gen : process
   begin
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
   end process;

   stimuli : process
      variable i : integer;
   begin
      report "Simulation start" severity note;
      
      rst <= '1';
      wait for rst_time;
      report "Reset asserted" severity note;
      rst <= '0';
      wait for rst_time;
      
      ----------------------------------------------------------------------------
      -- Test Sequence 1: Send test_data_arr1 (all zeros)
      ----------------------------------------------------------------------------
      report "Sending Test Data Array 1 (all zeros)" severity note;
      for i in 0 to number_of_taps - 1 loop
         data_in  <= std_logic_vector(test_data_arr1(i));
         valid_in <= '1';
         wait for data_in_per;
      end loop;
      valid_in <= '0';
      report "Test Data Array 1 sent" severity note;
      
      wait for out_delay;
      if valid_out = '1' then
         report "Output valid after Test Data Array 1" severity note;
      else
         report "Warning: Output not valid after Test Data Array 1" severity warning;
      end if;
      
      ----------------------------------------------------------------------------
      -- Test Sequence 2: Send test_data_arr2 (all ones)
      ----------------------------------------------------------------------------
      report "Sending Test Data Array 2 (all ones)" severity note;
      for i in 0 to number_of_taps - 1 loop
         data_in  <= std_logic_vector(test_data_arr2(i));
         valid_in <= '1';
         wait for data_in_per;
      end loop;
      valid_in <= '0';
      report "Test Data Array 2 sent" severity note;
      
      wait for out_delay;
      if valid_out = '1' then
         report "Output valid after Test Data Array 2" severity note;
      else
         report "Warning: Output not valid after Test Data Array 2" severity warning;
      end if;
      
      report "Simulation finished" severity note;
      wait;
   end process;

end behavioral;

