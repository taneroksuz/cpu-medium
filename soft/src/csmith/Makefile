default: all

csmith_incl = $(shell ls -d $(CSMITH)/include/csmith-* | head -n1)

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/csmith/elf
srcs = $(wildcard $(src_dir)/common/*.S) $(wildcard $(src_dir)/common/*.c) $(wildcard $(src_dir)/csmith/*.c)
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -ffast-math -fno-common
RISCV_LINK_OPTS ?= -static -nostdlib -nostartfiles -lm -lc -lgcc -T $(src_dir)/common/test.ld
RISCV_OBJDUMP ?= $(RISCV)objdump -S -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/env -I$(csmith_incl) -I$(src_dir)/common -I$(src_dir)/common/env
RISCV_NM ?= $(RISCV)nm -A

csmith.ref:
	${GCC} -I$(csmith_incl) -o $(src_dir)/csmith/csmith.o $(src_dir)/csmith/csmith.c

csmith.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

csmith.host: $(bld_dir)/csmith.elf
	$(RISCV_NM) $< | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(bld_dir)/$@

csmith.dump: $(bld_dir)/csmith.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

csmith.bin: $(bld_dir)/csmith.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: csmith.elf csmith.host csmith.dump csmith.bin csmith.ref
