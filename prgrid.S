.global pr
.data
newl: .asciz "\n"
message: .asciz  "P3 512 512 255\n"
pathname: .asciz "./image.ppm"
.text
pr:
    push %rbx
    push %r13
    push %r12
#open file
    mov $2, %rax
    lea pathname(%rip), %rdi
    mov $65, %rsi                # open for writing and CREAT flag
    mov $0777, %rdx
    syscall
    mov %rax, %rdi

#write initial string to file (header) 
    mov $1, %rax
    lea message(%rip), %rsi          # address of string to output
    mov $15, %rdx               # number of bytes
    syscall
    mov $0, %rdx
#do draw
    lea data(%rip), %r8
    mov $0, %r13
imgy:
    mov $0, %r12
imgx:
    push %rdi
    movzb (%r8), %rdi
    call convert
    pop %rdi
    mov %rbx, %rdx
    mov %rax,%rsi
    mov $1, %rax
    syscall
    inc %r8
    xor %rax, %rax
    push %rdi
    movzb (%r8), %rdi
    call convert
    pop %rdi
    mov %rbx, %rdx
    mov %rax,%rsi
    mov $1, %rax
    syscall
    inc %r8
    xor %rax, %rax
    push %rdi
    movzb (%r8), %rdi
    call convert
    pop %rdi
    mov %rbx, %rdx
    mov %rax,%rsi
    mov $1, %rax
    syscall
    inc %r8
#handle loop stuff
    inc %r12
    cmp $512, %r12
    jl  imgx

    mov newl(%rip), %rsi
    mov $1, %rdx
    mov $1, %rax
    syscall

    inc %r13
    cmp $512, %r13
    jl  imgy
#close file
    mov $3, %rax
    syscall
    pop %r12
    pop %r13
    pop %rbx
    ret
