---------------------------------------------------------------------------------------------------
-- Author : Mustafa Yetis
-- Description : 
-- Self-checking testbench with error injection capability
-- Tests both signed and unsigned multiplication modes
-- Usage:
-- 1. Normal mode: Verify correct multiplication results
-- 2. Error mode: Inject errors to test assertion mechanism
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.generic_multiplier_pkg.all;

entity generic_multiplier_tb is
end entity generic_multiplier_tb;

architecture tb of generic_multiplier_tb is
   -- Signal declarations (must be in the architecture, not the package)
   signal mult_in_1_unsig		: std_logic_vector(mult_in_width-1 downto 0)		:= (others => '0');
   signal mult_in_2_unsig		: std_logic_vector(mult_in_width-1 downto 0)		:= (others => '0');
   signal mult_out_unsig		: std_logic_vector(2*mult_in_width-1 downto 0);
   
   signal mult_in_1_signed		: std_logic_vector(mult_in_width-1 downto 0)		:= (others => '0');
   signal mult_in_2_signed		: std_logic_vector(mult_in_width-1 downto 0)		:= (others => '0');
   signal mult_out_signed		: std_logic_vector(2*mult_in_width-1 downto 0);

   -- Declare the test case array as a constant
   constant test_cases : test_case_array := init_test_cases; --calling init function from pkg to initialize the test case array

begin
   ----------------------------------------------------------------------------------------------------
   -- instantiate DUTs
   ----------------------------------------------------------------------------------------------------
   dut_unsigned : entity work.generic_multiplier
      generic map (
         mult_type		=> '0',	-- unsigned selected
         data_width		=> mult_in_width
      )
      port map (
         mult_in_1		=> mult_in_1_unsig,
         mult_in_2		=> mult_in_2_unsig,
         mult_out			=> mult_out_unsig
      );

   dut_signed : entity work.generic_multiplier
      generic map (
         mult_type		=> '1',	-- signed selected
         data_width		=> mult_in_width
      )
      port map (
         mult_in_1		=> mult_in_1_signed,
         mult_in_2		=> mult_in_2_signed,
         mult_out			=> mult_out_signed
      );

   ----------------------------------------------------------------------------------------------------
   -- test process
   ----------------------------------------------------------------------------------------------------
   process
   begin
      -- Initial delay
      wait for wait_time_1;

      ----------------------------------------------------------------------------------------------------
      -- Unsigned mode tests
      ----------------------------------------------------------------------------------------------------
      report "starting unsigned multiplication tests...";
      for i in test_cases'range loop
         mult_in_1_unsig <= std_logic_vector(to_unsigned(test_cases(i).mult_val_1, mult_in_width));
         mult_in_2_unsig <= std_logic_vector(to_unsigned(test_cases(i).mult_val_2, mult_in_width));
         wait for wait_time_2;
         check_result(mult_in_1_unsig, mult_in_2_unsig, mult_out_unsig, false, test_cases(i).inject_err);
      end loop;
      
      ----------------------------------------------------------------------------------------------------
      -- Signed mode tests
      ----------------------------------------------------------------------------------------------------
      report "starting signed multiplication tests...";
      for i in test_cases'range loop
         mult_in_1_signed <= std_logic_vector(to_signed(test_cases(i).mult_val_1, mult_in_width));
         mult_in_2_signed <= std_logic_vector(to_signed(test_cases(i).mult_val_2, mult_in_width));
         wait for wait_time_2;
         check_result(mult_in_1_signed, mult_in_2_signed, mult_out_signed, true, test_cases(i).inject_err);
      end loop;

      ----------------------------------------------------------------------------------------------------
      -- Test summary
      ----------------------------------------------------------------------------------------------------
      wait for wait_time_1;
      report "test completed successfully" severity note;
      wait;
   end process;

end architecture tb;
