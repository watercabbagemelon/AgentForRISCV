// SRAM macro wrappers for tinyRocket on sky130hd
// Replaces fakeram45 instances with sram22_sky130 physical macros
//
// Source: /OpenROAD-flow-scripts/flow/designs/nangate45/tinyRocket/freechips.rocketchip.system.TinyConfig.v
// SRAM modules needed:
//   data_arrays_0_ext   : 64x32 masked RW  -> sram22_64x32m4w8
//   tag_array_ext       : 4x25  RW         -> synthesized flops (too small)
//   data_arrays_0_0_ext : 64x32 RW         -> sram22_64x32m4w8
//   mem_ext             : 1024x32 1R+1W    -> sram22_1024x32m8w8 (pseudo-dual-port)

// ---------------------------------------------------------------------------
// data_arrays_0_ext: I-cache data array, 64x32 masked RW
// sram22_64x32m4w8: 64 words x 32 bits, write mask granularity 8 bits (4 masks)
// ---------------------------------------------------------------------------
module data_arrays_0_ext(
  input         RW0_clk,
  input  [5:0]  RW0_addr,
  input         RW0_en,
  input         RW0_wmode,
  input  [3:0]  RW0_wmask,
  input  [31:0] RW0_wdata,
  output [31:0] RW0_rdata
);

  sram22_64x32m4w8 mem (
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


// ---------------------------------------------------------------------------
// tag_array_ext: I-cache tag array, 4x25 RW
// Too small for any sram22 macro — synthesized as register file
// ---------------------------------------------------------------------------
module tag_array_ext(
  input         RW0_clk,
  input  [1:0]  RW0_addr,
  input         RW0_en,
  input         RW0_wmode,
  input  [0:0]  RW0_wmask,
  input  [24:0] RW0_wdata,
  output [24:0] RW0_rdata
);

  reg        reg_RW0_ren;
  reg [1:0]  reg_RW0_addr;
  reg [24:0] ram [0:3];

  always @(posedge RW0_clk) begin
    reg_RW0_ren  <= RW0_en & ~RW0_wmode;
    if (RW0_en & ~RW0_wmode)
      reg_RW0_addr <= RW0_addr;
    if (RW0_en & RW0_wmode & RW0_wmask[0])
      ram[RW0_addr] <= RW0_wdata;
  end

  assign RW0_rdata = ram[reg_RW0_addr];

endmodule


// ---------------------------------------------------------------------------
// data_arrays_0_0_ext: D-cache data array, 64x32 RW (no mask)
// sram22_64x32m4w8 with wmask tied to 4'hF (all bytes enabled)
// ---------------------------------------------------------------------------
module data_arrays_0_0_ext(
  input         RW0_clk,
  input  [5:0]  RW0_addr,
  input         RW0_en,
  input         RW0_wmode,
  input  [0:0]  RW0_wmask,
  input  [31:0] RW0_wdata,
  output [31:0] RW0_rdata
);

  sram22_64x32m4w8 mem (
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
// mem_ext: scratchpad/DTIM, 1024x32 true dual-port (1R + 1W)
// Implemented as pseudo-dual-port using sram22_1024x32m8w8:
//   - Write port takes priority; read uses same clock
//   - R0_clk assumed same as W0_clk (standard for this design)
// ---------------------------------------------------------------------------
module mem_ext(
  input         W0_clk,
  input  [9:0]  W0_addr,
  input         W0_en,
  input  [31:0] W0_data,
  input  [3:0]  W0_mask,
  input         R0_clk,
  input  [9:0]  R0_addr,
  input         R0_en,
  output [31:0] R0_data
);

  // Arbitrate: write takes priority over read
  wire [9:0] addr_mux = W0_en ? W0_addr : R0_addr;
  wire       ce       = W0_en | R0_en;

  sram22_1024x32m8w8 mem (
    .clk   (W0_clk),
    .rstb  (1'b1),
    .ce    (ce),
    .we    (W0_en),
    .wmask (W0_mask),
    .addr  (addr_mux),
    .din   (W0_data),
    .dout  (R0_data)
  );

endmodule
