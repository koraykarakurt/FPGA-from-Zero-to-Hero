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
    VENDOR              : string   := "Xilinx";			-- FPGA vendor ("Xilinx", "Altera")
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
  -- Vendor-Specific Metastability Attributes
  -- Xilinx: ASYNC_REG to place FFs in same slice
  -- Altera : Identify synchronizer for Quartus
  ------------------------------------------------------------------------------
  gen_xilinx_attr : if VENDOR = "Xilinx" generate
  
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
  
    -- Xilinx: ASYNC_REG for placement, DONT_TOUCH to prevent optimization
    attribute ASYNC_REG    : string;
    attribute DONT_TOUCH   : string;
    attribute ASYNC_REG    of sync_chain : signal is "true";
    attribute DONT_TOUCH   of sync_chain : signal is "true";
  end generate;

  gen_altera_attr : if VENDOR = "Altera" generate
  
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
  
    -- Altera: PRESERVE to retain registers, ALTERA_ATTRIBUTE for synchronization
    attribute PRESERVE         : boolean;
    attribute ALTERA_ATTRIBUTE : string;
    attribute PRESERVE         of sync_chain : signal is true;
    attribute ALTERA_ATTRIBUTE of sync_chain : signal is 
      "-name SYNCHRONIZER_IDENTIFICATION ""FORCED""";
	attribute altera_attribute of rst_async : signal is 
    "-name SDC_STATEMENT ""set_false_path -from [get_keepers rst_async] -to [get_keepers *sync_chain*]""";
  end generate;

end architecture;