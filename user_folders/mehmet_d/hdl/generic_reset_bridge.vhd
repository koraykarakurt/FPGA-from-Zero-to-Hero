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

entity generic_reset_bridge is
   generic (
      VENDOR              : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "intel", "other"
      RESET_ACTIVE_STATUS : std_logic            := '1'; -- '0': active low, '1': active high
      SYNCH_FF_NUMBER     : natural range 2 to 5 := 3 --  adjust according to FPGA/SoC family, clock speed and input rate of change
   );
   port (
      clk     : in std_logic;
      rst_in  : in std_logic; -- asynchronous reset input
      rst_out : out std_logic -- asynchronously asserted synchronously de-asserted output
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is

begin

   xilinx_gen : if VENDOR = "xilinx" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));

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
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left

         end if;
      end process xilinx;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out      
   end generate xilinx_gen;

   intel_gen : if VENDOR = "intel" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));

      attribute altera_attribute of data_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute dont_merge                   : boolean;
      attribute dont_merge of data_reg       : signal is true;
      attribute preserve                     : boolean;
      attribute preserve of data_reg         : signal is true;
   begin
      intel : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);

         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left

         end if;
      end process intel;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate intel_gen;

   other_gen : if VENDOR = "other" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => (not RESET_ACTIVE_STATUS));
   begin
      other_vendors : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);

         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left

         end if;
      end process other_vendors;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate other_gen;

end behavioral;
-- /* the end */ --