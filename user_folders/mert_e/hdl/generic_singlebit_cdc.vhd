---------------------------------------------------------------------------------------------------
-- Company           : FPGA_FROM_ZERO_TO_HERO
-- Engineer          : Mert Ecevit
-- 
-- Create Date       : 26.02.2025 22:36
-- Design Name       : One Bit Synchronizer
-- Module Name       : one_bit_synchronizer - behavioral
-- Project Name      : FILTER
-- Target Devices    : Sipeed Tang Primer 20k Dock-Ext board
-- Tool Versions     : Gowin EDA
-- Description       : One bit data synchronizer chain with generics for CDC
-- 
-- Dependencies      : none
-- 
-- Revision:
-- Revision 0.01 - File created
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity one_bit_synchronizer is
    generic (
        VENDOR              : string               := "GOWIN"; -- "xilinx", "intel", "GOWIN"
        RESET_ACTIVE_STATUS : std_logic            := '0'; -- '0': active low, '1': active high
        SYNCH_FF_NUMBER     : natural range 2 to 5 := 2  -- Adjust according to metastability requirements
    );
    port (
        Fast_Clk  : in std_logic;
        Reset     : in std_logic;
        Data_In   : in std_logic;
        Data_Out  : out std_logic
    );
end entity one_bit_synchronizer;

architecture behavioral of one_bit_synchronizer is

    signal Sync_Reg : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => '0');

begin

    -- Xilinx-specific implementation
    xilinx_gen : if VENDOR = "xilinx" generate
        attribute async_reg                 : string;
        attribute async_reg of Sync_Reg      : signal is "true";
        attribute shreg_extract              : string;
        attribute shreg_extract of Sync_Reg  : signal is "no";
    begin
        xilinx_sync : process (Fast_Clk, Reset)
        begin
            if Reset = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(Fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & Data_In;
            end if;
        end process xilinx_sync;

        Data_Out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate xilinx_gen;

    -- Intel-specific implementation
    intel_gen : if VENDOR = "intel" generate
        attribute altera_attribute of Sync_Reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
        attribute dont_merge                   : boolean;
        attribute dont_merge of Sync_Reg        : signal is true;
        attribute preserve                     : boolean;
        attribute preserve of Sync_Reg          : signal is true;
    begin
        intel_sync : process (Fast_Clk, Reset)
        begin
            if Reset = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(Fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & Data_In;
            end if;
        end process intel_sync;

        Data_Out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate intel_gen;

    -- Generic implementation for GOWIN vendor
    gowin_gen : if VENDOR = "GOWIN" generate
    begin
        other_sync : process (Fast_Clk, Reset)
        begin
            if Reset = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(Fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & Data_In;
            end if;
        end process other_sync;

        Data_Out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate other_gen;

end architecture behavioral;
