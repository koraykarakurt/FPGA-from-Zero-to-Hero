create_clock -name MAIN_CLOCK -period 10.00 -waveform {0 5} [get_ports clk]

#set_input_delay -max 10.0 -clock [get_clocks MAIN_CLOCK] [get_ports rst]
#set_input_delay -min 2.0  -clock [get_clocks MAIN_CLOCK] [get_ports rst]
set_false_path -from [get_ports rst]