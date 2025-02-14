library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplayer_v1_tb is
end multiplayer_v1_tb;

architecture Behavioral of multiplayer_v1_tb is

  component multiplayer_v1
    generic(
      multi_type : STD_LOGIC := '0';
      sizes_of_multiplier : integer := 8
    );
    Port ( 
      mult_1  : in STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
      mult_2  : in STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
      mult_o  : out STD_LOGIC_VECTOR ((sizes_of_multiplier*2)-1 downto 0)
    );
  end component multiplayer_v1;

  constant sizes_of_multiplier : integer := 8;
  constant uns_mult_type     : STD_LOGIC := '0';
  constant s_mult_type     : STD_LOGIC := '1';

  constant wait_time       : time := 10 ns;

  constant uns_error_inject_val      : integer := 3 ; 
  constant s_error_inject_val      : integer := -5;
  constant uns_min_value   : integer := 1;
  constant uns_max_value    : integer := 15;
  constant s_min_value     : integer := -8;
  constant s_max_value      : integer := 7;
  
  signal s_mult_1 : STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
  signal s_mult_2 : STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
  signal s_mult_o : STD_LOGIC_VECTOR ((sizes_of_multiplier*2)-1 downto 0);

  signal uns_mult_1 : STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
  signal uns_mult_2: STD_LOGIC_VECTOR (sizes_of_multiplier-1 downto 0);
  signal uns_mult_o: STD_LOGIC_VECTOR ((sizes_of_multiplier*2)-1 downto 0);

  signal uns_expected_output : unsigned(2 * sizes_of_multiplier - 1 downto 0);
  signal s_expected_output  : signed(2 * sizes_of_multiplier - 1 downto 0);

  signal s_error_injection     : std_logic := '1';
  signal uns_error_injection     : std_logic := '1';

  signal uns_test_done : std_logic := '0';
  signal s_test_done : std_logic := '0';
  signal is_all_done : std_logic := '0';

begin

s_mult:multiplayer_v1
    generic map(
      multi_type=>s_mult_type,
      sizes_of_multiplier=>sizes_of_multiplier
    )
    port map(
      mult_1=>s_mult_1,
      mult_2=>s_mult_2,
      mult_o=>s_mult_o
    );

uns_mult:multiplayer_v1
    generic map(
      multi_type=>uns_mult_type,
      sizes_of_multiplier=>sizes_of_multiplier
    )
    port map(
      mult_1=>uns_mult_1,
      mult_2=>uns_mult_2,
      mult_o=>uns_mult_o
    );

  uns_test: process

  begin

    for i in uns_min_value to uns_max_value loop
      for j in uns_min_value to uns_max_value loop
        uns_mult_1 <= std_logic_vector(to_unsigned(i, sizes_of_multiplier ));
        uns_mult_2 <= std_logic_vector(to_unsigned(j, sizes_of_multiplier ));
        uns_expected_output <= to_unsigned(i, sizes_of_multiplier ) * to_unsigned(j, sizes_of_multiplier );
        wait for wait_time;

		-- error injection
        if uns_error_injection = '1' and j = uns_error_inject_val then
          uns_expected_output <= not(uns_expected_output);
          wait for wait_time;
          assert unsigned(uns_mult_o) = uns_expected_output

          report"unsigned error injection occured sucsessfuly for unsigned"& 
					integer'image(to_integer(uns_expected_output)) & 
					", got " & integer'image(to_integer(unsigned(s_mult_o)))severity note;
                    uns_error_injection<='0';
      else
        assert unsigned(uns_mult_o) = uns_expected_output
          report "Unsigned multiplication failed: expected " & integer'image(to_integer(uns_expected_output)) & ", got " & integer'image(to_integer(unsigned(uns_mult_o)))
          severity error;

        --report "Unsigned multiplication successful: " & integer'image(i) & " * " &
		 --integer'image(j) & " = " & integer'image(to_integer(unsigned(uns_mult_o))) & 
		 --", expected: " & integer'image(to_integer(uns_expected_output))
          --severity note;
        end if;


      end loop;
    end loop;

    uns_test_done <= '1';
  end process uns_test;

  s_test :process

  begin

    for i in s_min_value to s_max_value loop
      for j in s_min_value to s_max_value loop
        s_mult_1 <= std_logic_vector(to_signed(i, sizes_of_multiplier ));
        s_mult_2 <= std_logic_vector(to_signed(j, sizes_of_multiplier ));
        s_expected_output <= to_signed(i, sizes_of_multiplier ) * to_signed(j, sizes_of_multiplier );

        wait for wait_time;

		-- error injection
        if s_error_injection='1' and i=s_error_inject_val  then
          s_expected_output <=not(s_expected_output);
           wait for wait_time;
          assert signed(s_mult_o) = s_expected_output
            report" signed error injection occured sucsessfuly for signed"& 
            integer'image(to_integer(s_expected_output)) & 
            ", got " & integer'image(to_integer(signed(s_mult_o)))severity note;
  			    s_error_injection<='0';
          
        else
          assert signed(s_mult_o) = s_expected_output
            report "signed multiplication failed: expected " & 
                integer'image(to_integer(s_expected_output)) & 
                ", got " & integer'image(to_integer(signed(s_mult_o)))
                severity error;
          
       --  report "Signed multiplication successful: " & 
         --  integer'image(i) & " * " & integer'image(j) & 
         --   " = " & integer'image(to_integer(signed(s_mult_o))) & 
         --   ", expected: " & integer'image(to_integer(s_expected_output))
         --   severity note;
             
        end if;

      end loop;
    end loop;
    s_test_done<='1';

  end process s_test;

  finish:process
  begin
    wait until uns_test_done = '1' and s_test_done = '1'; 
    report "All test cases completed successfully." severity note;
	end process finish;


end Behavioral;