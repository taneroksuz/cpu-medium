default: all

src_dir = $(BASEDIR)/soft/src
bld_dir = $(BASEDIR)/build/aapg/elf
srcs0 = $(wildcard $(src_dir)/aapg/setup/work/common/crt.S) $(wildcard $(src_dir)/aapg/setup/work/asm/*.S)
srcs = $(filter-out $(wildcard $(src_dir)/aapg/setup/work/asm/*template.S), $(srcs0))
objs0 = $(srcs:.c=.o)
objs = $(objs0:.S=.o)

RISCV_GCC ?= $(RISCV)gcc
RISCV_GCC_OPTS ?= -march=$(MARCH) -mabi=$(MABI) -g -DPREALLOCATE=1 -mcmodel=medany -static -std=gnu99 -O2 -fno-inline -ffast-math -fno-common -fno-builtin-printf
RISCV_LINK_OPTS ?= -static -nostartfiles -lm -lgcc -T $(src_dir)/aapg/link.ld
RISCV_OBJDUMP ?= $(RISCV)objdump -S -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)objcopy -O binary
RISCV_INCL ?= -I$(src_dir)/aapg/setup/common
RISCV_NM ?= $(RISCV)nm -A

aapg.elf: $(objs)
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) $^ -o $(bld_dir)/$@ $(RISCV_LINK_OPTS)
	mv $^ $(bld_dir)

%.o: %.c
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

%.o: %.S
	$(RISCV_GCC) $(RISCV_INCL) $(RISCV_GCC_OPTS) -c $< -o $@

aapg.host: $(bld_dir)/aapg.elf
	$(RISCV_NM) $< | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(bld_dir)/$@

aapg.dump: $(bld_dir)/aapg.elf
	$(RISCV_OBJDUMP) $< > $(bld_dir)/$@

aapg.bin: $(bld_dir)/aapg.elf
	$(RISCV_OBJCOPY) $< $(bld_dir)/$@

# Default

all: aapg.elf aapg.host aapg.dump aapg.bin
