library IEEE;
use IEEE.numeric_std.all;
use IEEE.std_logic_1164.all;

-- include random package for random number generation
library osvvm;
use osvvm.randompkg.all;

entity generic_multiplier_tb is
end generic_multiplier_tb;

architecture behavioral of generic_multiplier_tb is

    -- component declaration
    component generic_multiplier is
        generic(
            mult_type   : integer := 0;
            data_width  : integer := 8
        );
        port(
            mult1   : in std_logic_vector(data_width - 1 downto 0);
            mult2   : in std_logic_vector(data_width - 1 downto 0);
            mult_o  : out std_logic_vector(2 * data_width - 1 downto 0)
        );
    end component;

    constant data_width       : integer := 8;
    constant uns_mult_type    : integer := 0;
    constant s_mult_type      : integer := 1;
    constant wait_time        : time := 10 ns;
    constant uns_loop_start   : integer := 1;
    constant uns_loop_stop    : integer := 15;
    constant s_loop_start     : integer := -8;
    constant s_loop_stop      : integer := 7;

    signal uns_mult1   : std_logic_vector(data_width - 1 downto 0);
    signal uns_mult2   : std_logic_vector(data_width - 1 downto 0);
    signal uns_mult_o  : std_logic_vector(2 * data_width - 1 downto 0);

    signal s_mult1     : std_logic_vector(data_width - 1 downto 0);
    signal s_mult2     : std_logic_vector(data_width - 1 downto 0);
    signal s_mult_o    : std_logic_vector(2 * data_width - 1 downto 0);
	 
	 signal uns_stop_tb		: std_logic := '0';
	 signal s_stop_tb			: std_logic := '0';

    signal expected_output_uns : unsigned(2 * data_width - 1 downto 0);
    signal expected_output_s   : signed(2 * data_width - 1 downto 0);
    signal er_inj              : boolean := true;

begin

    uns_stimuli : process
    -- 29/01/2025, review note by koray_k 
    -- use two independent stimuli (one for signed one for unsigned component 
    -- and run tests in parallel not sequentially as below, also labels shall be lowercase as well
    -- p_stimuli >>> p_stimuli also randomptype >>> randomptype
        variable rand_gen : randomptype; 
        variable random_value_uns : integer;
        variable random_value_s : integer;
    begin
        -- initialize the random generator
        rand_gen.initseed(1);
        for i in uns_loop_start to uns_loop_stop loop
            for j in uns_loop_start to uns_loop_stop loop
                uns_mult1 <= std_logic_vector(to_unsigned(i, data_width));
                uns_mult2 <= std_logic_vector(to_unsigned(j, data_width));
                expected_output_uns <= to_unsigned(i, data_width) * to_unsigned(j, data_width);
					 
                random_value_uns := rand_gen.randint(uns_loop_start, uns_loop_stop);
					 
                wait for wait_time;
					 
                if er_inj and (i = random_value_uns) then
                    assert uns_mult_o /= std_logic_vector(expected_output_uns)
                        report "error injection occurred for unsigned multiplication." severity note;
                else
                    assert uns_mult_o = std_logic_vector(expected_output_uns)
                        report "unsigned multiplication failed: expected " & 
                        integer'image(to_integer(expected_output_uns)) & 
                        ", got " & integer'image(to_integer(unsigned(uns_mult_o)))
                        severity error;
                end if;
            end loop;
        end loop;
		  uns_stop_tb <= '1';
		  wait for wait_time;
    end process;
	 
	 p_stimuli : process
        variable rand_gen : randomptype; 
        variable random_value_uns : integer;
        variable random_value_s : integer;
    begin
        rand_gen.initseed(1); 
        for i in s_loop_start to s_loop_stop loop
            for j in s_loop_start to s_loop_stop loop
                s_mult1 <= std_logic_vector(to_signed(i, data_width));
                s_mult2 <= std_logic_vector(to_signed(j, data_width));
                expected_output_s <= to_signed(i, data_width) * to_signed(j, data_width);

                -- generate random values for error injection
                random_value_s := rand_gen.randint(s_loop_start, s_loop_stop);

                wait for wait_time;

                if er_inj and (i = random_value_s) then
                    assert s_mult_o /= std_logic_vector(expected_output_s)
                        report "error injection occurred for signed multiplication." severity note;
                else
                    assert s_mult_o = std_logic_vector(expected_output_s)
                        report "signed multiplication failed: expected " & 
                        integer'image(to_integer(expected_output_s)) & 
                        ", got " & integer'image(to_integer(signed(s_mult_o)))
                        severity error;
                end if;
            end loop;
        end loop;
        uns_stop_tb <= '1';
    end process;
	 
	 
	 assert ((s_stop_tb = '0') and (uns_stop_tb = '0')) report "Simulation is finished" severity failure;

    -- instantiate dut for unsigned multiplication
    dut_uns : generic_multiplier
        generic map (
            mult_type  => uns_mult_type,
            data_width => data_width
        )
        port map(
            mult1   => uns_mult1,
            mult2   => uns_mult2,
            mult_o => uns_mult_o
        );

    -- instantiate dut for signed multiplication
    dut_s : generic_multiplier
        generic map (
            mult_type  => s_mult_type,
            data_width => data_width
        )
        port map(
            mult1   => s_mult1,
            mult2   => s_mult2,
            mult_o => s_mult_o
        );

end behavioral;
