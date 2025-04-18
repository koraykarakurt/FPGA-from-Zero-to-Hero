---------------------------------------------------------------------------------------------------
-- Author : Abdullah Furkan Kaya
-- Description : generic reset bridge design
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

entity generic_reset_bridge is
   generic (
      VENDOR              : string               := "xilinx"; -- FPGA vendor -- choose "xilinx" OR "altera"
      RESET_ACTIVE_STATUS : std_logic            := '1';      -- active high and active low indicator -- '0' --> active low | '1' --> active high
      SYNCH_FF_NUMBER     : integer range 2 to 5 := 5         -- number of flip flops
   );
   port (
      clock               : in  std_logic;                    -- system clock
      reset_i             : in  std_logic;                    -- reset signal before reset bridge
      reset_o             : out std_logic                     -- reset signal after  reset bridge
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is

begin

   xilinx_rst_gen : if (VENDOR = "xilinx") generate
      signal rst_ff                  : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS); -- flip flop chain for the reset signal before reset bridge
      attribute ASYNC_REG            : string;
      attribute ASYNC_REG  of rst_ff : signal is "true";
      attribute DONT_TOUCH           : string;
      attribute DONT_TOUCH of rst_ff : signal is "true";
   begin
   
      reset_bridge_p : process (reset_i, clock)
      begin
         if (reset_i = RESET_ACTIVE_STATUS) then 
            rst_ff <= (others => RESET_ACTIVE_STATUS);
         elsif (rising_edge(clock)) then 
            rst_ff <= not RESET_ACTIVE_STATUS & rst_ff(SYNCH_FF_NUMBER - 1 downto 1); -- shift right operation
         end if;
      end process reset_bridge_p;
      
      reset_o      <= rst_ff(0);
      
   end generate xilinx_rst_gen;
   
   altera_rst_gen : if (VENDOR = "altera") generate
      signal rst_ff                        : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0) := (others => RESET_ACTIVE_STATUS); -- flip flop chain for the reset signal before reset bridge
      attribute ALTERA_ATTRIBUTE           : string;
      attribute ALTERA_ATTRIBUTE of rst_ff : signal is "-name SYNCHRONIZER_IDENTIFICATION AUTO, -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER-1) & ", -name SDC_STATEMENT ""set_false_path -from [get_ports reset_i]""";
      attribute PRESERVE                   : boolean;
      attribute PRESERVE         of rst_ff : signal is true;
   begin
   
      reset_bridge_p : process (reset_i, clock)
      begin
         if (reset_i = RESET_ACTIVE_STATUS) then 
            rst_ff <= (others => RESET_ACTIVE_STATUS);
         elsif (rising_edge(clock)) then 
            rst_ff <= not RESET_ACTIVE_STATUS & rst_ff(SYNCH_FF_NUMBER - 1 downto 1); -- shift right operation
         end if;
      end process reset_bridge_p;
      
      reset_o      <= rst_ff(0);
      
   end generate altera_rst_gen;
  
end behavioral;