---------------------------------------------------------------------------------------------------
-- Author : Utkan Genc
-- Description : 
--   This is a testbench for the generic multiplier.

-- More information (optional) :
-- DATA_WIDTH : width of the inputs
-- LOOP_COUNT : number of test cases

-- SCOPE : scope of the log messages
-- SIMULATION_TIMEOUT : timeout of the simulation

-- mult_in_1_u, mult_in_2_u : inputs of the unsigned multiplier
-- mult_out_u : output of the unsigned multiplier
-- mult_in_1_s, mult_in_2_s : inputs of the signed multiplier
-- mult_out_s : output of the signed multiplier
--
-- mult_out_u_expected, mult_out_s_expected : expected outputs

-- v_rand : random number generator
-- v_test_cases_success, v_test_cases_failures : counters for the test cases
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library uvvm_util;
context uvvm_util.uvvm_util_context;

entity generic_multiplier_tb is
end entity;

architecture behavioral of generic_multiplier_tb is
   -- Constants 
   constant DATA_WIDTH : integer := 8;
   constant LOOP_COUNT : integer := 100;

   constant SCOPE : string := "MULTIPLIER_TB";
   constant SIMULATION_TIMEOUT : time := LOOP_COUNT*20 ns;
   constant TEST_WAIT_TIME : time := 10 ns;

   -- Unsigned multiplier signals
   signal mult_in_1_u    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal mult_in_2_u    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal mult_out_u     : std_logic_vector(2*DATA_WIDTH-1 downto 0);

   -- Signed multiplier signals
   signal mult_in_1_s    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal mult_in_2_s    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
   signal mult_out_s     : std_logic_vector(2*DATA_WIDTH-1 downto 0);

   -- Expected output signals
   signal mult_out_u_expected : unsigned(2*DATA_WIDTH-1 downto 0);
   signal mult_out_s_expected : signed(2*DATA_WIDTH-1 downto 0);

   shared variable v_rand : t_rand;
   shared variable v_test_cases_success : natural := 0;
   shared variable v_test_cases_failures : natural := 0;

begin
   -- DUT for unsigned multiplication instance
   dut_unsigned: entity work.generic_multiplier
      generic map (
         MULTIPLIER_TYPE => 0,
         DATA_WIDTH      => DATA_WIDTH
      )
      port map (
         mult_in_1 => mult_in_1_u,
         mult_in_2 => mult_in_2_u,
         mult_out  => mult_out_u
      );

   -- DUT for signed multiplication instance
   dut_signed: entity work.generic_multiplier
      generic map (
         MULTIPLIER_TYPE => 1,
         DATA_WIDTH      => DATA_WIDTH
      )
      port map (
         mult_in_1 => mult_in_1_s,
         mult_in_2 => mult_in_2_s,
         mult_out => mult_out_s
      );
   
   -- LOGGING CONFIGURATION
   disable_log_msg(ALL_MESSAGES);
   enable_log_msg(ID_LOG_HDR);

   -- Unsigned multiplier test process
   test_proc_unsigned: process
      variable v_rand_val1_u, v_rand_val2_u : integer;
      variable v_error_injection : integer;
   begin
      -- Initialize random number generator
      v_rand.set_name("Random generator");
      v_rand.set_rand_seeds(C_RAND_INIT_SEED_1, C_RAND_INIT_SEED_2);

      for i in 1 to LOOP_COUNT loop
         -- Generate random inputs
         v_rand_val1_u := v_rand.rand(0, 2**DATA_WIDTH-1);
         v_rand_val2_u := v_rand.rand(0, 2**DATA_WIDTH-1);
         
         -- Determine if error injection occurs (10% probability)
         v_error_injection := v_rand.rand(0, 9);
         
         mult_in_1_u <= std_logic_vector(to_unsigned(v_rand_val1_u, DATA_WIDTH));
         mult_in_2_u <= std_logic_vector(to_unsigned(v_rand_val2_u, DATA_WIDTH));
         
         mult_out_u_expected <= to_unsigned(v_rand_val1_u * v_rand_val2_u, 2*DATA_WIDTH);
         
         wait for TEST_WAIT_TIME;

         if v_error_injection = 0 then
            log(ID_LOG_HDR, "ERROR INJECTION OCCURRED! Test Case: " &
                           integer'image(v_rand_val1_u) & " * " & 
                           integer'image(v_rand_val2_u) & 
                           " (Expected result modified intentionally)", SCOPE);
            
            -- Increment failure counter and expected alerts
            v_test_cases_failures := v_test_cases_failures + 1;
            increment_expected_alerts(ERROR);
            
            assert unsigned(mult_out_u) /= mult_out_u_expected
               report "Injected error detected for unsigned multiplication!"
               severity note;
         else
            if unsigned(mult_out_u) = mult_out_u_expected then
               -- Increment success counter
               v_test_cases_success := v_test_cases_success + 1;
               log(ID_LOG_HDR, 
                  "SUCCESS: " &
                  integer'image(v_rand_val1_u) & " * " & 
                  integer'image(v_rand_val2_u) & " = " &
                  integer'image(v_rand_val1_u * v_rand_val2_u),
                  SCOPE);
            else
               -- Increment failure counter and expected alerts
               v_test_cases_failures := v_test_cases_failures + 1;
               increment_expected_alerts(ERROR);
               
               assert unsigned(mult_out_u) = mult_out_u_expected
                  report "Unsigned multiplier error! " &
                     "Input 1: " & integer'image(v_rand_val1_u) &
                     ", Input 2: " & integer'image(v_rand_val2_u) &
                     ", Expected: " & integer'image(v_rand_val1_u * v_rand_val2_u) &
                     ", Got: " & integer'image(to_integer(unsigned(mult_out_u)))
                  severity error;
            end if;
         end if;
      end loop;
      wait;
   end process test_proc_unsigned;

      -- Signed multiplier test process    
   test_proc_signed: process
      variable v_rand_val1_s, v_rand_val2_s : integer;
      variable v_error_injection : integer;
   begin
      -- Initialize random number generator
      v_rand.set_name("Random generator signed");
      v_rand.set_rand_seeds(C_RAND_INIT_SEED_1, C_RAND_INIT_SEED_2);

      for i in 1 to LOOP_COUNT loop
         -- Generate random inputs
         v_rand_val1_s := v_rand.rand(-2**(DATA_WIDTH-1), 2**(DATA_WIDTH-1)-1);
         v_rand_val2_s := v_rand.rand(-2**(DATA_WIDTH-1), 2**(DATA_WIDTH-1)-1);
         
         -- Determine if error injection occurs (10% probability)
         v_error_injection := v_rand.rand(0, 9);

         mult_in_1_s <= std_logic_vector(to_signed(v_rand_val1_s, DATA_WIDTH));
         mult_in_2_s <= std_logic_vector(to_signed(v_rand_val2_s, DATA_WIDTH));

         mult_out_s_expected <= to_signed(v_rand_val1_s * v_rand_val2_s, 2*DATA_WIDTH);

         wait for TEST_WAIT_TIME;

         if v_error_injection = 0 then
            log(ID_LOG_HDR, "ERROR INJECTION OCCURRED! Test Case: " &
                              integer'image(v_rand_val1_s) & " * " & 
                              integer'image(v_rand_val2_s) & 
                              " (Expected result modified intentionally)", SCOPE);
               
               -- Increment failure counter and expected alerts
               v_test_cases_failures := v_test_cases_failures + 1;
               increment_expected_alerts(ERROR);
               
               assert signed(mult_out_s) /= mult_out_s_expected
                  report "Injected error detected for unsigned multiplication!"
                  severity note;  
         else
            if signed(mult_out_s) = mult_out_s_expected then
               -- Increment success counter
               v_test_cases_success := v_test_cases_success + 1;
               log(ID_LOG_HDR, 
                  "SUCCESS: " &
                  integer'image(v_rand_val1_s) & " * " & 
                  integer'image(v_rand_val2_s) & " = " &
                  integer'image(v_rand_val1_s * v_rand_val2_s),
                  SCOPE);
            else
               -- Increment failure counter and expected alerts
               v_test_cases_failures := v_test_cases_failures + 1;
               increment_expected_alerts(ERROR);
               
               assert false
                  report "Signed multiplier error! " &
                     "Input 1: " & integer'image(v_rand_val1_s) &
                     ", Input 2: " & integer'image(v_rand_val2_s) &
                     ", Expected: " & integer'image(v_rand_val1_s * v_rand_val2_s) &
                     ", Got: " & integer'image(to_integer(signed(mult_out_s)))
                  severity error;
            end if;
         end if;
      end loop;
      wait;
   end process test_proc_signed;

   -- Simulation control process
   simulation_control_proc: process
   begin
      wait for SIMULATION_TIMEOUT;
      
      log(ID_LOG_HDR,
         "=== TEST RESULTS ===" &
         "\nTotal Test Cases  : " & 
         integer'image(v_test_cases_success + v_test_cases_failures) &
         "\nSuccessful Tests  : " & 
         integer'image(v_test_cases_success) &
         "\nFailed Tests      : " & integer'image(v_test_cases_failures),
         SCOPE);
      
      if v_test_cases_failures > 0 then
         log(ID_LOG_HDR, "TEST FAILED - " & 
               integer'image(v_test_cases_failures) & " errors found!" &
               "\n" &
               "\nSIMULATION COMPLETED", SCOPE);
      else
         log(ID_LOG_HDR, "TEST PASSED - All " & 
         integer'image(v_test_cases_success) & " cases successful!" &
               "\n" &
               "\nSIMULATION COMPLETED", SCOPE);
      end if;

      -- Stop the simulation
      std.env.stop;
      wait;
   end process simulation_control_proc;
   -- koray_k, review note 5: good job but 260+ lines of code for this testbench is too many, you shall shorten it.
end architecture;