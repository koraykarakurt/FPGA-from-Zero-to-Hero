---------------------------------------------------------------------------------------------------
-- Author      :  Halil Furkan KIMKAK
-- Description :  Testbench for Generic Multiplier
--                - Tests signed multiplication
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity generic_multiplier_tb is
end generic_multiplier_tb;

architecture behavioral of generic_multiplier_tb is
    -- Constants
    constant MULT_LEN      : integer := 16; -- Multiplier length
    constant CLK_PERIOD    : time := 10 ns; -- Clock period
   
    -- Component declaration for generic_multiplier
    component generic_multiplier is
        Generic (    
            MULT_TYPE : boolean := true; -- Signed multiplier --> if I use false, expected results are not correct and error_count is not 0
            MULT_LEN  : integer range 2 to 64 := 16     -- Multiplier length
        );
        Port (    
            mult_in_1 : in std_logic_vector(MULT_LEN-1 downto 0); -- Input 1
            mult_in_2 : in std_logic_vector(MULT_LEN-1 downto 0); -- Input 2
            mult_out  : out std_logic_vector(2*MULT_LEN-1 downto 0) -- Output
        );
    end component;
    
    -- Signals for signed multiplier
    signal s_mult_in_1    : std_logic_vector(MULT_LEN-1 downto 0); -- Input 1
    signal s_mult_in_2    : std_logic_vector(MULT_LEN-1 downto 0); -- Input 2
    signal s_mult_out     : std_logic_vector(2*MULT_LEN-1 downto 0); -- Output
    signal s_expected_out : std_logic_vector(2*MULT_LEN-1 downto 0); -- Expected output
    
    -- Test status signals
    signal test_done     : boolean := false; -- Test done
    signal error_count   : integer := 0; -- Error count
    
begin
    -- Instantiate signed multiplier
    signed_mult_inst: generic_multiplier
    generic map (
        MULT_TYPE => true,      -- Signed multiplier --> if I use false, expected results are not correct and error_count is not 0
        MULT_LEN  => MULT_LEN   -- Multiplier length
    )
    port map (
        mult_in_1 => s_mult_in_1, -- Input 1
        mult_in_2 => s_mult_in_2, -- Input 2
        mult_out  => s_mult_out  -- Output
    );
    
    -- Stimulus process
    stimulus: process
        -- Variables for expected results calculation
        variable v_s_expected : std_logic_vector(2*MULT_LEN-1 downto 0);
    begin
        -- Initialize signals
        s_mult_in_1 <= (others => '0'); -- Input 1
        s_mult_in_2 <= (others => '0'); -- Input 2
        
        wait for CLK_PERIOD * 2;  -- Wait for initial stabilization

        -- Generate random test vectors
        s_mult_in_1 <= "1000101011110101";  -- -29,979 (decimal)
        s_mult_in_2 <= "0001100100010010";  -- 6,418 (decimal)
        
        -- Wait for inputs to propagate
        wait for CLK_PERIOD/2;
        
        -- Calculate expected results using variable
        v_s_expected := std_logic_vector(signed(s_mult_in_1) * signed(s_mult_in_2)); -- Signed multiplication
        
        -- Assign expected values to signal
        s_expected_out <= v_s_expected; -- Expected output
        
        -- Wait for multiplier outputs to stabilize
        wait for CLK_PERIOD/2;
        
        -- Signed multiplication check
        if s_mult_out /= v_s_expected then
            report "Signed multiplication error."
            severity error;
            error_count <= error_count + 1; -- Error count
        end if;                
      
        wait for CLK_PERIOD/2;
        
        -- Report test completion
        test_done <= true; -- Test done
        wait for CLK_PERIOD;
        
        if error_count = 0 then
            report "Test completed successfully with no errors!"
                severity note; -- Report test completion
        else
            report "Test completed with error."
                severity error; -- Report test completion
        end if;
            
        wait;
    end process stimulus;    
end behavioral;