.global convert #convert takes in a byte value in rax and returns its string representation in rsi, and returns the length in rbx (NOTE: NOT C COMPLIANT, RBX IS SUPPOSED TO BE A CALLER SAVED REGISTER BUT IS NEEDED FOR OUTPUT, but I'm too lazy to change anything right now so this should only be used as a planned subroutine and even then probably not much.)
.data
strResult:
    .zero 4# string buffer to store results
.text
convert:
    mov %rdi, %rax
    mov $10,%rcx         # divisor
    xor %rbx, %rbx         # count digits
divide:
    xor %rdx, %rdx       # high part = 0
    div %rcx             # rax = rdx:rax/rcx, rdx = remainder
    push %dx             # a digit in range [0..9]
    inc %bx              # count digits
    cmp $0, %rax         # rax is 0?
    jnz divide           # no, continue
    mov %bx, %cx         # pop digits from stack in reverse order
    lea strResult(%rip), %rsi  # ds:si points to string buffer
next_digit:
    pop %ax
    add $0x30, %al       # convert to ASCII
    movb %al,(%rsi)       # write it to the buffer
    inc %rsi
    dec %rcx
    jg next_digit
    mov $0x20,%al
    movb %al,(%rsi)       # write it to the buffer
    lea strResult(%rip), %rax
    inc %bx
    mov %rbx,%rcx
    ret
