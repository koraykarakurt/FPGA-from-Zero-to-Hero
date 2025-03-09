---------------------------------------------------------------------------------------------------
-- Author : Ege ömer Göksu
-- Description : FIRF-41 Generic Multiplier
-- More information (optional) : 
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier is
generic(
   SIGNED_FLAG : boolean := true; --signed mult. => true /// unsigned mult. => false
   DATA_LENGTH : integer := 32 
);
port(
   mult_in_1 : in std_logic_vector (DATA_LENGTH-1 downto 0);
   mult_in_2 : in std_logic_vector (DATA_LENGTH-1 downto 0);
   mult_out  : out std_logic_vector (2*DATA_LENGTH-1 downto 0)
);
end generic_multiplier;

architecture logic of generic_multiplier is
begin
SIGNED_GEN : if SIGNED_FLAG = true generate
   mult_out <= std_logic_vector(signed(mult_in_1) * signed(mult_in_2));
end generate SIGNED_GEN;

UNSIGNED_GEN : if SIGNED_FLAG = false generate
   mult_out <= std_logic_vector(unsigned(mult_in_1) * unsigned(mult_in_2));
end generate UNSIGNED_GEN;

end logic;