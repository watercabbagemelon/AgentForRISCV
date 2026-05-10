export DESIGN_NICKNAME = tinyRocket
export DESIGN_NAME     = RocketTile
export PLATFORM        = sky130hd

# RTL sources: use existing ORFS tinyRocket Verilog sources
export VERILOG_FILES = \
    $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/AsyncResetReg.v \
    $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/ClockDivider2.v \
    $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/ClockDivider3.v \
    $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/plusarg_reader.v \
    $(DESIGN_HOME)/src/$(DESIGN_NICKNAME)/freechips.rocketchip.system.TinyConfig.v \
    $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram_macros.v

export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

# SRAM22 sky130 macro LEF and LIB files
export ADDITIONAL_LEFS = \
    /workspace/persist/sram22_sky130_macros/sram22_64x32m4w8/sram22_64x32m4w8.lef \
    /workspace/persist/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8.lef

export ADDITIONAL_LIBS = \
    /workspace/persist/sram22_sky130_macros/sram22_64x32m4w8/sram22_64x32m4w8_tt_025C_1v80.lib \
    /workspace/persist/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8_tt_025C_1v80.lib

# Floorplan
export CORE_UTILIZATION  = 45
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN       = 2
export PLACE_DENSITY     = 0.60

# Synthesis
export SYNTH_HIERARCHICAL = 1

# ABC buffer removal (helps with sky130 timing)
export REMOVE_ABC_BUFFERS = 1
