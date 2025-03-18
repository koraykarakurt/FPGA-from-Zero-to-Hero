#CONSTRAINTS FILE FOR ZEDBOARD
# ----------------------------------------------------------------------------
# Clock Source - Bank 13
# ---------------------------------------------------------------------------- 
#set_property PACKAGE_PIN Y9 [get_ports {GCLK}];  # "GCLK"

# ----------------------------------------------------------------------------
# JA Pmod - Bank 13 
# ---------------------------------------------------------------------------- 
#set_property PACKAGE_PIN Y11  [get_ports {clk_dest}];  # "JA1" -- singlebitCDC Destination clock
#set_property PACKAGE_PIN AA11 [get_ports {data_async}];  # "JA2" -- singlebitCDC Asynchronous input signal
#set_property PACKAGE_PIN Y10  [get_ports {data_sync}];  # "JA3" -- singlebitCDC Synchronized output signal
#set_property PACKAGE_PIN AA9  [get_ports {JA4}];  # "JA4"
#set_property PACKAGE_PIN AB11 [get_ports {JA7}];  # "JA7"
#set_property PACKAGE_PIN AB10 [get_ports {clk_dest}];  # "JA8"	-- genericResetBridge Destination clock
#set_property PACKAGE_PIN AB9  [get_ports {rst_async}];  # "JA9"	-- Asynchronous reset input
#set_property PACKAGE_PIN AA8  [get_ports {rst_sync}];  # "JA10"	-- Asynchronously asserted Synchronously de-asserted reset output


# ----------------------------------------------------------------------------
# IOSTANDARD Constraints
#
# Note that these IOSTANDARD constraints are applied to all IOs currently
# assigned within an I/O bank.  If these IOSTANDARD constraints are 
# evaluated prior to other PACKAGE_PIN constraints being applied, then 
# the IOSTANDARD specified will likely not be applied properly to those 
# pins.  Therefore, bank wide IOSTANDARD constraints should be placed 
# within the XDC file in a location that is evaluated AFTER all 
# PACKAGE_PIN constraints within the target bank have been evaluated.
#
# Un-comment one or more of the following IOSTANDARD constraints according to
# the bank pin assignments that are required within a design.
# ---------------------------------------------------------------------------- 

# Note that the bank voltage for IO Bank 33 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 33]];

# Set the bank voltage for IO Bank 34 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 34]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 34]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 34]];

# Set the bank voltage for IO Bank 35 to 1.8V by default.
# set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 35]];
# set_property IOSTANDARD LVCMOS25 [get_ports -of_objects [get_iobanks 35]];
set_property IOSTANDARD LVCMOS18 [get_ports -of_objects [get_iobanks 35]];

# Note that the bank voltage for IO Bank 13 is fixed to 3.3V on ZedBoard. 
set_property IOSTANDARD LVCMOS33 [get_ports -of_objects [get_iobanks 13]];



# TIMING CONSTRAINTS
# ==============================================================================
# False Paths for CDC Modules
# ==============================================================================

# For generic_singlebit_cdc: Data pin of first sync stage
set_false_path -from [get_pins -hierarchical -filter {NAME =~ *data_async*}] \
               -to   [get_pins -hierarchical -filter {NAME =~ *sync_chain_reg[0]/D}]

# For generic_reset_bridge: Reset pin of all sync stages
set_false_path -from [get_pins -hierarchical -filter {NAME =~ *rst_async*}] \
               -to   [get_pins -hierarchical -filter {NAME =~ *sync_chain_reg[*]/PRE}]