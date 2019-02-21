.global addpoint
.global addedge
.global drawedges
.text
addpoint:
    // %rdi is matrix, x0:%xmm0, y0:%xmm1, z0:%xmm2
    mov 24(%rdi),%rdx
    cmp %rdx, 8(%rdi)
    jg nomemexpand
    push %rdi
    sub $48, %rsp
    movdqu %xmm0,32(%rsp)
    movdqu %xmm1,16(%rsp)
    movdqu %xmm2,(%rsp)
    mov $10, %rsi
    call resizematrix
    movdqu 32(%rsp),%xmm0
    movdqu 16(%rsp),%xmm1
    movdqu (%rsp) ,%xmm2
    add $48, %rsp
    pop %rdi
    nomemexpand:
    mov 24(%rdi), %rax
    shl $5, %rax
    mov (%rdi),%rdx
    add %rdx, %rax
    movsd %xmm0, (%rax)
    movsd %xmm1, 8(%rax)
    movsd %xmm2, 16(%rax)
    movsd one(%rip), %xmm0
    movsd %xmm0, 24(%rax)
    incq 24(%rdi)
    ret
addedge:
    //matrix is in %rdi, x0:%xmm0,y0:%xmm1,z0:%xmm2,x1:%xmm3,y1:%xmm4,z1:%xmm5
    call addpoint
    movsd %xmm3, %xmm0
    movsd %xmm4, %xmm1
    movsd %xmm5, %xmm2
    call addpoint
    ret

drawedges:
    //matrix is in %rdi, color is in %rsi
    push %r15
    push %r14
    mov $0, %r15
    mov %rsi, %r14
    drawloop:
    //finding memory location
    mov %rdi,matrixstart(%rip)
    mov %r15, %rax
    shl $5, %rax
    mov (%rdi),%rdx
    add %rdx, %rax
    mov %r14, %rdi
    movsd (%rax), %xmm0
    cvtsd2si %xmm0, %rsi
    movsd 8(%rax), %xmm0
    cvtsd2si %xmm0, %rdx
    movsd 32(%rax), %xmm0
    cvtsd2si %xmm0, %rcx
    movsd 40(%rax), %xmm0
    cvtsd2si %xmm0, %r8
    call bresenham
    //loop stuff
    add $2, %r15
    mov matrixstart(%rip), %rdi
    cmp 24(%rdi),%r15
    jl drawloop
    pop %r14
    pop %r15
    ret
