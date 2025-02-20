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

entity generic_reset_sycnhronizer is
   generic (
      FPGA_VENDOR         : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "general"
      RESET_ACTIVE_STATUS : std_logic            := '1'; -- '0': active low, '1': active high
      RST_SYNCH_FF_NUMBER : natural range 2 to 5 := 3 -- adjust corretly according to FPGA
   );
   port (
      clk     : in std_logic;
      rst_in  : in std_logic; -- asynchronous reset input
      rst_out : out std_logic -- asynchronously asserted synchronously de-asserted output
   );
end generic_reset_sycnhronizer;

architecture behavioral of generic_reset_sycnhronizer is

   signal rst_reg : std_logic_vector(RST_SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));

begin

   xilinx_gen : if FPGA_VENDOR = "xilinx" generate
      signal rst_reg : std_logic_vector(RST_SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));

      attribute async_reg                : string;
      attribute async_reg of rst_reg     : signal is "true";
      attribute shreg_extract            : string;
      attribute shreg_extract of rst_reg : signal is "no";
   begin
      xilinx : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);

         elsif rising_edge(clk) then
            rst_reg <= rst_reg(RST_SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left

         end if;
      end process xilinx;
      rst_out <= rst_reg(RST_SYNCH_FF_NUMBER - 1); -- assing MSb data to out      
   end generate xilinx_gen;

   general_gen : if FPGA_VENDOR = "general" generate
      signal rst_reg : std_logic_vector(RST_SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));
   begin
      general : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);

         elsif rising_edge(clk) then
            rst_reg <= rst_reg(RST_SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left

         end if;
      end process general;
      rst_out <= rst_reg(RST_SYNCH_FF_NUMBER - 1); -- assing MSb data to out
   end generate general_gen;

end behavioral;
-- /* the end */ --