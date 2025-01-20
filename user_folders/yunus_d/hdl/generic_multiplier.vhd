-----------------------
-- This is a generic multiplier design that can perform both signed and unsigned multiplication 
-- depending on the 'mult_type' generic. The width of the input vectors is determined by the 'data_width' generic.
-----------------------
library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all ; 

entity generic_multiplier is 
generic(
	mult_type 	: integer := 0;
	data_width 	: integer := 8
);
port(
	in_mult1	: in std_logic_vector(data_width -1 downto 0);
	in_mult2	: in std_logic_vector(data_width -1 downto 0);
	out_mult_o	: out std_logic_vector(2*data_width -1 downto 0)
);
end generic_multiplier;

architecture Behavioral of generic_multiplier is

begin

p_main: process(in_mult1,in_mult2) begin
	if( mult_type = 0) then
		out_mult_o <= std_logic_vector(unsigned(in_mult1) * unsigned(in_mult2));
	else
		out_mult_o <= std_logic_vector((signed(in_mult1) * signed(in_mult2)));
	end if;
end process p_main;

 

end Behavioral;