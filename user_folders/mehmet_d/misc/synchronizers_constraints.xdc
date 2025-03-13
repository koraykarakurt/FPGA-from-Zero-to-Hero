# modify the following according to the project
set clock_period 10;     # clock period in nano second, 100 MHz
set clock_port_name clk; # clock port name

# logic level and pin assignments
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K18} [get_ports {clk}];
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y21} [get_ports {rst_in}];
#set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB8} [get_ports {rst_out}];

set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN K18} [get_ports clk]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN Y21} [get_ports data_async]
set_property -dict {IOSTANDARD LVCMOS33 PACKAGE_PIN AB8} [get_ports data_sync]

# do NOT modify the following, they are adjusted automatically
# clock constraint
create_clock -name sys_clk -period $clock_period [get_ports $clock_port_name ];

# false path
set_false_path -from [get_ports data_async] -to [get_pins {xilinx_gen.data_reg_reg[0]/D}]