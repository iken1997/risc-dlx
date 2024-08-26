LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE WORK.ALL;
USE WORK.constants.ALL;
USE WORK.alu_types.ALL;

----------------------------------------------------------------------------------

ENTITY register_file IS
	GENERIC (
		NADD : INTEGER := 5
	);
	PORT (
		CLK     : IN STD_LOGIC;
		RESET   : IN STD_LOGIC;
		ENABLE  : IN STD_LOGIC;
		RD1     : IN STD_LOGIC;
		RD2     : IN STD_LOGIC;
		WR      : IN STD_LOGIC;
		ADD_WR  : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
		ADD_RD1 : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
		ADD_RD2 : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
		DATAIN  : IN WORD;
		OUT1    : OUT WORD;
		OUT2    : OUT WORD);
END register_file;

-----------------------------------------------------------------------------------

ARCHITECTURE A OF register_file IS

	-- suggested structures
	SUBTYPE REG_ADDR IS NATURAL RANGE 0 TO (2 ** NADD - 1); -- using natural type
	TYPE REG_ARRAY IS ARRAY(REG_ADDR) OF WORD;
	SIGNAL REGISTERS : REG_ARRAY;

	-----------------------------------------------------------------------------------	

BEGIN
	-- write your RF code 

	OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))) WHEN( RD1 = '1' AND RESET = '0') ELSE
		(OTHERS => '0');

    OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))) WHEN ( RD2 = '1' AND RESET = '0') ELSE
		(OTHERS => '0');

	p1 : PROCESS (CLK, RESET)
	BEGIN
		IF RESET = '1' THEN

			REGISTERS <= (OTHERS => (OTHERS => '0'));

		ELSIF ENABLE = '1' THEN
			IF (WR = '1' AND RESET = '0') THEN
				REGISTERS(to_integer(unsigned(ADD_WR))) <= DATAIN;
			END IF;

		END IF;
	END PROCESS;
END A;

----------------------------------------------------------------------------------
