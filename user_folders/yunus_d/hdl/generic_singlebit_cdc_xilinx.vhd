---------------------------------------------------------------------------------------------------
-- Author      : Yunus Dag
-- Description : generic_singlebit_cdc
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
generic (
   VENDOR          : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "intel", “other”
   SYNCH_FF_NUMBER : natural range 2 to 5 := 3 -- adjust according to FPGA/SoC family, clock speed and input rate of change
);
port(
   clk      : in std_logic;
   data_in  : in std_logic;
   data_out : out std_logic
);
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
   signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => ('0')); 
   attribute ASYNC_REG : string;
   attribute ASYNC_REG of sync_regs : signal is "true";
   attribute DONT_TOUCH : string;
   attribute DONT_TOUCH of sync_regs : signal is "true";
begin
   --synchronizer process
   process(clk) 
   begin
      if(rising_Edge(clk)) then
         sync_regs <= sync_regs(SYNCH_FF_NUMBER-2 downto 0) & data_in;
      end if;
   end process;
   data_out <= sync_regs(SYNCH_FF_NUMBER-1);
end behavioral;