## Clock signal
#set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports src_clk]
create_clock  -name SRC_CLK -period 10.00 -waveform {0 5} [get_ports src_clk]

#set_property -dict { PACKAGE_PIN J3   IOSTANDARD LVCMOS33 } [get_ports dest_clk]
create_clock  -name DST_CLK -period 8.00 -waveform {0 4} [get_ports dest_clk]

## Switches
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33 } [get_ports {a_data}]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports {s_data}]

set_false_path -to [get_pins generic_singlebit_cdc_inst/xilinx_sb_cdc_gen.data_ff_reg[4]/D]