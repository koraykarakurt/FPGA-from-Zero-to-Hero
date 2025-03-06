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
      VENDOR          : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "altera"
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
   attribute ASYNC_REG  : string;
   attribute DONT_TOUCH : string;
   -- altera attribute definitions
   attribute ALTERA_ATTRIBUTE : string;
   attribute DONT_MERGE       : boolean;
   attribute PRESERVE         : boolean;
begin
   -- xilinx process
   xilinx_gen : if VENDOR = "xilinx" generate
      signal data_reg                   : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      attribute ASYNC_REG of data_reg   : signal is "true";
      attribute DONT_TOUCH of rst_chain : signal is "true";
   begin
      xilinx : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left
         end if;
      end process xilinx;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate xilinx_gen;

   -- altera process
   altera_gen : if VENDOR = "altera" generate
      signal data_reg                        : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      attribute ALTERA_ATTRIBUTE of data_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute DONT_MERGE of data_reg       : signal is true;
      attribute PRESERVE of data_reg         : signal is true;
   begin
      altera : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left
         end if;
      end process altera;
      data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate altera_gen;

end behavioral;