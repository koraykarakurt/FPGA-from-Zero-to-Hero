---------------------------------------------------------------------------------------------------
-- Author : Recep Büyüktuncer
-- Description : Generic single-bit CDC module for synchronizing signals between different clock domains
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
    generic (
        VENDOR          : string               := "xilinx"; 
        SYNCH_FF_NUMBER : natural range 2 to 5 := 3
    );
    port (
        clk      : in std_logic;
        data_in  : in std_logic;
        data_out : out std_logic
    );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
begin

    xilinx_section : if VENDOR = "xilinx" generate
        signal regs : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
        attribute DONT_TOUCH : string;
        attribute ASYNC_REG : string;
        attribute DONT_TOUCH of regs : signal is "true";
        attribute ASYNC_REG of regs : signal is "true";
    begin
        process(clk)
        begin
            if rising_edge(clk) then
                regs <= regs(SYNCH_FF_NUMBER - 2 downto 0) & data_in;
            end if;
        end process;
        data_out <= regs(SYNCH_FF_NUMBER - 1);
    end generate;

    altera_section : if VENDOR = "altera" generate
        signal regs : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
        attribute PRESERVE : boolean;
        attribute ALTERA_ATTRIBUTE : string;
        attribute PRESERVE of regs : signal is true;
        attribute ALTERA_ATTRIBUTE of regs : signal is 
            "-name SDC_STATEMENT ""set_false_path -from [get_pins data_in]"";" &
            "-name SYNCHRONIZER_IDENTIFICATION ""FORCED"";" &
            "-name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER - 1);
    begin
        process(clk)
        begin
            if rising_edge(clk) then
                regs <= regs(SYNCH_FF_NUMBER - 2 downto 0) & data_in;
            end if;
        end process;
        data_out <= regs(SYNCH_FF_NUMBER - 1);
    end generate;

end behavioral;
