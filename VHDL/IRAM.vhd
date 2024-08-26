LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------------------------

ENTITY IRAM_ IS
    GENERIC (
        MEM_SIZE : INTEGER := 512;
        NADD : INTEGER := 6
    );
    PORT (
        DATA_OUT : OUT WORD;
        ADDR : IN STD_LOGIC_VECTOR (NADD - 1 DOWNTO 0);
        EN : STD_LOGIC;
        RDY : STD_LOGIC;
        CLK : STD_LOGIC;
        RST : STD_LOGIC
    );
END IRAM_;

-----------------------------------------------------------------------------------------------------------------------------

ARCHITECTURE behavioral OF IRAM_ IS

    SUBTYPE IRAM_ADDR IS NATURAL RANGE 0 TO (MEM_SIZE - 1); -- using natural type
    TYPE IRAM_ARRAY IS ARRAY(IRAM_ADDR) OF WORD;
    SIGNAL IRAM : IRAM_ARRAY;

    BEGIN
	-- write your RF code 

	p1 : PROCESS (CLK)
	BEGIN
		IF CLK'event AND CLK = '1' THEN
			IF RST = '1' THEN
				IRAM <= (OTHERS => (OTHERS => '0'));
			END IF;
			IF EN = '1' THEN
                DATA_OUT <= IRAM(to_integer(unsigned(ADDR)));
			END IF;
		END IF;
	END PROCESS;
END behavioral;