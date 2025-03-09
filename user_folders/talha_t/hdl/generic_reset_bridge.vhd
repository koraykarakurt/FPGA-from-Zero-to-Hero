----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2025 20:45:45
-- Design Name: 
-- Module Name: generic_reset_bridge - Behavioral
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
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity generic_reset_bridge is
	generic(
   FF_SIZE_SYNC: natural range 2 to 6 := 3;
   RST_ACTIVE_STATUS: STD_LOGIC := '1';
   VENDOR : string := "efinix"
	);
    Port ( 
   rst_in : in STD_LOGIC;
   clk : in STD_LOGIC;
   rst_out : out STD_LOGIC
	);
end generic_reset_bridge;

architecture Behavioral of generic_reset_bridge is
	signal ff_sync_buffer : STD_LOGIC_VECTOR (FF_SIZE_SYNC-1 downto 0) := (others => (not RST_ACTIVE_STATUS));

begin

   xilinx_version: if (VENDOR = "xilinx") generate
   attribute async_reg : string;
   attribute async_reg of ff_sync_buffer : signal is "true";
   attribute shreg_extract : string;
   attribute shreg_extract of ff_sync_buffer : signal is "no";

   xilinx_rst_sync : process(clk, rst_in)
   begin
   	if (rst_in = RST_ACTIVE_STATUS) then
      ff_sync_buffer <= (others => RST_ACTIVE_STATUS);
   	elsif (rising_edge(clk)) then
      ff_sync_buffer <= ff_sync_buffer(FF_SIZE_SYNC-2 downto 0) & (not RST_ACTIVE_STATUS);
   	end if;
   end process xilinx_rst_sync;
	end generate xilinx_version;

   intel_version : if (VENDOR = "intel") generate
      attribute ALTERA_ATTRIBUTE                     : string;
      attribute ALTERA_ATTRIBUTE of ff_sync_buffer : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute PRESERVE                             : boolean;
      attribute PRESERVE of ff_sync_buffer         : signal is true;

      intel_reset_sync : process(clk)
      begin
         if (rising_edge(clk)) then
            ff_sync_buffer <= ff_sync_buffer(SYNCH_FF_NUMBER-2 downto 0) & data_in;
         end if;
      end process intel_reset_sync;
   end generate intel_version;   
   
   efinix_version : if (VENDOR = "efinix") generate
	attribute async_reg: boolean;
	attribute async_reg of ff_sync_buffer : signal is true;


   efinix_rst_sync : process(clk, rst_in)
   begin
   	if (rst_in = RST_ACTIVE_STATUS) then
      ff_sync_buffer <= (others => RST_ACTIVE_STATUS);
   	elsif (rising_edge(clk)) then
      ff_sync_buffer <= ff_sync_buffer(FF_SIZE_SYNC-2 downto 0) & (not RST_ACTIVE_STATUS);
   	end if;
   end process efinix_rst_sync;
	end generate efinix_version;

	rst_out <= ff_sync_buffer(FF_SIZE_SYNC-1);

end Behavioral;
