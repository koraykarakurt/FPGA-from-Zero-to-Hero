---------------------------------------------------------------------------------------------------
-- Author : 
-- Description : 
--   
--   
--   
--   
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity parity_generator is
   port (
        data_in            : in  std_logic_vector(7 downto 0);  -- 8-bit input data
        parity_mode_select : in  std_logic;                     -- 0: even parity, 1: odd parity
        rx_parity_bit      : in  std_logic;                     -- received parity bit
        generated_parity   : out std_logic;                     -- generated parity bit
        parity_error       : out std_logic                      -- error signal (1 if mismatch)
   );
end parity_generator;

architecture behavioral of parity_generator is
begin
   process (data_in, parity_mode_select, rx_parity_bit)
      variable parity : std_logic;
   begin
      -- compute even parity
      parity := data_in(0);
      for i in 1 to 7 loop
         parity := parity xor data_in(i);
      end loop;
      -- adjust for odd parity if selected
      if parity_mode_select = '1' then
         parity := not parity;
      end if;
      -- assign outputs
      generated_parity <= parity;
      parity_error     <= rx_parity_bit xor parity;
   end process;
end behavioral;