OUTPUT_ARCH("riscv")

ENTRY(_start)

SECTIONS {
    . = 0x0;
    . = ALIGN(4096);

    .text BLOCK(4K) : AT(ADDR(.text)) {
        *.o(.bootstrap .text)
    }

    . = ALIGN(4096);
    .data BLOCK(4K) : AT(ADDR(.data)) {
        *.o(.data .bootstap.stack .rodata*)
    }

    . = ALIGN(4096);
    .bss BLOCK(4K) : AT(ADDR(.bss)) {
        *.o(.bss*)
        *(COMMON)
    }
}
