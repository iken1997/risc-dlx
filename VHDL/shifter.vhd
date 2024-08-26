LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

ENTITY shifter IS
    GENERIC (N : INTEGER := NumBit);
    PORT (
        FUNC : IN TYPE_OP;
        DATA1, DATA2 : IN STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
        OUTSHIFT : OUT STD_LOGIC_VECTOR(N - 1 DOWNTO 0));
END shifter;

ARCHITECTURE BEHAVIOR OF shifter IS

    SIGNAL mask : STD_LOGIC_VECTOR(N - 1 DOWNTO 0);
BEGIN

    
mask <= STD_LOGIC_VECTOR(to_unsigned(N - 1, N));

    PSHFT : PROCESS (FUNC, DATA1, DATA2)
        -- complete all the requested functions
        VARIABLE toshift : STD_LOGIC_VECTOR(N - 1 DOWNTO 0) := (OTHERS => '0');
    BEGIN
        CASE FUNC IS
            WHEN FUNCLSL => -- shift left
                toshift := DATA1; -- copy the variable
                shiftleft : FOR i IN 0 TO N - 1 LOOP --shift by a maximum amount on N
                    toshift := toshift(N - 2 DOWNTO 0) & '0';
                    EXIT WHEN i = DATA2 - 1; -- if shifted by DATA" then exit
                END LOOP;
                OUTSHIFT <= toshift;

            WHEN FUNCLSR => -- shift right
                toshift := DATA1;
                shiftright : FOR i IN 0 TO N - 1 LOOP
                    toshift := '0' & toshift(N - 1 DOWNTO 1);
                    EXIT WHEN i = DATA2 - 1;
                END LOOP;
                OUTSHIFT <= toshift;

            WHEN FUNCRL => -- rotate left
                toshift := DATA1;
                rotateleft : FOR i IN 0 TO N - 1 LOOP -- rotate for maximum nbit
                    toshift := toshift(N - 2 DOWNTO 0) & toshift(N - 1);
                    EXIT WHEN i = (mask AND DATA2); -- rotate foor the effective value (exclung then the full multiple rotations)
                END LOOP;
                OUTSHIFT <= toshift;

            WHEN FUNCRR =>
                toshift := DATA1;
                rotateright : FOR i IN 0 TO N - 1 LOOP
                    toshift := toshift(0) & toshift(N - 1 DOWNTO 1);
                    EXIT WHEN i = (mask AND DATA2);
                END LOOP;
                OUTSHIFT <= toshift; -- rotate right

            WHEN OTHERS => NULL;
        END CASE;
    END PROCESS PSHFT;

END BEHAVIOR;