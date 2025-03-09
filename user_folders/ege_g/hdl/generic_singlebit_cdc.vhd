---------------------------------------------------------------------------------------------------
-- Author : Ege Ömer Göksu
-- Description : generic singlebit cdc circuit
-- 
-- More information (optional) :
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity generic_singlebit_cdc is
generic(
   SYNCH_FF_NUMBER      : integer range 2 to 8 := 4; --can change with respect to clock speed
   VENDOR               : string    := "XILINX"
);
port(
   clk      : in std_logic;
   data_in  : in std_logic;
   data_o   : out std_logic
);
end generic_singlebit_cdc;

architecture logic of generic_singlebit_cdc is
begin

GEN_XILINX: if VENDOR = "XILINX" generate
signal ff_chain : std_logic_vector (SYNCH_FF_NUMBER-1 downto 0) := (others => '0');
attribute ASYNC_REG : string;
attribute DONT_TOUCH : string;
attribute ASYNC_REG of ff_chain : signal is "TRUE";
attribute DONT_TOUCH of sync_reg : signal is "TRUE";
begin
   process(clk) begin
      if rising_edge(clk) then
         for i in 0 to SYNCH_FF_NUMBER-2 loop
            ff_chain(i) <= ff_chain(i+1);
         end loop;
         ff_chain(SYNCH_FF_NUMBER-1)  <= data_in;
      end if;
   end process;
   data_o <= ff_chain(0);
end generate GEN_XILINX;

GEN_ALTERA: if VENDOR = "ALTERA" generate
signal ff_chain : std_logic_vector (SYNCH_FF_NUMBER-1 downto 0) := (others => '0');
attribute PRESERVE : boolean;
attribute PRESERVE of ff_chain : signal is true;

begin
   process(clk) begin
      if rising_edge(clk) then
         for i in 0 to SYNCH_FF_NUMBER-2 loop
            ff_chain(i) <= ff_chain(i+1);
         end loop;
         ff_chain(SYNCH_FF_NUMBER-1)  <= data_in;
      end if;
   end process;
   data_o <= ff_chain(0);
end generate GEN_ALTERA;

end logic;