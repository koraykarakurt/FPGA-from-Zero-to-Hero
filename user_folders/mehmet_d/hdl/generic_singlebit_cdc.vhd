---------------------------------------------------------------------------------------------------
-- Author : Mehmet DEMİR
-- Description : One bit data synchronizer chain with generics.
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity generic_singlebit_cdc is
   generic (
      VENDOR              : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "intel", "other"
      RESET_ACTIVE_STATUS : std_logic            := '1'; -- '0': active low, '1': active high
      SYNCH_FF_NUMBER     : natural range 2 to 5 := 3 --  adjust according to FPGA/SoC family, clock speed and input rate of change
   );
   port (
      clk      : in std_logic;
      rst      : in std_logic; -- asynchronous active high or low reset according to "RESET_ACTIVE_STATUS" generic
      data_in  : in std_logic; -- asynchronous data input
      data_out : out std_logic -- synchronous data output
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is

begin

   xilinx_gen : if VENDOR = "xilinx" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');

      attribute async_reg                 : string;
      attribute async_reg of data_reg     : signal is "true";
      attribute shreg_extract             : string;
      attribute shreg_extract of data_reg : signal is "no";
   begin
      xilinx : process (clk, rst)
      begin
         if rst = RESET_ACTIVE_STATUS then
            data_reg <= (others => '0');

         elsif rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left

         end if;
      end process xilinx;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate xilinx_gen;

   intel_gen : if VENDOR = "intel" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');

      attribute altera_attribute of data_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute dont_merge                   : boolean;
      attribute dont_merge of data_reg       : signal is true;
      attribute preserve                     : boolean;
      attribute preserve of data_reg         : signal is true;
   begin
      intel : process (clk, rst)
      begin
         if rst = RESET_ACTIVE_STATUS then
            data_reg <= (others => '0');

         elsif rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left

         end if;
      end process intel;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate intel_gen;

   other_gen : if VENDOR = "other" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
   begin
      other_vendors : process (clk, rst)
      begin
         if rst = RESET_ACTIVE_STATUS then
            data_reg <= (others => '0');

         elsif rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left

         end if;
      end process other_vendors;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate other_gen;

end behavioral;
-- /* the end */ --