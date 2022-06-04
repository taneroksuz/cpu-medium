default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/timer/elf
srcs = $(wildcard $(src_dir)/timer/*.S) $(wildcard $(src_dir)/timer/*.c)
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common
RISCV_LINK_OPTS ?= -static -nostartfiles -lm -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -S -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/timer -I$(src_dir)/common -I$(src_dir)/common/env
RISCV_NM ?= $(RISCV)/riscv64-unknown-elf-nm -A

timer.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

timer.host: $(bld_dir)/timer.elf
	$(RISCV_NM) $< | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(bld_dir)/$@

timer.dump: $(bld_dir)/timer.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

timer.bin: $(bld_dir)/timer.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: timer.elf timer.host timer.dump timer.bin
