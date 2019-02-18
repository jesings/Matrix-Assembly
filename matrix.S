.global makematrix
.global resizematrix
.global copymatrix
.global freematrix
.global identitymatrix
.global multiplymatrix
.global printmatrix
.global matrixstart
.extern free
.data
matrixstart:
    .quad 0
format:
    .asciz "%f "
newl:
    .asciz "\n"
//param order rdi, rsi, rdx, rcx, r8, r9
//return value in rax
.text
makematrix://makes a matrix with %rdi columns and %rsi rows, and returns its reference in %rax
    //columns put on the stack
    push %rbx
    push %rdi//number of columns
    push %rsi
    movq $32, %rdi
    call malloc@PLT
    pop %rsi
    pop %rdi
    mov %rax, matrixstart(%rip)
    //matrix address
    push %rdi
    push %rsi
    shl $5, %rdi//length of array in bytes
    call malloc@PLT
    pop %rsi
    pop %rdi

    movq matrixstart(%rip), %rbx
    movq %rax, (%rbx)
    movq %rdi, 8(%rbx)
    movq %rsi, 16(%rbx)
    movq $0, 24(%rbx)
    movq matrixstart(%rip), %rax
    pop %rbx
    ret

resizematrix://adds %rsi columns to matrix %rdi, no return val
    movq %rdi, matrixstart(%rip)
    movq %rdi, %rbx
    movq %rsi, %rcx
    movq 8(%rdi), %rdx
    addq %rsi, %rdx
    movq %rdx, 8(%rbx)
    movq (%rbx), %rdi
    movq 8(%rbx), %rsi
    shlq $5, %rsi
    call realloc@PLT
    movq matrixstart(%rip), %rbx
    movq %rax, (%rbx)
    ret

copymatrix://makes a deepcopy of matrix %rdi, returns the pointer to that new matrix
    mov %rdi, matrixstart(%rip)
    push %rdi
    mov 8(%rdi), %rdi
    mov $4, %rsi
    call makematrix
    pop %rbx
    push %rax
    movq (%rax), %rdi
    movq (%rbx), %rsi
    movq 8(%rbx), %rdx
    shl $5, %rdx
    push %rdi
    call memcpy@PLT
    pop %rdi
    pop %rax
    mov 24(%rdi), %rdx
    mov %rdx, 24(%rax)
    ret

freematrix://frees the memory of matrix %rdi, no return value
    mov %rdi, matrixstart(%rip)
    movq (%rdi), %rdi
    call free@PLT
    movq matrixstart(%rip), %rdi
    call free@PLT
    ret

printmatrix://prints matrix %rdi, no return value
    mov %rdi, matrixstart(%rip)
    push %r14
    push %r13
    mov $0, %r13
    poloop:
    cmp $4, %r13
    je peloop
    mov $0, %r14
    piloop:
    mov matrixstart(%rip), %rcx
    mov %r14, %rax
    mov %r13, %rbx
    shl $2, %rax
    add %rax, %rbx
    shl $3,%rbx
    movq (%rcx), %rdx
    add %rbx, %rdx
    lea format(%rip), %rdi
    movsd (%rdx), %xmm0
    mov $1, %rax
    call printf@PLT
    inc %r14
    mov matrixstart(%rip), %rcx
    cmp 8(%rcx),%r14
    jl piloop
    inc %r13
    lea newl(%rip), %rdi
    call printf@PLT
    jmp poloop
    peloop:
    pop %r13
    pop %r14
    ret

identitymatrix://turns square matrix %rdi into an identity matrix, no return value
    mov %rdi, matrixstart(%rip)
    mov 8(%rdi), %rdx
    mov %rdx,24(%rdi)
    push %r14
    push %r13
    push %rbx
    mov $0, %r13
    ioloop:
    cmp $4, %r13
    je ieloop
    mov $0, %r14
    iiloop:
    mov matrixstart(%rip), %rcx
    mov %r14, %rax
    mov %r13, %rbx
    shl $2, %rax
    add %rax, %rbx
    shl $3,%rbx
    movq (%rcx), %rdx
    cmp %r13, %r14
    jne mzero
    mov $1, %rax
    jmp moned
    mzero:
    mov $0, %rax
    moned:
    cvtsi2sd %rax, %xmm0
    add %rbx, %rdx
    movsd %xmm0, (%rdx)
    inc %r14
    cmp 8(%rcx),%r14
    jl iiloop
    inc %r13
    jmp ioloop
    ieloop:
    pop %rbx
    pop %r13
    pop %r14
    ret

multiplymatrix: //multiplies matrix1 rdi, matrix2 rsi, stores resulting matrix in rsi, no return value
    pushq %r13
    pushq %r14
    pushq %r15
    pushq %rbp
    movq %rsp, %rbp

    push %rdi
    push %rsi
    mov 8(%rsi), %rax
    imul 16(%rsi), %rax
    shl $3, %rax
    mov %rax, %rdi
    call malloc@PLT
    mov %rax, %r8
    pop %rsi
    pop %rdi//okay this makes a new array

    mov $0, %r13 //we take the rows of the first matrix, and the columns of the second
    loop_layer_0:
    mov $0, %r14
    loop_layer_1:
    mov $0, %r15
    cvtsi2sd %r15, %xmm0//sets accumulator to 0
    loop_layer_2:
    //put r15th element of the r13th row of matrix 1 in xmm1
    mov %r13, %rax
    mov %r15, %rcx
    shl $2, %rax
    add %rax, %rcx
    shl $3,%rcx
    mov (%rdi),%rdx
    add %rdx, %rcx
    movsd (%rcx), %xmm1
    //put r13th element of the r14th column of matrix 2 in xmm2
    mov %r14, %rax
    mov %r13, %rcx
    shl $2, %rax
    add %rax, %rcx
    shl $3,%rcx
    mov (%rsi),%rdx
    add %rdx, %rcx
    movsd (%rcx), %xmm2

    mulsd %xmm1, %xmm2 //add that to xmm0
    addsd %xmm2, %xmm0
    inc %r15
    cmp 8(%rdi),%r15
    jl loop_layer_2
    //move the accumulator into the proper memory location of the array pointed to by %r8
    mov %r14, %rax
    mov %r13, %rcx
    shl $2, %rax
    add %rax, %rcx
    shl $3,%rcx
    add %r8, %rcx
    movsd %xmm0,(%rcx)
    //okay
    inc %r14
    cmp 24(%rsi),%r14
    jl loop_layer_1
    inc %r13
    cmp 8(%rdi),%r13
    jl loop_layer_0

    push %rdi
    push %rsi
    push %r8
    mov (%rsi), %rdi
    call free@PLT
    pop %r8
    pop %rsi
    pop %rdi
    mov %r8, (%rsi)//frees the old array in matrix 2, and insert the array pointed to by %r8

    mov %rbp, %rsp
    popq %rbp
    popq %r15
    popq %r14
    popq %r13
    ret
