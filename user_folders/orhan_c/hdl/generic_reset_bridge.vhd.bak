----------------------------------------------------------------------------------------------------------------------------
-- Author : Orhan Çalışkan
-- Description : 
-- Generic reset bridge for synchronizing asynchronous and synchronous resets across different FPGA vendors
-- Supports vendor-specific attributes to optimize reset handling and synthesis  
-- Ensures safe reset de-assertion using a shift register mechanism
-- 
-- More information (optional) :
-- The necessary command should be added to the XDC file for the asynchronous reset false path in Xilinx!!! 
-- 
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity generic_reset_bridge is
   generic 
   (
      VENDOR              : string               := "altera" ; 	-- FPGA vendor name, valid values -> "xilinx", "altera"
      RESET_ACTIVE_STATUS : std_logic            := '1'		 ; 	-- '0': active low reset, '1': active high reset
      SYNCH_FF_NUMBER     : natural range 2 to 5 :=  3 		   	-- adjust according to FPGA/SoC family, clock speed and input rate of change

   );
   port 
   (
	   clk     : in std_logic;
	   rst_in  : in std_logic; 	-- asynchronous or synchronous reset asserted 
      rst_out : out std_logic 	-- synchronous reset de-asserted 
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is
   
begin

   -- Process for asynchronous reset (altera)
   -- This process ensures that the reset is applied asynchronously and released synchronously.
   intel_path : if VENDOR = "altera" generate
   
   signal rst_chain : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
  
   attribute PRESERVE                                 : boolean;
   attribute PRESERVE of rst_chain                    : signal is TRUE;       --rst_chain protect during synthesize
   attribute SYNCHRONIZER_IDENTIFICATION              : string ;
   attribute SYNCHRONIZER_IDENTIFICATION of rst_chain : signal is "FORCED";
   attribute ALTERA_ATTRIBUTE                         : string;
   attribute ALTERA_ATTRIBUTE of rst_chain            : signal is             --async reset input is not included the timing analysis 	 
   "-name SDC_STATEMENT ""set_false_path -from [get_pins {rst_chain[0]}] -to [all_registers]"""; 
   
   begin
      process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_chain <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_chain <= rst_chain(rst_chain'left - 1 downto 0) & not RESET_ACTIVE_STATUS; 
         end if;
      end process;
      rst_out <= rst_chain(rst_chain'left);
   end generate intel_path;
	
	
   -- Process for asynchronous reset (Xilinx)
   -- This process ensures that the reset is applied asynchronously and released synchronously.
   xilinx_path : if VENDOR = "xilinx" generate

   signal rst_chain : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS);
   
   attribute ASYNC_REG  : string;
   attribute DONT_TOUCH : string;
   attribute ASYNC_REG of rst_chain  : signal is "TRUE"; --Ensures safe synchronization of async signals 
   attribute DONT_TOUCH of rst_chain : signal is "TRUE"; --rst_chain protect during synthesize
   
   begin
      process (clk, rst_in)
      begin
         if rst_in = RESET_ACTIVE_STATUS then
            rst_chain <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_chain <= rst_chain(rst_chain'left - 1 downto 0) & not RESET_ACTIVE_STATUS; 
         end if;
      end process;
      
      rst_out <= rst_chain(rst_chain'left);
      
   end generate xilinx_path;

end behavioral;
