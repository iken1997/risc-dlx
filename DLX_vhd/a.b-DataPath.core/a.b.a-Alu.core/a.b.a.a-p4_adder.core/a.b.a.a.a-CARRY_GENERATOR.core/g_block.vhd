LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY g_block IS
    PORT (
        p1 : IN STD_LOGIC; -- Pi:k 
        g1 : IN STD_LOGIC;--Gi:k
        g2 : IN STD_LOGIC;-- Gk-1:j
        g_out : OUT STD_LOGIC -- Gi:j 
    );

END g_block;

ARCHITECTURE behavior OF g_block IS
BEGIN
    g_out <= g1 OR (p1 AND g2);
END ARCHITECTURE;