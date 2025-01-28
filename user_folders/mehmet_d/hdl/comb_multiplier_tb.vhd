--------------------------------------------------------------------------------------------------
-- Company  : False Paths --> https://www.youtube.com/@falsepaths
-- Project  : Generic FIR Filter Design and Verification
-- Engineer : Mehmet Demir
--
-- Testbench Name : Combinational Multiplier Testbench
-- VHDL Revision  : VHDL-2019
-- Target Devices : Aldec Riviera Pro 2023.04 / EDA playground
-- Tool Versions  : NA
-- Dependencies   : NA
-- Description    : Test the combinational multiplier module with selfchecking testbenches using assertions.
-- 
-- Revision --> 01v00; Date --> 29.01.25; JIRA No --> FIRF-9; Reason --> First Release
-- 
--------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- for arithmetic operations
use std.textio.all; -- for file operations on simulation
use std.env.all; -- for time operations on simulation

library osvvm;
use osvvm.randompkg.all; -- for random operations on simulation
use osvvm.randombasepkg.all; -- for salt operations on simulation 

library work;
use work.comb_multiplier_sim_pkg.all; -- testbench/simulation package, all constants, funcitons, procedures etc. are in the comb_multiplier_sim_pkg, soo see it.

entity comb_multiplier_tb is
   --port (); -- no need ports for simulation
end comb_multiplier_tb;

architecture behavioral_sim of comb_multiplier_tb is

   ----------------------------------------------------
   -- comb_multiplier (dut/duv) signals, initialize inputs not outputs
   ----------------------------------------------------
   signal mult_1_uns             : std_logic_vector(bitlength - 1 downto 0)               := (others => '0');
   signal mult_2_uns             : std_logic_vector(bitlength - 1 downto 0)               := (others => '0');
   signal mult_1_s               : std_logic_vector(bitlength - 1 downto 0)               := (others => '0');
   signal mult_2_s               : std_logic_vector(bitlength - 1 downto 0)               := (others => '0');
   signal multrslt_uns           : std_logic_vector((bitlength + bitlength) - 1 downto 0) := (others => '0'); -- _uns suffix --> unsigned
   signal multrslt_s             : std_logic_vector((bitlength + bitlength) - 1 downto 0) := (others => '0'); -- _s suffix --> signed
   signal expected_unsigned_rslt : std_logic_vector((bitlength + bitlength) - 1 downto 0) := (others => '0');
   signal expected_signed_rslt   : std_logic_vector((bitlength + bitlength) - 1 downto 0) := (others => '0');

   ----------------------------------------------------
   -- comb_multiplier_tb signals
   ----------------------------------------------------
   signal unsigned_sim_finished : std_logic := '0';
   signal signed_sim_finished   : std_logic := '0';

begin

   ----------------------------------------------------
   -- instantiation of design module with unsigned
   ----------------------------------------------------
   dut_inst_unsigned : entity work.comb_multiplier
      generic map(
         select_sign => unsigned_name, -- '0': unsigned, '1': signed
         bit_length  => bitlength -- define bit length for both inputs as same, the output length will be sum of the input lengths
      )
      port map
      (
         mult_1    => mult_1_uns,
         mult_2    => mult_2_uns,
         mult_rslt => multrslt_uns
      );

   ----------------------------------------------------
   -- instantiation of design module with signed
   ----------------------------------------------------
   dut_inst_signed : entity work.comb_multiplier
      generic map(
         select_sign => signed_name, -- '0': unsigned, '1': signed
         bit_length  => bitlength -- define bit length for both inputs as same, the output length will be sum of the input lengths
      )
      port map
      (
         mult_1    => mult_1_s,
         mult_2    => mult_2_s,
         mult_rslt => multrslt_s
      );

   ----------------------------------------------------  
   -- generates the test stimulus for dut_inst_unsigned
   ----------------------------------------------------
   stimulus_unsigned : process
      variable rv              : randomptype;
      variable loop_limit      : integer;
      variable error_injection : boolean;
      variable line_obj        : line;
   begin

      -- need for randomization
      setrandomsalt (to_string(gmtime));
      rv.initseed(to_string(gmtime));

      -- wait for the start
      wait for wait_time;

      -- generate test cases --

      -- generate random values
      loop_limit := rv.randint(50, 200);

      report "loop limit --> " & integer'image(loop_limit) & lf & " error injection percentage --> " & integer'image(error_inject_prcntg);

         -- open file with write mode and write header to file
         write_file_header(DUT_unsigned_file_name, line_obj, loop_limit);

      for i in 1 to loop_limit loop

         -- generate random vales
         case rv.distvalint(((0, 100 - error_inject_prcntg), (1, error_inject_prcntg))) is -- generate random values (only 0 or 1) with the rates
            when 0 => -- 95%
               error_injection := false;
            when 1 => -- 5%
               error_injection := true;
            when others => -- if not defined, gives error --> COMP96 ERROR COMP96_0301: "The choice 'others' must be present when all alternatives are not covered.
               null;
         end case;
         mult_1_uns <= rv.randslv(min => 0, max => (2 ** bitlength) - 1, size => bitlength);
         mult_2_uns <= rv.randslv(min => 0, max => (2 ** bitlength) - 1, size => bitlength);
         wait for delta_cycle;

         -- calculate expected values
         expected_unsigned_rslt <= std_logic_vector(unsigned(mult_1_uns) * unsigned(mult_2_uns));
         wait for wait_time;

         -- check and log the errors to file
         write_error2file(DUT_unsigned_file_name, mult_1_uns, mult_2_uns, line_obj, expected_unsigned_rslt, multrslt_uns, unsigned_name, error_injection);

         -- check with assertions
         check_with_assertion(mult_1_uns, mult_2_uns, expected_unsigned_rslt, multrslt_uns, unsigned_name, error_injection);

      end loop;

      unsigned_sim_finished <= '1';
      wait;

   end process stimulus_unsigned;

   ----------------------------------------------------  
   -- generates the test stimulus for dut_inst_signed
   ----------------------------------------------------
   stimulus_signed : process
      variable rv              : randomptype;
      variable loop_limit      : integer;
      variable error_injection : boolean;
      variable line_obj        : line;
   begin

      -- need for randomization
      setrandomsalt (to_string(gmtime) & rv'instance_name);
      rv.initseed(to_string(gmtime) & rv'instance_name);

      -- wait for the start
      wait for wait_time;

      -- generate test cases --

      -- generate random values
      loop_limit := rv.randint(50, 200);

      report "loop limit --> " & integer'image(loop_limit) & lf & " error injection percentage --> " & integer'image(error_inject_prcntg);

         -- open file with write mode and write header to file
         write_file_header(DUT_signed_file_name, line_obj, loop_limit);

      for i in 1 to loop_limit loop

         -- generate random vales
         case rv.distvalint(((0, 100 - error_inject_prcntg), (1, error_inject_prcntg))) is -- generate random values (only 0 or 1) with the rates
            when 0 => -- 95%
               error_injection := false;
            when 1 => -- 5%
               error_injection := true;
            when others => -- if not defined, gives error --> COMP96 ERROR COMP96_0301: "The choice 'others' must be present when all alternatives are not covered.
               null;
         end case;
         mult_1_s <= rv.randslv(min => 0, max => (2 ** bitlength) - 1, size => bitlength);
         mult_2_s <= rv.randslv(min => 0, max => (2 ** bitlength) - 1, size => bitlength);
         wait for delta_cycle;

         -- calculate expected values
         expected_signed_rslt <= std_logic_vector(signed(mult_1_s) * signed(mult_2_s));
         wait for wait_time;

         -- check and log the errors to file
         write_error2file(DUT_signed_file_name, mult_1_s, mult_2_s, line_obj, expected_signed_rslt, multrslt_s, signed_name, error_injection);

         -- check with assertions
         check_with_assertion(mult_1_s, mult_2_s, expected_signed_rslt, multrslt_s, signed_name, error_injection);

      end loop;

      signed_sim_finished <= '1';
      wait;

   end process stimulus_signed;

   finish_sim : process
   begin

      wait until (unsigned_sim_finished = '1' and signed_sim_finished = '1');
      sim_done;

   end process finish_sim;
end behavioral_sim;
-- /* The End */ --