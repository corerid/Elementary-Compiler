	.global main
	.text
main:
	mov %rsp, %rbp
	sub $208, %rsp

	xor %rax, %rax
	mov %rax, -8(%rbp)

	xor %rax, %rax
	mov %rax, -16(%rbp)

	xor %rax, %rax
	mov %rax, -208(%rbp)

	mov $2, %rax
	push %rax

	pop %rax
	mov %rax, -8(%rbp)

	mov $2, %rax
	push %rax

	mov $101, %rax
	push %rax

	pop %rcx
	pop %rbx
	cmp %rbx, %rcx
	je EL0

L0:
	push %rbx
	push %rcx
	mov $2, %rax
	push %rax

	pop %rax
	mov %rax, -16(%rbp)

	mov $0, %rax
	push %rax

	pop %rax
	mov %rax, -208(%rbp)

	mov -16(%rbp), %rax
	push %rax

	mov -8(%rbp), %rax
	push %rax

	pop %rcx
	pop %rbx
	cmp %rbx, %rcx
	je EL1

L1:
	push %rbx
	push %rcx
	mov -8(%rbp), %rax
	push %rax

	mov -16(%rbp), %rax
	push %rax

	pop %rbx
	pop %rax
	xor %rdx, %rdx
	idiv %rbx
	push %rdx

	mov $0, %rax
	push %rax

	pop %rbx
	pop %rax
	cmp %rax, %rbx
	jnz LI0

	mov $1, %rax
	push %rax

	pop %rax
	mov %rax, -208(%rbp)


LI0:
	mov -16(%rbp), %rax
	push %rax

	mov $1, %rax
	push %rax

	pop %rbx
	pop %rax
	add %rbx, %rax
	push %rax

	pop %rax
	mov %rax, -16(%rbp)

	pop %rcx
	dec %rcx
	pop %rbx
	cmp %rbx, %rcx
	jnz L1
EL1:
	mov -208(%rbp), %rax
	push %rax

	mov $0, %rax
	push %rax

	pop %rbx
	pop %rax
	cmp %rax, %rbx
	jnz LI1

	push %rax
	push %rbx
	push %rcx
	mov $fmt, %rdi
	mov $msg0, %rax
	mov %rax, %rsi
	xor %rax, %rax
	call printf
	pop %rcx
	pop %rbx
	pop %rax

	push %rax
	push %rbx
	push %rcx
	mov $printD, %rdi
	mov -8(%rbp), %rax
	mov %rax, %rsi
	xor %rax, %rax
	call printf
	pop %rcx
	pop %rbx
	pop %rax


LI1:
	mov -8(%rbp), %rax
	push %rax

	mov $1, %rax
	push %rax

	pop %rbx
	pop %rax
	add %rbx, %rax
	push %rax

	pop %rax
	mov %rax, -8(%rbp)

	pop %rcx
	dec %rcx
	pop %rbx
	cmp %rbx, %rcx
	jnz L0
EL0:

	add $208, %rsp
	ret

printD:
	.asciz "%ld\n"
printH:
	.asciz "0x%lx\n"
fmt:
	.asciz "%s\n"
msg0:
	.asciz "Prime Number"
