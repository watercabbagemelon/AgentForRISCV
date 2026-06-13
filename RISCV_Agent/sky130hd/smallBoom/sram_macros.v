// SmallBOOM All-Mock config - SRAM wrappers removed
// Only synthesizable stubs for removed verification/peripheral modules

// ===========================================================================
// Stub modules for deleted verification/peripheral modules
// All outputs tied to 0; Yosys opt_clean will eliminate them.
// ===========================================================================

module TLError(
  input clock, reset, auto_in_a_valid,
  input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param,
  input [3:0] auto_in_a_bits_size,
  input [2:0] auto_in_a_bits_source,
  input [13:0] auto_in_a_bits_address,
  input [3:0] auto_in_a_bits_mask,
  input [31:0] auto_in_a_bits_data,
  input auto_in_a_bits_corrupt, auto_in_d_ready,
  output auto_in_a_ready, auto_in_d_valid,
  output [2:0] auto_in_d_bits_opcode,
  output [3:0] auto_in_d_bits_size,
  output [2:0] auto_in_d_bits_source,
  output auto_in_d_bits_corrupt
);
  assign auto_in_a_ready = 1'b0;
  assign auto_in_d_bits_opcode = 3'b0;
  assign auto_in_d_bits_size = 4'b0;
  assign auto_in_d_bits_source = 3'b0;
  assign auto_in_d_bits_corrupt = 1'b0;
endmodule

module TLError_1(
  input clock, reset, auto_in_a_valid,
  input [2:0] auto_in_a_bits_opcode,
  input [127:0] auto_in_a_bits_address,
  input auto_in_d_ready,
  output auto_in_a_ready, auto_in_d_valid,
  output [2:0] auto_in_d_bits_opcode,
  output [1:0] auto_in_d_bits_size,
  output auto_in_d_bits_denied, auto_in_d_bits_corrupt
);
  assign auto_in_a_ready = 1'b0;
  assign auto_in_d_bits_opcode = 3'b0;
  assign auto_in_d_bits_size = 2'b0;
  assign auto_in_d_bits_denied = 1'b0;
endmodule

module TLAtomicAutomata(
  input clock, reset, auto_in_a_valid,
  input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param,
  input [3:0] auto_in_a_bits_size,
  input [2:0] auto_in_a_bits_source,
  input [30:0] auto_in_a_bits_address,
  input [3:0] auto_in_a_bits_mask,
  input [31:0] auto_in_a_bits_data,
  input auto_in_a_bits_corrupt, auto_in_d_ready, auto_out_a_ready, auto_out_d_valid,
  input [2:0] auto_out_d_bits_opcode,
  input [1:0] auto_out_d_bits_param,
  input [2:0] auto_out_d_bits_size, auto_out_d_bits_source,
  input auto_out_d_bits_sink, auto_out_d_bits_denied,
  input [31:0] auto_out_d_bits_data,
  input auto_out_d_bits_corrupt,
  output auto_in_a_ready, auto_in_d_valid,
  output [2:0] auto_in_d_bits_opcode,
  output [1:0] auto_in_d_bits_param,
  output [2:0] auto_in_d_bits_size, auto_in_d_bits_source,
  output auto_in_d_bits_sink, auto_in_d_bits_denied,
  output [31:0] auto_in_d_bits_data,
  output auto_in_d_bits_corrupt, auto_out_a_valid,
  output [2:0] auto_out_a_bits_opcode, auto_out_a_bits_param,
  output [3:0] auto_out_a_bits_size,
  output [2:0] auto_out_a_bits_source,
  output [30:0] auto_out_a_bits_address,
  output [3:0] auto_out_a_bits_mask,
  output [31:0] auto_out_a_bits_data,
  output auto_out_a_bits_corrupt, auto_out_d_ready
);
  assign auto_in_a_ready = 1'b0;
  assign auto_in_d_bits_opcode = 3'b0;
  assign auto_in_d_bits_param = 2'b0;
  assign auto_in_d_bits_size = 3'b0;
  assign auto_in_d_bits_sink = 1'b0;
  assign auto_in_d_bits_data = 32'b0;
  assign auto_in_d_bits_corrupt = 1'b0;
  assign auto_out_a_bits_opcode = 3'b0;
  assign auto_out_a_bits_address = 31'b0;
  assign auto_out_a_bits_mask = 4'b0;
  assign auto_out_a_bits_data = 32'b0;
  assign auto_out_a_bits_corrupt = 1'b0;
endmodule

module TLAtomicAutomata_1(
  input clock, reset, auto_in_a_valid,
  input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param,
  input [3:0] auto_in_a_bits_size,
  input [2:0] auto_in_a_bits_source,
  input [31:0] auto_in_a_bits_address,
  input [3:0] auto_in_a_bits_mask,
  input [31:0] auto_in_a_bits_data,
  input auto_in_a_bits_corrupt, auto_in_d_ready, auto_out_a_ready, auto_out_d_valid,
  input [2:0] auto_out_d_bits_opcode,
  input [1:0] auto_out_d_bits_param,
  input [3:0] auto_out_d_bits_size,
  input [2:0] auto_out_d_bits_source,
  input auto_out_d_bits_sink, auto_out_d_bits_denied,
  input [31:0] auto_out_d_bits_data,
  input auto_out_d_bits_corrupt,
  output auto_in_a_ready, auto_in_d_valid,
  output [2:0] auto_in_d_bits_opcode,
  output [1:0] auto_in_d_bits_param,
  output [3:0] auto_in_d_bits_size,
  output [2:0] auto_in_d_bits_source,
  output auto_in_d_bits_sink, auto_in_d_bits_denied,
  output [31:0] auto_in_d_bits_data,
  output auto_in_d_bits_corrupt, auto_out_a_valid,
  output [2:0] auto_out_a_bits_opcode, auto_out_a_bits_param,
  output [3:0] auto_out_a_bits_size,
  output [2:0] auto_out_a_bits_source,
  output [31:0] auto_out_a_bits_address,
  output [3:0] auto_out_a_bits_mask,
  output [31:0] auto_out_a_bits_data,
  output auto_out_a_bits_corrupt, auto_out_d_ready
);
  assign auto_in_a_ready = 1'b0;
  assign auto_in_d_bits_opcode = 3'b0;
  assign auto_in_d_bits_param = 2'b0;
  assign auto_in_d_bits_size = 4'b0;
  assign auto_in_d_bits_source = 3'b0;
  assign auto_in_d_bits_sink = 1'b0;
  assign auto_in_d_bits_data = 32'b0;
  assign auto_in_d_bits_corrupt = 1'b0;
  assign auto_out_a_bits_opcode = 3'b0;
  assign auto_out_a_bits_size = 4'b0;
  assign auto_out_a_bits_source = 3'b0;
  assign auto_out_a_bits_address = 32'b0;
  assign auto_out_a_bits_mask = 4'b0;
  assign auto_out_a_bits_data = 32'b0;
  assign auto_out_a_bits_corrupt = 1'b0;
endmodule

module TLROM(
  input clock, reset, auto_in_a_valid,
  input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param,
  input [1:0] auto_in_a_bits_size,
  input [7:0] auto_in_a_bits_source,
  input [16:0] auto_in_a_bits_address,
  input [3:0] auto_in_a_bits_mask,
  input auto_in_a_bits_corrupt, auto_in_d_ready,
  output auto_in_a_ready, auto_in_d_valid,
  output [1:0] auto_in_d_bits_size,
  output [7:0] auto_in_d_bits_source,
  output [31:0] auto_in_d_bits_data
);
  assign auto_in_a_ready = 1'b0;
  assign auto_in_d_bits_size = 2'b0;
  assign auto_in_d_bits_source = 8'b0;
  assign auto_in_d_bits_data = 32'b0;
endmodule

module EICG_wrapper(input clock, input reset);
endmodule

module GenericDigitalInIOCell(input clock, input reset);
endmodule

module GenericDigitalOutIOCell(input clock, input reset);
endmodule

module SimSerial(input clock, input reset);
endmodule
