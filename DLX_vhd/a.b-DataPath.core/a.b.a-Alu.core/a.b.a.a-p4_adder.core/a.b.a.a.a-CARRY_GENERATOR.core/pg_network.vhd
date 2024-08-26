LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY pg_network IS
    PORT (
        a : IN STD_LOGIC;
        b : IN STD_LOGIC;
        p_out : OUT STD_LOGIC; -- Pi:j 
        g_out : OUT STD_LOGIC -- Gi:j 
    );
END pg_network;

ARCHITECTURE behavior OF pg_network IS
BEGIN
    p_out <= a XOR b;
    g_out <= a AND b;
END behavior;
