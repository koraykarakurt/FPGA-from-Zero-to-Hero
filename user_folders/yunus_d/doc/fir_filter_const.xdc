# Set Clock Constraints
set_property PACKAGE_PIN W5 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} [get_ports clk]

# Set Input Delay Constraints
set_input_delay -max 5 -clock [get_clocks sys_clk_pin] [get_ports valid_in]
set_input_delay -min 3 -clock [get_clocks sys_clk_pin] [get_ports valid_in]

set_input_delay -max 5 -clock [get_clocks sys_clk_pin] [get_ports {data_in[*]}]
set_input_delay -min 3 -clock [get_clocks sys_clk_pin] [get_ports {data_in[*]}]

set_input_delay -max 5 -clock [get_clocks sys_clk_pin] [get_ports rst]
set_input_delay -min 3 -clock [get_clocks sys_clk_pin] [get_ports rst]

set_max_delay -from [get_ports {data_in[*]}] -to [get_ports {data_out[*]}] 9.5
set_min_delay -from [get_ports {data_in[*]}] -to [get_ports {data_out[*]}] 0.5


set_max_delay -from [get_ports valid_in] -to [get_ports valid_out] 9.5
set_min_delay -from [get_ports valid_in] -to [get_ports valid_out] 0.5

set_clock_uncertainty -hold 0.3 [get_clocks sys_clk_pin]
