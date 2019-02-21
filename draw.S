.global main
.global data
.data
    x: .quad 0
.bss
    data: .zero 786432#512*512*3
.text
main:
    mov $4, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, %r15

    mov %r15, %rdi
    call identitymatrix

    mov %r15, %rdi
    call copymatrix
    mov %rax, %r12

    mov %r15,%rdi
    mov $2,%rsi
    call resizematrix
    
    mov %r15, %rdi
    mov $0, %r14
    edgeloop:
    mov %r14, %rax
    cvtsi2sd %rax, %xmm0
    mov $0, %rax
    cvtsi2sd %rax, %xmm1
    cvtsi2sd %rax, %xmm2
    movq $511, %rax
    sub %r14, %rax
    cvtsi2sd %rax, %xmm3
    mov $511, %rax
    cvtsi2sd %rax, %xmm4
    cvtsi2sd %rax, %xmm5
    call addedge
    add $10, %r14
    cmp $512,%r14
    jl edgeloop

    mov %r12, %rdi
    mov %r15, %rsi
    call multiplymatrix

    mov %r15, %rdi
    call printmatrix

    mov $1, %rdi
    mov $4, %rsi
    call makematrix
    mov %rax, %r13

    mov %r13, %rdi
    mov $0, %r14
    edgeloop1:
    mov %r14, %rax
    cvtsi2sd %rax, %xmm1
    mov $0, %rax
    cvtsi2sd %rax, %xmm0
    cvtsi2sd %rax, %xmm2
    movq $511, %rax
    sub %r14, %rax
    cvtsi2sd %rax, %xmm4
    mov $511, %rax
    cvtsi2sd %rax, %xmm3
    cvtsi2sd %rax, %xmm5
    call addedge
    add $10, %r14
    cmp $512,%r14
    jl edgeloop1
    //counterpart to 250 is 511, why?
    mov %r13, %rdi
    call printmatrix

    mov $0xff5511, %rsi
    mov %r15, %rdi
    call drawedges

    mov %r13, %rdi
    mov $0x1155ff, %rsi
    call drawedges

    mov %r13, %rdi
    call freematrix

    call pr

    mov %r12, %rdi
    call freematrix

    mov %r15, %rdi
    call freematrix

    ret
