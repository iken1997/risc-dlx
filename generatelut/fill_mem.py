

address_size=7

#generate memory list
mem_list = ["B\"0000_00000_0000_00000_000000_00000\", -- No_op \n"] * (2**address_size - 1)
max_func_code = 0
#read function with its control word, store them in the specified address
with open("functions_cw.txt") as f:
    next(f)
    for line in f:
        line = line.strip()
        cw, _, func_name, opcode, func_code = line.split()
        func_code = int(func_code[2:],16)
        opcode = int(opcode[2:],16)
        if(opcode == 0):
            index = func_code
            if(func_code > max_func_code):
                max_func_code= func_code
        else:
            index= opcode + max_func_code
        mem_list[index] = f"{cw}, -- {func_name} \n"
        


with open("lut.txt", "w") as mem:
    mem.writelines(mem_list)
