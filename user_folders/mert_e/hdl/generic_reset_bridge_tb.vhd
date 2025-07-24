library ieee;
use ieee.std_logic_1164.all;

use std.textio.all;
use std.env.finish;

entity reset_sync_tb is
end reset_sync_tb;

architecture sim of reset_sync_tb is

  constant clk_hz : integer := 100e6;
  constant clk_period : time := 1 sec / clk_hz;

  signal clk : std_logic := '1';
  signal rst_in : std_logic := '0';
  signal rst_out : std_logic;

begin

  clk <= not clk after clk_period / 2;

  -- Instantiate the Device Under Test (DUT)
  DUT : entity work.generic_reset_bridge(behavioral)
  generic map (
    SYNCH_FF_NUMBER       => 3,              -- 3 FF synchronizer chain
    RST_STROBE_CYCLES     => 5               -- Hold reset for 5 additional cycles
  )
  port map (
    clk     => clk,
    rst_in  => rst_in,
    rst_out => rst_out
  );

  SEQUENCER_PROC : process
  begin
    
    -- Initial wait to see system start
    wait for clk_period * 10;
    
    -- Test Case 1: Short reset pulse
    report "=== Test Case 1: Short reset pulse ===";
    rst_in <= '1';
    wait for clk_period * 2;  -- Hold reset for 2 cycles
    rst_in <= '0';
    
    -- Wait to observe synchronous deassertion + strobe cycles
    -- Expected: 3 cycles for sync + 5 cycles for strobe = 8 cycles total
    wait for clk_period * 15;
    
    -- Test Case 2: Very short reset pulse (less than 1 cycle)
    report "=== Test Case 2: Very short reset pulse ===";
    rst_in <= '1';
    wait for clk_period / 4;  -- Hold reset for quarter cycle
    rst_in <= '0';
    
    -- Wait to observe behavior
    wait for clk_period * 15;
    
    -- Test Case 3: Long reset pulse
    report "=== Test Case 3: Long reset pulse ===";
    rst_in <= '1';
    wait for clk_period * 10;  -- Hold reset for 10 cycles
    rst_in <= '0';
    
    -- Wait to observe synchronous deassertion + strobe cycles
    wait for clk_period * 15;
    
    -- Test Case 4: Multiple consecutive reset pulses
    report "=== Test Case 4: Multiple consecutive reset pulses ===";
    rst_in <= '1';
    wait for clk_period * 2;
    rst_in <= '0';
    wait for clk_period * 3;  -- Don't wait for full deassertion
    
    rst_in <= '1';            -- Apply reset again before previous one fully deasserted
    wait for clk_period * 2;
    rst_in <= '0';
    
    -- Wait to observe final behavior
    wait for clk_period * 20;
    
    -- Test Case 5: Asynchronous reset during different clock phases
    report "=== Test Case 5: Asynchronous reset at different clock phases ===";
    wait for clk_period / 4;  -- Wait for quarter cycle (mid clock phase)
    rst_in <= '1';
    wait for clk_period * 2;
    rst_in <= '0';
    
    wait for clk_period * 15;
    
    report "=== Simulation completed successfully ===";
    finish;
  end process;

  -- Monitor process to display key signals
  MONITOR_PROC : process
  begin
    wait for 1 ns;  -- Small delay to avoid delta cycle issues
    loop
      wait until rising_edge(clk) or rst_in'event or rst_out'event;
      
      -- Report significant events
      if rst_in'event then
        if rst_in = '1' then
          report "Time " & time'image(now) & ": rst_in asserted (async)";
        else
          report "Time " & time'image(now) & ": rst_in deasserted";
        end if;
      end if;
      
      if rst_out'event then
        if rst_out = '1' then
          report "Time " & time'image(now) & ": rst_out asserted";
        else
          report "Time " & time'image(now) & ": rst_out deasserted (sync)";
        end if;
      end if;
    end loop;
  end process;

end architecture;