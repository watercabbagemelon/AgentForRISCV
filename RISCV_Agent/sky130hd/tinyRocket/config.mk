export DESIGN_NICKNAME = tinyRocket
export DESIGN_NAME     = RocketTile
export PLATFORM        = sky130hd

# RTL sources: ChipYard TinyRocketConfig firtool post-processed Verilog
# Exclude only the 4 SRAM black-boxes replaced by sram_macros.v wrappers:
#   data_arrays_0_ext, data_arrays_0_0_ext, mem_ext, tag_array_0_ext
# Keep rf_combMem and ram_combMem* (synthesized as register files)
export VERILOG_FILES = $(shell grep -vE '(data_arrays_0_ext|data_arrays_0_0_ext|mem_ext|tag_array_0_ext)\.sv' /workspace/vsrc/rtl_output/chipyard.TestHarness.TinyRocketConfig/verilog_synth/filelist.f) \
    $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/sram_macros.v

export SDC_FILE = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc

# SRAM22 sky130 macro LEF and LIB files
export ADDITIONAL_LEFS = \
    /workspace/tech/sram22_sky130_macros/sram22_2048x32m8w8/sram22_2048x32m8w8.lef \
    /workspace/tech/sram22_sky130_macros/sram22_64x22m4w22/sram22_64x22m4w22.lef \
    /workspace/tech/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8.lef

export ADDITIONAL_LIBS = \
    /workspace/tech/sram22_sky130_macros/sram22_2048x32m8w8/sram22_2048x32m8w8_tt_025C_1v80.lib \
    /workspace/tech/sram22_sky130_macros/sram22_64x22m4w22/sram22_64x22m4w22_tt_025C_1v80.lib \
    /workspace/tech/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8_tt_025C_1v80.lib

# SRAM22 GDS files for KLayout GDS merge (appended to platform GDS_FILES via ADDITIONAL_GDS)
export ADDITIONAL_GDS = \
    /workspace/tech/sram22_sky130_macros/sram22_2048x32m8w8/sram22_2048x32m8w8.gds \
    /workspace/tech/sram22_sky130_macros/sram22_64x22m4w22/sram22_64x22m4w22.gds \
    /workspace/tech/sram22_sky130_macros/sram22_1024x32m8w8/sram22_1024x32m8w8.gds

# Floorplan
export CORE_UTILIZATION  = 45
export CORE_ASPECT_RATIO = 1
export CORE_MARGIN       = 2
export PLACE_DENSITY     = 0.60

# Synthesis
export SYNTH_HIERARCHICAL = 1

# ABC buffer removal (helps with sky130 timing)
export REMOVE_ABC_BUFFERS = 1
