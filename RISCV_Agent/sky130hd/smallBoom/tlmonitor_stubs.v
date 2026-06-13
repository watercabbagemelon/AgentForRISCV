// Auto-generated TLMonitor black-box stubs

(* blackbox *) module TLMonitor (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input        io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_1 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [2:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_b_bits_param,
  input [3:0]  io_in_b_bits_size,
  input [2:0]  io_in_b_bits_source,
  input [31:0] io_in_b_bits_address,
  input        io_in_c_ready,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_size,
  input [2:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_10 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [4:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_11 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [14:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_12 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input        io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_13 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input        io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_14 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_15 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_16 (
  input        clock,
  input [30:0] io_in_a_bits_address,
  input        io_in_d_valid,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_17 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_18 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_19 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_2 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input        io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_20 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [13:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_corrupt
); endmodule

(* blackbox *) module TLMonitor_21 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [4:0]  io_in_a_bits_source,
  input [13:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_22 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [25:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [8:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_23 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [25:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_24 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [27:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [4:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_25 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [25:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [4:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_26 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [11:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [4:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_27 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [16:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_28 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [8:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_29 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_3 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [2:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_b_bits_param,
  input [3:0]  io_in_b_bits_size,
  input [2:0]  io_in_b_bits_source,
  input [31:0] io_in_b_bits_address,
  input        io_in_c_ready,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_size,
  input [2:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_30 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [8:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_31 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_32 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_33 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_34 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_35 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_36 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_37 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_b_bits_param,
  input [31:0] io_in_b_bits_address,
  input        io_in_c_ready,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_38 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [25:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_39 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_b_bits_param,
  input [31:0] io_in_b_bits_address,
  input        io_in_c_ready,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_4 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_40 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_c_bits_opcode,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_41 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_42 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [1:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_b_bits_opcode,
  input [1:0]  io_in_b_bits_param,
  input [3:0]  io_in_b_bits_size,
  input [1:0]  io_in_b_bits_source,
  input [31:0] io_in_b_bits_address,
  input [7:0]  io_in_b_bits_mask,
  input        io_in_b_bits_corrupt,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_size,
  input [1:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [1:0]  io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_43 (
  input        clock,
  input [31:0] io_in_a_bits_address,
  input        io_in_d_valid,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_44 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [2:0]  io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_b_bits_opcode,
  input [1:0]  io_in_b_bits_param,
  input [3:0]  io_in_b_bits_size,
  input [2:0]  io_in_b_bits_source,
  input [31:0] io_in_b_bits_address,
  input [7:0]  io_in_b_bits_mask,
  input        io_in_b_bits_corrupt,
  input [2:0]  io_in_c_bits_opcode,
  input [3:0]  io_in_c_bits_size,
  input [2:0]  io_in_c_bits_source,
  input [31:0] io_in_c_bits_address,
  input        io_in_c_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input [2:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied,
  input [2:0]  io_in_e_bits_sink
); endmodule

(* blackbox *) module TLMonitor_45 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [27:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_46 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [25:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_47 (
  input       clock,
  input [2:0] io_in_a_bits_opcode,
  input [8:0] io_in_a_bits_address,
  input       io_in_d_ready,
  input [2:0] io_in_d_bits_opcode,
  input [1:0] io_in_d_bits_param,
  input       io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_48 (
  input       clock,
  input [2:0] io_in_a_bits_opcode,
  input [6:0] io_in_a_bits_address,
  input       io_in_d_ready,
  input [2:0] io_in_d_bits_opcode
); endmodule

(* blackbox *) module TLMonitor_49 (
  input       clock,
  input [2:0] io_in_a_bits_opcode,
  input [8:0] io_in_a_bits_address,
  input       io_in_d_ready,
  input [2:0] io_in_d_bits_opcode,
  input [1:0] io_in_d_bits_param,
  input       io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_5 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_50 (
  input         clock,
  input [2:0]   io_in_a_bits_opcode,
  input [127:0] io_in_a_bits_address,
  input         io_in_d_ready,
  input [2:0]   io_in_d_bits_opcode,
  input [1:0]   io_in_d_bits_size,
  input         io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_51 (
  input       clock,
  input [2:0] io_in_a_bits_opcode,
  input [8:0] io_in_a_bits_address,
  input       io_in_d_ready,
  input [2:0] io_in_d_bits_opcode,
  input [1:0] io_in_d_bits_param,
  input       io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_52 (
  input       clock,
  input [2:0] io_in_a_bits_opcode,
  input [1:0] io_in_a_bits_size,
  input       io_in_a_bits_source,
  input [8:0] io_in_a_bits_address,
  input [3:0] io_in_a_bits_mask,
  input       io_in_a_bits_corrupt,
  input [2:0] io_in_d_bits_opcode,
  input [1:0] io_in_d_bits_size,
  input       io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_53 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [11:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_54 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [16:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_55 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_56 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_57 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_58 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_59 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [8:0]  io_in_a_bits_source,
  input [20:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [8:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_6 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_60 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input        io_in_a_bits_source,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_61 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [7:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_size,
  input [7:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_62 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [7:0]  io_in_a_bits_source,
  input [17:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [1:0]  io_in_d_bits_size,
  input [7:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_63 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_64 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [1:0]  io_in_a_bits_size,
  input [7:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [7:0]  io_in_d_bits_source,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_65 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [28:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_66 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_source,
  input [17:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_size,
  input [3:0]  io_in_d_bits_source
); endmodule

(* blackbox *) module TLMonitor_67 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [3:0]  io_in_a_bits_size,
  input [31:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_d_ready,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [3:0]  io_in_d_bits_size,
  input        io_in_d_bits_source,
  input [2:0]  io_in_d_bits_sink,
  input        io_in_d_bits_denied
); endmodule

(* blackbox *) module TLMonitor_7 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_8 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [30:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [1:0]  io_in_d_bits_param,
  input [2:0]  io_in_d_bits_size,
  input [4:0]  io_in_d_bits_source,
  input        io_in_d_bits_sink
); endmodule

(* blackbox *) module TLMonitor_9 (
  input        clock,
  input [2:0]  io_in_a_bits_opcode,
  input [4:0]  io_in_a_bits_source,
  input [14:0] io_in_a_bits_address,
  input [7:0]  io_in_a_bits_mask,
  input        io_in_a_bits_corrupt,
  input [2:0]  io_in_d_bits_opcode,
  input [4:0]  io_in_d_bits_source
); endmodule