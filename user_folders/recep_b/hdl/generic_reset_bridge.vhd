---------------------------------------------------------------------------------------------------
-- Author : Recep Büyüktuncer
-- Description : Generic reset bridge for asynchronous reset signal synchronization with configurable parameters
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity generic_reset_bridge is
    generic (
        VENDOR              : string := "xilinx";              -- "xilinx", "altera", or "other"
        RESET_ACTIVE_STATUS : std_logic := '1';                -- '1': active high, '0': active low
        SYNCH_FF_NUMBER     : natural range 2 to 5 := 3        -- Flip-flop stages for synchronization
    );
    port (
        clk     : in  std_logic;       -- Clock input
        rst_in  : in  std_logic;       -- Asynchronous reset input
        rst_out : out std_logic        -- Synchronized reset output
    );
end entity;

architecture behavioral of generic_reset_bridge is
begin

    --  XILINX VENDOR SYNC --
    XILINX_GEN : if VENDOR = "xilinx" generate
        signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => '0');
        attribute ASYNC_REG   : string;
        attribute DONT_TOUCH  : string;
        attribute ASYNC_REG of sync_regs   : signal is "true";
        attribute DONT_TOUCH of sync_regs  : signal is "true";
    begin
        process(clk, rst_in)
        begin
            if rst_in = RESET_ACTIVE_STATUS then
                sync_regs <= (others => RESET_ACTIVE_STATUS);
            elsif rising_edge(clk) then
                sync_regs <= sync_regs(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS);
            end if;
        end process;
        rst_out <= sync_regs(SYNCH_FF_NUMBER - 1);
    end generate;

    -- ALTERA (INTEL) VENDOR SYNC --
    ALTERA_GEN : if VENDOR = "altera" generate
        signal sync_regs : std_logic_vector(SYNCH_FF_NUMBER -1 downto 0) := (others => '0');
        attribute PRESERVE         : boolean;
        attribute ALTERA_ATTRIBUTE : string;
        attribute PRESERVE of sync_regs : signal is true;
        attribute ALTERA_ATTRIBUTE of sync_regs : signal is 
            "-name SYNCHRONIZER_IDENTIFICATION ""FORCED""; " &
            "-name SDC_STATEMENT ""set_false_path -from [get_ports rst_in]""; " &
            "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER - 1);
    begin
        process(clk, rst_in)
        begin
            if rst_in = RESET_ACTIVE_STATUS then
                sync_regs <= (others => RESET_ACTIVE_STATUS);
            elsif rising_edge(clk) then
                sync_regs <= sync_regs(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS);
            end if;
        end process;
        rst_out <= sync_regs(SYNCH_FF_NUMBER - 1);
    end generate;

end architecture;

