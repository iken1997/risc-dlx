LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

---------------------------------------------------------------------------------------

ENTITY reg IS
    GENERIC (Nbit : INTEGER := 16); --number of bits
    PORT (
        D : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0); --data input
        Q : OUT STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0); --data output
        EN : IN STD_LOGIC; --enable active high
        CLK : IN STD_LOGIC; --clock
        RST : IN STD_LOGIC --asynchronous reset active low
    );
END reg;

---------------------------------------------------------------------------------------

ARCHITECTURE behavioral OF reg IS --register with asyncronous reset and enable

BEGIN
    PSYNCH : PROCESS (CLK, RST) --asynchronous reset
    BEGIN
        IF RST = '0' THEN --if reset is active
            Q <= (OTHERS => '0'); --clear the output
        ELSIF rising_edge(CLK) THEN --otherwise if there is a positive clock edge
            IF EN = '1' THEN --and enable is active
                Q <= D; --writes the input on the output
            END IF;
        END IF;
    END PROCESS;

END behavioral;