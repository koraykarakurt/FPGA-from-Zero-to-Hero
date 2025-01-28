library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all ; 

entity generic_multiplier is 
generic(
	mult_type 	: integer := 0;
	data_width 	: integer := 8
);
port(
	mult1	: in std_logic_vector(data_width -1 downto 0);
	mult2	: in std_logic_vector(data_width -1 downto 0);
	mult_o	: out std_logic_vector(2*data_width -1 downto 0)
);
end generic_multiplier;

architecture Behavioral of generic_multiplier is

begin

p_main: process(mult1,mult2) begin
	if( mult_type = 0) then
		mult_o <= std_logic_vector(unsigned(mult1) * unsigned(mult2));
	else
		mult_o <= std_logic_vector((signed(mult1) * signed(mult2)));
	end if;
end process p_main;

 

end Behavioral;