LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY TB_P4_ADDER IS
END TB_P4_ADDER;

ARCHITECTURE TEST OF TB_P4_ADDER IS

	-- P4 component declaration
	COMPONENT P4_ADDER IS
		GENERIC (
			NBIT           : INTEGER := 32;
			NBIT_PER_BLOCK : INTEGER := 4);
		PORT (
			A    : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			B    : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			Cin  : IN STD_LOGIC;
			S    : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
			Cout : OUT STD_LOGIC);
	END COMPONENT;

	SIGNAL A    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL B    : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
	SIGNAL cin  : STD_LOGIC                     := '0';
	SIGNAL cout : STD_LOGIC                     := '0';
	SIGNAL S    : STD_LOGIC_VECTOR(31 DOWNTO 0);
	SIGNAL TEMP : STD_LOGIC_VECTOR(32 DOWNTO 0);
BEGIN
	-- P4 instantiation
	uut : P4_ADDER
	GENERIC MAP(NBIT => 32, NBIT_PER_BLOCK => 4)
	PORT MAP(A => A, B => B, Cin => cin, S => S, Cout => cout);

	stimuli : PROCESS

	BEGIN
		cin <= '0';
		A   <= x"0000FA0E";
		B   <= x"000000F0";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"0000BC0E";
		B   <= x"0000FFF0";
		WAIT FOR 10 ns;

		cin <= '1';
		A   <= x"0000FF0E";
		B   <= x"00CD00F0";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"0000FA0E";
		B   <= x"0000C0E0";
		WAIT FOR 10 ns;

		cin <= '1';
		A   <= x"0000FFFF";
		B   <= x"0000FFFF";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"00000001";
		B   <= x"00000001";
		WAIT FOR 10 ns;

		cin <= '1';
		A   <= x"FFFFFFFF";
		B   <= x"00000001";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"0000FF0E";
		B   <= x"0000CAF0";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"00F0FF0E";
		B   <= x"00F000F0";
		WAIT FOR 10 ns;

		cin <= '0';
		A   <= x"0F00FF0E";
		B   <= x"0FF000F0";
		WAIT FOR 10 ns;

		cin <= '1';
		A   <= x"0F00FF0E";
		B   <= x"0FF000FA";
		WAIT FOR 10 ns;

		WAIT;
	END PROCESS;

	test : PROCESS IS
	BEGIN
		WAIT FOR 5 ns;
		ASSERT (S = TEMP(31 DOWNTO 0))
		REPORT "WRONG SUM"
			SEVERITY error;
		ASSERT (cout = TEMP(32))
		REPORT "WRONG COUT"
			SEVERITY error;
	END PROCESS;
	TEMP <= ('0' & A) + ('0' & (B)) + (cin);
END TEST;
