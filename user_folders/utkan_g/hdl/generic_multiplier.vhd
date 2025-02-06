---------------------------------------------------------------------------------------------------
-- Author : Utkan Genc
-- Description : 
--   This is a RTL implementation of a generic multiplier.
--   
-- More information (optional) :
--   MULTIPLIER_TYPE : 0 for unsigned, 1 for signed
--   DATA_WIDTH : width of the inputs
--   mult_in_1, mult_in_2 : inputs of the multiplier
--   mult_out : output of the multiplier
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier is
   generic (
      MULTIPLIER_TYPE : integer range 0 to 1 := 0;
      DATA_WIDTH      : integer range 1 to 64 := 8
   );
   port (
      mult_in_1 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      mult_in_2 : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      mult_out  : out std_logic_vector(2*DATA_WIDTH-1 downto 0)
   );
end entity;

architecture behavioral of generic_multiplier is
begin
   gen_unsigned: if MULTIPLIER_TYPE = 0 generate
   begin
      mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
   end generate gen_unsigned;
   gen_signed: if MULTIPLIER_TYPE = 1 generate
   begin
      mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
   end generate gen_signed;
end architecture;
