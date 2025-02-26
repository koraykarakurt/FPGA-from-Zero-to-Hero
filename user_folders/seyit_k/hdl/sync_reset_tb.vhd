---------------------------------------------------------------------------------------------------
-- Author : Seyit Kadir Kocak
-- Description : 
-- 	  A safe reset signal is ensured in the target clock domain.
-- More information (optional) :
--
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity sync_reset_tb is
end sync_reset_tb;

architecture test of sync_reset_tb is
    constant CLK_PERIOD : time := 10 ns;

    signal clk               : std_logic := '0';
    signal discrete_sync_in  : std_logic := '0';
    signal discrete_sync_out : std_logic;

    constant ff_value_test : integer := 4;

    component sync_reset
        generic (
            ff_value : integer := 2
        );
        port (
            clk               : in  std_logic;
            discrete_sync_in  : in  std_logic;
            discrete_sync_out : out std_logic
        );
    end component;

begin
    uut: sync_reset
        generic map (ff_value => ff_value_test)
        port map (
            clk               => clk,
            discrete_sync_in  => discrete_sync_in,
            discrete_sync_out => discrete_sync_out
        );

	clk_process: process
	begin
		while true loop
			clk <= '0';
			wait for CLK_PERIOD / 2;
			clk <= '1';
			wait for CLK_PERIOD / 2;
		end loop;
	end process;

    stimulus: process
    begin
    discrete_sync_in <= '0';
    wait for 15 ns;

    for i in 1 to 4 loop
        discrete_sync_in <= '1';
        wait for 15 ns;
        discrete_sync_in <= '0';
        wait for 15 ns;
    end loop;

    wait for 50 ns;
		
    report "!!!SIMULATION END!!!" severity failure;
    end process;

end test;


