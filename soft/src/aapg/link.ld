/*======================================================================*/
/* Baremetal Linker Script                                              */
/*======================================================================*/
/* Taken from riscv-tests
/*----------------------------------------------------------------------*/
/* Setup                                                                */
/*----------------------------------------------------------------------*/

/* The OUTPUT_ARCH command specifies the machine architecture where the
   argument is one of the names used in the BFD library. More
   specifically one of the entires in bfd/cpu-mips.c */

OUTPUT_ARCH( "riscv" )
ENTRY(_start)

MEMORY
{
  iram : ORIGIN = 0x00000, LENGTH = 128K
  dram : ORIGIN = 0x20000, LENGTH = 128K
}

/*----------------------------------------------------------------------*/
/* Sections                                                             */
/*----------------------------------------------------------------------*/

SECTIONS
{

  /* text: test code section */
  .text.init : {
    . = 0x0;
    *(.text.init)
  } > iram


  .tohost : {
    . = ALIGN(0x1000);
    *(.tohost)
  } > iram

  .text : { *(.text) } > iram

  /* data segment */
  .data : { *(.data) } > dram

  /* data segment */
  .rodata : { *(.rodata) } > dram

  /* End of uninitalized data segement */
  .end : { _end = .;  } > dram
}
