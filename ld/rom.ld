OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  .init : {
  _start = .;
  _end = .;
  }
}

