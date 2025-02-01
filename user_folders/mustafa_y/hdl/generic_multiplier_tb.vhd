--============================================================================
-- Generic Multiplier Testbench
--============================================================================
-- Self-checking testbench with error injection capability
-- Tests both signed and unsigned multiplication modes
-- Usage:
-- 1. Normal mode: Verify correct multiplication results
-- 2. Error mode: Inject errors to test assertion mechanism
-- Author : Mustafa Yetis
--Revision History:
--30.01.2025 - Created Initial code
--============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_multiplier_tb is
end entity generic_multiplier_tb;

architecture tb of generic_multiplier_tb is
   constant WIDTH      : positive := 8;
   constant TEST_COUNT : positive := 5;
   
   signal a_uns, b_uns   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
   signal result_uns     : std_logic_vector(2*WIDTH-1 downto 0);
   
   signal a_sig, b_sig   : std_logic_vector(WIDTH-1 downto 0) := (others => '0');
   signal result_sig     : std_logic_vector(2*WIDTH-1 downto 0);
   
   shared variable error_count : natural := 0;
begin

   ----------------------------------------------------------------------------
   -- Instantiate DUTs
   ----------------------------------------------------------------------------
   dut_unsigned : entity work.generic_multiplier
      generic map (
         MULT_TYPE => '0',
         WIDTH     => WIDTH
      )
      port map (
         a      => a_uns,
         b      => b_uns,
         result => result_uns
      );

   dut_signed : entity work.generic_multiplier
      generic map (
         MULT_TYPE => '1',
         WIDTH     => WIDTH
      )
      port map (
         a      => a_sig,
         b      => b_sig,
         result => result_sig
      );

   ----------------------------------------------------------------------------
   -- Test Process
   ----------------------------------------------------------------------------
   process
      procedure check_result(
         a, b       : in std_logic_vector(WIDTH-1 downto 0);
         res        : in std_logic_vector(2*WIDTH-1 downto 0);
         signed_op  : in boolean;
         inject_err : in boolean
      ) is
         variable exp     : std_logic_vector(2*WIDTH-1 downto 0);
         variable exp_int : integer;
         variable a_int   : integer;
         variable b_int   : integer;
      begin
         -- Calculate expected result
         if signed_op then
            a_int := to_integer(signed(a));
            b_int := to_integer(signed(b));
            exp   := std_logic_vector(signed(a) * signed(b));
         else
            a_int := to_integer(unsigned(a));
            b_int := to_integer(unsigned(b));
            exp   := std_logic_vector(unsigned(a) * unsigned(b));
         end if;

         -- Error injection
         if inject_err then
            exp := std_logic_vector(unsigned(exp) + 1);
         end if;

         -- Result checking
         assert res = exp
            report "FAIL: " &
                   integer'image(a_int) & " * " & integer'image(b_int) & 
                   " = " & integer'image(to_integer(unsigned(res))) & 
                   " (exp " & integer'image(to_integer(unsigned(exp))) & ")"
            severity error;

         if res /= exp then
            error_count := error_count + 1;
         end if;
      end procedure;

      -- Test case array: (a, b, inject_error)
      type test_case is record
         a          : integer;
         b          : integer;
         inject_err : boolean;
      end record;
      
        -- Define an array type for test cases
        type test_case_array is array (1 to TEST_COUNT) of test_case;
        
        -- Function to initialize the test case array
        function init_test_cases return test_case_array is
            variable cases : test_case_array;
        begin
            cases(1) := (0,        0,        false);
            cases(2) := (255,      255,      false);  -- Max unsigned
            cases(3) := (127,      -128,     false);  -- Max signed
            cases(4) := (85,       170,      false);  -- Hex values converted to decimal
            cases(5) := (100,      42,       true);   -- Error injection case
            return cases;
        end function;
            
        -- Declare a constant initialized via the function
        constant test_cases : test_case_array := init_test_cases;
      
      
   begin
      -- Initial delay
      wait for 10 ns;

      -------------------------------------------------------------------------
      -- Unsigned Mode Tests
      -------------------------------------------------------------------------
      report "Starting unsigned multiplication tests...";
      for i in test_cases'range loop --test_cases'range is TEST_COUNT
         a_uns <= std_logic_vector(to_unsigned(test_cases(i).a, WIDTH));
         b_uns <= std_logic_vector(to_unsigned(test_cases(i).b, WIDTH));
         wait for 1 ns;
         check_result(a_uns, b_uns, result_uns, false, test_cases(i).inject_err);
      end loop;

      -------------------------------------------------------------------------
      -- Signed Mode Tests
      -------------------------------------------------------------------------
      report "Starting signed multiplication tests...";
      for i in test_cases'range loop
         a_sig <= std_logic_vector(to_signed(test_cases(i).a, WIDTH));
         b_sig <= std_logic_vector(to_signed(test_cases(i).b, WIDTH));
         wait for 1 ns;
         check_result(a_sig, b_sig, result_sig, true, test_cases(i).inject_err);
      end loop;

      -------------------------------------------------------------------------
      -- Test Summary
      -------------------------------------------------------------------------
      wait for 10 ns;
      if error_count = 1 then
         report "Test completed with 1 error" severity warning;
      elsif error_count > 1 then
         report "Test completed with " & integer'image(error_count) & " errors" severity failure;
      else
         report "Test completed successfully" severity note;
      end if;
      std.env.stop;
   end process;

end architecture tb;