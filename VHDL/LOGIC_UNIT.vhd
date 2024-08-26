LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------

ENTITY LOGIC_UNIT IS
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
        A_OR_B : OUT WORD); -- make the bitwise OR between input 1 and input 2
END LOGIC_UNIT;

-----------------------------------------------------------------------------------------------------------

ARCHITECTURE BEHAVIORAL OF LOGIC_UNIT IS

    SIGNAL nor_sum : STD_LOGIC;

BEGIN

    nor_sum <= nor_vector(SUM);

    PROCESS (FUNC, A, B, SUM, COUT)

    BEGIN
        CASE FUNC IS
            WHEN BITNOT =>
                NOT_A <= NOT A;
            WHEN BITAND =>
                A_AND_B <= A AND B;
            WHEN BITOR =>
                A_OR_B <= A OR B;
            WHEN BITXOR =>
                A_XOR_B <= A XOR B;

            WHEN GREATER_EQ =>
                A_GE_B <= COUT XOR (A (Nbit - 1) XOR B (Nbit - 1));
            WHEN LOWER_EQ =>
                A_LE_B <= nor_sum OR (NOT (COUT XOR (A (Nbit - 1) XOR B (Nbit - 1))));
            WHEN UGREATER_EQ =>
                A_GEU_B <= COUT;
            WHEN ULOWER_EQ =>
                A_LEU_B <= nor_sum OR (NOT COUT);
            WHEN EQ =>
                A_EQ_B <= nor_sum;
            WHEN NEQ =>
                A_NE_B <= NOT(nor_sum);

            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;
END BEHAVIORAL;