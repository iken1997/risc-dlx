LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.std_logic_arith.ALL;
USE work.myTypes.ALL;
USE ieee.numeric_std.ALL;
USE work.alu_types.ALL;
USE WORK.CONSTANTS.ALL;

ENTITY dlx_cu IS
    GENERIC (
        MICROCODE_MEM_SIZE : INTEGER := 2 ** 7 - 1 -- Microcode Memory Size
    );
    PORT (
        Clk : IN STD_LOGIC; -- Clock
        Rst : IN STD_LOGIC; -- Reset:Active-Low
        -- Instruction Register
        IR_IN : IN STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);

        -- IF Control Signal
        PC_LATCH_EN  : OUT STD_LOGIC;
        IR_LATCH_EN  : OUT STD_LOGIC; -- Instruction Register Latch Enable
        NPC_LATCH_EN : OUT STD_LOGIC; -- NextProgramCounter Register Latch Enable
        EN_STAGE1    : OUT STD_LOGIC;

        -- ID Control Signals
        EN_STAGE2 : OUT STD_LOGIC; -- Register A Latch Enable
        RD1       : OUT STD_LOGIC;
        RD2       : OUT STD_LOGIC;
        SEL_M_I   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

        -- EX Control Signals
        EN_STAGE3 : OUT STD_LOGIC;
        M1_SEL    : OUT STD_LOGIC; -- MUX-A Sel
        M2_SEL    : OUT STD_LOGIC; -- MUX-B Sel
        EQZ       : OUT STD_LOGIC; -- Branch if (not) Equal to Zero
        -- ALU Operation Code
        ALU_OPCODE : OUT TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

        -- MEM Control Signals
        EN_STAGE4 : OUT STD_LOGIC;
        DRAM_RE   : OUT STD_LOGIC;
        DRAM_WE   : OUT STD_LOGIC;                     -- Data RAM Write Enable
        JUMP_EN   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
        PC_J_EN   : OUT STD_LOGIC;                     -- Program Counter Latch Enable in case of jump/branch

        -- WB Control signals
        EN_STAGE5 : OUT STD_LOGIC;
        M3_SEL    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
        SEL_WR_RF : OUT STD_LOGIC;
        RF_WE     : OUT STD_LOGIC -- Register File Write Enable
    );
END dlx_cu;

ARCHITECTURE dlx_cu_hw OF dlx_cu IS

    COMPONENT reg IS
        GENERIC (Nbit : INTEGER := 16); --number of bits
        PORT (
            D   : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);  --data input
            Q   : OUT STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0); --data output
            EN  : IN STD_LOGIC;                             --enable active high
            CLK : IN STD_LOGIC;                             --clock
            RST : IN STD_LOGIC                              --asynchronous reset active low
        );
    END COMPONENT;

    TYPE mem_array IS ARRAY (INTEGER RANGE 0 TO MICROCODE_MEM_SIZE - 1) OF STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);
    SIGNAL cw_mem : mem_array;

    SIGNAL OPERATION : OPCODE;

    -- control word is shifted to the correct stage
    SIGNAL cw1   : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);      -- first stage
    SIGNAL cw2   : STD_LOGIC_VECTOR(CW_SIZE - 1 - 4 DOWNTO 0);  -- second stage
    SIGNAL cw3   : STD_LOGIC_VECTOR(CW_SIZE - 1 - 9 DOWNTO 0);  -- third stage
    SIGNAL cw4   : STD_LOGIC_VECTOR(CW_SIZE - 1 - 18 DOWNTO 0); -- fourth stage
    SIGNAL cw5   : STD_LOGIC_VECTOR(CW_SIZE - 1 - 24 DOWNTO 0); -- fifth stage
    SIGNAL stall : STD_LOGIC;

BEGIN

    cw_mem <= (
        B"1011_10000_0100_00000_000000_10000", -- NOP 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_01000_100000_10101", -- RTYPE_SLL 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_01001_100000_10101", -- RTYPE_SRL 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_00001_100000_10101", -- RTYPE_ADD 
        B"1111_11100_1100_00001_100000_10101", -- RTYPE_ADDU 
        B"1111_11100_1100_00010_100000_10101", -- RTYPE_SUB 
        B"1111_11100_1100_00010_100000_10101", -- RTYPE_SUBU 
        B"1111_11100_1100_00100_100000_10101", -- RTYPE_AND 
        B"1111_11100_1100_00101_100000_10101", -- RTYPE_OR 
        B"1111_11100_1100_00110_100000_10101", -- RTYPE_XOR 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_10001_100000_10101", -- RTYPE_SNE 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_01110_100000_10101", -- RTYPE_SLE 
        B"1111_11100_1100_01100_100000_10101", -- RTYPE_SGE 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1100_01111_100000_10101", -- RTYPE_SLEU 
        B"1111_11100_1100_01101_100000_10101", -- RTYPE_SGEU 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_10001_1010_00001_100101_00000", -- J 
        B"1111_10001_1010_00001_100101_11011", -- JAL 
        B"1111_11010_1011_00001_100011_00000", -- BEQZ 
        B"1111_11010_1010_00001_100011_00000", -- BNEZ 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_00001_100000_10101", -- ITYPE_ADD 
        B"1111_11000_1110_00001_100000_10101", -- ITYPE_ADDU 
        B"1111_11000_1110_00010_100000_10101", -- ITYPE_SUB 
        B"1111_11000_1110_00010_100000_10101", -- ITYPE_SUBU 
        B"1111_11000_1110_00100_100000_10101", -- ITYPE_AND 
        B"1111_11000_1110_00101_100000_10101", -- ITYPE_OR 
        B"1111_11000_1110_00110_100000_10101", -- ITYPE_XOR 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_01000_100000_10101", -- ITYPE_SLL 
        B"1011_10000_0100_00000_000000_10000", -- NOP_2 
        B"1111_11000_1110_01001_100000_10101", -- ITYPE_SRL 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_10001_100000_10101", -- ITYPE_SNE 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_01110_100000_10101", -- ITYPE_SLE 
        B"1111_11000_1110_01100_100000_10101", -- ITYPE_SGE 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_00001_110000_10001", -- LW 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11100_1110_00001_101000_00000", -- SW 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"1111_11000_1110_01111_100000_10101", -- ITYPE_SLEU 
        B"1111_11000_1110_01101_100000_10101", -- ITYPE_SGEU 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000", -- No_op 
        B"0000_00000_0000_00000_000000_00000"  -- No_op 

        );
    OPERATION <= instr_decode(IR_IN) WHEN stall = '0' ELSE
        NOP;

    -- if jump or branch instruction encountered, next 3 instuction are nop, to evaluate the jump
    stalling : PROCESS (OPERATION, CLK, RST)
        VARIABLE count : INTEGER := 0;
    BEGIN
        IF (Clk'event AND Clk = '1') THEN
            IF (OPERATION = J OR OPERATION = JAL OR OPERATION = BEQZ OR OPERATION = BNEZ) THEN
                stall <= '1';
                count := 3;
            ELSE
                IF (Rst = '0') THEN
                    stall <= '1';
                ELSIF (count = 0) THEN
                    stall <= '0';
                ELSE
                    count := count - 1;
                END IF;
            END IF;
        END IF;
    END PROCESS;
    cw1 <= cw_mem(getIndex(OPERATION));

    PC_LATCH_EN  <= cw1(28);
    IR_LATCH_EN  <= cw1(27);
    NPC_LATCH_EN <= cw1(26);
    EN_STAGE1    <= cw1(25);

    STAGE2 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 4
    )
    PORT MAP(
        D   => cw1 (CW_SIZE - 1 - 4 DOWNTO 0),
        Q   => cw2,
        EN  => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE2 <= cw2(24);

    RD1     <= cw2(23);
    RD2     <= cw2(22);
    SEL_M_I <= cw2 (21 DOWNTO 20);

    STAGE3 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 9
    )
    PORT MAP(
        D   => cw2 (CW_SIZE - 1 - 9 DOWNTO 0),
        Q   => cw3,
        EN  => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE3 <= cw3(19);

    M1_SEL <= cw3(18);
    M2_SEL <= cw3(17);
    EQZ    <= cw3(16);
    -- ALU Operation Code
    ALU_OPCODE <= func_decode(cw3(15 DOWNTO 11));

    STAGE4 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 18
    )
    PORT MAP(
        D   => cw3 (CW_SIZE - 1 - 18 DOWNTO 0),
        Q   => cw4,
        EN  => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE4 <= cw4 (10);

    DRAM_RE <= cw4 (9);
    DRAM_WE <= cw4 (8);
    JUMP_EN <= cw4 (7 DOWNTO 6);
    PC_J_EN <= cw4 (5);

    STAGE5 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 24
    )
    PORT MAP(
        D   => cw4 (CW_SIZE - 1 - 24 DOWNTO 0),
        Q   => cw5,
        EN  => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE5 <= cw5 (4);

    M3_SEL    <= cw5 (3 DOWNTO 2);
    SEL_WR_RF <= cw5 (1);
    RF_WE     <= cw5 (0);
END dlx_cu_hw;
