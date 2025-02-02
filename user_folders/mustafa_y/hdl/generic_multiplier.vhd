---------------------------------------------------------------------------------------------------
-- Author : Mustafa Yetis
-- Description : Configurable signed/unsigned multiplier with parametric data_width
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier is
   generic (
      mult_type       : std_logic := '0'; -- multiplication type selector, '0' = unsigned, '1' = signed
      data_data_width : positive  := 8    -- bit data_width of input operands (default 8-bit)
   );
   port (
      mult_in_1 : in  std_logic_vector(data_width-1 downto 0);
      mult_in_2 : in  std_logic_vector(data_width-1 downto 0);
      mult_out  : out std_logic_vector(2*data_width-1 downto 0)
   );
end entity generic_multiplier;

architecture rtl of generic_multiplier is
begin
   ----------------------------------------------------------------------------
   -- unsigned multiplication block
   ----------------------------------------------------------------------------
   unsigned_gen: if mult_type = '0' generate
   begin
      mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
   end generate unsigned_gen;
   ----------------------------------------------------------------------------
   -- signed multiplication block
   ----------------------------------------------------------------------------
   signed_gen: if mult_type = '1' generate
   begin
      mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
   end generate signed_gen;
end architecture rtl;