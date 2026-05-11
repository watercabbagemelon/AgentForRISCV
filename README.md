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

*修改：*
对hooks配置文件进行了修改，修改部分文件路径

## 第二阶段

**定义后端工程师**

输入RTL

使用OpenROAD docker完成**综合**、**布局**、**布线**、**版图生成**

每个阶段给出相应的报告，迭代测试

最后返回GDS文件

## 第三阶段

**Agent串联：**

输入spec自然语言

使用sky130工艺库

Agent根据需求调用ChipYard docker生成sv

claude code将sv转化成v，完成SRAM宏单元映射

调用OpenROAD docker完成后端综合布局布线

最后返回报告和GDS版图

根据用户需求调参迭代
