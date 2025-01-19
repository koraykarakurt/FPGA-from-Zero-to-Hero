library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity procedurewithclock is
    port (
        clk : in std_logic;
        reset : in std_logic;
        data_in : in std_logic_vector(7 downto 0);
        data_out : out std_logic_vector(7 downto 0)
    );
end procedurewithclock;

architecture behavioral of procedurewithclock is
    procedure updatevalue(
        signal clk : in std_logic;
        signal reset : in std_logic;
        signal data_in : in std_logic_vector(7 downto 0);
        variable data_out : inout std_logic_vector(7 downto 0)
    ) is
    begin
        if reset = '1' then
            data_out := (others => '0');
        elsif rising_edge(clk) then
            data_out := data_in;
        end if;
    end procedure;
begin
    process(clk, reset)
        variable temp_data : std_logic_vector(7 downto 0); 
    begin
        updatevalue(clk, reset, data_in, temp_data); 
        data_out <= temp_data; 
    end process;
end behavioral;
