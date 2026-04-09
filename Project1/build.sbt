// 指定 Scala 版本（Chisel 6 需要 Scala 2.13）
scalaVersion := "2.13.12"

// 项目名称（可选）
name := "riscv-module-generator"

// 添加 Chisel 依赖
libraryDependencies += "org.chipsalliance" %% "chisel" % "6.2.0"

// Chisel 编译器插件（必须）
addCompilerPlugin("org.chipsalliance" % "chisel-plugin" % "6.2.0" cross CrossVersion.full)

// 可选：将源码目录指向 src/（默认是 src/main/scala）
Compile / scalaSource := baseDirectory.value / "src"
