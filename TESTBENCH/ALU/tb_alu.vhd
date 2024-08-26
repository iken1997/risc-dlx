LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

ENTITY tb_alu IS

END ENTITY;

ARCHITECTURE test OF tb_alu IS
    COMPONENT ALU IS
        GENERIC (Nbit : INTEGER := 32);
        PORT (
            FUNC   : IN TYPE_OP;
            DATA1  : IN WORD;
            DATA2  : IN WORD;
            OUTALU : OUT WORD
        );
    END COMPONENT;

    SIGNAL DATA1    : WORD;
    SIGNAL FUNC     : TYPE_OP;
    SIGNAL DATA2    : WORD;
    SIGNAL OUTALU   : WORD;
    SIGNAL TEMP_ADD : STD_LOGIC_VECTOR(WORD_SIZE DOWNTO 0);
    SIGNAL TEMP_SUB : STD_LOGIC_VECTOR(WORD_SIZE DOWNTO 0);

BEGIN
    change_func : PROCESS
    BEGIN
        FUNC <= ADD;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = TEMP_ADD(31 DOWNTO 0))
        REPORT "WRONG SUM"
            SEVERITY error;
        FUNC <= SUB;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = TEMP_SUB(31 DOWNTO 0))
        REPORT "WRONG SUB"
            SEVERITY error;
        FUNC <= NOP;
        WAIT FOR 2 ns;
        FUNC <= FUNCRR;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = STD_LOGIC_VECTOR(rotate_right(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func RR failed"
            SEVERITY error;
        FUNC <= FUNCRL;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = STD_LOGIC_VECTOR(rotate_left(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func RL failed"
            SEVERITY error;
        FUNC <= FUNCLSR;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = STD_LOGIC_VECTOR(shift_right(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func SR failed"
            SEVERITY error;
        FUNC <= FUNCLSL;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = STD_LOGIC_VECTOR(shift_left(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func sl failed"
            SEVERITY error;
        FUNC <= NEQ;
        WAIT FOR 2 ns;
        ASSERT ( OR_REDUCE(OUTALU)= '1' XNOR DATA1 /= DATA2 ) 
        REPORT "func NEQ failed"
            SEVERITY error;
        FUNC <= EQ;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = x"00000001" XNOR DATA1 = DATA2)
        REPORT "func EQ failed"
            SEVERITY error;
        FUNC <= LOWER_EQ;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = x"00000001" XNOR signed(DATA1) <= signed(DATA2))
        REPORT "func LOWEQ failed"
            SEVERITY error;
        FUNC <= GREATER_EQ;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = x"00000001" XNOR signed(DATA1) >= signed(DATA2))
        REPORT "func GREQ failed"
            SEVERITY error;
        FUNC <= ULOWER_EQ;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = x"00000001" XNOR unsigned(DATA1) <= unsigned(DATA2))
        REPORT "func ULOWEQ failed"
            SEVERITY error;
        FUNC <= UGREATER_EQ;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = x"00000001" XNOR unsigned(DATA1) >= unsigned(DATA2))
        REPORT "func UGREQ failed"
            SEVERITY error;
        FUNC <= BITNOT;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = NOT(DATA1))
        REPORT "func NOT failed"
            SEVERITY error;
        FUNC <= BITAND;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = (DATA1 AND DATA2))
        REPORT "func AND failed"
            SEVERITY error;
        FUNC <= BITOR;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = (DATA1 OR DATA2))
        REPORT "func OR failed"
            SEVERITY error;
        FUNC <= BITXOR;
        WAIT FOR 2 ns;
        ASSERT (OUTALU = (DATA1 XOR DATA2))
        REPORT "func XOR failed"
            SEVERITY error;
    END PROCESS;

    change_inputs : PROCESS
    BEGIN
        DATA1 <= x"0000000F";
        DATA2 <= x"0000000A";
        WAIT FOR 34 ns;
        DATA1 <= x"0000000A";
        DATA2 <= x"0000000F";
        WAIT FOR 34 ns;
        DATA1 <= x"FFFFFFFF";
        DATA2 <= x"0000000A";
        WAIT FOR 34 ns;
        DATA1 <= x"FFFFFFFF";
        DATA2 <= x"FFFFFFFE";
        WAIT FOR 34 ns;
        DATA1 <= x"FFFFFFFE";
        DATA2 <= x"FFFFFFFF";
        WAIT FOR 34 ns;
        DATA1 <= x"F000000F";
        DATA2 <= x"8000000A";
        WAIT FOR 34 ns;
        DATA1 <= x"8000F00F";
        DATA2 <= x"0000000A";
        WAIT FOR 34 ns;
        DATA1 <= x"8000F00F";
        DATA2 <= x"8000F00F";
        WAIT FOR 34 ns;
        DATA1 <= x"0000FA0E";
        DATA2 <= x"000000F0";
        WAIT FOR 34 ns;
        DATA1 <= x"0000BC0E";
        DATA2 <= x"0000FFF0";
        WAIT FOR 34 ns;
        DATA1 <= x"0000FF0E";
        DATA2 <= x"00CD00F0";
        WAIT FOR 34 ns;
        DATA1 <= x"0000FA0E";
        DATA2 <= x"0000C0E0";
        WAIT FOR 34 ns;
        DATA1 <= x"0000FFFF";
        DATA2 <= x"0000FFFF";
        WAIT FOR 34 ns;
        DATA1 <= x"00000001";
        DATA2 <= x"00000001";
        WAIT FOR 34 ns;
        DATA1 <= x"FFFFFFFF";
        DATA2 <= x"00000001";
        WAIT FOR 34 ns;
        DATA1 <= x"0000FF0E";
        DATA2 <= x"0000CAF0";
        WAIT FOR 34 ns;
        DATA1 <= x"00F0FF0E";
        DATA2 <= x"00F000F0";
        WAIT FOR 34 ns;
        DATA1 <= x"0F00FF0E";
        DATA2 <= x"0FF000F0";
        WAIT FOR 34 ns;
        DATA1 <= x"0F00FF0E";
        DATA2 <= x"0FF000FA";
        WAIT FOR 34 ns;
        WAIT;
    END PROCESS;

    TEMP_SUB <= ('0' & DATA1) + ('0' & NOT(DATA2)) + 1;
    TEMP_ADD <= ('0' & DATA1) + ('0' & (DATA2));

    dut : ALU
    GENERIC MAP(
        Nbit => 32
    )
    PORT MAP(
        FUNC   => FUNC,
        DATA1  => DATA1,
        DATA2  => DATA2,
        OUTALU => OUTALU
    );

END ARCHITECTURE;
