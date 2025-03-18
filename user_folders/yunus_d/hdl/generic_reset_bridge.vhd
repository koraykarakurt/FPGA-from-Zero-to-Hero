---------------------------------------------------------------------------------------------------
-- Author      : Yunus Dag
-- Description : generic_singlebit_cdc
--   
--   
--   
-- More information (optional) : When reset is active, all flip-flops are reset, 
-- and the reset signal reaches the output by bridging with the each clock pulse.   
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity generic_reset_bridge is
generic (
VENDOR 					: string              := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "intel", “other”
RESET_ACTIVE_STATUS : std_logic            := '1'; -- '0': active low, '1': active high
SYNCH_FF_NUMBER     : natural range 2 to 5 := 3 -- adjust according to FPGA/SoC family, clock speed and input rate of change
);
port(
	clk 		: in std_logic;
	rst_in 	: in std_logic;
	rst_out	: out std_logic
);
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is
begin

XILINX_GEN : if VENDOR = "xilinx" generate
signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => ('0')); 
attribute ASYNC_REG : string;
attribute ASYNC_REG of sync_regs : signal is "true";
attribute DONT_TOUCH : string;
attribute DONT_TOUCH of sync_regs : signal is "true";
begin
	process(clk, rst_in) begin
		if(rst_in=RESET_ACTIVE_STATUS) then
		sync_regs <= (others => (RESET_ACTIVE_STATUS));
		elsif(rising_Edge(clk)) then
		sync_regs <= sync_regs(SYNCH_FF_NUMBER -2 downto 0) & (not RESET_ACTIVE_STATUS);
		end if;
	end process;
	rst_out <= sync_regs(SYNCH_FF_NUMBER -1 );
end generate XILINX_GEN;

ALTERA_GEN : if VENDOR = "altera" generate
signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => ('0')); 
attribute PRESERVE : boolean;
attribute PRESERVE of sync_regs : signal is true;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of sync_regs : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED"";"&
																	"-name SDC_STATEMENT ""set_false_path -from [get_ports rst_in]"";" &
																	"-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER-1);

begin
	process(clk, rst_in) begin
		if(rst_in=RESET_ACTIVE_STATUS) then
		sync_regs <= (others => (RESET_ACTIVE_STATUS));
		elsif(rising_Edge(clk)) then
		sync_regs <= sync_regs(SYNCH_FF_NUMBER -2 downto 0) & (not RESET_ACTIVE_STATUS);
		end if;
	end process;
	rst_out <= sync_regs(SYNCH_FF_NUMBER -1 );
end generate ALTERA_GEN;
end behavioral;