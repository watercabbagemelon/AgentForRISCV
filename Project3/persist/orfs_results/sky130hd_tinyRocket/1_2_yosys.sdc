current_design RocketTile

# 50 MHz clock (20 ns period) — conservative for sky130hd
create_clock -name core_clock -period 20.0 [get_ports {clock}]

set_clock_uncertainty 0.1 [get_clocks core_clock]

set_input_delay  -clock core_clock 2.0 [all_inputs]
set_output_delay -clock core_clock 2.0 [all_outputs]
