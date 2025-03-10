library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use STD.ENV.STOP;

entity mac_dsp48e1_tb is
end mac_dsp48e1_tb;

architecture behavioral of mac_dsp48e1_tb is

    -- Component Declaration
    component mac_dsp48e1
        Port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            a     : in  std_logic_vector (29 downto 0);
            b     : in  std_logic_vector (17 downto 0);
            p_out : out std_logic_vector (47 downto 0)
        );
    end component;

    -- Testbench Signals
    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal a     : std_logic_vector(29 downto 0) := (others => '0');
    signal b     : std_logic_vector(17 downto 0) := (others => '0');
    signal p_out : std_logic_vector(47 downto 0);

    -- Clock Period
    constant CLK_PERIOD : time := 10 ns;
    constant LATENCY    : natural := 3; -- Pipeline stages

begin

    -- Instantiate DUT
    dut: mac_dsp48e1
    port map (
        clk   => clk,
        rst   => rst,
        a     => a,
        b     => b,
        p_out => p_out
    );

    -- Clock Generation
    clk_process: process
    begin
        while now < 1000 ns loop
            clk <= '0', '1' after CLK_PERIOD/2;
            wait for CLK_PERIOD;
        end loop;
        wait;
    end process;

    -- Stimulus Process
    stim_proc: process
        variable test_counter : natural := 0;
        
        procedure run_test(
            a_val      : in natural;
            b_val      : in natural;
            expected   : in natural;
            delay      : in natural := LATENCY
        ) is
        begin
            test_counter := test_counter + 1;
            report "Starting Test #" & integer'image(test_counter);
            
            -- Apply inputs
            a <= std_logic_vector(to_unsigned(a_val, 30));
            b <= std_logic_vector(to_unsigned(b_val, 18));
            wait until rising_edge(clk);
            
            -- Clear inputs
            a <= (others => '0');
            b <= (others => '0');
            
            -- Wait for pipeline latency
            for i in 1 to delay loop
                wait until rising_edge(clk);
            end loop;
            
            -- Verify output
            assert to_integer(unsigned(p_out)) = expected
                report "Test #" & integer'image(test_counter) & " failed!" & lf &
                       "Expected: " & integer'image(expected) & lf &
                       "Got:      " & integer'image(to_integer(unsigned(p_out)))
                severity error;
            
            report "Test #" & integer'image(test_counter) & " passed!";
        end procedure;

    begin
        -- Initial Reset
        rst <= '1';
        wait for CLK_PERIOD*2;
        rst <= '0';
        wait until rising_edge(clk);
        
        -- Verify reset state
        assert unsigned(p_out) = 0
            report "Reset failed! Output not zero after reset"
            severity error;

        -- Test 1: Basic Multiplication
        run_test(2, 3, 2*3);
        
        -- Test 2: Accumulation
        run_test(4, 5, 2*3 + 4*5);
        
        -- Test 3: Zero Inputs
        run_test(0, 0, 2*3 + 4*5 + 0);
        
        -- Test 4: Large Values
        run_test(2**29-1, 2**17-1, (2**29-1)*(2**17-1) + (2*3 + 4*5));
        
        -- Test 5: Reset During Operation
        a <= (others => '1');
        b <= (others => '1');
        wait until rising_edge(clk);
        rst <= '1';
        wait until rising_edge(clk);
        rst <= '0';
        a <= (others => '0');
        b <= (others => '0');
        wait for CLK_PERIOD*LATENCY;
        assert unsigned(p_out) = 0
            report "Reset during operation failed!"
            severity error;

        report "All tests completed successfully!";
        stop;
    end process;

end behavioral;