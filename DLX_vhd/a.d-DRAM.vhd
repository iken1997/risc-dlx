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
    SIGNAL mem_int : DRAM_ARRAY;

BEGIN

  p1 : PROCESS (ADDR, EN, RST, W_EN, R_EN)
    BEGIN
            IF RST = '0' THEN
            mem_int <= (OTHERS => (OTHERS => '0'));
            DATA_OUT <=  (OTHERS => '0');
            ELSIF EN = '1' THEN
              IF W_EN = '1' AND R_EN ='0' THEN
                  mem_int(to_integer(unsigned(ADDR))) <= DATA_IN;
              ELSIF R_EN = '1' AND W_EN='0' THEN
                DATA_OUT <= mem_int(to_integer(unsigned(ADDR)));
                END IF;
            END IF;
    END PROCESS p1;
END behavioral;