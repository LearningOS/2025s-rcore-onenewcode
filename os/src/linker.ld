OUTPUT_ARCH(riscv)      /* 目标架构为RISC-V*/
ENTRY(_start)           /* 程序入口点为符号`_start` */
BASE_ADDRESS = 0x80200000;  /* 内核加载的基地址（RISC-V常见内核起始地址）*/

SECTIONS
{
    /* . 代表当前地址 */
    . = BASE_ADDRESS;
    skernel = .;

    stext = .;
    .text : {
        /* 入口代码地址 */
        *(.text.entry) 
        /*其他所有代码段（按顺序合并） */
        *(.text .text.*)
    }
    /* 内存对齐 */
    . = ALIGN(4K);
    etext = .;
    /* 只读数据段起始地址（ */
    srodata = .;
    .rodata : {
        *(.rodata .rodata.*)
        *(.srodata .srodata.*)
    }

    . = ALIGN(4K);
    erodata = .;
    sdata = .;
    /* 数据段起始地址 */
    .data : {
        *(.data .data.*)
        *(.sdata .sdata.*)
    }

    . = ALIGN(4K);
    edata = .;
    .bss : {
        /* 内核栈（通常位于.bss段开头） */
        *(.bss.stack)   
        /*  BSS段起始地址（符号`sbss`） */
        sbss = .;      
        /*  未初始化的全局/静态变量（初始值通常为0） */
        *(.bss .bss.*) 
        *(.sbss .sbss.*)
    }

    . = ALIGN(4K);
    ebss = .;
    ekernel = .;

    /DISCARD/ : {
        /* 丢弃调试和异常处理相关段（减少内核体积） */
        *(.eh_frame)
    }
}