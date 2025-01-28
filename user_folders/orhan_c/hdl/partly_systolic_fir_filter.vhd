library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity partly_systolic_fir_filter is
	
	generic
	(
		filter_taps 	: natural 					:= 16	;
		data_width		: natural 					:= 16	;
		coeff_width		: natural 					:= 16	;
		par_ser_factor : natural range 0 to 15 := 2	
	);
	
	port
	(
		clk 					: in std_logic;
		rst 					: in std_logic;
		
		data_i 				: in std_logic_vector(data_width-1 downto 0);
		data_i_vld			: in std_logic :='1';
		
		filtered_data_o 	: out std_logic_vector(data_width + coeff_width-1 downto 0);
		data_o_vld			: out std_logic
	);
   

end entity;

architecture behavioral of partly_systolic_fir_filter is

  attribute multstyle : string;
  attribute multstyle of behavioral : architecture is "dsp";
	
	constant par_stage_num : integer := 4;
	constant data_o_size	  : integer := data_width + coeff_width;
	
	type data_array	is array (filter_taps-1 downto 0) of signed(data_width-1 downto 0);
	signal data_arr 					: data_array := (others => (others=>'0'));
	signal data_count 				: integer range 0 to filter_taps := 0;
	signal filtered_data_arr_full	: std_logic :='0'; 
	signal par_stage					: integer range 0 to par_ser_factor := 0;
	signal data_o_count				: integer range 0 to data_o_size := 0;
	
	type coefficients is array (filter_taps-1 downto 0) of signed(coeff_width-1 downto 0);
	constant coeff : coefficients := (
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001",
													x"1001", x"1001", x"1001", x"1001"
												);
	
	type filtered_data_array is array (filter_taps-1 downto 0) of signed(data_width+coeff_width-1 downto 0);
	signal filtered_data_arr : filtered_data_array := (others => (others=>'0')); 

begin

	process(clk) begin
		
		if rising_edge(clk) then
			
			if(rst = '1') then
			
				filtered_data_o <= (others=>'0');
			
			else
			
				if(data_i_vld = '1' and data_count < filter_taps) then
							
						data_count <= data_count + 1 ;
						data_arr(data_count) <= signed(data_i);
						
				end if;
				
				if(data_count = filter_taps / par_ser_factor and filtered_data_arr_full = '0') then
				
					filtered_data_arr(0) <= data_arr(0)*coeff(0);
			
					for i in 1 to filter_taps / par_ser_factor - 1 loop
						
						filtered_data_arr(i) <= (signed(data_arr(i))*coeff(i)); 
						
					end loop;
					
				end if;
				
				if(data_count = filter_taps and filtered_data_arr_full = '0') then
				
					for j in filter_taps / par_ser_factor to filter_taps-1 loop
					
						filtered_data_arr(j) <= (data_arr(j)*coeff(j));
					
					end loop;
					
					filtered_data_arr_full <= '1'; 
					data_count <= 0;
					
				end if;
				
				if(filtered_data_arr_full = '1') then
				
					filtered_data_o 		<= std_logic_vector(filtered_data_arr(data_o_count));
					data_o_vld 				<= '1';
					data_o_count			<= data_o_count + 1;
				
				end if;
				
				if(data_o_count >= filter_taps) then
					
					filtered_data_arr_full <= '0';
					data_o_count <= 0;
					data_o_vld 	<= '0';
				
				end if;
				
			end if;
		
		end if;
	
	end process;
	
end behavioral;