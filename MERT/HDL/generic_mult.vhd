-- to have 2 generics, 1st generic (std_logic if '0' unsigned else signed) is for signed or unsigned multiplication, 2nd generic is for vector sizes of multipliers (mult_1, mult_2 both are std_logic_vectors)
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_mult is
   generic (
      is_signed  : std_logic := '0'; 
      data_width : integer   := 32    
   );
   port (
      mult_1 : in  std_logic_vector(data_width-1 downto 0);
      mult_2 : in  std_logic_vector(data_width-1 downto 0);
      mult_o : out std_logic_vector(2*data_width-1 downto 0)
   );
end entity generic_mult;

architecture bhv of generic_mult is
    signal mult_internal_signed   : signed(mult_o'range);
    signal mult_internal_unsigned : unsigned(mult_o'range);
begin

   if_generate_signed   : if is_signed = '1' generate 
      mult_internal_signed <= signed(mult_1) * signed(mult_2);
      mult_o               <= std_logic_vector(mult_internal_signed);
   end generate if_generate_signed;

   if_generate_unsigned : if is_signed = '0' generate 
      mult_internal_unsigned <= unsigned(mult_1) * unsigned(mult_2);
      mult_o                 <= std_logic_vector(mult_internal_unsigned);
   end generate if_generate_unsigned;
        
end architecture bhv;