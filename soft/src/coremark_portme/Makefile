default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/coremark/elf
srcs = $(wildcard $(src_dir)/common/*.S) $(wildcard $(src_dir)/common/*.c) $(wildcard $(src_dir)/coremark/*.c) $(wildcard $(src_dir)/coremark_portme/*.c)
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)gcc
RISCV_GCC_OPTS ?= -g -march=$(MARCH) -mabi=$(MABI) -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O3 -funroll-all-loops -finline-functions -ffast-math -fno-common
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lc -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV)objdump -S -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(src_dir)/coremark -I$(src_dir)/coremark_portme -I$(src_dir)/common -I$(src_dir)/common/env
RISCV_NM ?= $(RISCV)nm -A

FLAGS_STR = "$(RISCV_GCC_OPTS) $(RISCV_LINK_OPTS)"

coremark.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -DITERATIONS=$(ITER) -DFLAGS_STR=\"$(FLAGS_STR)\" -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

coremark.host: $(bld_dir)/coremark.elf
	$(RISCV_NM) $< | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(bld_dir)/$@

coremark.dump: $(bld_dir)/coremark.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

coremark.bin: $(bld_dir)/coremark.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: coremark.elf coremark.host coremark.dump coremark.bin
