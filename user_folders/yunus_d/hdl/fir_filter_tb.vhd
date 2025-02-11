library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

entity fir_filter_tb is
end fir_filter_tb;

architecture Behavioral of fir_filter_tb is

component fir_filter is
    generic(
        NUMBER_OF_TAP  : integer := 5;
        INPUT_WIDTH    : natural := 27;
        COEFF_WIDTH    : natural := 16;
        OUTPUT_WIDTH   : natural := 48
    );
    Port(
        clk         : in std_logic;
        rst         : in std_logic;
        valid_in    : in std_logic;
        data_in     : in std_logic_vector(INPUT_WIDTH-1 downto 0);
        data_out    : out std_logic_vector(OUTPUT_WIDTH-1 downto 0);
        valid_out   : out std_logic
    );
end component;

-- Constants
constant clk_period      : time := 10 ns;

-- Signals
signal clk       : std_logic := '0';
signal rst       : std_logic;
signal data_in   : std_logic_vector(26 downto 0);
signal data_out  : std_logic_vector(47 downto 0);
signal valid_in  : std_logic;
signal valid_out : std_logic;

begin
    -- Clock process
    clk_process: process
    begin
         clk <= '0';
         wait for clk_period / 2;
         clk <= '1';
         wait for clk_period / 2;
    end process;

    -- Stimulus process
    stim_proc: process
    begin
        -- Initialize inputs
        rst <= '1';
        valid_in <= '0';
        data_in <= (others => '0');
        wait for 2 * clk_period;
        
        rst <= '0';
        wait for clk_period;
        
        -- Apply input data
        for i in 1 to 6 loop
            valid_in <= '1';
            data_in <= std_logic_vector(to_signed(i, 27));
            wait for clk_period;
        end loop;
        wait for clk_period;
        valid_in <= '0';
		  wait for 100*clk_period;
		  report "Sim is done" severity failure;
    end process;

    uut: fir_filter
generic map (
    NUMBER_OF_TAP  => 5,
    INPUT_WIDTH    => 27,
    COEFF_WIDTH    => 16,
    OUTPUT_WIDTH   => 48
)
port map (
    clk         => clk,
    rst         => rst,
    valid_in    => valid_in,
    data_in     => data_in,
    data_out    => data_out,
    valid_out   => valid_out
);

end Behavioral;
