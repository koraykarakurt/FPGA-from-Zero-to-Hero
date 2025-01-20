library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all ;

entity tb_generic_multiplier is
generic(
	mult_type   : integer := 0;
	data_width : integer := 8
);
end tb_generic_multiplier;

architecture Behavioral of tb_generic_multiplier is

component generic_multiplier is
generic(
	mult_type   : integer := 0;
	data_width  : integer := 8
);
port(
	in_mult1    : in std_logic_vector(data_width - 1 downto 0);
	in_mult2    : in std_logic_vector(data_width - 1 downto 0);
	out_mult_o  : out std_logic_vector(2 * data_width - 1 downto 0)
);
end component;

	signal tb_in_mult1   : std_logic_vector(data_width - 1 downto 0);
	signal tb_in_mult2   : std_logic_vector(data_width - 1 downto 0);
	signal tb_out_mult_o : std_logic_vector(2 * data_width - 1 downto 0);

	signal expected_output_uns : unsigned(2 * data_width - 1 downto 0);
	signal expected_output_s   : signed(2 * data_width - 1 downto 0);
	signal er_inj             : boolean := true;

begin

DUT : generic_multiplier
generic map (
mult_type  => mult_type,
data_width => data_width
)
port map(
in_mult1   => tb_in_mult1,
in_mult2   => tb_in_mult2,
out_mult_o => tb_out_mult_o
);

P_STIMULI : process begin
	if (mult_type = 0) then 
		for i in 0 to 15 loop
			for j in 0 to 15 loop
				tb_in_mult1 <= std_logic_vector(to_unsigned(i, data_width));
				tb_in_mult2 <= std_logic_vector(to_unsigned(j, data_width));
				expected_output_uns <= to_unsigned(i, data_width) * to_unsigned(j, data_width);

				wait for 10 ns;            
				if er_inj and (i = 5 and j = 7) then
					 assert tb_out_mult_o /= std_logic_vector(expected_output_uns)
						  report "Error injection is occurred." severity note;
				else
					 assert tb_out_mult_o = std_logic_vector(expected_output_uns)
						  report "Unsigned multiplication failed: Expected " & 
						  integer'image(to_integer(expected_output_uns)) & 
						  ", Got " & integer'image(to_integer(unsigned(tb_out_mult_o)))
						  severity error;
				end if;
			end loop;
		end loop;
	end if;

	if (mult_type = 1) then 
		for i in -8 to 7 loop
			for j in -8 to 7 loop
				tb_in_mult1 <= std_logic_vector(to_signed(i, data_width));
				tb_in_mult2 <= std_logic_vector(to_signed(j, data_width));
				expected_output_s <= to_signed(i, data_width) * to_signed(j, data_width);

				wait for 10 ns;

				if er_inj and (i = -3 and j = -2) then
					 assert tb_out_mult_o /= std_logic_vector(expected_output_s)
						  report "Error injection is occurred." severity note;
				else
					 assert tb_out_mult_o = std_logic_vector(expected_output_s)
						  report "Signed multiplication failed: Expected " & 
						  integer'image(to_integer(expected_output_s)) & 
						  ", Got " & integer'image(to_integer(signed(tb_out_mult_o)))
						  severity error;
				end if;
			end loop;
		end loop;
	end if;
	report "Test is finished!" severity failure;
end process;

end Behavioral;
