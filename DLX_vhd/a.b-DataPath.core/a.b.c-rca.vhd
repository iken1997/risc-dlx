LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE WORK.constants.ALL;

-----------------------------------------------------------------------

ENTITY RCA IS
  GENERIC (
    NBIT : INTEGER := 4
  );
  PORT (
    A  : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    B  : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Ci : IN STD_LOGIC;
    S  : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
    Co : OUT STD_LOGIC);
END RCA;

-----------------------------------------------------------------------

ARCHITECTURE STRUCTURAL OF RCA IS

  SIGNAL STMP : STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
  SIGNAL CTMP : STD_LOGIC_VECTOR(NBIT DOWNTO 0);

  COMPONENT FA
    PORT (
      A  : IN STD_LOGIC;
      B  : IN STD_LOGIC;
      Ci : IN STD_LOGIC;
      S  : OUT STD_LOGIC;
      Co : OUT STD_LOGIC);
  END COMPONENT;

BEGIN

  CTMP(0) <= Ci;
  S       <= STMP;
  Co      <= CTMP(NBIT);

  ADDER1 : FOR I IN 1 TO NBIT GENERATE
    FAI : FA
    PORT MAP(A(I - 1), B(I - 1), CTMP(I - 1), STMP(I - 1), CTMP(I));
  END GENERATE;

END STRUCTURAL;
