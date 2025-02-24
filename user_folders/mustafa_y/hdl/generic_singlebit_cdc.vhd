---------------------------------------------------------------------------------------------------
-- Author : Mustafa YETIS
-- Description: Single-Bit Clock Domain Crossing Synchronizer
--					 2/3-stage synchronizer for single-bit signals crossing clock domains   
--   
-- More information (optional) :
-- 		Platform : FPGA Vendor-Independent        	
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
  generic (
    VENDOR              : string   := "Xilinx";	-- FPGA vendor ("Xilinx", "Intel")
    RESET_ACTIVE_STATUS : std_logic := '1';		-- Active level of reset ('0' or '1')
    SYNCH_FF_NUMBER     : integer  := 2			-- Number of sync stages (default 2)
  );
  port (
    clk_dest   : in  std_logic;  -- Destination clock
    rst_async  : in  std_logic;	-- Asynchronous reset
    data_async : in  std_logic;	-- Asynchronous input signal
    data_sync  : out std_logic	-- Synchronized output signal
  );
end entity;

architecture rtl of generic_singlebit_cdc is
  signal sync_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0);
begin

  ------------------------------------------------------------------------------
  -- Synchronizer Process: Metastability-hardened shift register
  -- - Resets all FFs to '0' when rst_async is active
  -- - Shifts input data through chain on clk_dest edges
  ------------------------------------------------------------------------------
  process(clk_dest, rst_async)
  begin
    if rst_async = RESET_ACTIVE_STATUS then
      sync_chain <= (others => '0');
    elsif rising_edge(clk_dest) then
      sync_chain <= sync_chain(SYNCH_FF_NUMBER-2 downto 0) & data_async;
    end if;
  end process;

  data_sync <= sync_chain(SYNCH_FF_NUMBER-1);

  ------------------------------------------------------------------------------
  -- Vendor-Specific Metastability Attributes
  -- Xilinx: ASYNC_REG to place FFs in same slice
  -- Intel : Identify synchronizer for Quartus
  ------------------------------------------------------------------------------
  gen_xilinx_attr : if VENDOR = "Xilinx" generate
    attribute async_reg : string;
    attribute async_reg of sync_chain : signal is "true";
  end generate;

  gen_intel_attr : if VENDOR = "Intel" generate
    attribute altera_attribute : string;
    attribute altera_attribute of sync_chain : signal is
      "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
  end generate;

end architecture;