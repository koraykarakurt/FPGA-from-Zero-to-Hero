-- Company:  FPGA_FROM_ZERO_TO_HERO
-- Engineer: Mert Ecevit
-- 
-- Create Date: 24.01.2025 11:37:01
-- Design Name: 
-- Module Name: fully_transposed_systolic_fir_filter_tb - bhv
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
use IEEE.math_real.all;

entity fully_parallel_systolic_fir_filter_tb is
end fully_parallel_systolic_fir_filter_tb;

architecture bhv of fully_parallel_systolic_fir_filter_tb is

  constant coeff_pipe : real_vector := (0.01662606, -0.00696415, -0.03403663, -0.04855056);

  signal rst      : std_logic := '0';
  signal clk      : std_logic := '0';
  signal finished : boolean := false;

signal data_in : std_logic_vector(15 downto 0) := (others => '0');
signal data_out , data_check : std_logic_vector(15 downto 0) := (others => '0');

constant input_width : natural := 16;
constant input_width_scale : real := real (2 ** input_width-1) - 1.0;

constant output_width : natural := 16;
constant output_width_scale : real := real (2 ** output_width-1) - 1.0;

constant filter_delay : natural := 1;

begin
  dut : entity work.fully_parallel_systolic_fir_filter
  generic map(coeff_pipe => coeff_pipe,
              input_width => input_width, 
              output_width => output_width
)
  port map (
      clk       => clk,
      rst       => rst,
      valid_in  => valid_in,
      data_in   => data_in,
      data_out  => data_out,
      valid_out => valid_out
);

  stim : process
  begin
    rst <= '1';
    wait for 100ns;
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);
    sample_driver : for i in 0 to 3 loop
      data_in <= std_logic_vector(to_signed(integer(input_width_scale*coeff_pipe(i)), 16));
      wait until rising_edge(clk);
    end loop;
    data_in <= (others => '0');

    wait for 1us;
    finished <= true;
  end process stim;

   -- 31/01/2025, review note by koray_k 
   -- provide some simple (maybe constant) inputs and check the functionality of the filter first
   -- also fix the tab size >> each tab = 3 spaces
  check : process
  variable current_output : real;
  begin
    wait for 100ns;
    wait until rising_edge(clk);
    wait until rising_edge(clk);

    for i in 0 to filter_delay loop
      wait until rising_edge(clk);
    end loop;
    for i in 0 to coeff_pipe'high + coeff_pipe'high loop
      current_output := 0.0;
      for number_of_taps in coeff_pipe'range loop
        if(i-number_of_taps >= 0) and (i-number_of_taps <= coeff_pipe'high) then
          current_output := current_output + coeff_pipe(number_of_taps) * real(to_signed(data_check(i-number_of_taps), 16));
          end if;
        end loop;
        data_check <= std_logic_vector(to_signed(integer(trunc(output_width_scale * current_output)), 16));

        assert abs(signed(data_check) - signed(data_out)) <= 2 report "FIR FILTER OUTPUT IS INCORRECT" severity error;
        wait until rising_edge(clk);
      end loop;
      data_check <= (others => '0');

      wait for 1us;
  end process check;

  clk <= not clk after 10ns when not finished;
end bhv;
