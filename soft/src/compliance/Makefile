default: all

src_dir = $(BASEDIR)/soft/src/compliance
bld_dir = $(BASEDIR)/build/compliance/elf
ref_dir = $(BASEDIR)/build/compliance/ref

include $(src_dir)/asm/rv32c/Makefrag
include $(src_dir)/asm/rv32i/Makefrag
include $(src_dir)/asm/rv32b/Makefrag
include $(src_dir)/asm/rv32m/Makefrag
include $(src_dir)/asm/rv32p/Makefrag
include $(src_dir)/asm/rv32z/Makefrag

RISCV_GCC ?= $(RISCV)/riscv64-unknown-elf-gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_INCL ?= -I $(src_dir)/env -I $(src_dir)/../common/env
RISCV_LINK_OPTS ?= -T $(src_dir)/../common/test.ld # -D RVMODEL_ASSERT
RISCV_OBJDUMP ?= $(RISCV)/riscv64-unknown-elf-objdump -Mnumeric,no-aliases --disassemble --disassemble-zeroes
RISCV_OBJCOPY ?= $(RISCV)/riscv64-unknown-elf-objcopy -O binary
RISCV_NM ?= $(RISCV)/riscv64-unknown-elf-nm -A

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

$(eval $(call compile_template,rv32c,$(src_dir),$(bld_dir),-march=rv32ic -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32i,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32b,$(src_dir),$(bld_dir),-march=rv32i_zba_zbb_zbc -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32m,$(src_dir),$(bld_dir),-march=rv32im -mabi=ilp32 -DXLEN=32))
$(eval $(call compile_template,rv32p,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32 -DXLEN=32 -Drvtest_mtrap_routine=True))
$(eval $(call compile_template,rv32z,$(src_dir),$(bld_dir),-march=rv32i -mabi=ilp32 -DXLEN=32))

all: $(tests)

clean:
	rm -rf $(tests)
