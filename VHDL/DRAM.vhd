LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------------------------

ENTITY DRAM IS
    GENERIC (
        MEM_SIZE : INTEGER := 512;
        NADD : INTEGER := 6
    );
    PORT (
        DATA_IN : IN WORD;
        DATA_OUT : OUT WORD;
        ADDR : IN STD_LOGIC_VECTOR (NADD - 1 DOWNTO 0);
        EN : STD_LOGIC;
        RDY : STD_LOGIC;
        R_EN : STD_LOGIC;
        W_EN : STD_LOGIC;
        CLK : STD_LOGIC;
        RST : STD_LOGIC
    );
END DRAM;

-----------------------------------------------------------------------------------------------------------------------------

ARCHITECTURE behavioral OF DRAM IS

    SUBTYPE DRAM_ADDR IS NATURAL RANGE 0 TO (MEM_SIZE - 1); -- using natural type
    TYPE DRAM_ARRAY IS ARRAY(DRAM_ADDR) OF WORD;
    SIGNAL DRAM : DRAM_ARRAY;

BEGIN
    -- write your RF code 

    p1 : PROCESS (ADDR)
    BEGIN
        --IF CLK'event AND CLK = '1' THEN
            IF RST = '1' THEN
                DRAM <= (OTHERS => (OTHERS => '0'));
            END IF;
            IF EN = '1' THEN
                IF W_EN = '1' THEN
                    DATA_OUT <= DRAM(to_integer(unsigned(ADDR)));
                ELSIF R_EN = '1' THEN
                    DRAM(to_integer(unsigned(ADDR))) <= DATA_IN;
                END IF;
            END IF;
        --END IF;
    END PROCESS p1;
END behavioral;