# debug

Diagnose and fix common issues in the tinyRocket RISC-V backend flow (ChipYard RTL generation + ORFS physical implementation).

## Usage

```
/debug [symptom]
```

- `symptom` (optional): brief description of the error or failing step

---

## Known Issues & Fixes

### 1. ChipYard 容器中找不到 verilator / java / sbt

**症状：** 运行 `make verilog` 时报 `command not found`。

**原因：** 工具链通过 conda 环境提供，未激活时不在 PATH 中。

**修复：**
```bash
source /workspace/chipyard/.conda-env/etc/profile.d/conda.sh
conda activate /workspace/chipyard/.conda-env
```

激活后自动设置：
- `RISCV=/workspace/chipyard/.conda-env/riscv-tools`
- PATH 包含 verilator、java、sbt 等工具

---

### 2. ORFS make 报 "RISCV is unset"

**症状：** 在 ChipYard 容器内运行 ORFS 相关命令时报环境变量未设置。

**原因：** 同上，conda 环境未激活。

**修复：**
```bash
source /workspace/chipyard/.conda-env/etc/profile.d/conda.sh
conda activate /workspace/chipyard/.conda-env
```

---

### 3. CTS 阶段 "child killed: illegal instruction"

**症状：** `make cts` 或全流程在 CTS 后的 `detailed_placement` 步骤崩溃，报 `illegal instruction`。

**原因：** WSL2 内核对某些 CPU 指令集扩展支持不完整，导致 OpenROAD 的 `detailed_placement` 崩溃。

**修复：** 跳过 CTS 后的时序修复步骤：
```bash
make DESIGN_CONFIG=designs/sky130hd/tinyRocket/config.mk \
     SKIP_CTS_REPAIR_TIMING=1
```

> 注意：在原生 Linux 环境下可去掉 `SKIP_CTS_REPAIR_TIMING=1`。

---

### 4. 更换 SRAM 宏

**症状：** 需要替换或新增 SRAM 物理宏。

**步骤：**

1. 修改 wrapper 文件中的模块实例化：
   ```
   sky130hd/tinyRocket/sram_macros.v
   ```

2. 更新 `config.mk` 中的 LEF/LIB 路径：
   ```makefile
   export ADDITIONAL_LEFS = \
       /workspace/tech/sram22_sky130_macros/<new_macro>/<new_macro>.lef
   export ADDITIONAL_LIBS = \
       /workspace/tech/sram22_sky130_macros/<new_macro>/<new_macro>_tt.lib
   ```

3. 重新部署配置文件到容器：
   ```bash
   docker exec orfs-agent bash -c "
     cp /workspace/sky130hd/tinyRocket/config.mk \
        /OpenROAD-flow-scripts/flow/designs/sky130hd/tinyRocket/
     cp /workspace/sky130hd/tinyRocket/sram_macros.v \
        /OpenROAD-flow-scripts/flow/designs/sky130hd/tinyRocket/
   "
   ```

---

### 5. 重新运行某个步骤

**症状：** 某步骤结果有误，需要从中间步骤重跑。

**方法：** 删除该步骤的 `.odb` 结果文件，make 会自动重新运行：

```bash
# 示例：重跑 place 步骤
docker exec orfs-agent bash -c "
  rm /OpenROAD-flow-scripts/flow/results/sky130hd/tinyRocket/base/3_*.odb
  cd /OpenROAD-flow-scripts/flow
  make DESIGN_CONFIG=designs/sky130hd/tinyRocket/config.mk place
"
```

各步骤对应的结果文件前缀：

| 步骤 | 文件前缀 |
|------|---------|
| synth | `1_*.v` |
| floorplan | `2_*.odb` |
| place | `3_*.odb` |
| cts | `4_*.odb` |
| route | `5_*.odb` |
| finish | `6_final.*` |

---

## 快速诊断命令

```bash
# 查看时序报告
docker exec orfs-agent cat \
  /OpenROAD-flow-scripts/flow/reports/sky130hd/tinyRocket/base/6_finish.rpt

# 查看面积/功耗摘要
docker exec orfs-agent grep -E 'Design area|Total power|Macro' \
  /OpenROAD-flow-scripts/flow/logs/sky130hd/tinyRocket/base/6_report.log

# 查看最新 make 日志（定位崩溃位置）
docker exec orfs-agent tail -100 \
  /OpenROAD-flow-scripts/flow/logs/sky130hd/tinyRocket/base/4_cts.log
```

---

## 本次 TinyRocketConfig 64-bit 流程遇到的 Bug（2026-05-11）

### 6. generate_rtl 返回 ENOBUFS 错误但 RTL 实际已生成

**症状：** `generate_rtl` MCP 工具返回 `ENOBUFS` 错误，看似失败。

**原因：** Node.js `spawnSync` 的 stdout 缓冲区溢出（默认 1MB），RTL 生成日志超出限制。RTL 文件实际已写入磁盘。

**修复：** 忽略该错误，直接用 `list_rtl_files` 确认产物是否存在：
```
list_rtl_files(config="TinyRocketConfig")
list_rtl_files(config="TinyRocketConfig", subdir="verilog_synth")
```
若 `verilog_synth/filelist.f` 存在则流程正常，无需重跑。

---

### 7. Yosys 报模块重定义：`data_arrays_0_combMem` 已存在

**症状：**
```
ERROR: Re-definition of module `data_arrays_0_combMem'
```

**原因：** `filelist.f` 包含 firtool 生成的 SRAM 行为模型（`data_arrays_0_combMem.sv` 等），同时 `sram_macros.v` 中也定义了同名 wrapper 模块，导致重定义。

**修复：** 在 `config.mk` 的 `VERILOG_FILES` 中用 `grep -vE` 过滤掉 SRAM 行为模型文件：
```makefile
export VERILOG_FILES = \
  $(shell grep -vE '(data_arrays_0_combMem|data_arrays_0_0_combMem|mem_combMem|tag_array_0_combMem)\.sv' \
    /workspace/vsrc/rtl_output/chipyard.TestHarness.TinyRocketConfig/verilog_synth/filelist.f) \
  $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram_macros.v
```

> 注意：过滤模式要精确匹配黑盒名，不能用 `_combMem\.sv` 通配，否则会误删 `rf_combMem.sv` 等其他文件。

---

### 8. Yosys 报 `ScratchpadSlavePort` 模块未找到

**症状：**
```
ERROR: Module `ScratchpadSlavePort' referenced in module `RocketTile' is not part of the design.
```

**原因：** firtool 后处理时将 `ScratchpadSlavePort` 模块删除（判定为外设/验证模块），但 `RocketTile.sv` 中仍有实例化引用。

**修复：** 在 `sram_macros.v` 中添加可综合 stub（所有输出赋 0，Yosys 会自动优化掉）：
```verilog
module ScratchpadSlavePort(
  input  clock, reset,
  input  io_tl_in_a_valid,
  // ... 完整端口列表从 gen-collateral/ScratchpadSlavePort.sv 复制
  output io_tl_in_a_ready
  // ...
);
  assign io_tl_in_a_ready = 1'b0;
  // 所有输出端口赋 0
endmodule
```

> 不能用 `(* blackbox *)`，否则 Yosys 会保留该模块并在 OpenROAD 布局时报找不到对应 LEF。

---

### 9. Yosys 报 47 个 TLMonitor 模块未找到（hierarchy -check 严格模式）

**症状：**
```
ERROR: Module `TLMonitor_1' referenced in module `...' is not part of the design.
（共 47 个 TLMonitor 变体）
```

**原因：** firtool 删除了所有 TLMonitor（总线监控/断言模块），但上层模块仍有实例化。`hierarchy -check` 严格模式下缺失模块直接报错。

**修复方案（二选一，推荐方案 A）：**

**方案 A：** 修改 Yosys 综合脚本，去掉 `-check` 标志：
```bash
docker exec orfs-agent bash -c "
  sed -i 's/hierarchy -check -top/hierarchy -top/g' \
    /OpenROAD-flow-scripts/flow/scripts/synth.tcl \
    /OpenROAD-flow-scripts/flow/scripts/synth_canonicalize.tcl
"
```

**方案 B：** 在 `sram_macros.v` 中为每个 TLMonitor 变体添加 `(* blackbox *)` stub（需从 `gen-collateral/` 读取端口声明，工作量大）。

> 方案 A 更简洁，但需注意容器重启后修改会丢失，需在每次 `run_stage(synth)` 前重新执行。

---

### 10. TLAtomicAutomata / TLError / TLROM 有输出端口，不能用 blackbox

**症状：** 使用 `(* blackbox *)` stub 后，OpenROAD 布局阶段报：
```
[ERROR] LEF macro not found for cell: TLAtomicAutomata
```

**原因：** Yosys 对有输出端口的 blackbox 模块不会优化掉，会保留在网表中，OpenROAD 需要对应的 LEF 文件。

**修复：** 改用可综合 stub，将所有输出端口赋 0：
```verilog
module TLAtomicAutomata(
  input clock, reset, ...
  output auto_in_a_ready, ...
);
  assign auto_in_a_ready = 1'b0;
  // 所有输出赋 0，Yosys opt_clean 会消除该模块
endmodule
```

同理适用于：`TLAtomicAutomata_1`、`TLError`、`TLError_1`、`TLROM`、`EICG_wrapper`、`GenericDigitalInIOCell`、`GenericDigitalOutIOCell`、`SimSerial`。

---

### 11. SRAM GDS 文件为 .gds.gz，finish 阶段 GDS merge 失败

**症状：**
```
ERROR: Cannot open file: sram22_2048x32m8w8.gds
```

**原因：** `tech/sram22_sky130_macros/` 下的 GDS 文件以 `.gds.gz` 压缩格式存储，OpenROAD 的 `merge_gds` 不支持直接读取压缩文件。

**修复：** 在容器内解压：
```bash
docker exec orfs-agent bash -c "
  for f in /workspace/tech/sram22_sky130_macros/*/*.gds.gz; do
    gunzip -k \"\$f\"
  done
"
```

然后在 `config.mk` 中使用 `ADDITIONAL_GDS`（不是 `GDS_FILES`）：
```makefile
export ADDITIONAL_GDS = \
    /workspace/tech/sram22_sky130_macros/sram22_2048x32m8w8/sram22_2048x32m8w8.gds \
    /workspace/tech/sram22_sky130_macros/sram22_64x22m4w22/sram22_64x22m4w22.gds \
    /workspace/tech/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8.gds
```

---

### 12. KLayout Python API：LayerPropertiesIterator 无 replace 方法

**症状：**
```python
AttributeError: 'LayerPropertiesIterator' object has no attribute 'replace'
```

**原因：** KLayout Python API 中修改图层属性的正确方法是 `lv.set_layer_properties(iterator, props)`，而非 `iterator.replace(props)`。

**修复：**
```python
import sys
sys.path.insert(0, '/usr/lib/klayout/pymod')
import pya

lv = pya.LayoutView()
lv.load_layout(gds_file, True)
lv.max_hier()

it = lv.begin_layers()
while not it.at_end():
    lp = it.current()
    new_lp = lp.dup()
    new_lp.visible = True
    new_lp.fill_color = 0xFF0000  # RGB
    new_lp.frame_color = 0xFF0000
    lv.set_layer_properties(it, new_lp)  # 正确 API
    it.next()

lv.zoom_fit()
img = lv.get_image(2048, 2048)
img.save('/tmp/layout.png', 'PNG')
```

> KLayout 批处理模式下 `pya` 模块路径为 `/usr/lib/klayout/pymod`，需手动加入 `sys.path`。
