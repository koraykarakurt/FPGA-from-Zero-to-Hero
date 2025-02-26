---------------------------------------------------------------------------------------------------
-- Author : Seyit Kadir Kocak
-- Description : 
-- 	  A safe reset signal is ensured in the target clock domain.
-- More information (optional) :
--    Asynchronous reset: When the reset signal is active, the circuit is reset immediately without waiting for the clock signal.
--    Synchronous reset: The reset signal takes effect only on the rising edge of the clock signal and resets the circuit.
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity sync_reset is
	generic (
		ff_value : integer := 2  -- Number of flip-flops
	);
	port (
		clk         		: in  std_logic;  
		discrete_sync_in 	: in  std_logic;  
		discrete_sync_out   : out std_logic   
	);
end sync_reset;

architecture behavioral of sync_reset is
    -- Flip-Flop array
    signal discrete_signal : std_logic_vector(ff_value-1 downto 0) := (others => '0');

begin
    process(clk)
    begin
        if rising_edge(clk) then
            discrete_signal(0) <= discrete_sync_in; 
            for i in 1 to ff_value-1 loop
                discrete_signal(i) <= discrete_signal(i-1); 
            end loop;
        end if;
    end process;
    discrete_sync_out <= discrete_signal(ff_value-1);
end behavioral;