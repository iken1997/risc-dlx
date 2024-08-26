LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pg_block IS
    PORT (
        p1 : IN STD_LOGIC; -- Pi:k 
        g1 : IN STD_LOGIC;--Gi:k
        p2 : IN STD_LOGIC; -- Pk-1:j 
        g2 : IN STD_LOGIC;-- Gk-1:j
        p_out : OUT STD_LOGIC; -- Pi:j 
        g_out : OUT STD_LOGIC -- Gi:j 
    );
END pg_block;

ARCHITECTURE behavior OF pg_block IS
BEGIN
    p_out <= p1 AND p2;
    g_out <= g1 OR (p1 AND g2);
END ARCHITECTURE;