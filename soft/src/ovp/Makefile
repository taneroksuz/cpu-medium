default: all

src_dir = $(BASEDIR)/soft/src/ovp
bld_dir = $(BASEDIR)/build/ovp/elf
ref_dir = $(BASEDIR)/build/ovp/ref

include $(src_dir)/asm/rv32i/Makefrag
include $(src_dir)/asm/rv32c/Makefrag
include $(src_dir)/asm/rv32b/Makefrag
include $(src_dir)/asm/rv32m/Makefrag

RISCV_GCC ?= $(RISCV)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/env -I $(src_dir)/env/p -I $(src_dir)/../common/env
RISCV_LINK_OPTS ?= -T $(src_dir)/../common/link.ld # -D RVMODEL_ASSERT
RISCV_OBJDUMP ?= $(RISCV)objdump -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)objcopy -O binary
RISCV_NM ?= $(RISCV)nm -A

vpath %.S $(src_dir)/asm

define compile_template

$$($(1)_tests): $(1)-%: $(1)/%.S
	$$(RISCV_GCC) $$(RISCV_GCC_OPTS) $(4) $$(RISCV_INCL) $$(RISCV_LINK_OPTS) $$< -o $(3)/$$@.elf
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'tohost' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.host
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'begin_signature' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.begin_signature
	$$(RISCV_NM) $(3)/$$@.elf | grep -sw 'end_signature' | sed -e 's/.*:\(.*\) D.*/\1/' > $(3)/$$@.end_signature
	$$(RISCV_OBJDUMP) $(3)/$$@.elf > $(3)/$$@.dump
	$$(RISCV_OBJCOPY) $(3)/$$@.elf $(3)/$$@.bin
tests += $$($(1)_tests)

endef

$(eval $(call compile_template,rv32i,$(src_dir),$(bld_dir),-march=rv32i_zicsr_zifencei -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32c,$(src_dir),$(bld_dir),-march=rv32ic_zicsr_zifencei -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32b,$(src_dir),$(bld_dir),-march=rv32i_zba_zbb_zbc_zbs_zicsr_zifencei -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32m,$(src_dir),$(bld_dir),-march=rv32im_zicsr_zifencei -mabi=ilp32 -DXLEN=32))

all: $(tests)

clean:
	rm -rf $(tests)
