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

-- 29/01/2025, review note by koray_k 
-- use if generate statement to implement this instead of process statement	

	uns_gen : if(mult_type = 0) generate
		mult_o <= std_logic_vector(unsigned(mult1) * unsigned(mult2));
	end generate;
	
	s_gen : if(mult_type /= 0) generate
		mult_o <= std_logic_vector((signed(mult1) * signed(mult2)));
	end generate;

 

end Behavioral;
