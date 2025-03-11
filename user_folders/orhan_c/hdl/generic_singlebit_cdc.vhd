----------------------------------------------------------------------------------------------------------------------------
-- Author : Orhan Çalışkan
-- Description : 
-- Generic single-bit clock domain crossing (CDC) synchronizer for different FPGA vendors.
-- This module ensures safe transfer of asynchronous signals across clock domains.
-- The synchronization depth can be adjusted using the SYNCH_FF_NUMBER generic parameter.
--
-- More information (optional) :
-- Design supports Intel, Xilinx, and other FPGA vendors with appropriate attributes. 
-- Attributes help synthesis tools recognize and optimize synchronization registers.
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity generic_singlebit_cdc is
   generic 
   (
      VENDOR              : string               := "intel" ; 	-- FPGA vendor name, valid values -> "xilinx", "intel"
      SYNCH_FF_NUMBER     : natural range 2 to 3 :=  3 			-- adjust according to FPGA/SoC family, clock speed and input rate of change

   );
   port 
   (
	   clk_dest		   : in std_logic; -- Destination clock domain
	   async_data   : in std_logic; -- Async input signal	
      sync_data    : out std_logic -- Sync output signal	 
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
   
begin
   -- Intel FPGA-specific implementation
   intel_cdc : if VENDOR = "intel" generate
      
	  signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
	  
     -- Intel Quartus-specific attributes to preserve synchronizer registers
     
     attribute PRESERVE                                : boolean;
     attribute SYNCHRONIZER_IDENTIFICATION             : string ;
     attribute PRESERVE of data_reg                    : signal is TRUE;       --data_reg protect during synthesize
     attribute SYNCHRONIZER_IDENTIFICATION of data_reg : signal is "FORCED";
     attribute ALTERA_ATTRIBUTE                        : string ;
     attribute ALTERA_ATTRIBUTE of data_reg            : signal is            --async data input is not included the timing analysis 	 
     "-name SDC_STATEMENT ""set_false_path -from [get_pins {data_reg[0]}] -to [all_registers]"""; 

   begin
      
	   -- Synchronizer process: Shifts the asynchronous input through flip-flops  
      -- to align with the destination clock, reducing metastability.
      process (clk_dest)
      begin
	     if rising_edge(clk_dest) then
           data_reg <= data_reg(data_reg'left-1 downto 0) & async_data;
		 end if;
	  end process;
     sync_data <= data_reg(data_reg'left);
   end generate intel_cdc;
	

   -- Xilinx FPGA-specific implementation
   xilinx_cdc : if VENDOR = "xilinx" generate
   
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');      
	  
	  -- Xilinx Vivado-specific attribute for CDC optimization
	
     attribute ASYNC_REG               : string;
     attribute DONT_TOUCH              : string;
     attribute ASYNC_REG of data_reg   : signal is "TRUE"; --Ensures safe synchronization of async signals 
     attribute DONT_TOUCH of data_reg  : signal is "TRUE"; --data_reg protect during synthesize
	   
   begin
      
	   -- Synchronizer process: Shifts the asynchronous input through flip-flops  
      -- to align with the destination clock, reducing metastability.
      process (clk_dest)
      begin
		 if rising_edge(clk_dest) then
          data_reg <= data_reg(data_reg'left-1 downto 0) & async_data;
		 end if;
      end process;
	  sync_data <= data_reg(data_reg'left);
   end generate xilinx_cdc;
end behavioral;
