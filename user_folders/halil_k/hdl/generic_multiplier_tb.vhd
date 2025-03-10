---------------------------------------------------------------------------------------------------
-- Author      : Halil Furkan KIMKAK
-- Description : Testbench for Generic Multiplier
--                - Performs 100 test iterations with random values
--                - Tests both signed and unsigned multiplication using random test values
--                - Generates random numbers for each test:
--                  * Signed: Random numbers between -2^(MULT_LEN-1) and 2^(MULT_LEN-1)-1
--                  * Unsigned: Random numbers between 0 and 2^MULT_LEN-1
--                - Verifies multiplication results against expected values
--                - Reports detailed test results for each iteration
--                - Includes error injection capability to demonstrate error detection:
--                  * Can inject errors at specified test iteration
--                  * Supports error injection for both signed and unsigned multiplication
--                  * Uses XOR operation to corrupt multiplication results
--                - Provides comprehensive test summary with error reporting
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all; -- for random number generation

entity generic_multiplier_tb is
end entity generic_multiplier_tb;

architecture behavioral of generic_multiplier_tb is
   -- Constants
   constant MULT_LEN   : integer := 16;    -- Multiplier length 
   constant CLK_PERIOD : time    := 10 ns; -- Clock period 
   constant NUM_TESTS  : integer := 100;   -- Number of test iterations 
   
   -- Component declaration for generic_multiplier 
   component generic_multiplier is
      generic (    
         MULT_TYPE : boolean              := true;   -- Signed multiplier
         MULT_LEN  : integer range 2 to 64 := 16     -- Multiplier length 
      );
      port (    
         mult_in_1 : in  std_logic_vector(MULT_LEN-1 downto 0);    -- Input 1
         mult_in_2 : in  std_logic_vector(MULT_LEN-1 downto 0);    -- Input 2
         mult_out  : out std_logic_vector(2*MULT_LEN-1 downto 0)   -- Output
      );
   end component;
   
   -- Signals for signed multiplier
   signal s_mult_in_1    : std_logic_vector(MULT_LEN-1 downto 0);     -- Input 1
   signal s_mult_in_2    : std_logic_vector(MULT_LEN-1 downto 0);     -- Input 2
   signal s_mult_out     : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Output
   signal s_expected_out : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Expected output
   
   -- Signals for unsigned multiplier
   signal u_mult_in_1    : std_logic_vector(MULT_LEN-1 downto 0);     -- Unsigned Input 1
   signal u_mult_in_2    : std_logic_vector(MULT_LEN-1 downto 0);     -- Unsigned Input 2
   signal u_mult_out     : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Unsigned Output
   signal u_expected_out : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Unsigned Expected output
   
   -- Test status signals
   signal test_done    : boolean := false;                            -- Test done
   signal error_count  : integer := 0;                               -- Error count
   signal test_number  : integer := 0;                               -- Current test number
   
   -- Error injection signals
   signal error_inject_enable : boolean := false;                    -- Enable error injection
   signal error_inject_test   : integer := 50;                       -- Test number to inject error
   signal error_inject_type   : integer := 0;                        -- 0: signed, 1: unsigned
   signal error_inject_value  : std_logic_vector(2*MULT_LEN-1 downto 0) := (others => '1');  -- Error value to inject
   
   -- Shared variables for random number generation
   shared variable seed1 : positive := 1;
   shared variable seed2 : positive := 1;
   
   -- Random number generation function
   function random_slv(len: integer; signed_val: boolean) return std_logic_vector is
      variable r        : real;
      variable rand_max : integer;
      variable rand_val : integer;
      variable result   : std_logic_vector(len-1 downto 0);
   begin
      -- Determine maximum value based on signed/unsigned
      if signed_val then
         rand_max := 2**(len-1) - 1;  -- For signed
      else
         rand_max := 2**len - 1;      -- For unsigned
      end if;

      -- Generate random number
      uniform(seed1, seed2, r);       -- Random real number between 0 and 1
      rand_val := integer(r * real(rand_max));

      -- For signed numbers, generate negative with 50% probability
      if signed_val then
         uniform(seed1, seed2, r);
         if r > 0.5 then
            rand_val := -rand_val;
         end if;
      end if;

      -- Convert integer to std_logic_vector
      if signed_val then
         result := std_logic_vector(to_signed(rand_val, len));
      else
         result := std_logic_vector(to_unsigned(rand_val, len));
      end if;

      return result;
   end function;

begin
   -- Instantiate signed multiplier
   signed_mult_inst: generic_multiplier
   generic map (
      MULT_TYPE => true,      -- Signed multiplier
      MULT_LEN  => MULT_LEN   -- Multiplier length
   )
   port map (
      mult_in_1 => s_mult_in_1,   -- Input 1
      mult_in_2 => s_mult_in_2,   -- Input 2
      mult_out  => s_mult_out     -- Output
   );

   -- Instantiate unsigned multiplier
   unsigned_mult_inst: generic_multiplier
   generic map (
      MULT_TYPE => false,     -- Unsigned multiplier
      MULT_LEN  => MULT_LEN   -- Multiplier length
   )
   port map (
      mult_in_1 => u_mult_in_1,   -- Input 1
      mult_in_2 => u_mult_in_2,   -- Input 2
      mult_out  => u_mult_out     -- Output
   );
   
   -- Stimulus process
   stimulus: process
      -- Variables for expected results calculation
      variable v_s_expected   : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Signed expected output
      variable v_u_expected   : std_logic_vector(2*MULT_LEN-1 downto 0);   -- Unsigned expected output
      variable v_error_msg    : string(1 to 18);                           -- Error message variable
      variable v_mult_type    : string(1 to 8);                            -- Multiplication type variable
      variable corrupted_value : std_logic_vector(2*MULT_LEN-1 downto 0);  -- For error injection
   begin
      -- Initialize signals
      s_mult_in_1 <= (others => '0');   -- Input 1
      s_mult_in_2 <= (others => '0');   -- Input 2
      u_mult_in_1 <= (others => '0');   -- Unsigned Input 1
      u_mult_in_2 <= (others => '0');   -- Unsigned Input 2
      
      -- Enable error injection for test demonstration
      error_inject_enable <= true;       -- Enable error injection
      error_inject_test   <= 10;         -- Inject error in test #50
      error_inject_type   <= 0;          -- Inject error in signed multiplication

      wait for CLK_PERIOD * 2;           -- Wait for initial stabilization

      -- Run multiple test iterations
      for i in 1 to NUM_TESTS loop
         test_number <= i;               -- Update current test number
         
         -- Generate random test values
         s_mult_in_1 <= random_slv(MULT_LEN, true);    -- Random signed number
         s_mult_in_2 <= random_slv(MULT_LEN, true);    -- Random signed number
         u_mult_in_1 <= random_slv(MULT_LEN, false);   -- Random unsigned number
         u_mult_in_2 <= random_slv(MULT_LEN, false);   -- Random unsigned number
         
         -- Wait for inputs to propagate
         wait for CLK_PERIOD/2;
         
         -- Calculate expected results
         v_s_expected := std_logic_vector(signed(s_mult_in_1) * signed(s_mult_in_2));
         v_u_expected := std_logic_vector(unsigned(u_mult_in_1) * unsigned(u_mult_in_2));
         
         -- Apply error injection if needed
         if error_inject_enable and i = error_inject_test then
            report "Error injection triggered for test #" & integer'image(i) &
                  " Type: " & integer'image(error_inject_type) severity note;
                  
            if error_inject_type = 0 then
               -- Inject error in signed multiplication
               corrupted_value := v_s_expected;                                        -- Copy expected value
               corrupted_value(MULT_LEN-1 downto 0) := not corrupted_value(MULT_LEN-1 downto 0);  -- Invert specific bits
               v_s_expected := corrupted_value;                                        -- Update expected value
               report "Injecting error in signed multiplication" severity note;
            else
               -- Inject error in unsigned multiplication
               corrupted_value := v_u_expected;                                        -- Copy expected value
               corrupted_value(MULT_LEN-1 downto 0) := not corrupted_value(MULT_LEN-1 downto 0);  -- Invert specific bits
               v_u_expected := corrupted_value;                                        -- Update expected value
               report "Injecting error in unsigned multiplication" severity note;
            end if;
         end if;
         
         -- Assign expected values to signals
         s_expected_out <= v_s_expected;
         u_expected_out <= v_u_expected;
         
         -- Wait for outputs to stabilize
         wait for CLK_PERIOD/10;
         
         -- Set error message based on condition for signed test
         if error_inject_enable and i = error_inject_test and error_inject_type = 0 then
            v_error_msg := " (Error Injected) ";
         else
            v_error_msg := "                  ";
         end if;
         
         -- Report current test values with error injection status
         report "Test #" & integer'image(i) & v_error_msg &
               "Signed: " & integer'image(to_integer(signed(s_mult_in_1))) & " * " & 
               integer'image(to_integer(signed(s_mult_in_2))) & " = " &
               integer'image(to_integer(signed(s_mult_out))) &
               ", Expected: " & integer'image(to_integer(signed(v_s_expected)))
         severity note;
         
         -- Set error message for unsigned test
         if error_inject_enable and i = error_inject_test and error_inject_type = 1 then
            v_error_msg := " (Error Injected) ";
         else
            v_error_msg := "                  ";
         end if;
         
         report "Test #" & integer'image(i) & v_error_msg &
               "Unsigned: " & integer'image(to_integer(unsigned(u_mult_in_1))) & " * " & 
               integer'image(to_integer(unsigned(u_mult_in_2))) & " = " &
               integer'image(to_integer(unsigned(u_mult_out))) &
               ", Expected: " & integer'image(to_integer(unsigned(v_u_expected)))
         severity note;
         
         -- Signed multiplication check
         if s_mult_out /= s_expected_out and not (error_inject_enable and i = error_inject_test and error_inject_type = 0) then
            report "Test #" & integer'image(i) & ": Signed multiplication error"
            severity error;
            error_count <= error_count + 1;
         end if;                

         -- Unsigned multiplication check
         if u_mult_out /= u_expected_out and not (error_inject_enable and i = error_inject_test and error_inject_type = 1) then
            report "Test #" & integer'image(i) & ": Unsigned multiplication error"
            severity error;
            error_count <= error_count + 1;
         end if;
         
         wait for CLK_PERIOD;
      end loop;
      
      -- Report test completion with error injection status
      test_done <= true;                 -- Test done
      wait for CLK_PERIOD;
      
      if error_count = 0 then
         if error_inject_enable then
            -- Set multiplication type string
            if error_inject_type = 0 then
               v_mult_type := "signed  ";
            else
               v_mult_type := "unsigned";
            end if;
            
            report "All tests completed. Error was successfully injected in test #" & 
                  integer'image(error_inject_test) & " for " & 
                  v_mult_type & " multiplication."
               severity note;
         else
            report "All " & integer'image(NUM_TESTS) & " test iterations completed successfully!"
               severity note;
         end if;
      else
         report "Test completed with " & integer'image(error_count) & " unexpected errors out of " & 
               integer'image(NUM_TESTS * 2) & " total multiplications."
            severity error;
      end if;
         
      wait;
   end process stimulus;    
end architecture behavioral;