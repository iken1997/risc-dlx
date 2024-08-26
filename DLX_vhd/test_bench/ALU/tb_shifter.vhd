LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;
USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

ENTITY tb_shifter IS
END ENTITY;

ARCHITECTURE test OF tb_shifter IS
    COMPONENT shifter IS
        GENERIC (N : INTEGER := WORD_SIZE);
        PORT (
            FUNC         : IN TYPE_OP;
            DATA1, DATA2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
            OUTSHIFT     : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
    END COMPONENT;

    SIGNAL FUNC         : TYPE_OP;
    SIGNAL DATA1, DATA2 : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL OUTSHIFT     : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
BEGIN

    CHANGE_FUNC : PROCESS
    BEGIN
        FUNC <= FUNCRR;
        WAIT FOR 2 ns;
        ASSERT (OUTSHIFT = STD_LOGIC_VECTOR(rotate_right(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func RR failed"
            SEVERITY error;
        FUNC <= FUNCRL;
        WAIT FOR 2 ns;
        ASSERT (OUTSHIFT = STD_LOGIC_VECTOR(rotate_left(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func RL failed"
            SEVERITY error;
        FUNC <= FUNCLSR;
        WAIT FOR 2 ns;
        ASSERT (OUTSHIFT = STD_LOGIC_VECTOR(shift_right(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func sr failed"
            SEVERITY error;
        FUNC <= FUNCLSL;
        WAIT FOR 2 ns;
        ASSERT (OUTSHIFT = STD_LOGIC_VECTOR(shift_left(unsigned(DATA1), to_integer(unsigned(DATA2)))))
        REPORT "func sl failed"
            SEVERITY error;
    END PROCESS;

    CHANGE_input : PROCESS
    BEGIN
        DATA1 <= X"0000F200";
        DATA2 <= X"00000005";
        WAIT FOR 8 ns;
        DATA1 <= X"0000F200";
        DATA2 <= X"0000004A";
        WAIT FOR 8 ns;
        DATA1 <= X"0000F200";
        DATA2 <= X"00000076";
        WAIT FOR 8 ns;
        DATA1 <= X"0000F200";
        DATA2 <= X"00000030";
        WAIT FOR 8 ns;
        DATA1 <= X"0000F200";
        DATA2 <= X"00000065";
        WAIT FOR 8 ns;
        DATA1 <= X"0000F200";
        DATA2 <= X"00000018";
        WAIT FOR 8 ns;
        DATA1 <= X"00000053";
        DATA2 <= X"0000003F";
        WAIT FOR 8 ns;
        DATA1 <= X"00000011";
        DATA2 <= X"0000002B";
        WAIT FOR 8 ns;
    END PROCESS;

    dut : shifter
    PORT MAP(
        FUNC     => FUNC,
        DATA1    => DATA1,
        DATA2    => DATA2,
        OUTSHIFT => OUTSHIFT
    );

END ARCHITECTURE;
