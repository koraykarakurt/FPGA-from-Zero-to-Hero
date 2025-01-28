--------------------------------------------------------------------------------------------------
-- Company  : False Paths --> https://www.youtube.com/@falsepaths
-- Project  : Generic FIR Filter Design and Verification
-- Engineer : Mehmet Demir
--
-- Testbench Name : Combinational Multiplier Package
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
package comb_multiplier_sim_pkg is

   ----------------------------------------------------
   -- comb_multiplier_tb
   ----------------------------------------------------
   constant delta_cycle : time := 0 ns;
   constant wait_time   : time := 10 ns;

   constant unsigned_name : std_logic := '0'; -- name suffix added to avoid raw unsigned name, gives error
   constant signed_name   : std_logic := '1'; -- name suffix added to avoid raw signed name, gives error

   constant error_inject_prcntg : natural range 0 to 100 := 5; -- error injection percentage

   constant DUT_unsigned_file_name : string := "DUT_unsigned_output_file.txt";
   constant DUT_signed_file_name   : string := "DUT_signed_output_file.txt";

   ----------------------------------------------------
   -- comb_multiplier (dut/duv) constants
   ----------------------------------------------------
   constant bitlength : natural range 2 to 255 := 8;

   ----------------------------------------------------
   -- functions declerations
   ----------------------------------------------------
   function compare_results(
      expected_result : std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      dut_result      : std_logic_vector((bitlength + bitlength) - 1 downto 0);
      inject_error    : boolean := false -- true --> inject error, 'false' --> do not inject error
   ) return boolean;

   ----------------------------------------------------
   -- procedures declerations
   ----------------------------------------------------
   procedure sim_done;

   procedure check_with_assertion(
      signal mult_1          : in std_logic_vector(bitlength - 1 downto 0);
      signal mult_2          : in std_logic_vector(bitlength - 1 downto 0);
      signal expected_result : in std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      signal dut_result      : in std_logic_vector((bitlength + bitlength) - 1 downto 0);
      unsigned_or_signed     : in std_logic; -- '0' --> unsigned, '1' --> signed;
      inject_error           : in boolean -- true --> inject error, 'false' --> do not inject error
   );

   procedure write_error2file (
      --file file_obj          : out text;
      file_name              : in string;
      signal mult_1          : in std_logic_vector(bitlength - 1 downto 0);
      signal mult_2          : in std_logic_vector(bitlength - 1 downto 0);
      variable line_obj      : out line;
      signal expected_result : in std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      signal dut_result      : in std_logic_vector((bitlength + bitlength) - 1 downto 0);
      unsigned_or_signed     : in std_logic; -- '0' --> unsigned, '1' --> signed;
      inject_error           : in boolean
   );

   procedure write_file_header (
      -- file file_obj          : in text; -- not possible
      file_name           : in string;
      variable line_obj   : out line;
      variable loop_limit : in integer
   );

end package comb_multiplier_sim_pkg;

package body comb_multiplier_sim_pkg is

   ----------------------------------------------------
   -- functions behaviour
   ----------------------------------------------------
   function compare_results(
      expected_result : std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      dut_result      : std_logic_vector((bitlength + bitlength) - 1 downto 0);
      inject_error    : boolean := false -- true --> inject error, 'false' --> do not inject error
   ) return boolean is
   begin
      if inject_error then
         --return expected_result /= dut_result;
         return not (expected_result = dut_result);
      else
         return expected_result = dut_result;
      end if;
   end function;

   ----------------------------------------------------
   -- procedures behaviour
   ----------------------------------------------------
   procedure sim_done is
   begin
      -- testing complete, stop with assertion
      assert false report lf &
      "--------------------------------------------------------------------------------------------------------------------------" & lf & 
      "--------------------------------------------------------------------------------------------------------------------------" & lf & 
      "-- simulation has been done properly at " & string'image(to_string(gmtime)) & " gmt +0 real time and at " & time'image(now) & " sim time, well done :) --" & lf &
      "--------------------------------------------------------------------------------------------------------------------------" & lf & 
      "--------------------------------------------------------------------------------------------------------------------------" severity failure;
   end procedure;

   procedure check_with_assertion(
      signal mult_1          : in std_logic_vector(bitlength - 1 downto 0);
      signal mult_2          : in std_logic_vector(bitlength - 1 downto 0);
      signal expected_result : in std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      signal dut_result      : in std_logic_vector((bitlength + bitlength) - 1 downto 0);
      unsigned_or_signed     : in std_logic; -- '0' --> unsigned, '1' --> signed;
      inject_error           : in boolean -- true --> inject error, 'false' --> do not inject error
   ) is
   begin

      if inject_error then
         report "error injected, no worry";
      end if;

      if unsigned_or_signed = '1' then -- signed
         assert compare_results(expected_result, dut_result, inject_error) report "signed expected/golden value not equal to dut result" & lf &
         " mult_1 --> " & integer'image(to_integer(signed(mult_1))) & " mult_2 --> " & integer'image(to_integer(signed(mult_2))) & 
         " expected result --> " & integer'image(to_integer(signed(expected_result))) & 
         " dut result --> " & integer'image(to_integer(signed(dut_result))) severity error;
      else -- unsigned
         assert compare_results(expected_result, dut_result, inject_error) report "unsigned expected/golden value not equal to dut result" & lf &
         " mult_1 --> " & integer'image(to_integer(unsigned(mult_1))) & " mult_2 --> " & integer'image(to_integer(unsigned(mult_2))) & 
         " expected result --> " & integer'image(to_integer(unsigned(expected_result))) & 
         " dut result --> " & integer'image(to_integer(unsigned(dut_result))) severity error;
      end if;

   end procedure;

   procedure write_error2file (
      --file file_obj          : out text;
      file_name              : in string;
      signal mult_1          : in std_logic_vector(bitlength - 1 downto 0);
      signal mult_2          : in std_logic_vector(bitlength - 1 downto 0);
      variable line_obj      : out line;
      signal expected_result : in std_logic_vector((bitlength + bitlength) - 1 downto 0); -- or golden_value
      signal dut_result      : in std_logic_vector((bitlength + bitlength) - 1 downto 0);
      unsigned_or_signed     : in std_logic; -- '0' --> unsigned, '1' --> signed;
      inject_error           : in boolean
   ) is
      file file_obj : text;
      --file file_obj : text open append_mode is file_name;
   begin
      file_open(file_obj, file_name, append_mode);

      if inject_error then
         write(line_obj, string'("error injected, no worry"));
         writeline(file_obj, line_obj);
      end if;

      if unsigned_or_signed = '1' then -- signed
         if not compare_results(expected_result, dut_result, inject_error) then
            write(line_obj, string'("signed expected/golden value not equal to dut result"));
            writeline(file_obj, line_obj); --> line break --> \n
            write(line_obj, string'(" mult_1 --> ")); write(line_obj, to_integer(signed(mult_1)));
            write(line_obj, string'(" mult_2 --> ")); write(line_obj, to_integer(signed(mult_2)));
            write(line_obj, string'(" expected result --> ")); write(line_obj, to_integer(signed(expected_result)));
            write(line_obj, string'(" dut result --> ")); write(line_obj, to_integer(signed(dut_result)));
            writeline(file_obj, line_obj); --> line break --> \n
            writeline(file_obj, line_obj); --> line break --> \n
         end if;
      else -- unsigned
         if not compare_results(expected_result, dut_result, inject_error) then
            write(line_obj, string'("unsigned expected/golden value not equal to dut result"));
            writeline(file_obj, line_obj); --> line break --> \n
            write(line_obj, string'(" mult_1 --> ")); write(line_obj, to_integer(unsigned(mult_1)));
            write(line_obj, string'(" mult_2 --> ")); write(line_obj, to_integer(unsigned(mult_2)));
            write(line_obj, string'(" expected result --> ")); write(line_obj, to_integer(unsigned(expected_result)));
            write(line_obj, string'(" dut result --> ")); write(line_obj, to_integer(unsigned(dut_result)));
            writeline(file_obj, line_obj); --> line break --> \n
            writeline(file_obj, line_obj); --> line break --> \n
         end if;
      end if;

      file_close(file_obj);

   end procedure;

   procedure write_file_header (
      -- file file_obj          : in text; -- not possible      
      file_name           : in string;
      variable line_obj   : out line;
      variable loop_limit : in integer
   ) is
      file file_obj : text;
      --file file_obj : text open write_mode is file_name;
   begin

      file_open(file_obj, file_name, write_mode);
      write(line_obj, string'(" -- only simulation errors -- "));
      writeline(file_obj, line_obj);
      write(line_obj, string'(" loop limit --> ")); write(line_obj, loop_limit);
      writeline(file_obj, line_obj);
      write(line_obj, string'(" error injection percentage --> ")); write(line_obj, error_inject_prcntg);
      writeline(file_obj, line_obj);
      writeline(file_obj, line_obj); --> line break --> \n
      file_close(file_obj);
   end procedure;

end package body comb_multiplier_sim_pkg;