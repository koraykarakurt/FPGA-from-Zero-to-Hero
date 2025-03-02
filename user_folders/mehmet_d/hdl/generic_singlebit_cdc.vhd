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
use IEEE.std_logic_1164.all;

entity generic_singlebit_cdc is
   generic (
      VENDOR          : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "altera", "other"
      SYNCH_FF_NUMBER : natural range 2 to 5 := 3         --  adjust according to FPGA/SoC family, clock speed and input rate of change
   );
   port (
      clk      : in std_logic;
      data_in  : in std_logic; -- asynchronous data input
      data_out : out std_logic -- synchronous data output
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
   -- xilinx attribute definitions
   attribute async_reg  : string;
   attribute dont_touch : string;
   -- altera attribute definitions
   attribute altera_attribute : string;
   attribute dont_merge       : boolean;
   attribute preserve         : boolean;
begin

   xilinx_gen : if VENDOR = "xilinx" generate
      signal data_reg                   : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
      attribute async_reg of data_reg   : signal is "true";
      attribute dont_touch of rst_chain : signal is "true";
   begin
      xilinx : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left
         end if;
      end process xilinx;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate xilinx_gen;

   altera_gen : if VENDOR = "altera" generate
      signal data_reg                        : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
      attribute altera_attribute of data_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute dont_merge of data_reg       : signal is true;
      attribute preserve of data_reg         : signal is true;
   begin
      altera : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left
         end if;
      end process altera;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate altera_gen;

   other_gen : if VENDOR = "other" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0');
   begin
      other_vendors : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left
         end if;
      end process other_vendors;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate other_gen;

end behavioral;