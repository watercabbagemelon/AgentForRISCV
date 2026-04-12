export DESIGN_NAME = ALU
export PLATFORM    = sky130hd

export VERILOG_FILES = /workspace/design/rtl/alu.sv
export SDC_FILE      = /workspace/design/constraint.sdc

export DIE_AREA            = 0 0 300 300
export CORE_AREA           = 10 10 290 290
export PLACE_DENSITY       = 0.3

export PNR_TOOL      = openroad