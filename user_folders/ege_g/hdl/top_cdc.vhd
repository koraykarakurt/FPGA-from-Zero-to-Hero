library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_cdc is
Port (
    clk_src     : in std_logic;
    clk_dest    : in std_logic;
    input_top   : in std_logic;
    output_top  : out std_logic 
);
end top_cdc;

architecture Behavioral of top_cdc is

component generic_singlebit_cdc is
generic(
   SYNCH_FF_NUMBER      : integer range 2 to 8 := 4; --can change with respect to clock speed
   VENDOR               : string    := "XILINX"
);
port(
   clk      : in std_logic;
   data_in  : in std_logic;
   data_o   : out std_logic
);
end component;

signal data_in_sync : std_logic;
signal data_out_sync : std_logic;

begin

instance_generic_singlebit_cdc : generic_singlebit_cdc
port map(
    clk      => clk_dest,
    data_in  => data_in_sync,
    data_o   => data_out_sync
);

SRC_REG : process(clk_src) begin
    if rising_edge(clk_src) then
        data_in_sync <= input_top;
    end if;
end process SRC_REG;

DEST_REG : process(clk_dest) begin
    if rising_edge(clk_dest) then
        output_top <= data_out_sync;
    end if;
end process DEST_REG;

end Behavioral;
