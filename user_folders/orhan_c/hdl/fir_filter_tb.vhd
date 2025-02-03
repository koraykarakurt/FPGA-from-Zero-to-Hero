library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity partly_systolic_fir_filter_tb is
	
	generic 
	(
		filter_taps  : natural := 16;
		data_width   : natural := 16;
		coeff_width  : natural := 16
	);
      
end entity;

architecture behavioral of partly_systolic_fir_filter_tb is

   -- Component Declaration
   component partly_systolic_fir_filter
      
		generic 
		(
         filter_taps  : natural := 16;
         data_width   : natural := 16;
         coeff_width  : natural := 16
      );
      
		port 
		(
         clk       : in std_logic;
         rst       : in std_logic;
         data_in   : in std_logic_vector(data_width-1 downto 0);
         valid_in  : in std_logic;
         data_out  : out std_logic_vector(data_width + coeff_width-1 downto 0);
         valid_out : out std_logic
      );
		
   end component;

   -- Testbench Signals
   constant clk_period : time := 10 ns;
	constant rst_time	  : time := 20 ns;
	constant data_in_per: time := 50 ns;
	constant out_delay  : time := 50 ns;
	
	type test_data_array is array (filter_taps-1 downto 0) of signed(data_width-1 downto 0);
	signal test_data_arr1 : test_data_array := (
																x"0000", x"0000", x"0000", x"0000", 
																x"0000", x"0000", x"0000", x"0000", 
																x"0000", x"0000", x"0000", x"0000", 
																x"0000", x"0000", x"0000", x"0000"
															 );
	
	signal test_data_arr2 : test_data_array := (
																x"0001", x"0001", x"0001", x"0001", 
																x"0001", x"0001", x"0001", x"0001", 
																x"0001", x"0001", x"0001", x"0001", 
																x"0001", x"0001", x"0001", x"0001" 
															 );
	
   signal clk         : std_logic := '0';
   signal rst         : std_logic := '1';
   signal data_in     : std_logic_vector(data_width - 1 downto 0) := (others => '0');
   signal valid_in    : std_logic := '0';
   signal data_out    : std_logic_vector(data_width + coeff_width - 1 downto 0);
   signal valid_out   : std_logic;

begin

	dut : partly_systolic_fir_filter 
		
		generic map 
		(
			filter_taps => filter_taps ,    
			data_width  => data_width  ,
			coeff_width => coeff_width  
		)
		
		port map
		(
			clk       => clk		 ,      
			rst       => rst      ,
			data_in   => data_in  ,
			valid_in  => valid_in ,
			data_out  => data_out ,
			valid_out => valid_out
		);
		

   -- Clock generation process
   clk_gen : process
   begin
     
		clk <= '0';
		wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
      
   end process;

   
   stimuli : process
   begin
      -- Activate reset
		report "simulation start" severity note;
      rst <= '1';
      wait for rst_time;
		report "system reset" severity note;
		rst <= '0';
		wait for rst_time;
	
		report "test data1 sending start" severity note;
		for i in 0 to filter_taps-1 loop
			
			data_in  <=  std_logic_vector(signed(test_data_arr2(i)));
			valid_in <='1';
			
			wait for data_in_per;
			
		end loop;
		
		valid_in <= '0';
		report "test data1 sended" severity note;
		
		wait for out_delay;
		
		if(valid_out = '1') then
		
			report "filtered data output" severity note;
		
		else
			
			report "filtered data not output" severity warning;
			
		end if;
		
		report "test data2 sending start" severity note;
		for i in 0 to filter_taps-1 loop
			
			data_in  <= std_logic_vector(signed(test_data_arr2(i)));
			valid_in <='1';
			
			wait for data_in_per;
			
		end loop;
		
		valid_in <= '0';
		report "test data2 sended" severity note;
		
		wait for out_delay;
		
		if(valid_out = '1') then
		
			report "filtered data output" severity note;
		
		else
			
			report "filtered data not output" severity warning;
			
		end if;
		
   end process;



end behavioral;
