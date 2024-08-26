LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.constants.ALL;

ENTITY SUM_GENERATOR IS
	GENERIC (
		NBIT_PER_BLOCK : INTEGER := 4;
		NBLOCKS : INTEGER := 8);
	PORT (
		A : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
		B : IN STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0);
		Ci : IN STD_LOGIC_VECTOR(NBLOCKS - 1 DOWNTO 0);
		S : OUT STD_LOGIC_VECTOR(NBIT_PER_BLOCK * NBLOCKS - 1 DOWNTO 0));
END SUM_GENERATOR;

ARCHITECTURE structural OF SUM_GENERATOR IS

	COMPONENT carry_select_block IS
		GENERIC (NBIT : INTEGER := NBIT_PER_BLOCK);
		PORT (
			INPUT_1 : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			INPUT_2 : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			Ci_sel : IN STD_LOGIC; -- carry out of the previous stage, used for selecting the "right" assumption
			SUM : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0));
		--Co:	Out	std_logic); isn't needed because the carry out is provided to the other block by a carry_generator_block 
	END COMPONENT;

BEGIN

	g1 : FOR i IN 0 TO NBLOCKS - 1 GENERATE
		CSB : carry_select_block
		GENERIC MAP(NBIT => NBIT_PER_BLOCK)
		PORT MAP(
			INPUT_1 => A((((i + 1) * NBIT_PER_BLOCK) - 1) DOWNTO ((i) * (NBIT_PER_BLOCK))),
			INPUT_2 => B((((i + 1) * NBIT_PER_BLOCK) - 1) DOWNTO ((i) * (NBIT_PER_BLOCK))),
			Ci_sel => Ci(i), SUM => S((((i + 1) * NBIT_PER_BLOCK) - 1) DOWNTO ((i) * (NBIT_PER_BLOCK))));
	END GENERATE;

END structural;