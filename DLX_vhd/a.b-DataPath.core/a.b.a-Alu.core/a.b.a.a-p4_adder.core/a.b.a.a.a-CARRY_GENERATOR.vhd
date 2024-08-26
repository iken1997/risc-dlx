LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

ENTITY CARRY_GENERATOR IS
    GENERIC (
        NBIT : INTEGER := 32;
        NBIT_PER_BLOCK : INTEGER := 4
    );
    PORT (
        A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
        B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
        Cin : IN STD_LOGIC;
        Co : OUT STD_LOGIC_VECTOR((NBIT/NBIT_PER_BLOCK) - 1 DOWNTO 0));
END CARRY_GENERATOR;

ARCHITECTURE BEHAVIORAL OF CARRY_GENERATOR IS
    CONSTANT NBLOCKS : INTEGER := NBIT/NBIT_PER_BLOCK;
    CONSTANT LEVELS : INTEGER := INTEGER(CEIL(LOG2(REAL(NBIT))));

    TYPE SignalVector IS ARRAY (LEVELS DOWNTO 0) OF STD_LOGIC_VECTOR(NBIT DOWNTO 0);

    SIGNAL p : SignalVector;
    SIGNAL g : SignalVector;
    COMPONENT g_block IS
        PORT (
            p1 : IN STD_LOGIC; -- Pi:k 
            g1 : IN STD_LOGIC;--Gi:k
            g2 : IN STD_LOGIC;-- Gk-1:j
            g_out : OUT STD_LOGIC -- Gi:j 
        );

    END COMPONENT;

    COMPONENT pg_block IS
        PORT (
            p1 : IN STD_LOGIC; -- Pi:k 
            g1 : IN STD_LOGIC;--Gi:k
            p2 : IN STD_LOGIC; -- Pk-1:j 
            g2 : IN STD_LOGIC;-- Gk-1:j
            p_out : OUT STD_LOGIC; -- Pi:j 
            g_out : OUT STD_LOGIC -- Gi:j  
        );
    END COMPONENT;

    COMPONENT pg_network IS
        PORT (
            a : IN STD_LOGIC;
            b : IN STD_LOGIC;
            p_out : OUT STD_LOGIC; -- Pi:j 
            g_out : OUT STD_LOGIC -- Gi:j 
        );
    END COMPONENT;

BEGIN
    p(0)(0) <= '0';
    g(0)(0) <= Cin;
    g(0)(1) <= (A(0) AND B(0)) OR ((A(0) XOR B(0)) AND g(0)(0)); -- Generate Block with added Cin logic
    pgNetwork : FOR i IN 2 TO NBIT GENERATE -- generate other blocks of the PG network
        PGNET : pg_network
        PORT MAP(a => A(i - 1), b => B(i - 1), p_out => p(0)(i), g_out => g(0)(i));
    END GENERATE;

    tree : FOR L IN 1 TO LEVELS GENERATE --generate the CLA SPARSE TREE

        row : FOR i IN 1 TO NBIT GENERATE -- generate row

            fist_part : IF (L <= INTEGER(log2(REAL(NBIT_PER_BLOCK)))) GENERATE -- if L < log2(NBIT) the tree logic is simpler 

                Gedge : IF (i = 2 ** L) GENERATE -- generate the mandatory gblock for the line
                    Gi : g_block
                    PORT MAP(p1 => p(L - 1)(i), g1 => g(L - 1)(i), g2 => g(L - 1)(i - 2 ** (L - 1)), g_out => g(L)(i));
                END GENERATE;

                G_cout : IF (i MOD NBIT_PER_BLOCK = 0 AND i < 2 ** L AND i > 2 ** (L - 1)) GENERATE --generate additional gblocks if needed
                    Gn : g_block
                    PORT MAP(p1 => p(L - 1)(i), g1 => g(L - 1)(i), g2 => g(L - 1)(2 ** (L - 1)), g_out => g(L)(i));

                END GENERATE;

                PG_row : IF ((i MOD 2 ** L = 0) AND (i > 2 ** L)) GENERATE -- generate pg blocks at multiples of 2^L different from the Gblock index
                    PGi : pg_block
                    PORT MAP(p1 => p(L - 1)(i), g1 => g(L - 1)(i), p2 => p(L - 1)(i - 2 ** (L - 1)), g2 => g(L - 1)(i - 2 ** (L - 1)), p_out => p(L)(i), g_out => g(L)(i));
                END GENERATE;

            END GENERATE;

            second_part : IF (L > INTEGER(log2(REAL(NBIT_PER_BLOCK)))) GENERATE -- second part needs additional conditions for the additional blocks

                BLOCKS : IF (((i MOD 2 ** L > 2 ** (L - 1)) OR (i MOD 2 ** L = 0)) AND (i MOD NBIT_PER_BLOCK = 0)) GENERATE

                    GBLOCKS : IF (i <= 2 ** L) GENERATE
                        Gi2 : g_block
                        PORT MAP(p1 => p(L - 1)(i), g1 => g(L - 1)(i), g2 => g(L - 1)(2 ** (L - 1)), g_out => g(L)(i));
                    END GENERATE;

                    PGBLOCKS : IF (i > 2 ** L) GENERATE
                        PGi2 : pg_block
                        PORT MAP(p1 => p(L - 1)(i), g1 => g(L - 1)(i), p2 => p(L - 1)((i - 1)/(2 ** (L - 1)) * 2 ** (L - 1)), g2 => g(L - 1)((i - 1)/(2 ** (L - 1)) * 2 ** (L - 1)), p_out => p(L)(i), g_out => g(L)(i));
                    END GENERATE;

                END GENERATE;

                WIRES : IF ((i MOD 2 ** L <= 2 ** (L - 1)) AND (i MOD 2 ** L /= 0) AND (i MOD NBIT_PER_BLOCK = 0)) GENERATE
                    p(L)(i) <= p(L - 1)(i);
                    g(L)(i) <= g(L - 1)(i);
                END GENERATE;

            END GENERATE;

            last_line : IF (L = LEVELS AND (i mod NBIT_PER_BLOCK = 0)) GENERATE
                Co((i/NBIT_PER_BLOCK)-1) <= g(L)(i);
            END GENERATE;
        END GENERATE;
    END GENERATE; -- tree

    

END BEHAVIORAL;