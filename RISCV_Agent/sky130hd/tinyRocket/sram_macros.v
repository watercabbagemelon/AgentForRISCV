// SRAM macro wrappers for tinyRocket (TinyRocketConfig) on sky130hd
//
// SRAM black-boxes from read_mems_conf:
//   data_arrays_0_ext   : 4096x32 mrw, mask_gran=8  -> 2x sram22_2048x32m8w8 (banked by addr[11])
//   tag_array_0_ext     : 64x21   rw                -> sram22_64x22m4w22 (low 21 bits used)
//   data_arrays_0_0_ext : 1024x32 rw                -> sram22_1024x32m8w8 (wmask tied 4'hF)
//   mem_ext             : 1024x32 mrw, mask_gran=8  -> sram22_1024x32m8w8

// ---------------------------------------------------------------------------
// data_arrays_0_ext: I-cache data array, 4096x32 masked RW
// Banked into two sram22_2048x32m8w8 instances, selected by addr[11]
// ---------------------------------------------------------------------------
module data_arrays_0_ext(
  input  [11:0] RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [31:0] RW0_wdata,
  input  [3:0]  RW0_wmask,
  output [31:0] RW0_rdata
);

  wire bank_sel = RW0_addr[11];
  wire ce_lo   = RW0_en & ~bank_sel;
  wire ce_hi   = RW0_en &  bank_sel;

  wire [31:0] dout_lo, dout_hi;

  sram22_2048x32m8w8 bank0 (
    .clk   (RW0_clk),
    .rstb  (1'b1),
    .ce    (ce_lo),
    .we    (RW0_wmode),
    .wmask (RW0_wmask),
    .addr  (RW0_addr[10:0]),
    .din   (RW0_wdata),
    .dout  (dout_lo)
  );

  sram22_2048x32m8w8 bank1 (
    .clk   (RW0_clk),
    .rstb  (1'b1),
    .ce    (ce_hi),
    .we    (RW0_wmode),
    .wmask (RW0_wmask),
    .addr  (RW0_addr[10:0]),
    .din   (RW0_wdata),
    .dout  (dout_hi)
  );

  // Register bank_sel to align with SRAM output (1-cycle read latency)
  reg bank_sel_r;
  always @(posedge RW0_clk)
    bank_sel_r <= bank_sel;

  assign RW0_rdata = bank_sel_r ? dout_hi : dout_lo;

endmodule


// ---------------------------------------------------------------------------
// tag_array_0_ext: I-cache tag array, 64x21 RW (no mask)
// sram22_64x22m4w22: 64 words x 22 bits, use low 21 bits
// ---------------------------------------------------------------------------
module tag_array_0_ext(
  input  [5:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [20:0] RW0_wdata,
  output [20:0] RW0_rdata
);

  wire [21:0] dout_raw;

  sram22_64x22m4w22 mem (
    .clk   (RW0_clk),
    .rstb  (1'b1),
    .ce    (RW0_en),
    .we    (RW0_wmode),
    .addr  (RW0_addr),
    .din   ({1'b0, RW0_wdata}),
    .dout  (dout_raw)
  );

  assign RW0_rdata = dout_raw[20:0];

endmodule


// ---------------------------------------------------------------------------
// data_arrays_0_0_ext: D-cache data array, 1024x32 RW (no mask)
// sram22_1024x32m8w8 with wmask tied to 4'hF (all bytes enabled)
// ---------------------------------------------------------------------------
module data_arrays_0_0_ext(
  input  [9:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [31:0] RW0_wdata,
  output [31:0] RW0_rdata
);

  sram22_1024x32m8w8 mem (
    .clk   (RW0_clk),
    .rstb  (1'b1),
    .ce    (RW0_en),
    .we    (RW0_wmode),
    .wmask (4'hF),
    .addr  (RW0_addr),
    .din   (RW0_wdata),
    .dout  (RW0_rdata)
  );

endmodule


// ---------------------------------------------------------------------------
// mem_ext: scratchpad/DTIM, 1024x32 masked RW
// sram22_1024x32m8w8: single-port, write-mask granularity 8 bits
// ---------------------------------------------------------------------------
module mem_ext(
  input  [9:0]  RW0_addr,
  input         RW0_en,
                RW0_clk,
                RW0_wmode,
  input  [31:0] RW0_wdata,
  input  [3:0]  RW0_wmask,
  output [31:0] RW0_rdata
);

  sram22_1024x32m8w8 mem (
    .clk   (RW0_clk),
    .rstb  (1'b1),
    .ce    (RW0_en),
    .we    (RW0_wmode),
    .wmask (RW0_wmask),
    .addr  (RW0_addr),
    .din   (RW0_wdata),
    .dout  (RW0_rdata)
  );

endmodule

// ===========================================================================
// Synthesizable stubs for removed verification/bus modules
// All outputs tied to 0 so Yosys opt_clean can eliminate dead logic.
// ===========================================================================

module ScratchpadSlavePort (
  input clock, reset,
  input auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param, auto_in_a_bits_size, input [8:0] auto_in_a_bits_source,
  input [31:0] auto_in_a_bits_address, input [3:0] auto_in_a_bits_mask, input [31:0] auto_in_a_bits_data,
  input auto_in_d_ready, output auto_in_a_ready, auto_in_d_valid, output [2:0] auto_in_d_bits_opcode, output [1:0] auto_in_d_bits_size,
  output [8:0] auto_in_d_bits_source, output [31:0] auto_in_d_bits_data,
  input io_dmem_req_ready, io_dmem_s2_nack, io_dmem_resp_valid, input [31:0] io_dmem_resp_bits_data_raw,
  output io_dmem_req_valid, output [31:0] io_dmem_req_bits_addr, output [4:0] io_dmem_req_bits_cmd,
  output [1:0] io_dmem_req_bits_size, output io_dmem_s1_kill, output [31:0] io_dmem_s1_data_data, output [3:0] io_dmem_s1_data_mask
);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_valid = 1'b0;
  assign auto_in_d_bits_opcode = 3'b0; assign auto_in_d_bits_size = 2'b0;
  assign auto_in_d_bits_source = 9'b0; assign auto_in_d_bits_data = 32'b0;
  assign io_dmem_req_valid = 1'b0; assign io_dmem_req_bits_addr = 32'b0;
  assign io_dmem_req_bits_cmd = 5'b0; assign io_dmem_req_bits_size = 2'b0;
  assign io_dmem_s1_kill = 1'b0; assign io_dmem_s1_data_data = 32'b0; assign io_dmem_s1_data_mask = 4'b0;
endmodule

(* blackbox *) module TLMonitor(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_1(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_2(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_3(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_4(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_5(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_6(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_8(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_9(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [14:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_10(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_11(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [14:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_12(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_13(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_14(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [2:0] io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input [2:0] io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_15(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [1:0] io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input [1:0] io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_16(input clock, reset, io_in_a_ready, io_in_a_valid, input [31:0] io_in_a_bits_address, input io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_17(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [2:0] io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input [2:0] io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_18(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [2:0] io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input [2:0] io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_21(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [2:0] io_in_a_bits_source, input [13:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input [2:0] io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_22(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [27:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_23(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [25:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_24(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [11:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_25(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [16:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_26(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input [7:0] io_in_d_bits_source, input io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_27(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_28(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input [7:0] io_in_d_bits_source, input io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_29(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_30(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_31(input clock, reset, io_in_a_ready, io_in_a_valid, input [31:0] io_in_a_bits_address, input io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_32(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_33(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [27:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_34(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [25:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_35(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, input [8:0] io_in_a_bits_address, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_36(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, input [6:0] io_in_a_bits_address, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode); endmodule
(* blackbox *) module TLMonitor_37(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, input [8:0] io_in_a_bits_address, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_39(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, input [8:0] io_in_a_bits_address, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_40(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input io_in_a_bits_source, input [8:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_41(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [11:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_43(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_44(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_45(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [30:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_46(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_47(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [20:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_48(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [3:0] io_in_a_bits_size, input io_in_a_bits_source, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_49(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_size, input [7:0] io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_51(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_52(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, input [1:0] io_in_a_bits_size, input [7:0] io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, io_in_d_bits_size, input [7:0] io_in_d_bits_source, input io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_53(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [28:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [2:0] io_in_d_bits_size, io_in_d_bits_source, input io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule
(* blackbox *) module TLMonitor_54(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, io_in_a_bits_param, io_in_a_bits_size, io_in_a_bits_source, input [17:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_a_bits_corrupt, io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_size, io_in_d_bits_source); endmodule
(* blackbox *) module TLMonitor_55(input clock, reset, io_in_a_ready, io_in_a_valid, input [2:0] io_in_a_bits_opcode, input [3:0] io_in_a_bits_size, input [31:0] io_in_a_bits_address, input [3:0] io_in_a_bits_mask, input io_in_d_ready, io_in_d_valid, input [2:0] io_in_d_bits_opcode, input [1:0] io_in_d_bits_param, input [3:0] io_in_d_bits_size, input io_in_d_bits_source, io_in_d_bits_sink, io_in_d_bits_denied, io_in_d_bits_corrupt); endmodule

module TLAtomicAutomata(input clock, reset, auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param, auto_in_a_bits_size, auto_in_a_bits_source, input [30:0] auto_in_a_bits_address, input [3:0] auto_in_a_bits_mask, input [31:0] auto_in_a_bits_data, input auto_in_a_bits_corrupt, auto_in_d_ready, auto_out_a_ready, auto_out_d_valid, input [2:0] auto_out_d_bits_opcode, input [1:0] auto_out_d_bits_param, input [2:0] auto_out_d_bits_size, auto_out_d_bits_source, input auto_out_d_bits_sink, auto_out_d_bits_denied, input [31:0] auto_out_d_bits_data, input auto_out_d_bits_corrupt, output auto_in_a_ready, auto_in_d_valid, output [2:0] auto_in_d_bits_opcode, output [1:0] auto_in_d_bits_param, output [2:0] auto_in_d_bits_size, auto_in_d_bits_source, output auto_in_d_bits_sink, auto_in_d_bits_denied, output [31:0] auto_in_d_bits_data, output auto_in_d_bits_corrupt, auto_out_a_valid, output [2:0] auto_out_a_bits_opcode, auto_out_a_bits_param, auto_out_a_bits_size, auto_out_a_bits_source, output [30:0] auto_out_a_bits_address, output [3:0] auto_out_a_bits_mask, output [31:0] auto_out_a_bits_data, output auto_out_a_bits_corrupt, auto_out_d_ready);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_bits_opcode = 3'b0; assign auto_in_d_bits_param = 2'b0; assign auto_in_d_bits_size = 3'b0; assign auto_in_d_bits_sink = 1'b0; assign auto_in_d_bits_data = 32'b0; assign auto_in_d_bits_corrupt = 1'b0; assign auto_out_a_bits_opcode = 3'b0; assign auto_out_a_bits_address = 31'b0; assign auto_out_a_bits_mask = 4'b0; assign auto_out_a_bits_data = 32'b0; assign auto_out_a_bits_corrupt = 1'b0;
endmodule

module TLAtomicAutomata_1(input clock, reset, auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param, input [3:0] auto_in_a_bits_size, input [2:0] auto_in_a_bits_source, input [31:0] auto_in_a_bits_address, input [3:0] auto_in_a_bits_mask, input [31:0] auto_in_a_bits_data, input auto_in_a_bits_corrupt, auto_in_d_ready, auto_out_a_ready, auto_out_d_valid, input [2:0] auto_out_d_bits_opcode, input [1:0] auto_out_d_bits_param, input [3:0] auto_out_d_bits_size, input [2:0] auto_out_d_bits_source, input auto_out_d_bits_sink, auto_out_d_bits_denied, input [31:0] auto_out_d_bits_data, input auto_out_d_bits_corrupt, output auto_in_a_ready, auto_in_d_valid, output [2:0] auto_in_d_bits_opcode, output [1:0] auto_in_d_bits_param, output [3:0] auto_in_d_bits_size, output [2:0] auto_in_d_bits_source, output auto_in_d_bits_sink, auto_in_d_bits_denied, output [31:0] auto_in_d_bits_data, output auto_in_d_bits_corrupt, auto_out_a_valid, output [2:0] auto_out_a_bits_opcode, auto_out_a_bits_param, output [3:0] auto_out_a_bits_size, output [2:0] auto_out_a_bits_source, output [31:0] auto_out_a_bits_address, output [3:0] auto_out_a_bits_mask, output [31:0] auto_out_a_bits_data, output auto_out_a_bits_corrupt, auto_out_d_ready);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_bits_opcode = 3'b0; assign auto_in_d_bits_param = 2'b0; assign auto_in_d_bits_size = 4'b0; assign auto_in_d_bits_source = 3'b0; assign auto_in_d_bits_sink = 1'b0; assign auto_in_d_bits_data = 32'b0; assign auto_in_d_bits_corrupt = 1'b0; assign auto_out_a_bits_opcode = 3'b0; assign auto_out_a_bits_size = 4'b0; assign auto_out_a_bits_source = 3'b0; assign auto_out_a_bits_address = 32'b0; assign auto_out_a_bits_mask = 4'b0; assign auto_out_a_bits_data = 32'b0; assign auto_out_a_bits_corrupt = 1'b0;
endmodule

module TLError(input clock, reset, auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param, input [3:0] auto_in_a_bits_size, input [2:0] auto_in_a_bits_source, input [13:0] auto_in_a_bits_address, input [3:0] auto_in_a_bits_mask, input [31:0] auto_in_a_bits_data, input auto_in_a_bits_corrupt, auto_in_d_ready, output auto_in_a_ready, auto_in_d_valid, output [2:0] auto_in_d_bits_opcode, output [3:0] auto_in_d_bits_size, output [2:0] auto_in_d_bits_source, output auto_in_d_bits_corrupt);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_bits_opcode = 3'b0; assign auto_in_d_bits_size = 4'b0; assign auto_in_d_bits_source = 3'b0; assign auto_in_d_bits_corrupt = 1'b0;
endmodule

module TLError_1(input clock, reset, auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, input [127:0] auto_in_a_bits_address, input auto_in_d_ready, output auto_in_a_ready, auto_in_d_valid, output [2:0] auto_in_d_bits_opcode, output [1:0] auto_in_d_bits_size, output auto_in_d_bits_denied, auto_in_d_bits_corrupt);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_bits_opcode = 3'b0; assign auto_in_d_bits_size = 2'b0; assign auto_in_d_bits_denied = 1'b0;
endmodule

module TLROM(input clock, reset, auto_in_a_valid, input [2:0] auto_in_a_bits_opcode, auto_in_a_bits_param, input [1:0] auto_in_a_bits_size, input [7:0] auto_in_a_bits_source, input [16:0] auto_in_a_bits_address, input [3:0] auto_in_a_bits_mask, input auto_in_a_bits_corrupt, auto_in_d_ready, output auto_in_a_ready, auto_in_d_valid, output [1:0] auto_in_d_bits_size, output [7:0] auto_in_d_bits_source, output [31:0] auto_in_d_bits_data);
  assign auto_in_a_ready = 1'b0; assign auto_in_d_bits_size = 2'b0; assign auto_in_d_bits_source = 8'b0; assign auto_in_d_bits_data = 32'b0;
endmodule

module EICG_wrapper(input clock, input reset);
endmodule

module GenericDigitalInIOCell(input clock, input reset);
endmodule

module GenericDigitalOutIOCell(input clock, input reset);
endmodule

module SimSerial(input clock, input reset);
endmodule
