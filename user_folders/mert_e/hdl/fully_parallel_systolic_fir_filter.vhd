library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fully_parallel_systolic_fir_filter is
    generic (
        taps         : integer := 4;
        input_width  : integer range 8 to 25 := 16;
        coeff_width  : integer range 8 to 18 := 16;
        output_width : integer range 8 to 43 := 32  
    );
    port (
        clk    : in  std_logic;
        reset  : in  std_logic;
        enable : in  std_logic;
        data_i : in  std_logic_vector(input_width-1 downto 0);
        data_o : out std_logic_vector(output_width-1 downto 0)
    );
end fully_parallel_systolic_fir_filter;

architecture behavioral of fully_parallel_systolic_fir_filter is

    -- Constant for the multiplication width
    constant mac_width : integer := input_width + coeff_width;

    -- Type definitions for systolic pipeline stages
    type pipeline_data is array (0 to taps-1) of signed(input_width-1 downto 0);
    signal data_pipe : pipeline_data := (others => (others => '0'));

    type pipeline_coeffs is array (0 to taps-1) of signed(coeff_width-1 downto 0);
    signal coeff_pipe : pipeline_coeffs := (
        x"0001", x"0002", x"0003", x"0004", x"0005", x"0006", x"0007", x"0008",
        x"0009", x"000A", x"000B", x"000C", x"000D", x"000E", x"000F", x"0010",
        x"0011", x"0012", x"0013", x"0014", x"0015", x"0016", x"0017", x"0018",
        x"0019", x"001A", x"001B", x"001C", x"001D", x"001E"
    );

    type pipeline_products is array (0 to taps-1) of signed(mac_width-1 downto 0);
    signal product_pipe : pipeline_products := (others => (others => '0'));

    type pipeline_sums is array (0 to taps-1) of signed(output_width-1 downto 0);
    signal sum_pipe : pipeline_sums := (others => (others => '0'));

begin

    process (clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                data_pipe <= (others => (others => '0'));
                product_pipe <= (others => (others => '0'));
                sum_pipe <= (others => (others => '0'));
            elsif enable = '1' then
                for i in taps-1 downto 1 loop
                    data_pipe(i) <= data_pipe(i-1);
                end loop;
                data_pipe(0) <= signed(data_i);
                -- Performing of multiplications and accumulations
                for i in 0 to taps-1 loop
                    product_pipe(i) <= data_pipe(i) * coeff_pipe(i);
                    if i = 0 then
                        sum_pipe(i) <= resize(product_pipe(i), output_width);
                    else
                        sum_pipe(i) <= sum_pipe(i-1) + resize(product_pipe(i), output_width);
                    end if;
                end loop;
            end if;
        end if;
    end process;
    data_o <= std_logic_vector(sum_pipe(taps-1));

end behavioral;
