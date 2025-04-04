create_clock -name SOURCE_CLOCK -period 8.00 -waveform {0 4} [get_ports clk_src]
create_clock -name DESTINATION_CLOCK -period 6.00 -waveform {0 3} [get_ports clk_dest]

#set_false_path -from [get_clocks SOURCE_CLOCK] -to [get_clocks DESTINATION_CLOCK]
set_false_path -to [get_pins instance_generic_singlebit_cdc/GEN_XILINX.ff_chain_reg[3]/D]