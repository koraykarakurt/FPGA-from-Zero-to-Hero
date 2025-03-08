---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : generic signle bit cdc design
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
      VENDOR              : string               := "xilinx"; -- FPGA vendor -- choose "xilinx" OR "altera"
      SYNCH_FF_NUMBER     : integer range 2 to 5 := 2         -- number of flip flops
   );
   port (
      clock               : in  std_logic;                    -- clock that we want to pass our data to its domain
      adata_i             : in  std_logic;                    -- async. data to this clock domain
      sdata_o             : out std_logic                     -- sync.  data to this clock domain
   );
end generic_singlebit_cdc;

architecture behavioral of generic_singlebit_cdc is

begin

   xilinx_sb_cdc_gen : if (VENDOR = "xilinx") generate
      signal data_ff                  : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0'); -- flip flop chain for the single bit cdc 
      attribute ASYNC_REG             : string;
      attribute ASYNC_REG  of data_ff : signal is "true";
      attribute DONT_TOUCH            : string;
      attribute DONT_TOUCH of data_ff : signal is "true";
   begin

      cdc_p : process (clock)
      begin
         if (rising_edge(clock)) then 
            data_ff <= adata_i & data_ff(SYNCH_FF_NUMBER - 1 downto 1); -- shift right
         end if;
      end process cdc_p;
      
      sdata_o       <= data_ff(0);   
   
   end generate xilinx_sb_cdc_gen;
   
   altera_sb_cdc_gen : if (VENDOR = "altera") generate
      signal data_ff                        : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => '0'); -- flip flop chain for the single bit cdc 
      attribute ALTERA_ATTRIBUTE            : string;
      attribute ALTERA_ATTRIBUTE of data_ff : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute PRESERVE                    : boolean;
      attribute PRESERVE         of data_ff : signal is true;
   begin
     
      cdc_p : process (clock)
      begin
         if (rising_edge(clock)) then 
            data_ff <= adata_i & data_ff(SYNCH_FF_NUMBER - 1 downto 1); -- shift right
         end if;
      end process cdc_p;
      
      sdata_o       <= data_ff(0);      
   
   end generate altera_sb_cdc_gen;

end behavioral;