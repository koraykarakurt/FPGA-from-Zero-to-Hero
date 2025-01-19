library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_mult_tb is
end entity generic_mult_tb;

architecture bhv_tb of generic_mult_tb is
    
   constant DATA_WIDTH : integer := 32;
   
   signal mult_1_unsigned : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_2_unsigned : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_o_unsigned : std_logic_vector(2*DATA_WIDTH-1 downto 0);
   signal mult_1_signed   : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_2_signed   : std_logic_vector(DATA_WIDTH-1 downto 0);
   signal mult_o_signed   : std_logic_vector(2*DATA_WIDTH-1 downto 0);
   
   signal expected_mult_unsigned : integer;
   signal expected_mult_signed   : integer;
    
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
                          expected : integer;
                          result_signal : std_logic_vector) is
   begin
      report "Testing with input: " & 
             integer'image(to_integer(signed(input1))) & 
             " and " & 
             integer'image(to_integer(signed(input2)));

      assert to_integer(signed(result_signal)) = expected
          report "Test Failed: Expected " & integer'image(expected) & 
                 ", Got " & integer'image(to_integer(signed(result_signal)))
          severity failure;

      report "Test Passed";
   end procedure;

begin

   -- Instance for unsigned multiplication
   uut_unsigned: generic_mult
     generic map (
         is_signed  => '0',  
         data_width => DATA_WIDTH
     )
     port map (
         mult_1 => mult_1_unsigned,
         mult_2 => mult_2_unsigned,
         mult_o => mult_o_unsigned
     );

   -- Instance for signed multiplication
   uut_signed: generic_mult
     generic map (
         is_signed  => '1',  
         data_width => DATA_WIDTH
     )
     port map (
         mult_1 => mult_1_signed,
         mult_2 => mult_2_signed,
         mult_o => mult_o_signed
     );

   stim_proc: process begin
      -- Unsigned tests
      mult_1_unsigned <= std_logic_vector(to_unsigned(3, DATA_WIDTH));
      mult_2_unsigned <= std_logic_vector(to_unsigned(5, DATA_WIDTH));
      expected_mult_unsigned <= 3 * 5;

      wait for 10 ns;
      check_result(mult_1_unsigned, mult_2_unsigned, expected_mult_unsigned, mult_o_unsigned);

      mult_1_unsigned <= std_logic_vector(to_unsigned(10, DATA_WIDTH));
      mult_2_unsigned <= std_logic_vector(to_unsigned(15, DATA_WIDTH));
      expected_mult_unsigned <= 10 * 15;

      wait for 10 ns;
      check_result(mult_1_unsigned, mult_2_unsigned, expected_mult_unsigned, mult_o_unsigned);

      -- Signed tests
      mult_1_signed <= std_logic_vector(to_signed(-3, DATA_WIDTH));
      mult_2_signed <= std_logic_vector(to_signed(5, DATA_WIDTH));
      expected_mult_signed <= -3 * 5 + 1;

      wait for 10 ns;
      check_result(mult_1_signed, mult_2_signed, expected_mult_signed, mult_o_signed);

      mult_1_signed <= std_logic_vector(to_signed(-10, DATA_WIDTH));
      mult_2_signed <= std_logic_vector(to_signed(-15, DATA_WIDTH));
      expected_mult_signed <= -10 * -15;

      wait for 10 ns;
      check_result(mult_1_signed, mult_2_signed, expected_mult_signed, mult_o_signed);

      report "All Test Cases Passed";
      wait;
   end process;
    
end architecture bhv_tb;
