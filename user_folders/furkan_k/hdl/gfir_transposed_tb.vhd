---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : Transposed FIR Filter design's testbech
--   
--   
--  
-- More information (optional) :
-- a procedure is used to calculate expected filter output and it is compared with the real
-- filter output
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.gfir_transposed_pkg.all;

entity gfir_transposed_tb is
   generic (
      clk_period  : time    := 10 ns; -- system clock's period 
      filter_taps : integer :=  5   ; -- filter order
      input_len   : integer := 24   ; -- filter input  length
      coeff_len   : integer := 16   ; -- filter coefficient length
      output_len  : integer := 24     -- filter output length
   );
end gfir_transposed_tb;

architecture behavioral of gfir_transposed_tb is

   -- Transposed FIR Filter signals
   signal reset        : std_logic;
   signal clock        : std_logic;
   signal data_in      : std_logic_vector(input_len - 1 downto 0);
   signal valid_in     : std_logic;
   signal valid_out    : std_logic;
   signal data_out     : std_logic_vector(input_len + coeff_len - 1 downto 0);

   -- transposed fir filter output checker procedure
   procedure checker_filter_out (
      filter_in        : in std_logic_vector(input_len - 1 downto 0);
      filter_out       : in std_logic_vector(input_len + coeff_len - 1 downto 0)
   )  is 
      type product_ary is array (0 to filter_taps - 1) of signed(input_len + coeff_len - 1 downto 0);
      variable product : product_ary;
      variable sum     : signed(input_len + coeff_len - 1 downto 0) := (others => '0');
   begin
      for prod_idx in 0 to filter_taps - 1 loop 
         product(prod_idx) := signed(filter_in) * filter_coeff(prod_idx);
         sum               := sum + product(prod_idx);
      end loop;
      
      if (std_logic_vector(sum) = filter_out) then 
         report "Transposed FIR Filter's output SAME with expected filter output" severity note;
      else 
         report "Transposed FIR Filter's output DIFFERENT from expected filter output" severity warning;
      end if;      
   end procedure checker_filter_out;

begin

   -- component instantiation for Transposed FIR Filter
   gfir_transposed_inst : entity work.gfir_transposed
   generic map (
      filter_taps => filter_taps ,
      input_len   => input_len   ,
      coeff_len   => coeff_len   ,
      output_len  => output_len  
   )
   port map (
      clock       => clock       ,
      reset       => reset       ,
      data_in     => data_in     ,
      valid_in    => valid_in    ,
      data_out    => data_out    ,
      valid_out   => valid_out
   );

   -- clock generation process
   clk_gen_p : process 
   begin
      clock <= '0';
      wait for clk_period / 2;
      clock <= '1';
      wait for clk_period / 2;
   end process clk_gen_p;

   -- reset generation process
   reset_gen_p : process 
   begin
      reset <= '1';
      wait for clk_period * 10;
      reset <= '0';
      wait for clk_period * 100;
      reset <= '1';
      wait;
   end process reset_gen_p;

   gfir_basic_test_p : process 
   begin
      report "!!!SIMULATION START!!!" severity note;
      wait until reset = '0';
      valid_in <= '1';
      data_in  <= std_logic_vector(to_signed(-5, input_len));
      wait until valid_out = '1';
      checker_filter_out(data_in, data_out);
      
      wait until rising_edge(clock);
      valid_in <= '0';     
      wait until reset = '1';    
      data_in  <= std_logic_vector(to_signed(5, input_len));
      wait until rising_edge(clock);
      checker_filter_out(data_in, data_out);
      
      report "!!!SIMULATION END!!!" severity failure;
   end process gfir_basic_test_p;

end behavioral;