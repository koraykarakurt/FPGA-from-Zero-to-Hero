--------------------------------------------------------------------------------------------------
-- Company  : False Paths --> https://www.youtube.com/@falsepaths
-- Project  : Generic FIR Filter Design and Verification
-- Engineer : Mehmet Demir
--
-- Testbench Name : Combinational Multiplier Tesbench
-- VHDL Revision  : VHDL-2019
-- Target Devices : Aldec Riviera Pro 2023.04 / EDA playground
-- Tool Versions  : NA
-- Dependencies   : NA
-- Description    : Test the combinational multiplier module with selfchecking testbenches using assertions.
-- 
-- Revision --> 01v00; Date --> 25.01.25; JIRA No --> FIRF-9; Reason --> First Release
-- 
--------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- for arithmetic operations
use std.textio.all;       -- for file operations on simulation
use std.env.all;          -- for time operations on simulation

library osvvm;
use osvvm.randompkg.all;     -- for random operations on simulation
use osvvm.randombasepkg.all; -- for salt operations on simulation 

entity comb_multiplier_tb is
  --port (); -- no need ports for simulation
end comb_multiplier_tb;

architecture behavioral_rtl of comb_multiplier_tb is

  ----------------------------------------------------
  -- comb_multiplier_tb
  ----------------------------------------------------
  constant wait_delta_cycle_c           : time                   := 1 ps;
  constant wait_time_c                  : time                   := 10 ns;
  constant error_injection_percentage_c : natural range 0 to 100 := 5;

  file file_obj         : text; -- must be in here for procedures, if it is in below of process than a procedure can not be see this object

  ----------------------------------------------------
  -- comb_multiplier_mdl (dut/duv), initialize inputs not outputs
  ----------------------------------------------------
  constant bitlengthof_dutgnrc_c : natural range 2 to 255 := 8;
  constant unsigned_c            : std_logic              := '0';
  constant signed_c              : std_logic              := '1';
  constant not_inject_error_c    : boolean                := false; 
  constant inject_error_c        : boolean                := true; 

  signal mult_1_dutin_s           : std_logic_vector(bitlengthof_dutgnrc_c - 1 downto 0) := (others => '0');
  signal mult_2_dutin_s           : std_logic_vector(bitlengthof_dutgnrc_c - 1 downto 0) := (others => '0');
  signal dutout1_multrslt_s       : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
  signal dutout2_multrslt_s       : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
  signal expected_unsigned_rslt_s : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0) := (others => '0');
  signal expected_signed_rslt_s   : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0) := (others => '0');

  ----------------------------------------------------
  -- functions
  ----------------------------------------------------
  function compare_results_func(
    expected_result : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0); -- or golden_value
    dut_result      : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
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
  -- procedures
  ----------------------------------------------------
  procedure sim_done_prcdr is
  begin
    -- testing complete, stop with assertion
    assert false report lf &
    "--------------------------------------------------------------------------------------------------------------------------" & lf & 
    "--------------------------------------------------------------------------------------------------------------------------" & lf & 
    "-- simulation has been done properly at " & string'image(to_string(gmtime)) & " gmt +0 real time and at " & time'image(now) & " sim time, well done :) --" & lf &
    "--------------------------------------------------------------------------------------------------------------------------" & lf & 
    "--------------------------------------------------------------------------------------------------------------------------" severity failure;
  end procedure;
  
  procedure check_with_assertion_prcdr(
    signal expected_result : in std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0); -- or golden_value
    signal dut_result      : in std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
    unsigned_or_signed     : in std_logic;                                                                      -- '0' --> unsigned, '1' --> signed;
    inject_error           : in boolean                                                                         -- true --> inject error, 'false' --> do not inject error
  ) is
  begin
    
    if inject_error then
      report "error injected, no worry";
    end if;

    if unsigned_or_signed = '1' then -- signed
      assert compare_results_func(expected_result, dut_result, inject_error) report "signed expected/golden value not equal to dut result" & lf &
      " mult_1 --> " & integer'image(to_integer(signed(mult_1_dutin_s))) & " mult_2 --> " & integer'image(to_integer(signed(mult_2_dutin_s))) & " dut result --> " & integer'image(to_integer(signed(expected_signed_rslt_s))) severity error;
    else -- unsigned
      assert compare_results_func(expected_result, dut_result, inject_error) report "unsigned expected/golden value not equal to dut result" & lf &
      " mult_1 --> " & integer'image(to_integer(unsigned(mult_1_dutin_s))) & " mult_2 --> " & integer'image(to_integer(unsigned(mult_2_dutin_s))) & " dut result --> " & integer'image(to_integer(unsigned(expected_unsigned_rslt_s))) severity error;
    end if;

  end procedure;

  procedure write_error2file_prcdr (
    --file file_obj          : out text;   
    variable line_obj      : out line;  
    signal expected_result : in std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0); -- or golden_value
    signal dut_result      : in std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
    unsigned_or_signed     : in std_logic;                                                                      -- '0' --> unsigned, '1' --> signed;
    inject_error           : in boolean  
  ) is
  begin

  if inject_error then
    write(line_obj, string'("error injected, no worry")); writeline(file_obj, line_obj);
  end if;

  if unsigned_or_signed = '1' then -- signed
    if not compare_results_func(expected_result, dut_result, inject_error) then
      write(line_obj, string'("signed expected/golden value not equal to dut result")); writeline(file_obj, line_obj); --> line break --> \n
      write(line_obj, string'(" mult_1 --> ")); write(line_obj, to_integer(signed(mult_1_dutin_s))); write(line_obj, string'(" mult_2 --> ")); write(line_obj, to_integer(signed(mult_2_dutin_s))); write(line_obj, string'(" dut result --> ")); write(line_obj, to_integer(signed(expected_signed_rslt_s))); writeline(file_obj, line_obj); --> line break --> \n
    end if;
  else -- unsigned
    if not compare_results_func(expected_result, dut_result, inject_error) then
      write(line_obj, string'("unsigned expected/golden value not equal to dut result")); writeline(file_obj, line_obj); --> line break --> \n
      write(line_obj, string'(" mult_1 --> ")); write(line_obj, to_integer(unsigned(mult_1_dutin_s))); write(line_obj, string'(" mult_2 --> ")); write(line_obj, to_integer(unsigned(mult_2_dutin_s))); write(line_obj, string'(" dut result --> ")); write(line_obj, to_integer(unsigned(expected_signed_rslt_s))); writeline(file_obj, line_obj); --> line break --> \n
    end if;
  end if;

  end procedure;

begin

  ----------------------------------------------------
  -- instantiation of design module with unsigned
  ----------------------------------------------------
  dut_inst_unsigned : entity work.comb_multiplier_mdl
    generic map(
      select_sign_g => unsigned_c,           -- '0': unsigned, '1': signed
      bit_length_g  => bitlengthof_dutgnrc_c -- define bit length for both inputs as same, the output length will be sum of the input lengths
    )
    port map
    (
      mult_1_i    => mult_1_dutin_s,
      mult_2_i    => mult_2_dutin_s,
      mult_rslt_o => dutout1_multrslt_s
    );

  ----------------------------------------------------
  -- instantiation of design module with signed
  ----------------------------------------------------
  dut_inst_signed : entity work.comb_multiplier_mdl
    generic map(
      select_sign_g => signed_c,             -- '0': unsigned, '1': signed
      bit_length_g  => bitlengthof_dutgnrc_c -- define bit length for both inputs as same, the output length will be sum of the input lengths
    )
    port map
    (
      mult_1_i    => mult_1_dutin_s,
      mult_2_i    => mult_2_dutin_s,
      mult_rslt_o => dutout2_multrslt_s
    );

  ----------------------------------------------------  
  -- generate the test stimulus
  ----------------------------------------------------
  stimulus_prcss : process
    variable rv                : randomptype;
    variable loop_limit_v      : integer;
    variable error_injection_v : boolean;
    variable line_obj          : line;
    --file file_obj              : text;
  begin
    
    -- need for randomization
    setrandomsalt (to_string(gmtime));
    rv.initseed(to_string(gmtime));

    -- wait for the start
    wait for wait_time_c;

    -- generate test cases --

    -- generate random values
    loop_limit_v := rv.randint(50, 200);

    report "loop limit --> " & integer'image(loop_limit_v) & lf & " error injection percentage --> " & integer'image(error_injection_percentage_c);
    -- open file with write mode
    file_open(file_obj, "dene", write_mode);
    write(line_obj, string'(" -- only simulation errors -- ")); writeline(file_obj, line_obj); 
    write(line_obj, string'(" loop limit --> ")); write(line_obj, loop_limit_v); writeline(file_obj, line_obj);
    write(line_obj, string'(" error injection percentage --> ")); write(line_obj, error_injection_percentage_c); writeline(file_obj, line_obj); writeline(file_obj, line_obj); --> line break --> \n


    for i in 1 to loop_limit_v loop

      -- generate random vales
      case rv.distint((100 - error_injection_percentage_c, error_injection_percentage_c)) is
        when 0 => -- 95%
          error_injection_v := false;
        when 1 => -- 5%
          error_injection_v := true;
        when others => -- not possible
          null;
      end case;
      mult_1_dutin_s <= rv.randslv(min => 0, max => (2 ** bitlengthof_dutgnrc_c) - 1, size => bitlengthof_dutgnrc_c);
      mult_2_dutin_s <= rv.randslv(min => 0, max => (2 ** bitlengthof_dutgnrc_c) - 1, size => bitlengthof_dutgnrc_c);
      wait for wait_delta_cycle_c;

      -- calculate expected values
      expected_unsigned_rslt_s <= std_logic_vector(unsigned(mult_1_dutin_s) * unsigned(mult_2_dutin_s));
      expected_signed_rslt_s   <= std_logic_vector(signed(mult_1_dutin_s) * signed(mult_2_dutin_s));
      wait for wait_time_c;

      -- check and log the errors to file
      write_error2file_prcdr(line_obj, expected_unsigned_rslt_s, dutout1_multrslt_s, unsigned_c, error_injection_v);
      write_error2file_prcdr(line_obj, expected_signed_rslt_s, dutout2_multrslt_s, signed_c, error_injection_v);      
      
      -- check with assertions
      check_with_assertion_prcdr(expected_unsigned_rslt_s, dutout1_multrslt_s, unsigned_c, error_injection_v);
      check_with_assertion_prcdr(expected_signed_rslt_s, dutout2_multrslt_s, signed_c, error_injection_v);

    end loop;

    -- close file
    file_close(file_obj);

    -- testing complete, stop with assertion
    sim_done_prcdr;

  end process stimulus_prcss;

end behavioral_rtl;
--/* The End*/