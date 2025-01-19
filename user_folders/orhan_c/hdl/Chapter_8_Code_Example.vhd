library IEEE;
use IEEE.std_logic_1164.all;						--This line is example for selected name
use work.example_package.all;						--This line is example for external name

Entity my_design is									--my_design is a simple name

port
(
	clk 		: in  std_logic						;
    rst 		: in  std_logic						;
					  
	input_vld	: in  std_logic						;
	comm_input	: in  std_logic_vector (15 downto 0); --comm_input port is a slice name
	
	output_vld	: in  std_logic						;
	data_out	: out std_logic_vector(15 downto 0)	  --data_out port is a slice name
);

end my_design;

architecture behavioral of my_design is

signal data : std_logic_vector(data_upper_lmt downto data_lower_lmt); --data is a static name

begin

process(clk) begin

	if (clk'event and clk = '1') then --clk'event is a attribute name
	
		if(input_vld = '1') then
	
			data <= comm_input(15 downto 1) & not comm_input(0); --comm_input(0) is a indexed name
		
		end if;
		
		if(output_vld = '1') then
		
			data_out <= data;
		
		end if;
	
	end if;

end process;

end behavioral;