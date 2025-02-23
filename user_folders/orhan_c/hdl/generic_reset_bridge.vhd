----------------------------------------------------------------------------------------------------------------------------
-- Author : Orhan Çalışkan
-- Description : 
-- Generic reset bridge for synchronizing asynchronous and synchronous resets across different FPGA vendors
-- Supports vendor-specific attributes to optimize reset handling and synthesis  
-- Ensures safe reset de-assertion using a shift register mechanism
-- 
-- More information (optional) :
-- Others option of Vendor generic for FPGAs that supports synch reset
-- The necessary command should be added to the XDC file for the asynchronous reset false path in Xilinx!!! 
----------------------------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity generic_reset_bridge is
   generic 
   (
      VENDOR              : string               := "intel" ; 	-- FPGA vendor name, valid values -> "xilinx", "intel", "other"
      RESET_ACTIVE_STATUS : std_logic            := '1'		; 	-- '0': active low reset, '1': active high reset
      SYNCH_FF_NUMBER     : natural range 2 to 5 :=  3 			-- adjust according to FPGA/SoC family, clock speed and input rate of change

   );
   port 
   (
	  clk     : in std_logic;
	  rst_i	  : in std_logic; 	-- asynchronous or synchronous reset asserted 
      rst_o   : out std_logic 	-- synchronous reset de-asserted 
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is

   signal rst_chain : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => not RESET_ACTIVE_STATUS);
    
   --intel attributes
   attribute USEIOOFF : string;				     	 --Disable I/O buffers
   attribute PRESERVE : boolean;
   attribute ALTERA_ATTRIBUTE : string;
   
   attribute USEIOOFF of rst_i : signal is "ON"; 	 --Enable rst_i ports I/O buffers
   attribute PRESERVE of rst_chain : signal is TRUE; --rst_chain protect during synthesize
   attribute ALTERA_ATTRIBUTE of rst_i : signal is   --async reset input is not included the timing analysis 	 
   "-name SDC_STATEMENT ""set_false_path -from [get_ports {rst_i}] -to [all_registers]"""; 
	
   --xilinx attributes
   attribute IOB        : string;
   attribute ASYNC_REG  : string;
   attribute DONT_TOUCH : string;
   
   attribute IOB of rst_i	         : signal is "TRUE"; --Forces rst_i into I/O Block
   attribute ASYNC_REG of rst_chain  : signal is "TRUE"; --Ensures safe synchronization of async signals 
   attribute DONT_TOUCH of rst_chain : signal is "TRUE"; --rst_chain protect during synthesize
   
begin

   -- Process for asynchronous reset (Intel)
   -- This process ensures that the reset is applied asynchronously and released synchronously.
   intel_path : if VENDOR = "intel" generate

   begin
      process (clk, rst_i)
      begin
         if rst_i = RESET_ACTIVE_STATUS then
            rst_chain <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_chain <= rst_chain(rst_chain'left - 1 downto 0) & not RESET_ACTIVE_STATUS; 
         end if;
      end process;
   end generate intel_path;
	
	
   -- Process for asynchronous reset (Xilinx)
   -- This process ensures that the reset is applied asynchronously and released synchronously.
   xilinx_path : if VENDOR = "xilinx" generate

   begin
      process (clk, rst_i)
      begin
         if rst_i = RESET_ACTIVE_STATUS then
            rst_chain <= (others => RESET_ACTIVE_STATUS);
         elsif rising_edge(clk) then
            rst_chain <= rst_chain(rst_chain'left - 1 downto 0) & not RESET_ACTIVE_STATUS; 
         end if;
      end process;
   end generate xilinx_path;


   -- Process for synchronous reset (other vendors)
   -- This process ensures that both reset assertion and de-assertion occur synchronously.
   other : if VENDOR = "other" generate
   begin
      process (clk)
      begin
         if rising_edge(clk) then
            if rst_i = RESET_ACTIVE_STATUS then
               rst_chain <= (others => RESET_ACTIVE_STATUS);
            else
              rst_chain <= rst_chain(rst_chain'left - 1 downto 0) & not RESET_ACTIVE_STATUS;			  
            end if;
         end if;
      end process;
   end generate other;

   rst_o <= rst_chain(rst_chain'left);

end behavioral;
