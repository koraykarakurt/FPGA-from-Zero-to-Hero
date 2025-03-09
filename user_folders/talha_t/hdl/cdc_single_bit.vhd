-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.02.2025 20:55:55
-- Design Name: 
-- Module Name: generic_cdc - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

library IEEE;
use IEEE.std_logic_1164.all;

entity generic_singlebit_cdc is
   generic(
      VENDOR : string := "efinix";
      SYNCH_FF_NUMBER: natural range 2 to 6 := 3
   );
    port ( 
      clk      : in std_logic;
      data_in  : in std_logic;
      data_out : out std_logic
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
   signal data_sync_buffer : std_logic_vector (SYNCH_FF_NUMBER-1 downto 0) := (others => '0');
begin
-- Xilinx attributes IOB, ASYNC_REG ve DONT_TOUCH
-- Altera attributes USEIOOFF, PRESERVE, ALTERA_ATTRIBUTE (inline constraint)
   xilinx_version: if (VENDOR = "xilinx") generate
      attribute async_reg : string;
      attribute async_reg of data_sync_buffer : signal is "true";
	  attribute DONT_TOUCH : string;
      attribute DONT_TOUCH of data_sync_buffer : signal is "true";

	  
      xilinx_data_sync : process(clk)
      begin
         if (rising_edge(clk)) then
            data_sync_buffer <= data_sync_buffer(SYNCH_FF_NUMBER-2 downto 0) & data_in;
         end if;
      end process xilinx_data_sync;
   end generate xilinx_version;
   
   
   
   intel_version : if (VENDOR = "intel") generate
      attribute ALTERA_ATTRIBUTE                     : string;
      attribute ALTERA_ATTRIBUTE of data_sync_buffer : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute PRESERVE                             : boolean;
      attribute PRESERVE of data_sync_buffer         : signal is true;

      intel_data_sync : process(clk)
      begin
         if (rising_edge(clk)) then
            data_sync_buffer <= data_sync_buffer(SYNCH_FF_NUMBER-2 downto 0) & data_in;
         end if;
      end process intel_data_sync;
   end generate intel_version;   
   
   
   efinix_version : if (VENDOR = "efinix") generate
      attribute async_reg: boolean;
      attribute async_reg of data_sync_buffer : signal is true;

      efinix_data_sync : process(clk)
      begin
         if (rising_edge(clk)) then
            data_sync_buffer <= data_sync_buffer(SYNCH_FF_NUMBER-2 downto 0) & data_in;
         end if;
      end process efinix_data_sync;
   end generate efinix_version;

   data_out <= data_sync_buffer(SYNCH_FF_NUMBER-1);

end Behavioral;
