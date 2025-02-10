library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity local_reset is
    port (
        clk     : in  std_logic;
        async_reset : in  std_logic;
        data_in : in  std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
    );
end local_reset;
architecture behavioral of local_reset is
    signal shift_reg : std_logic_vector(3 downto 0) := (others => '1');
    signal local_reset : std_logic := '1';
    signal data_reg : std_logic_vector(7 downto 0);
begin
    process(clk, async_reset)
    begin
        if async_reset = '1' then
            shift_reg <= (others => '1');
        elsif rising_edge(clk) then
            shift_reg <= shift_reg(2 downto 0) & '0';
        end if;
    end process;
    local_reset <= shift_reg(3);
    process(clk)
    begin
        if rising_edge(clk) then
            if local_reset = '0' then
                data_reg <= (others => '0');
            else
                data_reg <= data_in;
            end if;
        end if;
    end process;
    data_out <= data_reg;
end behavioral;
