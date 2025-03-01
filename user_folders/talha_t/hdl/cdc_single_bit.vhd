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
use IEEE.STD_LOGIC_1164.ALL;

entity generic_reset_bridge is
	generic(
		FF_SIZE_SYNC: natural range 2 to 6 := 3;
		RST_ACTIVE_STATUS: std_logic := '1';
		VENDOR : string := "efinix"
	);
    Port ( 
		rst_in : in std_logic;
		clk : in std_logic;
		data_in : in std_logic;
		data_out : out std_logic
	);
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is
	signal data_sync_buffer : std_logic_vector (ff_size_sync-1 downto 0) := (others => (not RST_ACTIVE_STATUS));

begin

	xilinx_version: if (VENDOR = "xilinx") generate
		attribute async_reg : string;
		attribute async_reg of data_sync_buffer : signal is "true";
		attribute shreg_extract : string;
		attribute shreg_extract of data_sync_buffer : signal is "no";

		xilinx_rst_sync : process(clk, rst_in)
		begin
			if (rst_in = RST_ACTIVE_STATUS) then
				data_sync_buffer <= (others => RST_ACTIVE_STATUS);
			elsif (rising_edge(clk)) then
				data_sync_buffer <= data_sync_buffer(FF_SIZE_SYNC-2 downto 0) & (not RST_ACTIVE_STATUS);
			end if;
		end process xilinx_rst_sync;
	end generate xilinx_version;
	
	efinix_version : if (VENDOR = "efinix") generate
		attribute async_reg: boolean;
		attribute async_reg of data_sync_buffer : signal is true;

		efinix_rst_sync : process(clk, rst_in)
		begin
			if (rst_in = RST_ACTIVE_STATUS) then
				data_sync_buffer <= (others => RST_ACTIVE_STATUS);
			elsif (rising_edge(clk)) then
				data_sync_buffer <= data_sync_buffer(FF_SIZE_SYNC-2 downto 0) & (not RST_ACTIVE_STATUS);
			end if;
		end process efinix_rst_sync;
	end generate efinix_version;

	rst_out <= data_sync_buffer(FF_SIZE_SYNC-1);

end Behavioral;
