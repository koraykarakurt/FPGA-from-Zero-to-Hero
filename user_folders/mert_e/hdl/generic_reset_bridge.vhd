---------------------------------------------------------------------------------------------------
-- Company           : FPGA_FROM_ZERO_TO_HERO
-- Engineer          : Mert Ecevit
-- 
-- Create Date       : 26.02.2025 21:36
-- Design Name       : Asynchronous Reset Synchronizer + Reset Bridge
-- Module Name       : generic_reset_bridge - behavioral
-- Project Name      : FILTER
-- Target Devices    : Sipeed Tang Primer 20k Dock-Ext board, BASYS3 FPGA Board
-- Tool Versions     : Gowin EDA, XILINX Vivado 2025.1
-- Description       : Asynchronous reset synchronizer (single‐bit CDC) +
--                     synchronous de-assert with programmable strobe
-- 
-- Dependencies      : none
-- 
-- Revision:
-- Revision 0.03 - Added RST_STROBE_CYCLES generic
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity generic_reset_bridge is
  generic (
    VENDOR                : string               := "XILINX";   -- "XILINX", "ALTERA", "GOWIN"
    RESET_ACTIVE_STATUS   : std_logic            := '1';        -- '0': active low, '1': active high
    SYNCH_FF_NUMBER       : natural range 2 to 5 := 3;           -- depth of CDC chain
    RST_STROBE_CYCLES     : natural range 1 to 128 := 128
                             -- number of cycles to hold reset after sync de-assertion
  );
  port (
    clk     : in  std_logic;
    rst_in  : in  std_logic;   -- asynchronous reset input
    rst_out : out std_logic    -- synchronously de-asserted reset output
  );
end entity generic_reset_bridge;

architecture behavioral of generic_reset_bridge is

  -- counter range depends on RST_STROBE_CYCLES
  constant STROBE_MAX : integer := RST_STROBE_CYCLES - 1;
  signal   counter    : integer range 0 to STROBE_MAX := 0;

  -- CDC chain for single‐bit reset
  signal async_chain : std_logic_vector(SYNCH_FF_NUMBER-1 downto 0)
                       := (others => not RESET_ACTIVE_STATUS);
  signal sync_rst    : std_logic;

begin

  ------------------------------------------------------------------------
  -- generic_singlebit_cdc: asynchronous assert, synchronous de-assert
  ------------------------------------------------------------------------

-- Xilinx attributes - Düzeltilmiş versiyon
xilinx_impl : if VENDOR = "XILINX" generate
  attribute ASYNC_REG  : string;
  attribute DONT_TOUCH : string;
  attribute ASYNC_REG  of async_chain : signal is "TRUE";
  attribute DONT_TOUCH of async_chain : signal is "TRUE";
end generate xilinx_impl;
-- -- Intel/Altera attributes
-- altera_impl : if VENDOR = "ALTERA" generate
--   attribute ALTERA_ATTRIBUTE : boolean  of async_chain : signal is true;
--   attribute DONT_MERGE        : boolean  of async_chain : signal is true;
--   attribute PRESERVE          : boolean  of async_chain : signal is true;
-- end generate altera_impl;
--
 -- Gowin attributes
 --gowin_impl : if VENDOR = "GOWIN" generate
   --attribute SYN_PRESERVE : integer;
   --attribute SYN_PRESERVE of sync_reg : signal is 1;
 --end generate gowin_impl;
--
  -- Shift-register synchronizer
  proc_cdc_sync : process(clk, rst_in)
  begin
    if rst_in = RESET_ACTIVE_STATUS then
      async_chain <= (others => RESET_ACTIVE_STATUS);
    elsif rising_edge(clk) then
      async_chain <= async_chain(SYNCH_FF_NUMBER-2 downto 0) & (not RESET_ACTIVE_STATUS);
    end if;
  end process proc_cdc_sync;

  -- the synchronized reset (de-assert delayed by SYNCH_FF_NUMBER cycles)
  sync_rst <= async_chain(SYNCH_FF_NUMBER-1);

  ------------------------------------------------------------------------
  -- RST_OUT_PROC: hold reset active for RST_STROBE_CYCLES clock cycles
  ------------------------------------------------------------------------
  RST_OUT_PROC : process(clk, sync_rst)
  begin
    if sync_rst = RESET_ACTIVE_STATUS then
      -- reset katı olarak geri gelmiş: counter sıfırla, rst_out aktif et
      rst_out <= RESET_ACTIVE_STATUS;
      counter <= 0;
    elsif rising_edge(clk) then
      if counter = STROBE_MAX then
        
        rst_out <= not RESET_ACTIVE_STATUS;
      else
        
        counter <= counter + 1;
      end if;
    end if;
  end process RST_OUT_PROC;

end architecture behavioral;
