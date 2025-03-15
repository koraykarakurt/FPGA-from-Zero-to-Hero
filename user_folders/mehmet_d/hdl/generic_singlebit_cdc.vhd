---------------------------------------------------------------------------------------------------
-- Author : Mehmet DEMİR
-- Description : One bit data synchronizer chain with generics. This module synchronize the one bit
-- data, after that the synchronous data output can be used in the clock domain.
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
      VENDOR          : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "altera", "efinity", "microchip", "lattice"
      SYNCH_FF_NUMBER : natural range 2 to 5 := 3         --  adjust according to FPGA/SoC family, clock speed and input rate of change
   );
   port (
      clk        : in std_logic;
      data_async : in std_logic; -- asynchronous data input
      data_sync  : out std_logic -- synchronous data output
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is
begin
   -- xilinx process
   xilinx_gen : if VENDOR = "xilinx" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      -- xilinx attributes
      attribute ASYNC_REG              : string;
      attribute ASYNC_REG of data_reg  : signal is "true";
      attribute DONT_TOUCH             : string;
      attribute DONT_TOUCH of data_reg : signal is "true";
   begin
      xilinx : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_async; -- shift left
         end if;
      end process xilinx;
      data_sync <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate xilinx_gen;

   -- altera process
   altera_gen : if VENDOR = "altera" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      -- altera attributes
      attribute ALTERA_ATTRIBUTE             : string;
      attribute ALTERA_ATTRIBUTE of data_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute DONT_MERGE                   : boolean;
      attribute DONT_MERGE of data_reg       : signal is true;
      attribute PRESERVE                     : boolean;
      attribute PRESERVE of data_reg         : signal is true;
   begin
      altera : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_async; -- shift left
         end if;
      end process altera;
      data_sync <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate altera_gen;

   -- efinity process
   efinity_gen : if VENDOR = "efinity" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      -- efinity attributes
      attribute ASYNC_REG                : boolean;
      attribute ASYNC_REG of data_reg    : signal is true;
      attribute SYN_KEEP                 : boolean;
      attribute SYN_KEEP of data_reg     : signal is true;
      attribute SYN_PRESERVE             : boolean;
      attribute SYN_PRESERVE of data_reg : signal is true;
   begin
      efinity : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_async; -- shift left
         end if;
      end process efinity;
      data_sync <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate efinity_gen;

   -- microchip process
   microchip_gen : if VENDOR = "microchip" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      -- microchip attributes
      attribute SYN_KEEP                 : boolean;
      attribute SYN_KEEP of data_reg     : signal is true;
      attribute SYN_PRESERVE             : boolean;
      attribute SYN_PRESERVE of data_reg : signal is true;
      attribute ALSPRESERVE              : boolean;
      attribute ALSPRESERVE of rst_reg   : signal is true;
   begin
      microchip : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_async; -- shift left
         end if;
      end process microchip;
      data_sync <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate microchip_gen;

   -- lattice process
   lattice_gen : if VENDOR = "lattice" generate
      signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0);
      -- lattice attributes
      attribute SYN_KEEP                 : boolean;
      attribute SYN_KEEP of data_reg     : signal is true;
      attribute SYN_PRESERVE             : boolean;
      attribute SYN_PRESERVE of data_reg : signal is true;
   begin
      lattice : process (clk)
      begin
         if rising_edge(clk) then
            data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_async; -- shift left
         end if;
      end process lattice;
      data_sync <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate lattice_gen;

end behavioral;