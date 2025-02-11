library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity fir_filter is
generic(
    NUMBER_OF_TAP  : integer := 5;
    INPUT_WIDTH    : natural := 27;
    COEFF_WIDTH    : natural := 16; 
    OUTPUT_WIDTH   : natural := 48
);
Port(
    clk      	: in std_logic;
    rst        : in std_logic;
	 valid_in   : in std_logic;
    data_in    : in std_logic_vector(INPUT_WIDTH-1 downto 0);
    data_out   : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
	 valid_out	: out std_logic
);
end fir_filter;

architecture Behavioral of fir_filter is
-- force synthesis tool to use dsp block
attribute USE_DSP48 : string;
attribute USE_DSP48 of Behavioral: architecture is "YES";


type sum_array is array (0 to NUMBER_OF_TAP -1) of signed(OUTPUT_WIDTH-1 downto 0);-- store sum array
type coefficients is array (0 to NUMBER_OF_TAP -1 ) of signed(COEFF_WIDTH-1 downto 0);


signal sums      	: sum_array := (others=>(others=>'0'));
signal data_reg  	: signed(INPUT_WIDTH-1 downto 0); -- think as data pipeline
signal o_valid 	: std_logic := '0';

-- for test 
constant coefs: coefficients :=( 
    x"0002", x"0003", x"0005", x"0003", x"0002"  
);

begin

data_out <= std_logic_vector(sums(0));
valid_out <= o_valid;

-- use two pipeline register
process (clk, rst)
	variable counter :integer range 0 to NUMBER_OF_TAP :=0; --wait until number of taps
    if rising_edge(clk) then
        if rst = '1' then
            sums 		<= (others => (others => '0'));
				o_valid	<= '0';
        else
				if( valid_in = '1') then
					data_reg <= signed(data_in);
					for i in 0 to NUMBER_OF_TAP -1 loop  
						 if i = NUMBER_OF_TAP -1 then -- At last add block another input is 0
							  sums(i) <= resize(coefs(i) * data_reg, OUTPUT_WIDTH);  
						 else
							  sums(i) <= resize(coefs(i) * data_reg, OUTPUT_WIDTH) + sums(i+1);
						 end if;
					end loop;
					if(counter = NUMBER_OF_TAP) then
						counter := 0;
						o_valid <= '1';
					else
						counter := counter + 1;
					end if;
				end if;
        end if;
    end if;
end process;

end Behavioral;