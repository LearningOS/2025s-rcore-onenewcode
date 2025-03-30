/*启用增强宏支持*/
.altmacro
# 将寄存器 x\n 的值保存到栈偏移 n*8 的位置
.macro SAVE_GP n
    sd x\n, \n*8(sp)
.endm
.macro LOAD_GP n
    ld x\n, \n*8(sp)
.endm
    .section .text
    .globl __alltraps
    .globl __restore
    .align 2
__alltraps:
    csrrw sp, sscratch, sp     # 交换 sp 和 sscratch，sp 切换到内核栈
    addi sp, sp, -34*8         # 在内核栈分配 34*8 字节的 TrapContext
    sd x1, 1*8(sp)             # 保存 x1(ra)
    sd x3, 3*8(sp)             # 保存 x3(gp)
    .set n, 5
    .rept 27                   # 保存 x5-x31（共27个寄存器）
        SAVE_GP %n
        .set n, n+1
    .endr
    csrr t0, sstatus           # 保存 CSR 寄存器
    csrr t1, sepc
    sd t0, 32*8(sp)
    sd t1, 33*8(sp)
    csrr t2, sscratch          # 保存用户栈指针到 TrapContext
    sd t2, 2*8(sp)
    mv a0, sp                  # 将 TrapContext 指针作为参数
    call trap_handler           # 调用陷阱处理函数
__restore:
    mv sp, a0                  # 从参数 a0 恢复内核栈指针
    ld t0, 32*8(sp)            # 恢复 sstatus
    ld t1, 33*8(sp)            # 恢复 sepc
    ld t2, 2*8(sp)             # 恢复用户栈指针
    csrw sstatus, t0
    csrw sepc, t1
    csrw sscratch, t2          # 保存用户栈指针到 sscratch
    ld x1, 1*8(sp)             # 恢复 x1(ra)
    ld x3, 3*8(sp)             # 恢复 x3(gp)
    .set n, 5
    .rept 27                   # 恢复 x5-x31
        LOAD_GP %n
        .set n, n+1
    .endr
    addi sp, sp, 34*8          # 释放 TrapContext 空间
    csrrw sp, sscratch, sp     # 切换回用户栈
    sret                       # 返回用户模式