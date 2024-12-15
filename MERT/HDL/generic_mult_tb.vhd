-- to be a self-checking testbench using vhdl report and assert keywords

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_mult_tb is
end entity generic_mult_tb;

architecture bhv_tb of generic_mult_tb is
    
   constant DATA_WIDTH : integer := 8;
   
   signal mult_1	    : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_2 		: std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_o	    : std_logic_vector(2*DATA_WIDTH-1 downto 0);
   signal expected_mult : integer;
    
   component generic_mult is
       generic (
           is_signed : std_logic := '0'; 
           data_width : integer  := 32    
       );
       port (
           mult_1   : in  std_logic_vector(data_width-1 downto 0);
           mult_2  : in  std_logic_vector(data_width-1 downto 0);
           mult_o  : out std_logic_vector(2*data_width-1 downto 0)
       );
   end component;
   
      procedure check_result(signal input1 : std_logic_vector;
                           signal input2 : std_logic_vector;
                           expected : integer) is
   begin
      report "Testing with input: " &
             integer'image(to_integer(unsigned(input1))) & 
             " and " &
             integer'image(to_integer(unsigned(input2)));

      
      assert to_integer(unsigned(mult_o)) = expected
          report "Test Failed: Expected " & integer'image(expected) &
                 ", Got " & integer'image(to_integer(unsigned(mult_o)))
          severity failure;

      report "Test Passed";
   end procedure;



begin

   uut: generic_mult
     generic map (
         is_signed  => '0',  
         data_width => DATA_WIDTH
     )
     port map (
         mult_1 => mult_1,
         mult_2 => mult_2,
         mult_o => mult_o
     );

    
   stim_proc: process begin
      mult_1 <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
      mult_2 <= std_logic_vector(to_unsigned(5, DATA_WIDTH));
      expected_mult <= 3 * 5;

      wait for 10 ns;  
      check_result(mult_1, mult_2, expected_mult);

      mult_1 <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
      mult_2 <= std_logic_vector(to_unsigned(15, DATA_WIDTH));
      expected_mult <= 10 * 15;

      wait for 10 ns;
      check_result(mult_1, mult_2, expected_mult);

      mult_1 <= std_logic_vector(to_unsigned(0, DATA_WIDTH));
      mult_2 <= std_logic_vector(to_unsigned(20, DATA_WIDTH));
      expected_mult <= 0 * 20;

      wait for 10 ns;
      check_result(mult_1, mult_2, expected_mult);

      mult_1 <= std_logic_vector(to_unsigned(255, DATA_WIDTH));
      mult_2 <= std_logic_vector(to_unsigned(1, DATA_WIDTH));
      expected_mult <= 255 * 1;

      wait for 10 ns;
      check_result(mult_1, mult_2, expected_mult);

      report "All Test Cases Passed";
      wait;
   end process;
    
end architecture bhv_tb;