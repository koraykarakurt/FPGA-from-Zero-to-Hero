---------------------------------------------------------------------------------------------------
-- Author : Recep Büyüktuncer
-- Description : Generic single-bit CDC module for synchronizing signals between different clock domains
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_singlebit_cdc is
    generic (
        VENDOR : string := "Xilinx";               -- Vendor specification 
        SYNCH_FF_NUMBER : integer range 2 to 5 := 2 -- Number of flip-flops for synchronization
    );
    port (
        clk      : in  std_logic;  -- Single clock domain
        data_in  : in  std_logic;  -- Single-bit input signal
        data_out : out std_logic   
    );
end entity;

architecture behavioral of generic_singlebit_cdc is
   signal sync_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => '0');
   attribute ASYNC_REG : string;
   attribute ASYNC_REG of sync_chain : signal is "TRUE";
   attribute DONT_TOUCH : string;
   attribute DONT_TOUCH of sync_chain : signal is "TRUE";
begin
    -- Synchronization process
    sync_process : process (clk)
   begin
       if rising_edge(clk) then
           -- Shift the synchronization chain
           sync_chain <= sync_chain(SYNCH_FF_NUMBER-2 downto 0) & data_in;
       end if;
   end process sync_process;

   -- Output the synchronized signal
   data_out <= sync_chain(SYNCH_FF_NUMBER-1);
end behavioral;
