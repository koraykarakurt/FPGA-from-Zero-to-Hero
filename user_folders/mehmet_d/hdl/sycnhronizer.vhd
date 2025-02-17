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
--use IEEE.numeric_std.all;

entity sycnhronizer is
   generic (
      RST_ACTIVE_STATU : std_logic            := '1'; -- '0': active low, '1': active high
      DATA_RST_VALUE   : std_logic            := '0'; -- '0' or '1'
      SYNCH_FF_NUMBER  : natural range 2 to 5 := 3 -- adjust corretly
   );
   port (
      clk      : in std_logic;
      rst      : in std_logic; -- asynchronous active high reset
      data_in  : in std_logic; -- asynchronous data input
      data_out : out std_logic -- synchronous data output
   );
end sycnhronizer;

architecture behavioral of sycnhronizer is

   signal data_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => DATA_RST_VALUE);

begin

   main : process (clk, rst)
   begin
      if rst = RST_ACTIVE_STATU then
         data_reg <= (others => DATA_RST_VALUE);

      elsif rising_edge(clk) then
         data_reg <= data_reg(SYNCH_FF_NUMBER - 2 downto 0) & data_in; -- shift left

         -- or use below code snippet for shift left operation
         --data_reg(0) <= data_in;
         --shift_left_loop : for i in 0 to SYNCH_FF_NUMBER - 2 loop
         --   data_reg(i + 1) <= data_reg(i);
         --end loop shift_left_loop;

      end if;
   end process main;

   data_out <= data_reg(SYNCH_FF_NUMBER - 1); -- assing MSb data to out

end behavioral;
-- /* the end */ --