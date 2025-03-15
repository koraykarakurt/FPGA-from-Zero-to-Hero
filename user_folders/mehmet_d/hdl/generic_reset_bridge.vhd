---------------------------------------------------------------------------------------------------
-- Author : Mehmet DEMİR
-- Description : Asynchronous reset synchronizer chain with generics. This module used in
-- asynchronous resets to prevent metastability issues. Remember that "rst_out" is asynchronously
-- asserted and synchronously de-asserted. 
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

entity generic_reset_bridge is
   generic (
      VENDOR              : string               := "xilinx"; -- FPGA vendor name, valid values --> "xilinx", "altera", "efinity", "microchip", "lattice"
      RESET_ACTIVE_STATUS : std_logic            := '1';      -- '0': active low, '1': active high
      SYNCH_FF_NUMBER     : natural range 2 to 5 := 3         --  adjust according to FPGA/SoC family, clock speed and input rate of change
   );
   port (
      clk     : in std_logic; -- module clock
      rst_in  : in std_logic; -- asynchronous reset input
      rst_out : out std_logic -- asynchronously asserted synchronously de-asserted reset output
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is
begin
   -- xilinx process
   xilinx_gen : if VENDOR = "xilinx" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
      -- xilinx attributes
      attribute ASYNC_REG             : string;
      attribute ASYNC_REG of rst_reg  : signal is "true";
      attribute DONT_TOUCH            : string;
      attribute DONT_TOUCH of rst_reg : signal is "true";
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

   -- altera process
   altera_gen : if VENDOR = "altera" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
      -- altera attributes
      attribute ALTERA_ATTRIBUTE            : string;
      attribute ALTERA_ATTRIBUTE of rst_reg : signal is "-name SYNCHRONIZER_IDENTIFICATION ""FORCED IF ASYNCHRONOUS""";
      attribute DONT_MERGE                  : boolean;
      attribute DONT_MERGE of rst_reg       : signal is true;
      attribute PRESERVE                    : boolean;
      attribute PRESERVE of rst_reg         : signal is true;
   begin
      altera : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left
         end if;
      end process altera;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate altera_gen;

   -- microchip process
   microchip_gen : if VENDOR = "microchip" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
      -- microchip attributes
      attribute SYN_KEEP                : boolean;
      attribute SYN_KEEP of rst_reg     : signal is true;
      attribute SYN_PRESERVE            : boolean;
      attribute SYN_PRESERVE of rst_reg : signal is true;
      attribute ALSPRESERVE             : boolean;
      attribute ALSPRESERVE of rst_reg  : signal is true;
   begin
      microchip : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left
         end if;
      end process microchip;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate microchip_gen;

   -- efinity process
   efinity_gen : if VENDOR = "efinity" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
      -- efinity attributes
      attribute ASYNC_REG               : boolean;
      attribute ASYNC_REG of rst_reg    : signal is true;
      attribute SYN_KEEP                : boolean;
      attribute SYN_KEEP of rst_reg     : signal is true;
      attribute SYN_PRESERVE            : boolean;
      attribute SYN_PRESERVE of rst_reg : signal is true;

   begin
      efinity : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left
         end if;
      end process efinity;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate efinity_gen;

   -- lattice process
   lattice_gen : if VENDOR = "lattice" generate
      signal rst_reg : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
      -- lattice attributes
      attribute SYN_KEEP                : boolean;
      attribute SYN_KEEP of rst_reg     : signal is true;
      attribute SYN_PRESERVE            : boolean;
      attribute SYN_PRESERVE of rst_reg : signal is true;
   begin
      lattice : process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_reg <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_reg <= rst_reg(SYNCH_FF_NUMBER - 2 downto 0) & (not RESET_ACTIVE_STATUS); -- shift left
         end if;
      end process lattice;
      rst_out <= rst_reg(SYNCH_FF_NUMBER - 1); -- assing MSb to out
   end generate lattice_gen;

end behavioral;