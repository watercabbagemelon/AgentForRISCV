# Testbench 生成技能

## 触发条件
当 Chisel 代码生成并成功转换为 Verilog 后，自动生成对应 Testbench。

## 执行步骤
1. 分析模块接口，确定测试策略（遍历所有操作、随机值、边界值）。
2. 生成 C++ 仿真驱动（基于 Verilator）或 Verilog Testbench，放置于 `testbench/` 目录。
3. 确保测试输出符合作业要求的格式：`[TEST N] 操作: 输入 | expect=值 got=值 | PASS/FAIL`。
4. 仿真结果保存至 `sim/logs/sim_result.log`。