---------------------------------------------------------------------------------------------------
-- Author : Mustafa YETIS
-- Description: Single-Bit Clock Domain Crossing Synchronizer
--					 2/3/4-stage synchronizer for single-bit signals crossing clock domains   
--   
-- More information (optional) :
-- 		Platform : FPGA Vendor-Independent        	
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
  generic (
    VENDOR              : string   := "Xilinx";			-- FPGA vendor ("Xilinx", "Intel")
    SYNCH_FF_NUMBER     : integer range 2 to 4 := 2	-- Number of sync stages (default 2)
  );
  port (
    clk_dest   : in  std_logic;  -- Destination clock
    data_async : in  std_logic;	-- Asynchronous input signal
    data_sync  : out std_logic	-- Synchronized output signal
  );
end entity;

architecture rtl of generic_singlebit_cdc is
  signal sync_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0);
begin

  ------------------------------------------------------------------------------
  -- Synchronizer Process: Metastability-hardened shift register
  -- - Shifts input data through chain on clk_dest edges
  ------------------------------------------------------------------------------
  process(clk_dest)
  begin
    if rising_edge(clk_dest) then
      sync_chain <= sync_chain(SYNCH_FF_NUMBER-2 downto 0) & data_async;
    end if;
  end process;

  data_sync <= sync_chain(SYNCH_FF_NUMBER-1);--MSB of shift reg is directed as synchronized data

  ------------------------------------------------------------------------------
  -- Vendor-Specific Metastability Attributes
  -- Xilinx: ASYNC_REG to place FFs in same slice
  -- Intel : Identify synchronizer for Quartus
  ------------------------------------------------------------------------------
  gen_xilinx_attr : if VENDOR = "Xilinx" generate
    -- Xilinx: ASYNC_REG for placement, DONT_TOUCH to prevent optimization
    attribute async_reg    : string;
    attribute dont_touch   : string;
    attribute async_reg    of sync_chain : signal is "true";
    attribute dont_touch   of sync_chain : signal is "true";
  end generate;

  gen_intel_attr : if VENDOR = "Intel" generate
    -- Intel: PRESERVE to retain registers, ALTERA_ATTRIBUTE for synchronization
    attribute preserve         : boolean;
    attribute altera_attribute : string;
    attribute preserve         of sync_chain : signal is true;
    attribute altera_attribute of sync_chain : signal is 
      "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
  end generate;

end architecture;