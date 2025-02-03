---------------------------------------------------------------------------------------------------
-- Author : Mustafa Yetis
-- Description : Necessary Declarations(Type,Procedure,Constant etc.) for generic_multiplier_tb
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

package generic_multiplier_pkg is
   constant mult_in_width		: positive := 8;
   constant test_count			: positive := 5;
   constant wait_time_1			: time := 10 ns;
   constant wait_time_2			: time := 1 ns;

   -- Test case record and array types
   type test_case is record
      mult_val_1  : integer;
      mult_val_2  : integer;
      inject_err  : boolean;
   end record;
   
   type test_case_array is array (1 to test_count) of test_case;

   -- Function to initialize test cases
   function init_test_cases return test_case_array;

   -- Procedure for result checking
   procedure check_result(
      mult_val_1, mult_val_2	: in std_logic_vector(mult_in_width-1 downto 0);
      mult_val_out				: in std_logic_vector(2*mult_in_width-1 downto 0);
      signed_op					: in boolean;
      inject_err					: in boolean
   );

end package generic_multiplier_pkg;

package body generic_multiplier_pkg is

   function init_test_cases return test_case_array is
      variable cases : test_case_array;
   begin
      cases(1) 					:= (0,        0,        false);
      cases(2) 					:= (255,      255,      false);  -- max unsigned
      cases(3) 					:= (127,      -128,     false);  -- max signed
      cases(4) 					:= (85,       170,      false);  -- hex values converted to decimal
      cases(5) 					:= (100,      42,       true);   -- error injection case
      return cases;
   end function;

   procedure check_result(
      mult_val_1, mult_val_2	: in std_logic_vector(mult_in_width-1 downto 0);
      mult_val_out				: in std_logic_vector(2*mult_in_width-1 downto 0);
      signed_op					: in boolean;
      inject_err					: in boolean
   ) is
      variable exp_result		: std_logic_vector(2*mult_in_width-1 downto 0);
      variable mult_int_1		: integer;
      variable mult_int_2		: integer;
   begin
      -- Calculate expected result
      if signed_op then
         mult_int_1				:= to_integer(signed(mult_val_1));
         mult_int_2				:= to_integer(signed(mult_val_2));
         exp_result				:= std_logic_vector(signed(mult_val_1) * signed(mult_val_2));
      else			
         mult_int_1				:= to_integer(unsigned(mult_val_1));
         mult_int_2				:= to_integer(unsigned(mult_val_2));
         exp_result				:= std_logic_vector(unsigned(mult_val_1) * unsigned(mult_val_2));
      end if;

      -- Error injection
      if inject_err then
         exp_result				:= std_logic_vector(unsigned(exp_result) + 1);
      end if;

      -- Result checking
      assert mult_val_out = exp_result
         report "fail: " & integer'image(mult_int_1) & " * " & integer'image(mult_int_2) & 
                " = " & integer'image(to_integer(unsigned(mult_val_out))) & 
                " (expected " & integer'image(to_integer(unsigned(exp_result))) & ")"
         severity error;
   end procedure;

end package body generic_multiplier_pkg;
