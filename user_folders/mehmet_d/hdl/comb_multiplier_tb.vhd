--------------------------------------------------------------------------------------------------
-- Company  : False Paths --> https://www.youtube.com/@falsepaths
-- Project  : Generic FIR Filter Design and Verification (GFIR)
-- Engineer : Mehmet Demir
--
-- Testbench Name : Combinational Multiplier Tesbench
-- VHDL Revision  : VHDL-2019
-- Target Devices : Aldec Riviera Pro 2023.04 / EDA playground
-- Tool Versions  : NA
-- Dependencies   : NA
-- Description    : Test the combinational multiplier module with selfchecking testbenches using assertions.
-- 
-- Revision --> 01v00; Date --> 23.01.25; JIRA No --> FIRF-9; Reason --> First Release
-- 
--------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; -- for arithmetic operations
--use std.textio.all;   -- for file operations on simulation
use std.env.all; -- for time operations on simulation

library osvvm;
use osvvm.randompkg.all; -- for random operations on simulation
use osvvm.randombasepkg.all; -- for salt operations on simulation 

entity comb_multiplier_tb is
  --port ();
end comb_multiplier_tb;

architecture behavioral_rtl of comb_multiplier_tb is

  -- comb_multiplier_tb
  constant wait_delta_cycle_c : time := 1 ps;
  constant wait_time_c        : time := 10 ns;

  -- comb_multiplier_mdl (dut/duv), initialize inputs not outputs

  constant bitlengthof_dutgnrc_c : natural range 2 to 255 := 8;

  signal mult_1_dutin_s           : std_logic_vector(bitlengthof_dutgnrc_c - 1 downto 0) := (others => '0');
  signal mult_2_dutin_s           : std_logic_vector(bitlengthof_dutgnrc_c - 1 downto 0) := (others => '0');
  signal dutout1_multrslt_s       : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
  signal dutout2_multrslt_s       : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0);
  signal expected_unsigned_rslt_s : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0) := (others => '0');
  signal expected_signed_rslt_s   : std_logic_vector((bitlengthof_dutgnrc_c + bitlengthof_dutgnrc_c) - 1 downto 0) := (others => '0');

begin

  -- instantiation of design module with unsigned
  dut_inst_unsigned : entity work.comb_multiplier_mdl
    generic map(
      select_sign_g => '0', -- '0': unsigned, '1': signed
      bit_length_g  => bitlengthof_dutgnrc_c -- define bit length for both inputs as same, the output length will be sum of the input lengths
    )
    port map
    (
      mult_1_i    => mult_1_dutin_s,
      mult_2_i    => mult_2_dutin_s,
      mult_rslt_o => dutout1_multrslt_s
    );

  -- instantiation of design module with signed
  dut_inst_signed : entity work.comb_multiplier_mdl
    generic map(
      select_sign_g => '1', -- '0': unsigned, '1': signed
      bit_length_g  => bitlengthof_dutgnrc_c -- define bit length for both inputs as same, the output length will be sum of the input lengths
    )
    port map
    (
      mult_1_i    => mult_1_dutin_s,
      mult_2_i    => mult_2_dutin_s,
      mult_rslt_o => dutout2_multrslt_s
    );
  -- generate the test stimulus
  stimulus_prcss : process
    variable rv           : randomptype;
    variable loop_limit_v : integer;
  begin

    setrandomsalt (to_string(gmtime));
    rv.initseed(to_string(gmtime));

    -- wait for the start
    wait for wait_time_c;

    -- generate test cases

    loop_limit_v := rv.randint(50, 200);

    report "loop limit --> " & integer'image(loop_limit_v);

    for i in 1 to loop_limit_v loop

      -- generate random vales
      mult_1_dutin_s <= rv.randslv(min => 0, max => (2 ** bitlengthof_dutgnrc_c) - 1, size => bitlengthof_dutgnrc_c);
      mult_2_dutin_s <= rv.randslv(min => 0, max => (2 ** bitlengthof_dutgnrc_c) - 1, size => bitlengthof_dutgnrc_c);
      wait for wait_delta_cycle_c;

      -- calculate expected values
      expected_unsigned_rslt_s <= std_logic_vector(unsigned(mult_1_dutin_s) * unsigned(mult_2_dutin_s));
      expected_signed_rslt_s   <= std_logic_vector(signed(mult_1_dutin_s) * signed(mult_2_dutin_s));
      wait for wait_time_c;

      -- check with assertions
      assert expected_unsigned_rslt_s = dutout1_multrslt_s report "unsigned expected/golden value not equal to dut result" & lf &
      " mult_1 --> " & integer'image(to_integer(unsigned(mult_1_dutin_s))) & " mult_2 --> " & integer'image(to_integer(unsigned(mult_2_dutin_s))) & " dut result --> " & integer'image(to_integer(unsigned(expected_unsigned_rslt_s))) severity error;

      assert expected_signed_rslt_s = dutout2_multrslt_s report "signed expected/golden value not equal to dut result" & lf &
      " mult_1 --> " & integer'image(to_integer(signed(mult_1_dutin_s))) & " mult_2 --> " & integer'image(to_integer(signed(mult_2_dutin_s))) & " dut result --> " & integer'image(to_integer(signed(expected_signed_rslt_s))) severity error;

    end loop;

    -- testing complete, stop with assertion
    assert false report lf &
    "---------------------------------------------------------------------------------------------------------------------" & lf & 
    "---------------------------------------------------------------------------------------------------------------------" & lf & 
    " simulation has been done properly at " & string'image(to_string(gmtime)) & " gmt +0 real time and at " & time'image(now) & " sim time, well done :)" & lf &
    "---------------------------------------------------------------------------------------------------------------------" & lf & 
    "---------------------------------------------------------------------------------------------------------------------" severity failure;

  end process stimulus_prcss;

end behavioral_rtl;
