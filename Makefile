ROM_DEPTH := 2048
PREFIX ?= riscv64-unknown-elf-

AS := $(PREFIX)as
LD := $(PREFIX)ld
OBJCOPY := $(PREFIX)objcopy
OBJDUMP := $(PREFIX)objdump

ASFLAGS := -march=rv32im -mabi=ilp32
OBJDUMPFLAGS := --disassemble-all --source --section-headers --demangle
LDFLAGS := -melf32lriscv -nostdlib
BIN2COEFLAGS := --width 32 --depth $(ROM_DEPTH) --fill 0

.PHONY: all
all: opentitan_patched.v

.PHONY: clean
clean:
	rm -f \
		firmware/*.o firmware/*.bin firmware/*.lst firmware/*.elf \
		*.mem \
		opentitan.v \
		opentitan_patched.v \
		opentitan_tb.out \
		opentitan.vcd

#######################################
# firmware
#######################################
%.bin: %.elf
	$(OBJCOPY) $< -O binary $@

%.o: %.s
	$(AS) $(ASFLAGS) -c $< -o $@

%.lst: %.elf
	$(OBJDUMP) $(OBJDUMPFLAGS) $< > $@

firmware/bootrom.elf: firmware/rom.ld firmware/bootrom.o
	@mkdir -p firmware
	$(LD) $(LDFLAGS) -T $^ -o $@

bootrom.mem: firmware/bootrom.bin
	bin2coe $(BIN2COEFLAGS) --mem -i $< -o $@

#######################################
# verilog
#######################################
include ot_srcs.mk

opentitan.v: $(OT_SRCS)
	sv2v -D=SV2V -D=ROM_INIT_FILE=bootrom.mem $^ > $@

opentitan_patched.v: opentitan.v
	patch opentitan.v -o opentitan_patched.v < opentitan.patch

#######################################
# yosys
#######################################
# Check for logic loops and dump visualization
.PHONY: logicloop
logicloop: opentitan_patched.v bootrom.mem
	yosys \
		-p 'read_verilog opentitan_patched.v' \
		-p 'prep -flatten -top top_earlgrey -nordff' \
		-p 'techmap -map +/adff2dff.v' \
		-p 'scc -select' \
		-p 'show -colors 1 -prefix ./output-split -format svg'


#######################################
# simulation
#######################################
opentitan_tb.out: opentitan_tb.v opentitan_patched.v
	iverilog -v -o $@ $^

sim: opentitan_tb.out bootrom.mem
	./opentitan_tb.out && gtkwave opentitan.vcd

.PHONY: vivado-sim-sv vivado-sim-v
vivado-sim-sv: bootrom.mem
	xvlog -d ROM_INIT_FILE=bootrom.mem --sv -nolog $(OT_SRCS)
	xvlog -nolog opentitan_tb.v
	xelab -nolog -debug typical opentitan_tb -s top_sim
	xsim -nolog top_sim -gui -view top_sim.wcfg &

# This target doesn't currently work due to some Vivado-specific parameter
# ordering issue
vivado-sim-v: bootrom.mem opentitan_patched.v
	xvlog -d ROM_INIT_FILE=bootrom.mem --sv -nolog opentitan_patched.v
	xvlog -nolog opentitan_tb.v
	xelab -nolog -debug typical opentitan_tb -s top_sim
	xsim -nolog top_sim -gui -view top_sim.wcfg &
