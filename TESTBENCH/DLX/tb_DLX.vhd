LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY tb_DLX IS
          GENERIC (
            FILENAME : string := "Branch.mem"--"test-arith.mem" -- change filename to change asm test
          );
END ENTITY;

ARCHITECTURE test OF tb_DLX IS
    ----------------------------------------------------------------------------------------------------
    --                                    Component declaration                                       --
    ----------------------------------------------------------------------------------------------------
    COMPONENT DLX IS
          GENERIC (
            FILENAME : string := "test.asm.mem";
            IR_SIZE : INTEGER := 32; -- Instruction Register Size
            PC_SIZE : INTEGER := 32  -- Program Counter Size
        );                       -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
        PORT (
            Clk : IN STD_LOGIC;
            Rst : IN STD_LOGIC); -- Active Low
    END COMPONENT;

    ----------------------------------------------------------------------------------------------------
    --                                  Signal Declaration                                            --
    ----------------------------------------------------------------------------------------------------
    SIGNAL CLK : STD_LOGIC := '0';
    SIGNAL RST : STD_LOGIC := '0';
BEGIN
    dlx_inst : DLX
    GENERIC MAP( FILENAME => FILENAME)
    PORT MAP(
        Clk => Clk,
        Rst => Rst
    );

    
    CLOCK: PROCESS (CLK)
    BEGIN
      CLK <= NOT (CLK) AFTER 5 ns;
    END PROCESS;

    RST <=  '1' after 10 ns;

END ARCHITECTURE;
