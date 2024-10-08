LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;

PACKAGE CONSTANTS IS
   CONSTANT NumBit : INTEGER := 4;
   CONSTANT N_BitReg : INTEGER := 5;
   CONSTANT DRAM_SIZE : INTEGER := 1024;
   CONSTANT DRAM_ADDR_SIZE : INTEGER := 32;
   CONSTANT WORD_SIZE : INTEGER := 32;
   CONSTANT CW_SIZE : INTEGER := 29;
   SUBTYPE CONTROL_WORD IS STD_LOGIC_VECTOR (CW_SIZE - 1 DOWNTO 0);
   SUBTYPE WORD IS STD_LOGIC_VECTOR (WORD_SIZE - 1 DOWNTO 0);
   CONSTANT WORD_4            : STD_LOGIC_VECTOR (WORD_SIZE - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(4, WORD_SIZE));
   CONSTANT LAST_REG          : STD_LOGIC_VECTOR (N_BitReg - 1 DOWNTO 0)  := STD_LOGIC_VECTOR(to_unsigned(31, N_BitReg));
   CONSTANT ZERO              : STD_LOGIC_VECTOR (WORD_SIZE - 1 DOWNTO 0) := STD_LOGIC_VECTOR(to_unsigned(0, WORD_SIZE));
   FUNCTION NOR_reduce(vector : STD_LOGIC_VECTOR) RETURN STD_LOGIC;
   FUNCTION OR_reduce(vector  : STD_LOGIC_VECTOR) RETURN STD_LOGIC;

END CONSTANTS;

PACKAGE BODY CONSTANTS IS

   FUNCTION NOR_reduce (vector : STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
      VARIABLE tmp                : STD_LOGIC := '0';
   BEGIN
      FOR i IN vector'RANGE LOOP
         tmp := tmp OR vector(i);
      END LOOP;
      RETURN NOT tmp;
   END FUNCTION NOR_reduce;

   FUNCTION OR_reduce (vector : STD_LOGIC_VECTOR) RETURN STD_LOGIC IS
      VARIABLE tmp               : STD_LOGIC := '0';
   BEGIN
      FOR i IN vector'RANGE LOOP
         tmp := tmp OR vector(i);
      END LOOP;
      RETURN tmp;
   END FUNCTION OR_reduce;

END PACKAGE BODY CONSTANTS;
