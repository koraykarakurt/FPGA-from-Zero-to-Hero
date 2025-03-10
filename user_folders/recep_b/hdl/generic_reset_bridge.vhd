---------------------------------------------------------------------------------------------------
-- Author : Recep Büyüktuncer
-- Description : Generic reset bridge for asynchronous reset signal synchronization with configurable parameters
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_reset_bridge is
   generic (
        VENDOR : string := "Xilinx";               -- Vendor specification 
        RESET_ACTIVE_STATUS : std_logic := '1';   -- Active high or low reset 
        SYNCH_FF_NUMBER : integer range 2 to 5 := 2 -- Number of flip-flops for synchronization
    );
   port (
        clk     : in  std_logic;  -- Clock input
        rst_in  : in  std_logic;  -- Asynchronous reset input
        rst_out : out std_logic   
    );
end entity;

architecture behavioral of generic_reset_bridge is
    -- Internal signal for synchronization chain
   signal rst_sync : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => (not RESET_ACTIVE_STATUS));
begin
   process (clk, rst_in)
   begin
        if rst_in = RESET_ACTIVE_STATUS then  -- Asynchronous reset condition
            rst_sync <= (others => RESET_ACTIVE_STATUS);  -- Set all flip-flops to reset state
        elsif rising_edge(clk) then           -- Synchronous operation on clock edge
            -- Shift the synchronization chain
            rst_sync <= rst_sync(SYNCH_FF_NUMBER-2 downto 0) & (not RESET_ACTIVE_STATUS);
        end if;
   end process;

    -- Output the last flip-flop in the synchronization chain
    rst_out <= rst_sync(SYNCH_FF_NUMBER-1);
end behavioral;
