###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
#create_clock -period 10 -name clk [get_pins IBUFGDS_inst/O]
#create_clock -name clk_mode0 -period 10 [get_ports clkin]
#create_clock -name SysClk -period 10 -waveform {0 5} [get_ports sysclk]

#create_clock -name clk -period 33 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 15 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 10 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 8.33 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 8 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 7.3 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 4.2 -waveform {0 5} [get_ports clk_p]
#create_clock -name clk -period 4.15 -waveform {0 5} [get_ports clk_p]

#create_clock -period 10.000 -name clk -waveform {0.000 5.000} [get_ports clk]

create_clock -period 3.37 -name clk [get_ports clk]
#create_clock -period 2.79 -name clk [get_ports clk_p]
###############################################################################
# User Physical Constraints
###############################################################################
#SYSCLK
#set_property IOSTANDARD LVDS_25 [get_ports clk_p]
#set_property PACKAGE_PIN R3 [get_ports clk_p]
#set_property PACKAGE_PIN P3 [get_ports clk_n]
#set_property IOSTANDARD LVDS_25 [get_ports clk_n]

#set_property PACKAGE_PIN R3 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]

#set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {i_u_wire[*]}]
#set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {i_u_wire[*]}]
#set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {i_v_wire[*]}]
#set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {i_v_wire[*]}]
#set_input_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {omega_wire[*]}]
#set_input_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {omega_wire[*]}]
#set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {o_u_reg[*]}]
#set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {o_u_reg[*]}]
#set_output_delay -clock [get_clocks clk] -min -add_delay 0.000 [get_ports {o_v_reg[*]}]
#set_output_delay -clock [get_clocks clk] -max -add_delay 0.000 [get_ports {o_v_reg[*]}]
