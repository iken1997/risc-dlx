start:
addi r1,r0,#2 -- r1 = 0+2 2
subi r2,r1,#1 -- r2 = 2-1 1
addi r3,r1,#-4 -- r3 = 2- 4 -2 
subi r4,r3,#-1 -- r4 = r3 +1 -1
addui r5,r1,#4 -- r5 = r1 + 4  6
subui r6,r5,#3 -- r6 =  3
add r7,r1,r2 3 
sub r8,r5,r6 3 
j start
addu r9,r6,r1
sge r10,r1,r2
sge r10,r2,r1
sge r10,r1,r1
sle r10,r1,r2
sle r10,r2,r1
sle r10,r1,r1
sne r10,r1,r1
sne r10,r1,r2
sgeu r10,r1,r3
sgeu r10,r3,r1
sgei r10,r1,#4
sgei r10,r1,#1
slei r10,r1,#0
slei r10,r1,#2
snei r10,r1,#1
snei r10,r1,#2
sgeui r10,r1,#4
sgeui r10,r1,#1
addui r11,r0,#65535
or r13,r11,r12
ori r14,r12,#65535
and r15,r14,r2
andi r16,r14,#1
sll r17,r16,r2
slli r18,r16,#1
srl r19,r16,r2
srli r20,r16,#1
xor r24,r1,r1
xori r25,r1,#2