default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/sram/elf
srcs = $(wildcard $(src_dir)/sram/*.S) $(wildcard $(src_dir)/sram/*.c)
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common
RISCV_LINK_OPTS ?= -static -nostartfiles -lm -lgcc -T $(src_dir)/sram/link.ld
RISCV_OBJDUMP ?= $(RISCV)objdump -S -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/sram -I$(src_dir)/common -I$(src_dir)/common/env
RISCV_NM ?= $(RISCV)nm -A

sram.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

sram.host: $(bld_dir)/sram.elf
	$(RISCV_NM) $< | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(bld_dir)/$@

sram.dump: $(bld_dir)/sram.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

sram.bin: $(bld_dir)/sram.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: sram.elf sram.host sram.dump sram.bin
