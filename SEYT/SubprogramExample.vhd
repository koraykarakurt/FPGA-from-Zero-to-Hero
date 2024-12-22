library IEEE; 
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL; 

procedure UpdateValue(signal clk : in STD_LOGIC; signal reset : in STD_LOGIC; 
			signal data_in : in STD_LOGIC_VECTOR(7 downto 0); 
			signal data_out : out STD_LOGIC_VECTOR(7 downto 0)) is 
Begin
	 if reset = '1' then 
		data_out <= (others => '0’); 
	elsif rising_edge(clk) then 
		data_out <= data_in; 
	end if; 
end procedure; 
entity ProcedureWithClock is 
     Port ( 
          clk : in STD_LOGIC; 
          reset : in STD_LOGIC; 
          data_in : in STD_LOGIC_VECTOR(7 downto 0); 
          data_out : out STD_LOGIC_VECTOR(7 downto 0) ); 
end ProcedureWithClock; 
architecture Behavioral of ProcedureWithClock is 
begin 
            process(clk, reset) 
            begin  
            UpdateValue(clk, reset, data_in, data_out); 
            end process; 
end Behavioral;

