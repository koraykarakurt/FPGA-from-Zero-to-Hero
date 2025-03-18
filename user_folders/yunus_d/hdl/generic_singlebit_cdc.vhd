---------------------------------------------------------------------------------------------------
-- Author      : Yunus Dag
-- Description : generic_singlebit_cdc
--   
--   
--   
-- More information (optional) : This design sychonizes input signal data_in in clk clock domain
-- and output is sychonized data_in signal    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
generic (
   VENDOR          : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "altera"
   SYNCH_FF_NUMBER : natural range 2 to 5 := 3 -- adjust according to FPGA/SoC family, clock speed and input rate of change
);
port(
   clk      : in std_logic;
   data_in  : in std_logic;
   data_out : out std_logic
);
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
begin

XILINX_GEN : if VENDOR = "xilinx" generate
signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => ('0')); 
attribute ASYNC_REG : string;
attribute ASYNC_REG of sync_regs : signal is "true";
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of sync_regs : signal is "true";
begin
process(clk)
   begin
      if(rising_Edge(clk)) then
         sync_regs <= sync_regs(SYNCH_FF_NUMBER-2 downto 0) & data_in;
      end if;
   end process;
   data_out <= sync_regs(SYNCH_FF_NUMBER-1);
end generate XILINX_GEN;

ALTERA_GEN : if VENDOR = "altera" generate
	signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => ('0')); 
	attribute PRESERVE : boolean;
	attribute PRESERVE of sync_regs : signal is true;
	attribute ALTERA_ATTRIBUTE : string;
	attribute ALTERA_ATTRIBUTE of sync_regs : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED"";"&
																		"-name SDC_STATEMENT ""set_false_path -from [get_pins data_in]"";" &
																		"-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER-1);
begin
	process(clk) 
		begin
			if(rising_edge(clk)) then
				sync_regs <= sync_regs(SYNCH_FF_NUMBER-2 downto 0) & data_in;
			end if;
	end process;
	data_out <= sync_regs(SYNCH_FF_NUMBER-1);
end generate ALTERA_GEN;

end behavioral;

