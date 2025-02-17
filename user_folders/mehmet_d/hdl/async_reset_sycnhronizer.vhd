---------------------------------------------------------------------------------------------------
-- Author : Mehmet DEMİR
-- Description : Asynchronous reset synchronizer chain with generics.
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

entity async_reset_sycnhronizer is
   generic (
      RST_IN_ACTIVE_STATU  : std_logic            := '1'; -- '0': active low, '1': active high
      RST_OUT_ACTIVE_STATU : std_logic            := '1'; -- '0': active low, '1': active high
      RST_SYNCH_FF_NUMBER  : natural range 2 to 5 := 3 -- adjust corretly according to FPGA
   );
   port (
      clk       : in std_logic;
      async_rst : in std_logic; -- asynchronous reset input
      sync_rst  : out std_logic -- synchronous reset output
   );
end async_reset_sycnhronizer;

architecture behavioral of async_reset_sycnhronizer is

   signal rst_reg : std_logic_vector(RST_SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RST_OUT_ACTIVE_STATU));

begin

   main : process (clk, async_rst)
   begin
      if async_rst = RST_IN_ACTIVE_STATU then
         rst_reg <= (others => RST_OUT_ACTIVE_STATU);

      elsif rising_edge(clk) then
         rst_reg <= rst_reg(RST_SYNCH_FF_NUMBER - 2 downto 0) & (not RST_OUT_ACTIVE_STATU); -- shift left

         -- or use below code snippet for shift left
         --rst_reg(0) <= not RST_OUT_ACTIVE_STATU;
         --shift_left_loop : for i in 0 to RST_SYNCH_FF_NUMBER - 2 loop
         --   rst_reg(i + 1) <= rst_reg(i);
         --end loop shift_left_loop;

      end if;
   end process main;

   sync_rst <= rst_reg(RST_SYNCH_FF_NUMBER - 1); -- assing MSb data to out

end behavioral;
-- /* the end */ --