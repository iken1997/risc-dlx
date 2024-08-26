LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------------------------
ENTITY ALU IS
    GENERIC (Nbit : INTEGER := 32);
    PORT (
        FUNC : IN TYPE_OP;
        A_GEU_B : OUT STD_LOGIC;
        A_GE_B : OUT STD_LOGIC;
        A_LEU_B : OUT STD_LOGIC;
        A_LE_B : OUT STD_LOGIC;
        A_NE_B : OUT STD_LOGIC;
        A_EQ_B : OUT STD_LOGIC;
        DATA1 : IN WORD;
        DATA2 : IN WORD;
        OUTALU : OUT WORD
    );
END ALU;

-----------------------------------------------------------------------------------------------------------------------------

ARCHITECTURE BEHAVIORAL OF ALU IS

    COMPONENT P4_ADDER IS
        GENERIC (
            NBIT : INTEGER := 32;
            NBIT_PER_BLOCK : INTEGER := 4);
        PORT (
            A : IN WORD;
            B : IN WORD;
            Cin : IN STD_LOGIC;
            S : OUT WORD;
            Cout : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT shifter IS
        GENERIC (N : INTEGER := NumBit);
        PORT (
            FUNC : IN TYPE_OP;
            DATA1, DATA2 : IN WORD;
            OUTSHIFT : OUT WORD
        );
    END COMPONENT;

    COMPONENT LOGIC_UNIT IS
        GENERIC (Nbit : INTEGER := 32);
        PORT (
            FUNC : IN TYPE_OP;
            A : IN WORD;
            B : IN WORD;
            SUM : IN WORD; -- sum by the adder
            COUT : IN STD_LOGIC; -- carry out by the adder
            A_GEU_B : OUT STD_LOGIC; -- comparison A >= B for unsigned, if true flag = 1, otherwise = 0
            A_GE_B : OUT STD_LOGIC; -- comparison A >= B for signed, if true flag = 1, otherwise = 0
            A_LEU_B : OUT STD_LOGIC; -- comparison A <= B for unsigned, if true flag = 1, otherwise = 0
            A_LE_B : OUT STD_LOGIC; -- comparison A <= B for signed, if true flag = 1, otherwise = 0
            A_NE_B : OUT STD_LOGIC; -- if A is different from B, if true flag = 1, otherwise = 0
            A_EQ_B : OUT STD_LOGIC; -- if A is equal to B, if true flag = 1, otherwise = 0
            NOT_A : OUT WORD; -- make the bitwise not of the input operand A
            A_AND_B : OUT WORD; -- make the bitwise AND between input 1 and input 2
            A_XOR_B : OUT WORD; -- make the bitwise XOR between input 1 and input 2
            A_OR_B : OUT WORD -- make the bitwise OR between input 1 and input 2
        );
    END COMPONENT;

    SIGNAL OUTALU_shift, OUTALU_s, OUTALU_lu : WORD;
    SIGNAL B_i : WORD;
    SIGNAL Cin_s, Cout_s : STD_LOGIC;

    -----------------------------------------------------------------------------------------------------------------------------

BEGIN

    SHFT : shifter
    GENERIC MAP(
        N => Nbit
    )
    PORT MAP(
        FUNC => FUNC,
        DATA1 => DATA1,
        DATA2 => DATA2,
        OUTSHIFT => OUTALU_shift
    );

    ADDER : P4_ADDER
    GENERIC MAP(
        NBIT => Nbit,
        NBIT_PER_BLOCK => 4
    )
    PORT MAP(
        A => DATA1,
        B => B_i,
        Cin => Cin_s,
        S => OUTALU_s,
        Cout => Cout_s
    );

    LOGIC : LOGIC_UNIT
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        --input
        FUNC => FUNC,
        A => DATA1,
        B => DATA2,
        SUM => OUTALU_s,
        COUT => Cout_s,
        --output
        A_GEU_B => A_GEU_B,
        A_GE_B => A_GE_B,
        A_LEU_B => A_LEU_B,
        A_LE_B => A_LE_B,
        A_NE_B => A_NE_B,
        A_EQ_B => A_EQ_B,
        NOT_A => OUTALU_lu,
        A_AND_B => OUTALU_lu,
        A_XOR_B => OUTALU_lu,
        A_OR_B => OUTALU_lu
    );

    --Process to create a vector in order to perform the xor operation of the secon input if I have to perform a subtraction
    PROCESS (DATA2)
    variable B_v : WORD;
    BEGIN
        FOR i IN 0 TO NBIT - 1 LOOP
            B_v (i) := DATA2(i) xor Cin_s;
        END LOOP;
        B_i <= B_v;
    END PROCESS;

    --aggiungere un segnale di enable all'adder cosi da non utilizzarlo se non richiesta un operazione con esso 
    WITH FUNC SELECT Cin_s <=
        '0' WHEN ADD,
        '1' WHEN SUB,
        '1' WHEN OTHERS; --set to one because when i want to check a certain flag the operation that i have to perform is a subtraction

    WITH FUNC SELECT OUTALU <=
        OUTALU_shift WHEN FUNCLSL,
        OUTALU_shift WHEN FUNCRL,
        OUTALU_shift WHEN FUNCLSR,
        OUTALU_shift WHEN FUNCRR,
        OUTALU_lu WHEN BITAND,
        OUTALU_lu WHEN BITOR,
        OUTALU_lu WHEN BITXOR,
        OUTALU_lu WHEN BITNOT,
        OUTALU_s WHEN OTHERS;

END behavioral;