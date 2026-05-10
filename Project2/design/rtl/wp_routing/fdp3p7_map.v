// Techmap: 将 Yosys 内部  映射到 LUT2/LUT3/LUT4
// 将  映射到 DFFRHQ

// LUT4 映射
module $lut (A, Y);
  parameter WIDTH = 0;
  parameter LUT = 0;
  input [WIDTH-1:0] A;
  output Y;
  generate
    if (WIDTH == 1) begin
      LUT2 #(.LUT_INIT({{2{LUT[1]}}, {2{LUT[0]}}})) _TECHMAP_REPLACE_ (
        .O(Y), .ADR0(A[0]), .ADR1(1'b0)
      );
    end else if (WIDTH == 2) begin
      LUT2 #(.LUT_INIT(LUT)) _TECHMAP_REPLACE_ (
        .O(Y), .ADR0(A[0]), .ADR1(A[1])
      );
    end else if (WIDTH == 3) begin
      LUT3 #(.LUT_INIT(LUT)) _TECHMAP_REPLACE_ (
        .O(Y), .ADR0(A[0]), .ADR1(A[1]), .ADR2(A[2])
      );
    end else if (WIDTH == 4) begin
      LUT4 #(.LUT_INIT(LUT)) _TECHMAP_REPLACE_ (
        .O(Y), .ADR0(A[0]), .ADR1(A[1]), .ADR2(A[2]), .ADR3(A[3])
      );
    end else begin
      wire _TECHMAP_FAIL_ = 1;
    end
  endgenerate
endmodule

// DFF with async reset (active low reset -> DFFRHQ has active low RN)
module $_DFF_PN0_ (C, D, Q, R);
  input C, D, R;
  output Q;
  DFFRHQ _TECHMAP_REPLACE_ (.CK(C), .D(D), .Q(Q), .RN(R));
endmodule

module $_DFF_PN1_ (C, D, Q, R);
  input C, D, R;
  output Q;
  // active high reset: invert R
  wire rn;
  assign rn = ~R;
  DFFRHQ _TECHMAP_REPLACE_ (.CK(C), .D(D), .Q(Q), .RN(rn));
endmodule

// DFFE variants - map to DFFRHQ with mux on D
module $_DFFE_PN0N_ (C, D, E, Q, R);
  input C, D, E, R;
  output Q;
  wire d_mux;
  assign d_mux = E ? D : Q;
  DFFRHQ _TECHMAP_REPLACE_ (.CK(C), .D(d_mux), .Q(Q), .RN(R));
endmodule

module $_DFFE_PN0P_ (C, D, E, Q, R);
  input C, D, E, R;
  output Q;
  wire d_mux;
  assign d_mux = E ? D : Q;
  DFFRHQ _TECHMAP_REPLACE_ (.CK(C), .D(d_mux), .Q(Q), .RN(R));
endmodule

module $_DFFE_PN1P_ (C, D, E, Q, R);
  input C, D, E, R;
  output Q;
  wire rn, d_mux;
  assign rn = ~R;
  assign d_mux = E ? D : Q;
  DFFRHQ _TECHMAP_REPLACE_ (.CK(C), .D(d_mux), .Q(Q), .RN(rn));
endmodule
