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
        MICROCODE_MEM_SIZE : INTEGER := 10 -- Microcode Memory Size
    );
    PORT (
        Clk : IN STD_LOGIC; -- Clock
        Rst : IN STD_LOGIC; -- Reset:Active-Low
        -- Instruction Register
        IR_IN : IN STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);

        -- IF Control Signal
        PC_LATCH_EN : OUT STD_LOGIC;
        IR_LATCH_EN : OUT STD_LOGIC; -- Instruction Register Latch Enable
        NPC_LATCH_EN : OUT STD_LOGIC; -- NextProgramCounter Register Latch Enable
        EN_STAGE1 : OUT STD_LOGIC;
        RST_STAGE1 : OUT STD_LOGIC;

        -- ID Control Signals
        EN_STAGE2 : OUT STD_LOGIC; -- Register A Latch Enable
        RST_STAGE2 : OUT STD_LOGIC;
        RD1 : OUT STD_LOGIC;
        RD2 : OUT STD_LOGIC;
        SEL_M_I : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

        -- EX Control Signals
        EN_STAGE3 : OUT STD_LOGIC;
        RST_STAGE3 : OUT STD_LOGIC;
        M1_SEL : OUT STD_LOGIC; -- MUX-A Sel
        M2_SEL : OUT STD_LOGIC; -- MUX-B Sel
        EQZ : OUT STD_LOGIC; -- Branch if (not) Equal to Zero
        -- ALU Operation Code
        ALU_OPCODE : OUT TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

        -- MEM Control Signals
        EN_STAGE4 : OUT STD_LOGIC;
        RST_STAGE4 : OUT STD_LOGIC;
        DRAM_RE : OUT STD_LOGIC;
        DRAM_WE : OUT STD_LOGIC; -- Data RAM Write Enable
        JUMP_EN : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
        PC_J_EN : OUT STD_LOGIC; -- Program Counter Latch Enable in case of jump/branch

        -- WB Control signals
        EN_STAGE5 : OUT STD_LOGIC;
        RST_STAGE5 : OUT STD_LOGIC;
        M3_SEL : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
        SEL_WR_RF : OUT STD_LOGIC;
        RF_WE : OUT STD_LOGIC -- Register File Write Enable
    );
END dlx_cu;

ARCHITECTURE dlx_cu_hw OF dlx_cu IS

    COMPONENT reg IS
        GENERIC (Nbit : INTEGER := 16); --number of bits
        PORT (
            D : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0); --data input
            Q : OUT STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0); --data output
            EN : IN STD_LOGIC; --enable active high
            CLK : IN STD_LOGIC; --clock
            RST : IN STD_LOGIC --asynchronous reset active low
        );
    END COMPONENT;

    TYPE mem_array IS ARRAY (INTEGER RANGE 0 TO MICROCODE_MEM_SIZE - 1) OF STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0);
    SIGNAL cw_mem : mem_array := (
    "0000000000000000000000000000000000", -- NOP 
    "1111010110010100000011000000100101", -- RTYPE_ADD
    "1111010110010100000101000000100101", -- RTYPE_SUB
    "1111010110010100001001000000100101", -- RTYPE_AND
    "1111010110010100001011000000100101", -- RTYPE_OR
    "1111010110010100001101000000100101", -- RTYPE_XOR 
    "1111010110010100010001000000100101", -- RTYPE_SLL
    "1111010110010100010011000000100101", -- RTYPE_SRL 
    "1111010110010100011000000000000000", -- RTYPE_SGE
    "1111010110010100011100000000000000", -- RTYPE_SLE
    "1111010110010100100010000000000000", -- RTYPE_SNE
    "1111010110010100011010000000000000", -- RTYPE_SGEU
    "1111010110010100011110000000000000", -- RTYPE_SLEU
    "1111010100010110000011000000100101", -- ITYPE_ADD 
    "1111010100010110000101000000100101", -- ITYPE_SUB
    "1111010100010110001001000000100101", -- ITYPE_AND
    "1111010100010110001011000000100101", -- ITYPE OR
    "1111010100010110001101000000100101", -- ITYPE_XOR
    "1111010100010110010001000000100101", -- ITYPE_SLL 
    "1111010100010110010011000000100101", -- ITYPE_SRL
    "1111010100010110011000000000000000", -- ITYPE_SGE
    "1111010100010110011100000000000000", -- ITYPE_SLE
    "1111010100010110100010000000000000", -- ITYPE_SNE 
    "1111010100010110000011001000000000", -- SW
    "1111010100010110000011010000100001", -- LW 
    "1111010101010011000011000011000000", -- BEQZ 
    "1111010101010010000011000011000000", -- BNEZ 
    "1111010000110010000011000101000000", -- J 
    "1111010000110010000011000101101011", -- JAL
    "1111010100010110011010000000000000", -- ITYPE_SGEU
    "1111010100010110011110000000000000" -- ITYPE_SLEU
    );

    SIGNAL OPERATION : OPCODE;

    -- control word is shifted to the correct stage
    SIGNAL cw1 : STD_LOGIC_VECTOR(CW_SIZE - 1 DOWNTO 0); -- first stage
    SIGNAL cw2 : STD_LOGIC_VECTOR(CW_SIZE - 1 - 5 DOWNTO 0); -- second stage
    SIGNAL cw3 : STD_LOGIC_VECTOR(CW_SIZE - 1 - 11 DOWNTO 0); -- third stage
    SIGNAL cw4 : STD_LOGIC_VECTOR(CW_SIZE - 1 - 21 DOWNTO 0); -- fourth stage
    SIGNAL cw5 : STD_LOGIC_VECTOR(CW_SIZE - 1 - 28 DOWNTO 0); -- fifth stage

BEGIN

    cw1 <= cw_mem(getIndex(OPERATION));
    PC_LATCH_EN <= cw1(CW_SIZE - 1);
    IR_LATCH_EN <= cw1(CW_SIZE - 2);
    NPC_LATCH_EN <= cw1(CW_SIZE - 3);
    EN_STAGE1 <= cw1(CW_SIZE - 4);
    RST_STAGE1 <= cw1(CW_SIZE - 5);

    STAGE2 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 5
    )
    PORT MAP(
        D => cw1 (CW_SIZE - 1 - 5 DOWNTO 0),
        Q => cw2,
        EN => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE2 <= cw2(CW_SIZE - 6);
    RST_STAGE2 <= cw2(CW_SIZE - 7);
    RD1 <= cw2(CW_SIZE - 8);
    RD2 <= cw2(CW_SIZE - 9);
    SEL_M_I <= cw2 (CW_SIZE - 10 DOWNTO CW_SIZE - 10 - 1);

    STAGE3 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 11
    )
    PORT MAP(
        D => cw2 (CW_SIZE - 1 - 11 DOWNTO 0),
        Q => cw3,
        EN => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE3 <= cw3(CW_SIZE - 12);
    RST_STAGE3 <= cw3(CW_SIZE - 13);
    M1_SEL <= cw3(CW_SIZE - 14);
    M2_SEL <= cw3(CW_SIZE - 15);
    EQZ <= cw3(CW_SIZE - 16);
    -- ALU Operation Code
    ALU_OPCODE <= func_decode(cw3(CW_SIZE - 17 DOWNTO CW_SIZE - 17 - 4));

    STAGE4 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 21
    )
    PORT MAP(
        D => cw3 (CW_SIZE - 1 - 21 DOWNTO 0),
        Q => cw4,
        EN => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE4 <= cw4 (CW_SIZE - 22);
    RST_STAGE4 <= cw4 (CW_SIZE - 23);
    DRAM_RE <= cw4 (CW_SIZE - 24);
    DRAM_WE <= cw4 (CW_SIZE - 25);
    JUMP_EN <= cw4 (CW_SIZE - 26 DOWNTO CW_SIZE - 26 - 1);
    PC_J_EN <= cw4 (CW_SIZE - 28);

    STAGE5 : reg
    GENERIC MAP(
        Nbit => CW_SIZE - 28
    )
    PORT MAP(
        D => cw4 (CW_SIZE - 1 - 28 DOWNTO 0),
        Q => cw5,
        EN => '1',
        CLK => CLK,
        RST => RST
    );

    EN_STAGE5 <= cw5 (CW_SIZE - 29);
    RST_STAGE5 <= cw5 (CW_SIZE - 30);
    M3_SEL <= cw5 (CW_SIZE - 31 DOWNTO CW_SIZE - 31 - 1);
    SEL_WR_RF <= cw5 (CW_SIZE - 33);
    RF_WE <= cw5 (CW_SIZE - 34);

    OPERATION <= instr_decode(IR_IN);
END dlx_cu_hw;