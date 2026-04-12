create_clock -name clock -period 10.0 [get_ports clock]

set_input_delay  2.0 -clock clock [get_ports {reset io_a io_b io_op}]
set_output_delay 2.0 -clock clock [get_ports {io_result io_zero}]
