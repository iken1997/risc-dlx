LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE std.textio.ALL;
USE ieee.std_logic_textio.ALL;
-- Instruction memory for DLX
-- Memory filled by a process which reads from a file
-- file name is "test.asm.mem"
ENTITY IRAM IS
  GENERIC (
    RAM_DEPTH : INTEGER := 48;
    I_SIZE : INTEGER := 32);
  PORT (
    Rst : IN STD_LOGIC;
    EN : STD_LOGIC;
    RDY : STD_LOGIC;
    Addr : IN STD_LOGIC_VECTOR(I_SIZE - 1 DOWNTO 0);
    Dout : OUT STD_LOGIC_VECTOR(I_SIZE - 1 DOWNTO 0)
  );

END IRAM;

ARCHITECTURE IRam_Bhe OF IRAM IS

  TYPE RAMtype IS ARRAY (0 TO RAM_DEPTH - 1) OF INTEGER;-- std_logic_vector(I_SIZE - 1 downto 0);

  SIGNAL IRAM_mem : RAMtype;

BEGIN -- IRam_Bhe

  p1 : PROCESS (ADDR)
  BEGIN
    IF EN = '1' THEN
      Dout <= conv_std_logic_vector(IRAM_mem(conv_integer(unsigned(Addr))), I_SIZE);
    END IF;
  END PROCESS p1;

  -- purpose: This process is in charge of filling the Instruction RAM with the firmware
  -- type   : combinational
  -- inputs : Rst
  -- outputs: IRAM_mem
  FILL_MEM_P : PROCESS (Rst)
    FILE mem_fp : text;
    VARIABLE file_line : line;
    VARIABLE index : INTEGER := 0;
    VARIABLE tmp_data_u : STD_LOGIC_VECTOR(I_SIZE - 1 DOWNTO 0);
  BEGIN -- process FILL_MEM_P
    IF (Rst = '0') THEN
      file_open(mem_fp, "test.asm.mem", READ_MODE);
      WHILE (NOT endfile(mem_fp)) LOOP
        readline(mem_fp, file_line);
        hread(file_line, tmp_data_u);
        IRAM_mem(index) <= conv_integer(unsigned(tmp_data_u));
        index := index + 1;
      END LOOP;
    END IF;
  END PROCESS FILL_MEM_P;

END IRam_Bhe;