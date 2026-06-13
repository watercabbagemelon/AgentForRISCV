export DESIGN_NICKNAME = smallBoom
export DESIGN_NAME     = BoomTile
export PLATFORM        = sky130hd

# RTL: all 840 Verilog files concatenated to avoid "Argument list too long"
# sram_macros.v provides stub modules (TLError, TLAtomicAutomata, etc.)
export VERILOG_FILES = /workspace/persist/sky130hd/smallBoom/all_rtl.v \
    $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram_macros.v

export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

# All-Mock: Yosys black-boxes all memories > 1 bit as mock placeholders
export SYNTH_MEMORY_MAX_BITS      = 1
export SYNTH_MOCK_LARGE_MEMORIES  = 1
export SYNTH_KEEP_MOCKED_MEMORIES = 1

# Floorplan (conservative for BOOM out-of-order core)
export CORE_UTILIZATION  = 40
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN       = 4
export PLACE_DENSITY     = 0.45

# Disable timing-driven global placement to avoid GP hang on large designs
export GPL_TIMING_DRIVEN = 0

# Synthesis
export SYNTH_HIERARCHICAL = 1
export REMOVE_ABC_BUFFERS = 1
