---------------------------------------------------------------------------------------------------
-- Author : Mustafa YETIS
-- Description: Reset Synchronizer Bridge for Cross-Domain Reset Deassertion.
--				Synchronizes reset deassertion to destination clock domain using a chain of FFs.
--          The module synchronizes the deassertion edge of rst_async (asynchronous reset) 
--				to clk_dest, ensuring the reset release is glitch-free and 
--				aligned with the destination clock.The Design Supports Xilinx/Intel attributes for CDC.      
-- More information (optional) :
-- 		Platform   : FPGA Vendor-Independent      
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_reset_bridge is
  generic (
    VENDOR              : string		:= "Xilinx";	--FPGA vendor ("Xilinx", "Intel")
    RESET_ACTIVE_STATUS : std_logic	:= '1';			--Active level of reset ('0' or '1')
    SYNCH_FF_NUMBER     : integer range 2 to 4	:= 2				--Number of sync stages (default 2)
  );
  port (
    clk_dest  : in  std_logic;	-- Destination clock
    rst_async : in  std_logic;	-- Asynchronous reset input
    rst_sync  : out std_logic		-- Synchronized reset output
  );
end entity;

architecture rtl of generic_reset_bridge is
  signal sync_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0);
begin

  ------------------------------------------------------------------------------
  -- Synchronizer Process: Shift register for metastability hardening
  -- - Resets all FFs asynchronously when rst_async is active
  -- - Shifts deasserted value through chain on clk_dest edges
  ------------------------------------------------------------------------------
  process(clk_dest, rst_async)
  begin
    if rst_async = RESET_ACTIVE_STATUS then
      sync_chain <= (others => RESET_ACTIVE_STATUS);--fill all FFs with RESET_ACTIVE_STATUS val
    elsif rising_edge(clk_dest) then
      sync_chain <= sync_chain(SYNCH_FF_NUMBER-2 downto 0) & not RESET_ACTIVE_STATUS;
    end if;
  end process;

  rst_sync <= sync_chain(SYNCH_FF_NUMBER-1);--MSB of shiftreg is directed as synch-rst-deassertion

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