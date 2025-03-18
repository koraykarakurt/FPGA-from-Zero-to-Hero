---------------------------------------------------------------------------------------------------
-- Author : Mustafa YETIS
-- Description: Reset Synchronizer Bridge for Cross-Domain Reset Deassertion.
--				Synchronizes reset deassertion to destination clock domain using a chain of FFs.
--          The module synchronizes the deassertion edge of rst_async (asynchronous reset) 
--				to clk_dest, ensuring the reset release is aligned with the destination clock. 
--				The Design Supports Xilinx/Altera attributes for CDC.      
-- More information (optional) :
-- 		Platform   : FPGA Vendor-Independent      
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_reset_bridge is
  generic (
    VENDOR              : string		:= "Xilinx";	--FPGA vendor ("Xilinx", "Altera")
    RESET_ACTIVE_STATUS : std_logic	:= '1';			--Active level of reset ('0' or '1')
    SYNCH_FF_NUMBER     : integer range 2 to 4	:= 2	--Number of sync stages (default 2)
  );
  port (
    clk_dest  : in  std_logic;	-- Destination clock
    rst_async : in  std_logic;	-- Asynchronous reset input
    rst_sync  : out std_logic		-- Asynchronously asserted Synchronously de-asserted reset output
  );
end entity;

architecture rtl of generic_reset_bridge is
  signal sync_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => RESET_ACTIVE_STATUS);
begin

  ------------------------------------------------------------------------------
  -- Vendor-Specific Metastability Attributes
  -- Xilinx: ASYNC_REG to place FFs in same slice
  -- Altera : Identify synchronizer for Quartus
  ------------------------------------------------------------------------------
  gen_xilinx_attr : if VENDOR = "Xilinx" generate
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
  
    -- Xilinx: ASYNC_REG for placement, DONT_TOUCH to prevent optimization
    attribute ASYNC_REG    : string;
    attribute DONT_TOUCH   : string;
    attribute ASYNC_REG    of sync_chain : signal is "true";
    attribute DONT_TOUCH   of sync_chain : signal is "true";
  end generate;


  gen_altera_attr : if VENDOR = "Altera" generate
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
  
    -- Altera: PRESERVE to retain registers, ALTERA_ATTRIBUTE for synchronization
    attribute PRESERVE         : boolean;
    attribute ALTERA_ATTRIBUTE : string;
    attribute PRESERVE         of sync_chain : signal is true;
    attribute ALTERA_ATTRIBUTE of sync_chain : signal is 
      "-name SYNCHRONIZER_IDENTIFICATION ""FORCED""";
	 -- False path from rst_async to first sync stage (sync_chain(0))
    attribute ALTERA_ATTRIBUTE of rst_async : signal is 
      "-name SDC_STATEMENT ""set_false_path -from [get_keepers rst_async] -to [get_keepers sync_chain(0)]""";
  end generate;

end architecture;