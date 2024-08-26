LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------

ENTITY LOGIC_UNIT IS
    GENERIC (Nbit : INTEGER := 32);
    PORT (
        FUNC      : IN TYPE_OP;
        A         : IN WORD;
        B         : IN WORD;
        SUM       : IN WORD;      -- sum by the adder
        COUT      : IN STD_LOGIC; -- carry out by the adder
        LOGIC_OUT : OUT WORD);    -- operations output
END LOGIC_UNIT;

-----------------------------------------------------------------------------------------------------------

ARCHITECTURE BEHAVIORAL OF LOGIC_UNIT IS

BEGIN
    PROCESS (FUNC, A, B, SUM, COUT)

    BEGIN
        CASE FUNC IS
            WHEN BITNOT =>
                LOGIC_OUT <= NOT A;
            WHEN BITAND =>
                LOGIC_OUT <= A AND B;
            WHEN BITOR =>
                LOGIC_OUT <= A OR B;
            WHEN BITXOR =>
                LOGIC_OUT <= A XOR B;
            WHEN GREATER_EQ => --sge
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right + 1 => '0') & (COUT XOR (A (Nbit - 1) XOR B (Nbit - 1)));
            WHEN LOWER_EQ  => --sle
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right + 1 => '0') & (NOR_reduce(SUM) OR (NOT (COUT XOR (A (Nbit - 1) XOR B (Nbit - 1)))));
            WHEN UGREATER_EQ => --sgeu
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right+1 => '0') & COUT;
            WHEN ULOWER_EQ => --sleu
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right + 1 => '0') & (NOR_reduce(SUM) OR (NOT COUT));
            WHEN EQ  => --seq 
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right + 1 => '0') & (NOR_reduce(SUM));
            WHEN NEQ  => --sneq
                LOGIC_OUT <= (LOGIC_OUT'left DOWNTO LOGIC_OUT'right + 1 => '0') & (OR_reduce(SUM));
            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS;

END BEHAVIORAL;
