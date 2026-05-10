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
   persist/sky130hd/tinyRocket/sram_macros.v
   ```

2. 更新 `config.mk` 中的 LEF/LIB 路径：
   ```makefile
   export ADDITIONAL_LEFS = \
       /workspace/persist/sram22_sky130_macros/<new_macro>/<new_macro>.lef
   export ADDITIONAL_LIBS = \
       /workspace/persist/sram22_sky130_macros/<new_macro>/<new_macro>_tt.lib
   ```

3. 重新部署配置文件到容器：
   ```bash
   docker exec orfs-agent bash -c "
     cp /workspace/persist/sky130hd/tinyRocket/config.mk \
        /OpenROAD-flow-scripts/flow/designs/sky130hd/tinyRocket/
     cp /workspace/persist/sky130hd/tinyRocket/sram_macros.v \
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
