---------------------------------------------------------------------------------------------------
-- Author : Utkan Genc
-- Description : Clock domain crossing for single bit data
-- This module provides a solution for clock domain crossing of single bit data.

-- More information (optional) :
-- This design is compatible with Xilinx and Altera FPGA.

-- Inline constraints:
-- ASYNC_REG (for XILINX): This attribute is used to optimize the placement of the flip flops.
-- DONT_TOUCH (for XILINX): This attribute is used to prevent the flip flops from being optimized.

-- ALTERA_ATTRIBUTE (for ALTERA): This attribute is used to optimize the placement of the flip flops.
-- PRESERVE (for ALTERA): This attribute is used to preserve the flip flops.

-- Assertions:
-- VENDOR must be "XILINX" or "ALTERA"
-- SYNC_FF_NUMBER must be between 2 and 5
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_singlebit_cdc is
   generic (
      VENDOR              : string               := "XILINX"; -- Only Xilinx and Altera are supported
      SYNC_FF_NUMBER      : integer range 2 to 5 := 2 -- Number of flip-flops
   );
   port (
      clk                 : in  std_logic; -- Destination clock
      data_i              : in  std_logic; -- from source clock domain
      data_o              : out std_logic  -- to destination clock domain
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
begin

   gen_xilinx : if (VENDOR = "XILINX") generate
      signal sync_reg : std_logic_vector(SYNC_FF_NUMBER - 1 downto 0) := (others => '0'); -- Synchronized register
      -- Inline constraints
      attribute ASYNC_REG              : string;
      attribute ASYNC_REG of sync_reg  : signal is "true";
      attribute DONT_TOUCH             : string;
      attribute DONT_TOUCH of sync_reg : signal is "true";
   begin
      process(clk)
      begin
         if rising_edge(clk) then
            sync_reg <= sync_reg(SYNC_FF_NUMBER - 2 downto 0) & data_i;
         end if;
      end process;
      data_o <= sync_reg(SYNC_FF_NUMBER - 1);
   end generate gen_xilinx;

   gen_altera : if VENDOR = "ALTERA" generate
      signal sync_reg : std_logic_vector(SYNC_FF_NUMBER - 1 downto 0) := (others => '0'); -- Synchronized register
      -- Inline constraints
      attribute ALTERA_ATTRIBUTE             : string;
      attribute ALTERA_ATTRIBUTE of sync_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS"" " &
                                                "-name SDC_STATEMENT ""set_false_path -from [get_pins {data_i}] -to [get_registers {sync_reg[" & 
                                                integer'image(SYNC_FF_NUMBER-1) & "]}]""";
      attribute PRESERVE                     : boolean;
      attribute PRESERVE of sync_reg         : signal is true;
   begin
      process(clk)
      begin
         if rising_edge(clk) then
            sync_reg <= sync_reg(SYNC_FF_NUMBER - 2 downto 0) & data_i;
         end if;
      end process;
      data_o <= sync_reg(SYNC_FF_NUMBER - 1);
   end generate gen_altera;

   -- Simulation assertions (Assertions are not compatible with synthesis, so we use synthesis translate_off/on)
   -- synthesis translate_off
   assert VENDOR = "XILINX" or VENDOR = "ALTERA" report "Unsupported vendor: " & VENDOR severity failure;
   assert SYNC_FF_NUMBER >= 2 and SYNC_FF_NUMBER <= 5 report "SYNC_FF_NUMBER must be between 2 and 5" severity failure;
   -- synthesis translate_on

end behavioral;
