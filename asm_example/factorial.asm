;compute the factorial of register r1
addi r1, r1, 4       

addi r3, r1, 0 ;copy r1
loop:
subi r3,r3,1   ;decrease
beqz r3, end   ;check if zero
addi r2, r3, 0 ;copy r2
jal mul         
continue:
addi r1,r4,0
bnez r3, loop
end:
j end

;routine for multiplication
mul:
xor r4, r4, r4  ;zero in r4     
multiply_loop:
slei r5, r1, 0      ;check if r1 is zero
bnez r5, end_multiply_loop
andi r6, r1, 1       ;check if r1 is odd
beqz r6, shift_B        
add r4, r4, r2        
shift_B:
srli r1,r1, 1        
slli r2,r2, 1            
j multiply_loop 

end_multiply_loop:
j continue