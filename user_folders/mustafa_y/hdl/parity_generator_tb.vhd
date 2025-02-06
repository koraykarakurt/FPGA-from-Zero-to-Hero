library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all; 

entity tb_parity_generator is
end tb_parity_generator;

architecture behavioral of tb_parity_generator is

   -- testbench signals
   signal tb_data_in         : std_logic_vector(7 downto 0)  := "00000000";
   signal tb_parity_mode_sel : std_logic  := '0';
   signal tb_generated_parity: std_logic  := '0';
   signal tb_rx_parity_bit   : std_logic  := '0';
   signal tb_parity_error    : std_logic  := '0';

   constant wait_time_1 : time := 10 ns;
   constant wait_time_2 : time := 15 ns;
   constant wait_time_3 : time := 20 ns;
   constant wait_time_4 : time := 77 ns;

   -- function to calculate expected parity
   function calculate_parity(
      data_in    : std_logic_vector(7 downto 0);
      parity_mode: std_logic  -- '0' for even, '1' for odd
   ) return std_logic is
     variable parity : std_logic := data_in(0); 
   begin
      --calculate even parity
      for i in 1 to 7 loop
         parity := parity xor data_in(i);
      end loop;
      --parity := parity when (parity_mode = '0') else not parity ;
      if parity_mode = '1' then
      parity := not parity;
      end if;
      return parity;
   end function;
    
begin
    -- instantiate DUT
    dut: entity work.parity_generator
        port map (
            data_in            => tb_data_in,
            parity_mode_select => tb_parity_mode_sel,
            generated_parity   => tb_generated_parity,
            rx_parity_bit      => tb_rx_parity_bit,
            parity_error       => tb_parity_error
        );

    -- testbench process
    p_stimulu: process
    begin
        for data_in_val in 0 to 2**(tb_data_in'width)-1 loop
            -- Assign data_in using to_unsigned and convert to std_logic_vector
            tb_data_in <= std_logic_vector(to_unsigned(data_in_val, tb_data_in'width));
            -- Check for even parity mode (mode_sel = '0')
            tb_parity_mode_sel <= '0';
            -- Test without parity error
            tb_rx_parity_bit <= calculate_parity(std_logic_vector(to_unsigned(data_in_val, tb_data_in'width)), '0'); -- Correct even parity
            
            wait for wait_time_1;
            
            assert (tb_rx_parity_bit = tb_generated_parity) and (tb_parity_error = '0')
                report "correct even testcase: parity mismatch for data_in = " & integer'image(data_in_val) 
                & " pcalc=" & std_logic'image(tb_rx_parity_bit)   
                & " pgen=" & std_logic'image(tb_generated_parity)
                & " perror=" & std_logic'image(tb_parity_error)
                severity error;
                
            -- Test with intended even parity error
            tb_rx_parity_bit <= not calculate_parity(std_logic_vector(to_unsigned(data_in_val, tb_data_in'width)), '0'); -- incorrect even parity
            
            wait for wait_time_2;
            
            assert (tb_rx_parity_bit /= tb_generated_parity) and (tb_parity_error = '1')
                report "incorrect even testcase: parity mismatch for data_in = " & integer'image(data_in_val) 
                & " pcalc=" & std_logic'image(tb_rx_parity_bit)   
                & " pgen=" & std_logic'image(tb_generated_parity)
                & " perror=" & std_logic'image(tb_parity_error)
                severity error;                
                
            -- Check for odd parity mode (mode_sel = '1')
            tb_parity_mode_sel <= '1';
            -- Test without parity error
            tb_rx_parity_bit <= calculate_parity(std_logic_vector(to_unsigned(data_in_val, tb_data_in'width)), '1'); -- Correct odd parity
            
            wait for wait_time_3;
            
            assert (tb_rx_parity_bit = tb_generated_parity) and (tb_parity_error = '0')
                report "correct odd testcase: parity mismatch for data_in = " & integer'image(data_in_val) 
                & " pcalc=" & std_logic'image(tb_rx_parity_bit)   
                & " pgen=" & std_logic'image(tb_generated_parity)
                & " perror=" & std_logic'image(tb_parity_error)
                severity error;
                
            -- Test with intended odd parity error
            tb_rx_parity_bit <= not calculate_parity(std_logic_vector(to_unsigned(data_in_val, 8)), '1'); -- incorrect odd parity
            
            wait for wait_time_4;
            
            assert (tb_rx_parity_bit /= tb_generated_parity) and (tb_parity_error = '1')
                report "incorrect odd testcase: parity mismatch for data_in = " & integer'image(data_in_val) 
                & " pcalc=" & std_logic'image(tb_rx_parity_bit)   
                & " pgen=" & std_logic'image(tb_generated_parity)
                & " perror=" & std_logic'image(tb_parity_error)
                severity error;  
        end loop;
        -- Simulation complete
        report "All tests passed successfully." severity note;
        wait;
    end process p_stimulu;
end behavioral;