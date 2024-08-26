LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.alu_types.ALL;

------------------------------------------------------------------------------------------------------

ENTITY MUX_4to1 IS
    GENERIC (N : INTEGER := 1); --number of bits
    PORT (
        A, B, C, D : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0); --data inputs
        SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --selection input
        Y : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0) --data output
    );
END ENTITY MUX_4to1;

------------------------------------------------------------------------------------------------------

ARCHITECTURE behavioral OF MUX_4to1 IS
BEGIN

    WITH SEL SELECT Y <=
        A WHEN "00",
        B WHEN "01",
        C WHEN "10",
        D WHEN OTHERS;

END ARCHITECTURE behavioral;