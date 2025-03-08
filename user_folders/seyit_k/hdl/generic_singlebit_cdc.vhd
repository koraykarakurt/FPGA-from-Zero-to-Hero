---------------------------------------------------------------------------------------------------
-- Author : Seyit Kadir Kocak
-- Description : Generic Single Bit Clock Domain Crossing (CDC) for Xilinx
--
-- More information (optional) :
--    
--    
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity generic_singlebit_cdc is
	generic (
		VENDOR              			: string               := "xilinx" ; 	
		SYNC_FF_NUMBER      			: natural range 2 to 5 := 5		
	);			
	port (			
		clk         					: in  std_logic;  
		rst								: in  std_logic;
		data_in			 				: in  std_logic;  
		data_out			   			: out std_logic   
	);
end generic_singlebit_cdc;

architecture Behavioral of generic_singlebit_cdc is

begin
	xilinx : if VENDOR = "xilinx" generate
		
		signal sync_reg : std_logic_vector(SYNC_FF_NUMBER-1 downto 0);
	    
		attribute async_reg                 : string;
        attribute async_reg of sync_reg     : signal is "true";
		
		attribute dont_touch 				: string;
		attribute dont_touch of sync_reg 	: signal is "true";
		
		attribute keep 						: string;
		attribute keep of sync_reg			: signal is "true"; -- protect optimization during synthesis 	
    begin
        process (clk, rst)
        begin
            if rst = '1' then
                sync_reg <= (others => '0');
            elsif rising_edge(clk) then
                sync_reg <= sync_reg(SYNC_FF_NUMBER-2 downto 0) & data_in;
            end if;
        end process;

        data_out <= sync_reg(sync_reg'left);
		
    end generate xilinx;

end Behavioral;
