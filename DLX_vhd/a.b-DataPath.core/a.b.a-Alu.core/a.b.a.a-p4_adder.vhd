LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

USE WORK.constants.ALL;

-----------------------------------------------------------------------------------------------------------

ENTITY P4_ADDER IS
    GENERIC (
        NBIT : INTEGER := 32;
        NBIT_PER_BLOCK : INTEGER := 4);
    PORT (
        A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        S : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
        Cout : OUT STD_LOGIC);
END P4_ADDER;

-----------------------------------------------------------------------------------------------------------

ARCHITECTURE STRUCTURAL OF P4_ADDER IS

    COMPONENT CARRY_GENERATOR IS
        GENERIC (
            NBIT : INTEGER := 32;
            NBIT_PER_BLOCK : INTEGER := 4);
        PORT (
            A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
            Cin : IN STD_LOGIC;
            Co : OUT STD_LOGIC_VECTOR((NBIT/NBIT_PER_BLOCK) - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT SUM_GENERATOR IS
        GENERIC (
            NBIT_PER_BLOCK : INTEGER := 4;
            NBLOCKS : INTEGER := 8);
        PORT (
            A : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
            Ci : IN STD_LOGIC_VECTOR(NBLOCKS - 1 DOWNTO 0);
            S : OUT STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0));
    END COMPONENT;

    SIGNAL Co_out : STD_LOGIC_VECTOR((NBIT/NBIT_PER_BLOCK) - 1 DOWNTO 0);
    SIGNAL Co_in : STD_LOGIC_VECTOR((NBIT/NBIT_PER_BLOCK) - 1 DOWNTO 0);

BEGIN

    CLA : CARRY_GENERATOR
    GENERIC MAP(NBIT => NBIT, NBIT_PER_BLOCK => NBIT_PER_BLOCK)
    PORT MAP(A => A, B => B, Cin => Cin, Co => Co_out);

    SG : SUM_GENERATOR
    GENERIC MAP(NBIT_PER_BLOCK => NBIT_PER_BLOCK, NBLOCKS => NBIT/NBIT_PER_BLOCK)
    PORT MAP(A => A, B => B, Ci => Co_in, S => S);

    Co_in <= (Co_out(Co_out'LEFT - 1 DOWNTO 0) & Cin);

    Cout <= Co_out(Co_out'LEFT);


END ARCHITECTURE;