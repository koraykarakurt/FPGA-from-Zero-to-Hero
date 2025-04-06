---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : generic signle bit cdc design test module
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

entity cdc_top is
   port ( 
      src_clk  : in  std_logic;
      dest_clk : in  std_logic;
      a_data   : in  std_logic; -- async. data to dest. clock domain -- sync. data to src clock domain
      s_data   : out std_logic  -- sync.  data to dest. clock domain
   );
end cdc_top;

architecture behavioral of cdc_top is

   component generic_singlebit_cdc is
      generic (
         VENDOR              : string               := "xilinx"; -- FPGA vendor -- choose "xilinx" OR "altera"
         SYNCH_FF_NUMBER     : integer range 2 to 5 := 2         -- number of flip flops
      );
      port (
         clock               : in  std_logic;                    -- clock that we want to pass our data to its domain
         adata_i             : in  std_logic;                    -- async. data to this clock domain
         sdata_o             : out std_logic                     -- sync.  data to this clock domain
      );
   end component generic_singlebit_cdc;

   signal adata_d1 : std_logic;
   --signal : std_logic;

begin

   generic_singlebit_cdc_inst : generic_singlebit_cdc
   generic map (
      VENDOR          => "xilinx",
      SYNCH_FF_NUMBER => 5
   )
   port map (
      clock           => dest_clk ,
      adata_i         => adata_d1 ,
      sdata_o         => s_data
   );

   SYNC_IN_P : process (src_clk)
   begin
      if (rising_edge(src_clk)) then 
         adata_d1 <= a_data;
      end if;
   end process SYNC_IN_P;

end behavioral;