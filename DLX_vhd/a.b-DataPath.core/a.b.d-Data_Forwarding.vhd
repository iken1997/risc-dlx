LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.myTypes.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------

ENTITY DATAFORWARDING IS
    GENERIC (
        Nbit : INTEGER := 5
    );
    PORT (
        EN : IN STD_LOGIC;
        IN1 : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
        IN2 : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
        INTARGET : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
        OUTPUT : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
    );
END DATAFORWARDING;

-----------------------------------------------------------------------------------------------------------

ARCHITECTURE behavioral OF DATAFORWARDING IS
BEGIN
    --if Output is one the data must be forwarded in input at the ALU
    p1 : PROCESS (IN1, IN2, INTARGET)
    BEGIN
        IF EN = '1' THEN
            IF IN1 = INTARGET THEN
                OUTPUT (0) <= '1';
            ELSE
                OUTPUT (0) <= '0';
            END IF;
            IF IN2 = INTARGET THEN
                OUTPUT (1) <= '1';
            ELSE
                OUTPUT (1) <= '0';
            END IF;
        END IF;
    END PROCESS;
END behavioral;