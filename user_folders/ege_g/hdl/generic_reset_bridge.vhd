---------------------------------------------------------------------------------------------------
-- Author : Ege Ömer Göksu
-- Description : generic_reset_bridge
--  
-- More information (optional) :
--Takes an asynchronous reset as input.
--The output (rst_o) is an asynchronous assertion/synchronous de-assertion reset.
---------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

entity generic_reset_bridge is
generic(
   RESET_ACTIVE_STATUS  : std_logic := '0'; -- 0 is active low, 1 is active high
   SYNCH_FF_NUMBER      : integer range 2 to 8 := 4; --can change with respect to clock speed
   VENDOR               : string    := "XILINX"
);
port(
   clk   : in std_logic;
   rst   : in std_logic; --asynchronous reset
   rst_o : out std_logic --must be also used as asynchronous reset
);
end generic_reset_bridge;

architecture logic of generic_reset_bridge is


begin

GEN_XILINX: if VENDOR = "XILINX" generate
signal ff_chain : std_logic_vector (SYNCH_FF_NUMBER-1 downto 0) := (others => RESET_ACTIVE_STATUS);
attribute ASYNC_REG : string;
attribute DONT_TOUCH : string;
attribute ASYNC_REG of ff_chain : signal is "TRUE";
attribute DONT_TOUCH of ff_chain : signal is "TRUE";
begin
   process(clk, rst) begin
      if (rst = RESET_ACTIVE_STATUS) then
         ff_chain(SYNCH_FF_NUMBER-1 downto 0) <= (others => RESET_ACTIVE_STATUS);
      elsif rising_edge(clk) then
         for i in 0 to SYNCH_FF_NUMBER-2 loop
            ff_chain(i) <= ff_chain(i+1);
         end loop;
         ff_chain(SYNCH_FF_NUMBER-1)  <= not RESET_ACTIVE_STATUS;
      end if;
   end process;
   rst_o <= ff_chain(0);
end generate GEN_XILINX;

GEN_ALTERA: if VENDOR = "ALTERA" generate
signal ff_chain : std_logic_vector (SYNCH_FF_NUMBER-1 downto 0) := (others => RESET_ACTIVE_STATUS);
attribute PRESERVE : boolean;
attribute PRESERVE of ff_chain : signal is true;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of ff_chain : signal is
  "-name SYNCHRONIZER_IDENTIFICATION AUTO, -name SYNCHRONIZATION_REGISTER_CHAIN_LENGTH " & integer'image(SYNCH_FF_NUMBER-1) &
  ", -name SDC_STATEMENT ""set_false_path -from [get_ports rst]""";
begin
   process(clk, rst) begin
      if (rst = RESET_ACTIVE_STATUS) then
         ff_chain(SYNCH_FF_NUMBER-1 downto 0) <= (others => RESET_ACTIVE_STATUS);
      elsif rising_edge(clk) then
         for i in 0 to SYNCH_FF_NUMBER-2 loop
            ff_chain(i) <= ff_chain(i+1);
         end loop;
         ff_chain(SYNCH_FF_NUMBER-1)  <= not RESET_ACTIVE_STATUS;
      end if;
   end process;
   rst_o <= ff_chain(0);
end generate GEN_ALTERA;

end logic;