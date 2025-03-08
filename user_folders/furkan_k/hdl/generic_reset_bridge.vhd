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
      RESET_ACTIVE_STATUS : std_logic            := '1'; -- active high and active low indicator -- '0' --> active low | '1' --> active high
      SYNCH_FF_NUMBER     : integer range 2 to 5 := 2    -- number of flip flops
   );
   port (
      clock               : in  std_logic;               -- system clock
      reset_i             : in  std_logic;               -- reset signal before reset bridge
      reset_o             : out std_logic                -- reset signal after  reset bridge
   );
end generic_reset_bridge;

architecture behavioral of generic_reset_bridge is

   signal rst_ff          : std_logic_vector(SYNCH_FF_NUMBER - 1 downto 0); -- flip flop chain for the reset signal before reset bridge

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
   
end behavioral;
