---------------------------------------------------------------------------------------------------
-- Author      :  Halil Furkan KIMKAK
-- Description :  Testbench for Generic Multiplier
--                - Tests both signed and unsigned multiplication
--                - Verifies multiplication results against expected values
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
            MULT_TYPE : boolean := true; -- Signed multiplier
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
    
    -- Signals for unsigned multiplier
    signal u_mult_in_1    : std_logic_vector(MULT_LEN-1 downto 0); -- Unsigned Input 1
    signal u_mult_in_2    : std_logic_vector(MULT_LEN-1 downto 0); -- Unsigned Input 2
    signal u_mult_out     : std_logic_vector(2*MULT_LEN-1 downto 0); -- Unsigned Output
    signal u_expected_out : std_logic_vector(2*MULT_LEN-1 downto 0); -- Unsigned Expected output
    
    -- Test status signals
    signal test_done     : boolean := false; -- Test done
    signal error_count   : integer := 0; -- Error count
    
begin
    -- Instantiate signed multiplier
    signed_mult_inst: generic_multiplier
    generic map (
        MULT_TYPE => true,      -- Signed multiplier
        MULT_LEN  => MULT_LEN   -- Multiplier length
    )
    port map (
        mult_in_1 => s_mult_in_1, -- Input 1
        mult_in_2 => s_mult_in_2, -- Input 2
        mult_out  => s_mult_out  -- Output
    );

    -- Instantiate unsigned multiplier
    unsigned_mult_inst: generic_multiplier
    generic map (
        MULT_TYPE => false,     -- Unsigned multiplier
        MULT_LEN  => MULT_LEN   -- Multiplier length
    )
    port map (
        mult_in_1 => u_mult_in_1, -- Input 1
        mult_in_2 => u_mult_in_2, -- Input 2
        mult_out  => u_mult_out  -- Output
    );
    
    -- Stimulus process
    stimulus: process
        -- Variables for expected results calculation
        variable v_s_expected : std_logic_vector(2*MULT_LEN-1 downto 0); -- Signed expected output
        variable v_u_expected : std_logic_vector(2*MULT_LEN-1 downto 0); -- Unsigned expected output
    begin
        -- Initialize signals
        s_mult_in_1 <= (others => '0'); -- Input 1
        s_mult_in_2 <= (others => '0'); -- Input 2
        u_mult_in_1 <= (others => '0'); -- Unsigned Input 1
        u_mult_in_2 <= (others => '0'); -- Unsigned Input 2
        
        wait for CLK_PERIOD * 2;  -- Wait for initial stabilization

        -- Test Case 1: Signed multiplication
        s_mult_in_1 <= "1000101011110101";  -- -29,979 (decimal)
        s_mult_in_2 <= "0001100100010010";  -- 6,418 (decimal)
        
        -- Test Case 1: Unsigned multiplication
        u_mult_in_1 <= "0110101011110101";  -- 27,381 (decimal)
        u_mult_in_2 <= "0001100100010010";  -- 6,418 (decimal)
        
        -- Wait for inputs to propagate
        wait for CLK_PERIOD/2;
        
        -- Calculate expected results
        v_s_expected := std_logic_vector(signed(s_mult_in_1) * signed(s_mult_in_2)); -- Signed multiplication
        v_u_expected := std_logic_vector(unsigned(u_mult_in_1) * unsigned(u_mult_in_2)); -- Unsigned multiplication
        
        -- Assign expected values to signals
        s_expected_out <= v_s_expected; -- Expected signed output
        u_expected_out <= v_u_expected; -- Expected unsigned output
        
        -- Wait for multiplier outputs to stabilize
        wait for CLK_PERIOD/2;
        
        -- Signed multiplication check
        if s_mult_out /= v_s_expected then
            report "Signed multiplication error."
            severity error;
            error_count <= error_count + 1;
        end if;                

        -- Unsigned multiplication check
        if u_mult_out /= v_u_expected then
            report "Unsigned multiplication error."
            severity error;
            error_count <= error_count + 1;
        end if;
      
        wait for CLK_PERIOD/2;
        
        -- Report test completion
        test_done <= true; -- Test done
        wait for CLK_PERIOD;
        
        if error_count = 0 then
            report "Test completed successfully with no errors!"
                severity note; -- Report test completion
        else
            report "Test completed with " & integer'image(error_count) & " errors."
                severity error; -- Report test completion
        end if;
            
        wait;
    end process stimulus;    
end behavioral;