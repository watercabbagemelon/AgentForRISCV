import chisel3._
import chisel3.util._

// ALU 操作码定义
object ALUOp {
  val ADD = 0.U(3.W)
  val SUB = 1.U(3.W)
  val AND = 2.U(3.W)
  val OR  = 3.U(3.W)
  val XOR = 4.U(3.W)
  val SLT = 5.U(3.W)
}

class ALU extends Module {
  val io = IO(new Bundle {
    val a      = Input(UInt(32.W))
    val b      = Input(UInt(32.W))
    val op     = Input(UInt(3.W))   // 0=ADD,1=SUB,2=AND,3=OR,4=XOR,5=SLT
    val result = Output(UInt(32.W))
    val zero   = Output(Bool())
  })

  val result = WireDefault(0.U(32.W))

  switch(io.op) {
    is(ALUOp.ADD) { result := io.a + io.b }
    is(ALUOp.SUB) { result := io.a - io.b }
    is(ALUOp.AND) { result := io.a & io.b }
    is(ALUOp.OR)  { result := io.a | io.b }
    is(ALUOp.XOR) { result := io.a ^ io.b }
    is(ALUOp.SLT) { result := Mux(io.a.asSInt < io.b.asSInt, 1.U, 0.U) }
  }

  io.result := result
  io.zero   := (result === 0.U)
}

object ALUMain extends App {
  val sv = _root_.circt.stage.ChiselStage.emitSystemVerilog(
    new ALU,
    firtoolOpts = Array(
      "--lowering-options=disallowLocalVariables,disallowPackedArrays",
      "--disable-all-randomization",
      "--strip-debug-info"
    )
  )
  val outDir = new java.io.File("generated")
  outDir.mkdirs()
  val pw = new java.io.PrintWriter(new java.io.File(outDir, "top.sv"))
  pw.write(sv)
  pw.close()
  println("Generated: generated/top.sv")
}
