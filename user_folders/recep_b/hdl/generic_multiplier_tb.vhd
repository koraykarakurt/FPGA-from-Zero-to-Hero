library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- include random package for random number generation
library osvvm;
use osvvm.randompkg.all;

entity generic_multiplier_tb is
end generic_multiplier_tb;

architecture behavioral of generic_multiplier_tb is

    -- Constants
    constant data_width : natural := 8; -- Input bit width
    constant num_tests : natural := 10; -- Number of tests
    constant random_min : integer := -20; -- Minimum random value
    constant random_max : integer := 20; -- Maximum random value
    constant wait_time : time := 10 ns;

    -- Signals for the multiplier
    signal mult_in_1_unsigned : std_logic_vector(data_width - 1 downto 0);
    signal mult_in_2_unsigned : std_logic_vector(data_width - 1 downto 0);
    signal mult_out_unsigned : std_logic_vector(2 * data_width - 1 downto 0);

    signal mult_in_1_signed : std_logic_vector(data_width - 1 downto 0);
    signal mult_in_2_signed : std_logic_vector(data_width - 1 downto 0);
    signal mult_out_signed : std_logic_vector(2 * data_width - 1 downto 0);

    -- Signals for error injection
    signal er_inj : boolean := true;  -- Enable error injection
    signal expected_unsigned : std_logic_vector(2 * data_width - 1 downto 0);
    signal expected_signed : std_logic_vector(2 * data_width - 1 downto 0);

    -- Control signals to stop simulation
    signal uns_stop_tb : std_logic := '0';
    signal s_stop_tb : std_logic := '0';

begin

    -- Instantiate DUT for unsigned multiplication
    dut_unsigned : entity work.generic_multiplier
        generic map (
            signed_flag => false,  -- Unsigned multiplication
            data_width  => data_width
        )
        port map (
            mult_in_1 => mult_in_1_unsigned,
            mult_in_2 => mult_in_2_unsigned,
            mult_out  => mult_out_unsigned
        );

    -- Instantiate DUT for signed multiplication
    dut_signed : entity work.generic_multiplier
        generic map (
            signed_flag => true,  -- Signed multiplication
            data_width  => data_width
        )
        port map (
            mult_in_1 => mult_in_1_signed,
            mult_in_2 => mult_in_2_signed,
            mult_out  => mult_out_signed
        );

    -- Unsigned test process
    uns_stimuli : process
        variable rand_gen_uns : randomptype;  -- Random generator for unsigned multiplication
        variable random_value_uns : integer;  -- Random value for unsigned multiplication
        variable error_random_uns : integer;  -- Random value for error injection in unsigned test
    begin
        -- Initialize the random generator
        rand_gen_uns.initseed(1);

        for i in 1 to num_tests loop
            -- Randomly generate unsigned inputs
            random_value_uns := rand_gen_uns.randint(1, 20);
            mult_in_1_unsigned <= std_logic_vector(to_unsigned(random_value_uns, data_width));
            random_value_uns := rand_gen_uns.randint(1, 20);
            mult_in_2_unsigned <= std_logic_vector(to_unsigned(random_value_uns, data_width));

            -- Calculate expected output for unsigned multiplication
            expected_unsigned <= std_logic_vector(to_unsigned(to_integer(unsigned(mult_in_1_unsigned)) * to_integer(unsigned(mult_in_2_unsigned)), 2 * data_width));

            -- Randomize error injection (50% chance)
            error_random_uns := rand_gen_uns.randint(0, 1);  -- Random value to decide error injection
            if er_inj and (error_random_uns = 1) then
                -- Inject error in expected output
                expected_unsigned <= std_logic_vector(to_unsigned(to_integer(unsigned(mult_in_1_unsigned)) * to_integer(unsigned(mult_in_2_unsigned)) - 1, 2 * data_width));
            end if;

            wait for wait_time;

            -- Check unsigned result with error injection
            assert mult_out_unsigned = expected_unsigned
                report "Unsigned multiplication failed: Expected " & to_hstring(expected_unsigned) & ", got " & to_hstring(mult_out_unsigned)
                severity error;

        end loop;

        uns_stop_tb <= '1';
        wait for wait_time;
    end process;

    -- Signed test process
sgn_stimuli : process
    variable rand_gen_sgn : randomptype;  -- Random generator for signed multiplication
    variable random_value_sgn_1 : integer;  -- Random value for the first signed input
    variable random_value_sgn_2 : integer;  -- Random value for the second signed input
    variable error_random_sgn : integer;  -- Random value for error injection in signed test
begin
    -- Initialize the random generator
    rand_gen_sgn.initseed(1);

    for i in 1 to NUM_TESTS loop
        -- Randomly generate signed inputs
        random_value_sgn_1 := rand_gen_sgn.randint(random_min, random_max);
        mult_in_1_signed <= std_logic_vector(to_signed(random_value_sgn_1, data_width));

        random_value_sgn_2 := rand_gen_sgn.randint(random_min, random_max);
        mult_in_2_signed <= std_logic_vector(to_signed(random_value_sgn_2, data_width));

        -- Calculate expected output for signed multiplication
        expected_signed <= std_logic_vector(to_signed(random_value_sgn_1 * random_value_sgn_2, 2 * data_width));

        -- 50% chance
        error_random_sgn := rand_gen_sgn.randint(0, 1);  -- Random value to decide error injection
        if er_inj and (error_random_sgn = 1) then
            -- Inject error in expected output
            expected_signed <= std_logic_vector(to_signed(random_value_sgn_1 * random_value_sgn_2 - 1, 2 * data_width));
        end if;

        wait for wait_time;

        -- Check signed result with error injection
        assert mult_out_signed = expected_signed
            report "Signed multiplication failed: Expected " & to_hstring(expected_signed) & ", got " & to_hstring(mult_out_signed)
            severity error;

    end loop;

    s_stop_tb <= '1';
end process;


    -- Assert to check that both tests are complete
    assert ((s_stop_tb = '1') and (uns_stop_tb = '1')) report "Simulation is finished" severity failure;

end behavioral;
