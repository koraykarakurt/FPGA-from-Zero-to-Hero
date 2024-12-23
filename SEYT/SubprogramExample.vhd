library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

procedure updatevalue(signal clk : in std_logic; signal reset : in std_logic; 
            signal data_in : in std_logic_vector(7 downto 0); 
            signal data_out : out std_logic_vector(7 downto 0)) is 
begin
    if reset = '1' then 
        data_out <= (others => '0'); 
    elsif rising_edge(clk) then 
        data_out <= data_in; 
    end if; 
end procedure; 

entity procedurewithclock is 
     port ( 
          clk : in std_logic; 
          reset : in std_logic; 
          data_in : in std_logic_vector(7 downto 0); 
          data_out : out std_logic_vector(7 downto 0) ); 
end procedurewithclock; 

architecture behavioral of procedurewithclock is 
begin 
            process(clk, reset) 
            begin  
            updatevalue(clk, reset, data_in, data_out); 
            end process; 
end behavioral;