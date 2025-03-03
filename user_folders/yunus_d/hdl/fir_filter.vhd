---------------------------------------------------------------------------------------------------
-- Author : Yunus Dag	
-- Description : Transposed FIR filter
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
use work.fir_filter_pkg.all;

entity fir_filter is
generic(
	INPUT_WIDTH : natural := 25;
	OUTPUT_WIDTH: natural := 48
);
Port(
	clk      : in std_logic;
	rst      : in std_logic;
	valid_in : in std_logic;
	data_in  : in std_logic_vector(INPUT_WIDTH-1 downto 0);
	data_out : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
	valid_out: out std_logic
);
end fir_filter;

architecture Behavioral of fir_filter is
attribute USE_DSP : string;
attribute USE_DSP of Behavioral: architecture is "YES";
type sum_array is array (0 to NUMBER_OF_TAP -1) of signed(OUTPUT_WIDTH-1 downto 0);-- store sum array
signal sums      	: sum_array := (others=>(others=>'0'));
signal data_reg  	: signed(INPUT_WIDTH-1 downto 0); -- think as data pipeline
signal o_valid 	: std_logic := '0';
signal counter    : integer range 0 to NUMBER_OF_TAP := 0;
begin
data_out <= std_logic_vector(sums(0));
valid_out <= o_valid;
process (clk) begin 
	if rising_edge(clk) then
		if rst = '1' then
			sums 		<= (others => (others => '0'));
			counter <= 0;
			o_valid <= '0';
		else
			if(valid_in = '1') then
				for i in 0 to NUMBER_OF_TAP-1 loop  
					if i = NUMBER_OF_TAP-1 then -- At last add block another input is 0
						sums(i) <= resize(coefs(i)*signed(data_in),OUTPUT_WIDTH);  
					else
						sums(i) <= resize(coefs(i)*signed(data_in),OUTPUT_WIDTH)+sums(i+1);
					end if;
				end loop;
				
				if(counter=NUMBER_OF_TAP-1) then
					o_valid <= '1';
				else
					counter <= counter + 1;
				end if;
			else
				o_valid <= '0';
			end if;
		end if;
	end if;
end process;
end Behavioral;