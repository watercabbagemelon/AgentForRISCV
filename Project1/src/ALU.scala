import chisel3._
import chisel3.util._

class ALU extends Module {
  val io = IO(new Bundle {
    val a      = Input(UInt(32.W))
    val b      = Input(UInt(32.W))
    val op     = Input(UInt(3.W))  // 0=ADD,1=SUB,2=AND,3=OR,4=XOR,5=SLT
    val result = Output(UInt(32.W))
    val zero   = Output(Bool())
  })

  io.result := MuxLookup(io.op, 0.U)(Seq(
    0.U -> (io.a + io.b),
    1.U -> (io.a - io.b),
    2.U -> (io.a & io.b),
    3.U -> (io.a | io.b),
    4.U -> (io.a ^ io.b),
    5.U -> (io.a.asSInt < io.b.asSInt).asUInt
  ))

  io.zero := io.result === 0.U
}

object ALU extends App {
  val sv = _root_.circt.stage.ChiselStage.emitSystemVerilog(
    new ALU,
    firtoolOpts = Array("--lowering-options=disallowLocalVariables")
  )
  val outDir = new java.io.File("generated")
  outDir.mkdirs()
  val pw = new java.io.PrintWriter(new java.io.File(outDir, "top.sv"))
  pw.write(sv)
  pw.close()
  println("Generated: generated/top.sv")
}
