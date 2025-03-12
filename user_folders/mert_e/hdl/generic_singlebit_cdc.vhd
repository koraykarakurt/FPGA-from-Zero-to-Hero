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
        VENDOR              : string               := "GOWIN";-- "XILINX", "ALTERA", "GOWIN"
        RESET_ACTIVE_STATUS : std_logic            := '0';-- '0': active low, '1': active high
        SYNCH_FF_NUMBER     : natural range 2 to 5 := 2-- Adjust according to metastability requirements
    );
    port (
        fast_Clk  : in std_logic;
        rst     : in std_logic;
        data_in   : in std_logic;
        data_out  : out std_logic
    );
end entity one_bit_synchronizer;

architecture behavioral of one_bit_synchronizer is

    signal Sync_Reg : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0) := (others => '0');

begin

    -- Xilinx-specific implementation
    xilinx_gen : if VENDOR = "XILINX" generate
        attribute ASYNC_REG                 : string;
        attribute ASYNC_REG  of Sync_Reg      : signal is "true";
        attribute DONT_TOUCH             : string;
        attribute DONT_TOUCH of Sync_Reg  : signal is "no";
    begin
        xilinx_sync : process (fast_Clk, rst)
        begin
            if rst = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & data_in;
            end if;
        end process xilinx_sync;

        data_out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate xilinx_gen;

    -- Altera-specific implementation
    altera_gen : if VENDOR = "ALTERA" generate
        attribute ALTERA_ATTRIBUTE             : boolean;
        attribute ALTERA_ATTRIBUTE of Sync_Reg : signal is true;
        attribute DONT_MERGE                   : boolean;
        attribute DONT_MERGE of Sync_Reg       : signal is true;
        attribute PRESERVE                     : boolean;
        attribute PRESERVE of Sync_Reg         : signal is true;
    begin
        altera_sync : process (fast_Clk, rst)
        begin
            if rst = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & data_in;
            end if;
        end process altera_gen_sync;

        data_out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate altera_gen;

    -- Generic implementation for GOWIN vendor
    gowin_gen : if VENDOR = "GOWIN" generate
        attribute MULTALU18X18_MODE                : integer;
        attribute MULTALU18X18_MODE of Sync_Reg    : signal is 1;
        attribute 
    begin
        other_sync : process (fast_Clk, rst)
        begin
            if rst = RESET_ACTIVE_STATUS then
                Sync_Reg <= (others => '0');
            elsif rising_edge(fast_Clk) then
                Sync_Reg <= Sync_Reg(SYNCH_FF_NUMBER-2 downto 0) & data_in;
            end if;
        end process other_sync;

        data_out <= Sync_Reg(SYNCH_FF_NUMBER-1);
    end generate other_gen;

end architecture behavioral;
