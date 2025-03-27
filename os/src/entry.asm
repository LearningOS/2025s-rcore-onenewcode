    # 从这里开始的代码将被放置在 .text.entry 子段中
    .section .text.entry
    # _start 程序入口点，globl 类似函数解耦
    .globl _start
_start:
    # sp 栈指针寄存器
    la sp, boot_stack_top
    call rust_main
    .section .bss.stack
    .globl boot_stack_lower_bound
boot_stack_lower_bound:
    .space 4096 * 16
    .globl boot_stack_top
boot_stack_top: