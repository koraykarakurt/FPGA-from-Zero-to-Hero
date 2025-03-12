---------------------------------------------------------------------------------------------------
-- Company           : FPGA_FROM_ZERO_TO_HERO
-- Engineer          : Mert Ecevit
-- 
-- Create Date       : 26.02.2025 21:36
-- Design Name       : Asynchronous Reset Synchronizer
-- Module Name       : async_reset_synchronizer - behavioral
-- Project Name      : FILTER
-- Target Devices    : Sipeed Tang Primer 20k Dock-Ext board
-- Tool Versions     : Gowin EDA
-- Description       : Asynchronous reset synchronizer with generics for CDC
-- 
-- Dependencies      : none
-- 
-- Revision:
-- Revision 0.01 - File created
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity async_reset_synchronizer is
    generic (
        VENDOR              : string               := "GOWIN"; -- "XILINX", "ALTERA", "GOWIN"
        RESET_ACTIVE_STATUS : std_logic            := '1';      -- '0': active low, '1': active high
        ASYNCH_FF_NUMBER     : natural range 2 to 5 := 2         
    );
    port (
        clk     : in std_logic;
        rst_in  : in std_logic;  -- asynchronous reset input
        rst_out : out std_logic  -- synchronously de-asserted reset output
    );
end entity async_reset_synchronizer;

architecture behavioral of async_reset_synchronizer is

    signal async_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => (not RESET_ACTIVE_STATUS));

begin

    -- Xilinx-specific implementation
    xilinx_impl : if VENDOR = "XILINX" generate
        attribute async_reg                     : string;
        attribute async_reg of async_chain        : signal is "true";
        attribute shreg_extract                  : string;
        attribute shreg_extract of async_chain    : signal is "no";
    begin
        proc_xilinx_sync : process (clk, rst_in)
        begin
            if rst_in = RESET_ACTIVE_STATUS then
                async_chain <= (others => RESET_ACTIVE_STATUS);
            elsif rising_edge(clk) then
                async_chain <= async_chain(SYNCH_FF_NUMBER-2 downto 0) & (not RESET_ACTIVE_STATUS);
            end if;
        end process proc_xilinx_sync;

        rst_out <= async_chain(SYNCH_FF_NUMBER-1);
    end generate xilinx_impl;

    -- Intel-specific implementation
    intel_impl : if VENDOR = "intel" generate
        attribute altera_attribute of async_chain : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
        attribute dont_merge                     : boolean;
        attribute dont_merge of async_chain        : signal is true;
        attribute preserve                       : boolean;
        attribute preserve of async_chain          : signal is true;
    begin
        proc_intel_sync : process (clk, rst_in)
        begin
            if rst_in = RESET_ACTIVE_STATUS then
                async_chain <= (others => RESET_ACTIVE_STATUS);
            elsif rising_edge(clk) then
                async_chain <= async_chain(SYNCH_FF_NUMBER-2 downto 0) & (not RESET_ACTIVE_STATUS);
            end if;
        end process proc_intel_sync;

        rst_out <= async_chain(SYNCH_FF_NUMBER-1);
    end generate intel_impl;

    -- GOWIN-specific implementation
    gowin_impl : if VENDOR = "GOWIN" generate
    begin
        proc_gowin_sync : process (clk, rst_in)
        begin
            if rst_in = RESET_ACTIVE_STATUS then
                async_chain <= (others => RESET_ACTIVE_STATUS);
            elsif rising_edge(clk) then
                async_chain <= async_chain(SYNCH_FF_NUMBER-2 downto 0) & (not RESET_ACTIVE_STATUS);
            end if;
        end process proc_gowin_sync;

        rst_out <= async_chain(SYNCH_FF_NUMBER-1);
    end generate gowin_impl;

end architecture behavioral;
