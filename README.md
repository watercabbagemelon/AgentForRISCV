# 复旦大学EDA系统软件分析及设计方法学课程作业

本项目基于Claude code实现了一个设计RISCV处理器的agent

## 第一阶段

**定义前端工程师**

输入自然语言

Claude Code解读自然语言，生成chisel

调用sbt将chisel编译为verilog

claude code自行编写testbench

调用verilator进行仿真迭代

最后返回正确的RTL代码

