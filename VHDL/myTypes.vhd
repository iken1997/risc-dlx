LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE WORK.CONSTANTS.ALL;

PACKAGE myTypes IS

    -- Control unit input sizes
    CONSTANT IR_SIZE : INTEGER := 32;
    CONSTANT OP_CODE_SIZE : INTEGER := 6; -- OPCODE field size
    CONSTANT FUNC_SIZE : INTEGER := 11; -- FUNC field size
    CONSTANT R1_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE);
    CONSTANT R2_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE - N_BitReg);
    CONSTANT RD_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE - 2 * N_BitReg);
    CONSTANT IMM_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE - 2 * N_BitReg);
    CONSTANT IMM_J_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE);
    CONSTANT IMM_B_OFFSET : INTEGER := (WORD_SIZE - OP_CODE_SIZE - N_BitReg);
    CONSTANT R_OP_NUMBER : INTEGER := 13;
    -- R-Type    
    -- R-Type instruction -> OPCODE field
    CONSTANT RTYPE : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000000"; -- for ADD, SUB, AND, OR register-to-register operation

    -- R-Type instruction -> FUNC field

    TYPE OPCODE IS (NOP, RTYPE_ADD, RTYPE_SUB, RTYPE_SLL, RTYPE_SRL, RTYPE_AND, RTYPE_OR, RTYPE_XOR, ITYPE_ADD, ITYPE_SUB, ITYPE_SLL, ITYPE_SRL, ITYPE_AND, ITYPE_OR, ITYPE_XOR,
        RTYPE_SGE, RTYPE_SGEU, ITYPE_SGE, ITYPE_SGEU, RTYPE_SLE, RTYPE_SLEU, ITYPE_SLE, ITYPE_SLEU, RTYPE_SNE, ITYPE_SNE, SW, LW, BEQZ, BNEZ, J, JAL);

    CONSTANT NOP_C : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000000"; -- NOP
    CONSTANT R_ADD : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000001"; -- ADD RS1,RS2,RD
    CONSTANT R_SUB : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000010"; -- SUB RS1,RS2,RD
    CONSTANT R_AND : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000011"; -- AND RS1,RS2,RD
    CONSTANT R_OR : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000100"; -- OR RS1,RS2,RD
    CONSTANT R_XOR : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000101"; -- XOR RS1, RS2, RD
    CONSTANT R_SLL : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000110"; -- Shift logical left
    CONSTANT R_SRL : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000000111"; -- Shift logical right
    CONSTANT R_SGE : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000001000"; -- SET greater equal
    CONSTANT R_SLE : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000001001"; -- SET lower equal
    CONSTANT R_SNE : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000001010"; -- SET not equal
    CONSTANT R_SGEU : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000001011"; -- SET greater equal unsigned
    CONSTANT R_SLEU : STD_LOGIC_VECTOR(FUNC_SIZE - 1 DOWNTO 0) := "00000001100"; -- SET lower equal unsigned

    -- I-Type
    -- I-Type instruction -> OPCODE field
    CONSTANT I_ADD : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000001"; -- ADDI1 RS1,RS2,INP1
    CONSTANT I_SUB : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000010"; -- SUBI1 RS1,RS2,INP1
    CONSTANT I_AND : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000011"; -- ANDI1 RS1,RS2,INP1
    CONSTANT I_OR : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000100"; -- ORI1 RS1,RS2,INP1
    CONSTANT I_XOR : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000101"; -- MOV RS1,RS2
    CONSTANT I_SLL : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000110"; -- MOV RS1,RS2
    CONSTANT I_SRL : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "000111"; -- MOV RS1,RS2
    CONSTANT I_SGE : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001000"; -- SET greater equal immediate
    CONSTANT I_SLE : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001001"; -- SET lower equal immediate
    CONSTANT I_SNE : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001010"; -- SET not equal immediate
    CONSTANT STR_WR : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001011"; -- STORE word
    CONSTANT LD_WR : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001100"; -- LOAD word
    CONSTANT B_EQ : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001101"; -- BRANCH if equal zero
    CONSTANT B_NEQ : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001110"; -- BRANCH if not equal zero 
    CONSTANT JUMP : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "001111"; -- JUMP
    CONSTANT JUMP_AL : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "010000"; -- JUMP and LINK
    CONSTANT I_SGEU : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "010001"; -- SET greater equal immediate unsigned
    CONSTANT I_SLEU : STD_LOGIC_VECTOR(OP_CODE_SIZE - 1 DOWNTO 0) := "010010"; -- SET lower equal immediate unsigned

    FUNCTION instr_decode (instr : STD_LOGIC_VECTOR) RETURN OPCODE;
    FUNCTION getIndex (op : OPCODE) RETURN INTEGER;

END myTypes;

PACKAGE BODY myTypes IS
    FUNCTION instr_decode (instr : STD_LOGIC_VECTOR) RETURN OPCODE IS
        VARIABLE Opcode_i : OPCODE;
        VARIABLE IR_opcode : STD_LOGIC_VECTOR (OP_CODE_SIZE - 1 DOWNTO 0) := instr (WORD_SIZE - 1 DOWNTO (WORD_SIZE - OP_CODE_SIZE));
        VARIABLE IR_func : STD_LOGIC_VECTOR (FUNC_SIZE - 1 DOWNTO 0) := instr (FUNC_SIZE - 1 DOWNTO 0);
    BEGIN

        CASE IR_opcode IS
                -- case of R type requires analysis of FUNC
            WHEN RTYPE =>
                CASE IR_func IS
                    WHEN NOP_C => Opcode_i := NOP;
                    WHEN R_ADD => Opcode_i := RTYPE_ADD;
                    WHEN R_SUB => Opcode_i := RTYPE_SUB;
                    WHEN R_AND => Opcode_i := RTYPE_AND;
                    WHEN R_OR => Opcode_i := RTYPE_OR;
                    WHEN R_XOR => Opcode_i := RTYPE_XOR;
                    WHEN R_SLL => Opcode_i := RTYPE_SLL;
                    WHEN R_SRL => Opcode_i := RTYPE_SRL;
                    WHEN R_SGE => Opcode_i := RTYPE_SGE;
                    WHEN R_SLE => Opcode_i := RTYPE_SLE;
                    WHEN R_SNE => Opcode_i := RTYPE_SNE;
                    WHEN R_SLEU => Opcode_i := RTYPE_SLEU;
                    WHEN R_SGEU => Opcode_i := RTYPE_SGEU; 
                    WHEN OTHERS => Opcode_i := NOP;
                END CASE;

            WHEN I_ADD => Opcode_i := ITYPE_ADD;
            WHEN I_SUB => Opcode_i := ITYPE_SUB;
            WHEN I_AND => Opcode_i := ITYPE_AND;
            WHEN I_OR => Opcode_i := ITYPE_OR;
            WHEN I_XOR => Opcode_i := ITYPE_XOR;
            WHEN I_SLL => Opcode_i := ITYPE_SLL;
            WHEN I_SRL => Opcode_i := ITYPE_SRL;
            WHEN I_SGE => Opcode_i := ITYPE_SGE;
            WHEN I_SLE => Opcode_i := ITYPE_SLE;
            WHEN I_SNE => Opcode_i := ITYPE_SNE;
            WHEN STR_WR => Opcode_i := SW;
            WHEN LD_WR => Opcode_i := LW;
            WHEN B_EQ => Opcode_i := BEQZ;
            WHEN B_NEQ => Opcode_i := BNEZ;
            WHEN JUMP => Opcode_i := J;
            WHEN JUMP_AL => Opcode_i := JAL;
            WHEN I_SGEU => Opcode_i := ITYPE_SGEU;
            WHEN I_SLEU => Opcode_i := ITYPE_SLEU;
            WHEN OTHERS => Opcode_i := NOP;

        END CASE;
        RETURN Opcode_i;
    END FUNCTION;

    FUNCTION getIndex (op : OPCODE) RETURN INTEGER IS
        VARIABLE index : INTEGER;
    BEGIN
        CASE OP IS
            WHEN NOP => index := to_integer(unsigned(NOP_C));
            WHEN RTYPE_ADD => index := to_integer(unsigned (R_ADD));
            WHEN RTYPE_SUB => index := to_integer(unsigned(R_SUB));
            WHEN RTYPE_AND => index := to_integer(unsigned(R_AND));
            WHEN RTYPE_OR => index := to_integer(unsigned (R_OR));
            WHEN RTYPE_XOR => index := to_integer(unsigned(R_XOR));
            WHEN RTYPE_SLL => index := to_integer(unsigned(R_SLL));
            WHEN RTYPE_SRL => index := to_integer(unsigned(R_SRL));
            WHEN RTYPE_SGE => index := to_integer(unsigned(R_SGE));
            WHEN RTYPE_SLE => index := to_integer(unsigned(R_SLE));
            WHEN RTYPE_SNE => index := to_integer(unsigned(R_SNE));
            WHEN RTYPE_SGEU => index := to_integer(unsigned(R_SGEU));
            WHEN RTYPE_SLEU => index := to_integer(unsigned(R_SLEU));

            WHEN ITYPE_ADD => index := (to_integer(unsigned(I_ADD)) + R_OP_NUMBER);
            WHEN ITYPE_SUB => index := (to_integer(unsigned(I_SUB)) + R_OP_NUMBER);
            WHEN ITYPE_AND => index := (to_integer(unsigned(I_AND)) + R_OP_NUMBER);
            WHEN ITYPE_OR => index := (to_integer(unsigned(I_OR) )+ R_OP_NUMBER);
            WHEN ITYPE_XOR => index := (to_integer(unsigned(I_XOR)) + R_OP_NUMBER);
            WHEN ITYPE_SLL => index := (to_integer(unsigned(I_SLL)) + R_OP_NUMBER);
            WHEN ITYPE_SRL => index := (to_integer(unsigned(I_SRL)) + R_OP_NUMBER);
            WHEN ITYPE_SGE => index := (to_integer(unsigned(I_SGE)) + R_OP_NUMBER);
            WHEN ITYPE_SLE => index := (to_integer(unsigned(I_SLE)) + R_OP_NUMBER);
            WHEN ITYPE_SNE => index := (to_integer(unsigned(I_SNE)) + R_OP_NUMBER);
            WHEN ITYPE_SGEU => index := (to_integer(unsigned(I_SGEU)) + R_OP_NUMBER);
            WHEN ITYPE_SLEU => index := (to_integer(unsigned(I_SLEU)) + R_OP_NUMBER);
            WHEN SW => index := (to_integer(unsigned(STR_WR)) + R_OP_NUMBER);
            WHEN LW => index := (to_integer(unsigned(LD_WR)) + R_OP_NUMBER);
            WHEN BEQZ => index := (to_integer(unsigned(B_EQ) )+ R_OP_NUMBER);
            WHEN BNEZ => index := (to_integer(unsigned(B_NEQ)) + R_OP_NUMBER);
            WHEN J => index := (to_integer(unsigned(JUMP))+ R_OP_NUMBER);
            WHEN JAL => index := (to_integer(unsigned(JUMP_AL)) + R_OP_NUMBER);
            WHEN OTHERS => index := to_integer(unsigned(NOP_C));
        END CASE;
        RETURN index;
    END FUNCTION;
END PACKAGE BODY myTypes;