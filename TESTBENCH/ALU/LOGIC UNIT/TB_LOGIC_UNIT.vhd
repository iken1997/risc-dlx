LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
-- USE ieee.std_logic_arith.all;
USE WORK.alu_types.ALL;
USE WORK.CONSTANTS.ALL;

ENTITY TB_LOGIC_UNIT IS

END ENTITY;

ARCHITECTURE TEST OF TB_LOGIC_UNIT IS
    COMPONENT LOGIC_UNIT IS
        GENERIC (Nbit : INTEGER := 32);
        PORT (
            FUNC      : IN TYPE_OP;
            A         : IN WORD;
            B         : IN WORD;
            SUM       : IN WORD;      -- sum by the adder
            COUT      : IN STD_LOGIC; -- carry out by the adder
            LOGIC_OUT : OUT WORD);    -- operations output
    END COMPONENT;

    SIGNAL A         : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL FUNC      : TYPE_OP                                  := NEQ;
    SIGNAL B         : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL SUM       : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
    SIGNAL TEMP      : STD_LOGIC_VECTOR(WORD_SIZE DOWNTO 0)     := (OTHERS => '0');
    SIGNAL COUT      : STD_LOGIC                                := '0';
    SIGNAL LOGIC_OUT : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0) := (OTHERS => '0');

BEGIN

    PROCESS
    BEGIN
        FUNC <= NEQ;
        WAIT FOR 2 ns;
        FUNC <= EQ;
        WAIT FOR 2 ns;
        FUNC <= LOWER_EQ;
        WAIT FOR 2 ns;
        FUNC <= GREATER_EQ;
        WAIT FOR 2 ns;
        FUNC <= ULOWER_EQ;
        WAIT FOR 2 ns;
        FUNC <= UGREATER_EQ;
        WAIT FOR 2 ns;
        FUNC <= BITNOT;
        WAIT FOR 2 ns;
        FUNC <= BITAND;
        WAIT FOR 2 ns;
        FUNC <= BITOR;
        WAIT FOR 2 ns;
        FUNC <= BITXOR;
        WAIT FOR 2 ns;
    END PROCESS;

    input_variation : PROCESS
    BEGIN
        A <= x"0000000F";
        B <= x"0000000A";
        WAIT FOR 20 ns;
        A <= x"0000000A";
        B <= x"0000000F";
        WAIT FOR 20 ns;
        A <= x"FFFFFFFF";
        B <= x"0000000A";
        WAIT FOR 20 ns;
        A <= x"FFFFFFFF";
        B <= x"FFFFFFFE";
        WAIT FOR 20 ns;
        A <= x"FFFFFFFE";
        B <= x"FFFFFFFF";
        WAIT FOR 20 ns;
        A <= x"F000000F";
        B <= x"8000000A";
        WAIT FOR 20 ns;
        A <= x"8000F00F";
        B <= x"0000000A";
        WAIT FOR 20 ns;
        A <= x"8000F00F";
        B <= x"8000F00F";
        WAIT FOR 20 ns;
        WAIT;
    END PROCESS;

    TEMP <= STD_LOGIC_VECTOR(unsigned('0' & A) + unsigned('0' & NOT(B)) + 1);
    COUT <= TEMP(temp'left);
    SUM  <= TEMP(TEMP'left - 1 DOWNTO 0);
    dut : LOGIC_UNIT
    PORT MAP(FUNC, A, B, SUM, COUT, LOGIC_OUT);

END ARCHITECTURE;
