.global bresenham
.data
x: .quad 0
y: .quad 0
x0: .quad 0
x1: .quad 0
y0: .quad 0
y1: .quad 0
colorR:
    .byte 255 
colorG:
    .byte 255 
colorB:
    .byte 255
    .align 8
.text
bresenham: //something like this: bresenham(int color,int x0,int x1, int y0, int y1), color is a hex value
#process arguments
    push %rbx
    mov %rdi, %rax
    movb %al, colorB(%rip)
    shr $8, %rax
    movb %al, colorG(%rip)
    shr $8, %rax
    movb %al, colorR(%rip)
    mov %rsi, x0(%rip)
    mov %rdx, y0(%rip)
    mov %rcx, x1(%rip)
    mov %r8, y1(%rip)
#handle wrong direction coords
    mov x0(%rip), %rcx
    cmp x1(%rip), %rcx
    jl noswap
    xchg x1(%rip), %rcx
    mov %rcx, x0(%rip)
    mov y0(%rip), %rcx
    xchg y1(%rip), %rcx
    mov %rcx, y0(%rip)
    noswap:
#assign x and y
    movq x0(%rip), %r8
    movq %r8, x(%rip) //x = x-naught
    movq y0(%rip), %r8
    movq %r8, y(%rip) //y = y-naught
#assign a b and d
    movq y0(%rip), %rax
    subq y1(%rip), %rax//A = y-naught - y-one these needed to be negated for some reason...?
    movq x1(%rip), %rbx
    subq x0(%rip), %rbx//B = x-one - x-naught
#differentiate between octants
    cmp $0, %rax
    jl topq
    bottomq:
    cmp %rax, %rbx
    jg o7
    jmp o8
    topq:
    mov %rax, %rcx
    neg %rcx
    cmp %rcx,%rbx
    jg o1
    jmp o2
#A is rax, B is rbx, rdx is d (twice d actually)
o1:
    movq %rax,%rdx //d=2a+b
    salq %rdx
    addq %rbx, %rdx
    salq %rax
    salq %rbx //double a and b
    start1:
    mov x1(%rip), %rcx
    cmpq x(%rip), %rcx
    jl end
    call plot
    cmp $0,%rdx#check if y needs to be incremented
    jg ifninc1
    incq y(%rip)
    add %rbx, %rdx
    ifninc1:
    incq x(%rip)
    add %rax, %rdx
    jmp start1
o2:
    neg %rax
    neg %rbx
    movq %rbx,%rdx //d=2b+a
    salq %rdx
    addq %rax, %rdx
    salq %rax
    salq %rbx //double a and b
    start2:
    mov y1(%rip), %rcx
    cmpq y(%rip), %rcx
    jl end
    call plot
    cmp $0,%rdx#check if y needs to be incremented
    jg ifninc2
    incq x(%rip)
    add %rax, %rdx
    ifninc2:
    incq y(%rip)
    add %rbx, %rdx
    jmp start2
o7:
    movq %rax,%rdx //d=2b-a
    salq %rdx
    subq %rbx, %rdx
    salq %rax
    salq %rbx //double a and b
    start7:
    mov x1(%rip), %rcx
    cmpq x(%rip), %rcx
    jl end
    call plot
    cmp $0,%rdx#check if y needs to be decremented
    jl ifninc7
    decq y(%rip)
    sub %rbx, %rdx
    ifninc7:
    incq x(%rip)
    add %rax, %rdx
    jmp start7
o8:
    movq %rax,%rdx //d=2a-b
    salq %rdx
    subq %rbx, %rdx
    salq %rax
    salq %rbx //double a and b
    start8:
    mov y1(%rip), %rcx
    cmpq y(%rip), %rcx
    jg end
    call plot
    cmp $0,%rdx#check if y needs to be incremented
    jg ifninc8
    incq x(%rip)
    add %rax, %rdx
    ifninc8:
    decq y(%rip)
    sub %rbx, %rdx
    jmp start8
    end:
    pop %rbx
    ret
plot:
#plot x,y
    mov y(%rip), %r8//this will be the index
    sal $9, %r8
    add x(%rip), %r8
    imul $3, %r8
    lea data(%rip),%rcx
    add %rcx, %r8
//color the pixel :)
    movzbw colorR(%rip), %cx
    movb %cl, 0(%r8)
    movzbw colorG(%rip), %cx
    movb %cl, 1(%r8)
    movzbw colorB(%rip), %cx
    movb %cl, 2(%r8)
//Plotting done 
    ret

