LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE WORK.myTypes.ALL;
USE WORK.alu_types.ALL;

-----------------------------------------------------------------------------------------------------------

ENTITY datapath IS
    GENERIC (
        Nbit : INTEGER := 32
    );
    PORT (
        --Data signals
        IRAM_ADDR : OUT WORD;
        IRAM_IN : IN WORD;
        DRAM_ADDR : OUT WORD;
        DRAM_IN : IN WORD;
        DRAM_OUT : OUT WORD;

        --Control signals

        --instr signals 
        --Control Word signals
        -- IF Control Signal
        PC_LATCH_EN : IN STD_LOGIC;
        IR_LATCH_EN : IN STD_LOGIC; -- Instruction Register Latch Enable
        NPC_LATCH_EN : IN STD_LOGIC; -- NextProgramCounter Register Latch Enable
        EN_STAGE1 : IN STD_LOGIC;

        -- ID Control Signals
        EN_STAGE2 : IN STD_LOGIC; -- Register A Latch Enable
        RD1 : IN STD_LOGIC;
        RD2 : IN STD_LOGIC;
        SEL_M_I : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

        -- EX Control Signals
        EN_STAGE3 : IN STD_LOGIC;
        M1_SEL : IN STD_LOGIC; -- MUX-A Sel
        M2_SEL : IN STD_LOGIC; -- MUX-B Sel
        EQZ : IN STD_LOGIC; -- Branch if (not) Equal to Zero
        -- ALU Operation Code
        ALU_OPCODE : IN TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

        -- MEM Control Signals
        EN_STAGE4 : IN STD_LOGIC;
        JUMP_EN : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
        PC_J_EN : IN STD_LOGIC; -- Program Counter Latch Enable in case of jump/branch

        -- WB Control signals
        EN_STAGE5 : IN STD_LOGIC;
        M3_SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
        SEL_WR_RF : IN STD_LOGIC;
        RF_WE : IN STD_LOGIC; -- Register File Write Enable

        --clock and reset
        CLK : IN STD_LOGIC;
        RST : IN STD_LOGIC
    );
END datapath;

ARCHITECTURE structural OF datapath IS

    COMPONENT ALU IS
        GENERIC (Nbit : INTEGER := 32);
        PORT (
            FUNC : IN TYPE_OP;
            DATA1 : IN WORD;
            DATA2 : IN WORD;
            OUTALU : OUT WORD);
    END COMPONENT;

    COMPONENT RCA IS
        GENERIC (
            NBIT : INTEGER := 4
        );
        PORT (
            A : IN WORD;
            B : IN WORD;
            Ci : IN STD_LOGIC;
            S : OUT WORD;
            Co : OUT STD_LOGIC);
    END COMPONENT;

    COMPONENT register_file IS
        GENERIC (
            NADD : INTEGER := 5
        );
        PORT (
            CLK : IN STD_LOGIC;
            RESET : IN STD_LOGIC;
            ENABLE : IN STD_LOGIC;
            RD1 : IN STD_LOGIC;
            RD2 : IN STD_LOGIC;
            WR : IN STD_LOGIC;
            ADD_WR : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
            ADD_RD1 : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
            ADD_RD2 : IN STD_LOGIC_VECTOR(NADD - 1 DOWNTO 0);
            DATAIN : IN WORD;
            OUT1 : OUT WORD;
            OUT2 : OUT WORD
        );
    END COMPONENT;

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

    COMPONENT MUX21_GENERIC IS
        GENERIC (
            NBIT : INTEGER := NumBit);
        PORT (
            A : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
            B : IN STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0);
            SEL : IN STD_LOGIC;
            Y : OUT STD_LOGIC_VECTOR(NBIT - 1 DOWNTO 0));
    END COMPONENT;

    COMPONENT MUX_4to1 IS
        GENERIC (N : INTEGER := 1); --number of bits
        PORT (
            A, B, C, D : IN STD_LOGIC_VECTOR (N - 1 DOWNTO 0); --data inputs
            SEL : IN STD_LOGIC_VECTOR(1 DOWNTO 0); --selection input
            Y : OUT STD_LOGIC_VECTOR (N - 1 DOWNTO 0) --data output
        );
    END COMPONENT;

    COMPONENT DATAFORWARDING IS
        GENERIC (
            Nbit : INTEGER := 5
        );
        PORT (
            EN : STD_LOGIC;
            IN1 : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
            IN2 : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
            INTARGET : IN STD_LOGIC_VECTOR (Nbit - 1 DOWNTO 0);
            OUTPUT : OUT STD_LOGIC_VECTOR (1 DOWNTO 0)
        );
    END COMPONENT;

    --register input and output signals
    SIGNAL D_PC, Q_PC, D_NPC, PCADD_s, Q_NPC, Q_NPC1, Q_NPC2, Q_NPC3, Q_NPC4, D_I, Q_I, D_A, Q_A, D_B, Q_B, Q_B2, D_ALU, Q_ALU, Q_ALU1, Q_MEM, IR_IN : WORD;

    --Control Unit signals Register
    SIGNAL EN_PC, EN_NPC,  EN_IR, EN_I, EN_A, EN_B, EN_B2, EN_ALU, EN_ALU1, EN_MEM : STD_LOGIC;

    --Control Unit signals register file
    SIGNAL EN_RD1, EN_RD2, EN_RF, EN_WR : STD_LOGIC;

    --Control Unit Signal for destination registers
    SIGNAL EN_WR_REG1, EN_WR_REG2, EN_WR_REG3 : STD_LOGIC;

    --signal for RD 
    SIGNAL Q1, Q2, Q3, DEST : STD_LOGIC_VECTOR(N_BitReg - 1 DOWNTO 0);

    --signal for RF
    SIGNAL ADDR_WR_RF : STD_LOGIC_VECTOR(N_BitReg - 1 DOWNTO 0);

    --signal for sign extension and IR
    SIGNAL Q_IR, Q_IR_16, Q_IR_26, Q_IR_16_B : WORD;
  
    --MUX in/out signals
    SIGNAL Y_M1, Y_M2, Y_M3, Y_M4 : WORD;

    --BRANCH condition reg
    SIGNAL EN_BRANCH : STD_LOGIC;
    SIGNAL Q_BRANCH, JumpTaken, SEL_M4 : STD_LOGIC_VECTOR (0 DOWNTO 0);

    --MUX sel signals
    SIGNAL SEL_M1, SEL_M2, SEL_MPC : STD_LOGIC;
    SIGNAL SEL_M3 : STD_LOGIC_VECTOR (1 DOWNTO 0);

    --ADD_PC signals
    SIGNAL Co_NPC : STD_LOGIC;

    SIGNAL CNT_out : STD_LOGIC;

    SIGNAL RST_n : STD_LOGIC;

    --signals for data forwarding and related mux
    SIGNAL RF_RA_IN, RF_RB_IN : STD_LOGIC_VECTOR(WORD_SIZE - 1 DOWNTO 0);
    SIGNAL MUX_DF1_SEL, MUX_DF2_SEL, MUX_DF2_SEL_i : STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN
    RST_n <= NOT(RST); --reset active high
    SEL_MPC <= JUMP_EN(1) OR JUMP_EN(0);

    --IF stage
    --registers instantiation
    mux_PC : MUX21_GENERIC
    GENERIC MAP(
        NBIT => NBIT
    )
    PORT MAP(
        A => PCADD_s,
        B => Y_M4,
        SEL => SEL_MPC,
        Y => D_NPC
    );

    PC : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_NPC,
        Q => Q_PC,
        EN => EN_PC,
        CLK => CLK,
        RST => RST
    );

    IRAM_ADDR <= Q_PC;

    --ADDER FOR NEXT INSTRUCTION  
    PC_ADD : RCA
    GENERIC MAP(
        NBIT => Nbit
    )
    PORT MAP(
        A => Q_NPC,
        B => WORD_4,
        Ci => '0',
        S => PCADD_s,
        Co => Co_NPC
    );
    --we used 4 different because i need the right value of the NPC at the MEM e WB stage so i insert different register in order to pipline the values
    NPC : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => D_NPC,
        Q => Q_NPC,
        EN => EN_NPC,
        CLK => CLK,
        RST => RST
    );

    NPC1 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_NPC,
        Q => Q_NPC1,
        EN => EN_PC,
        CLK => CLK,
        RST => RST
    );

    NPC2 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_NPC1,
        Q => Q_NPC2,
        EN => EN_NPC,
        CLK => CLK,
        RST => RST
    );

    NPC3 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_NPC2,
        Q => Q_NPC3,
        EN => EN_NPC,
        CLK => CLK,
        RST => RST
    );
    NPC4 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_NPC3,
        Q => Q_NPC4,
        EN => EN_NPC,
        CLK => CLK,
        RST => RST
    );


    IR : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => IRAM_IN,
        Q => Q_IR,
        EN => EN_IR,
        CLK => CLK,
        RST => RST
    );
    --ID Stage
    --register
    A : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => D_A,
        Q => Q_A,
        EN => EN_A,
        CLK => CLK,
        RST => RST
    );

    --we used 3 reg  because I need the right value of the RB at the MEM stage so i insert different register in order to pipline the values
    B : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => D_B,
        Q => Q_B,
        EN => EN_B,
        CLK => CLK,
        RST => RST
    );

    B1 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_B,
        Q => Q_B2,
        EN => EN_B2,
        CLK => CLK,
        RST => RST
    );

    --sign extension:
    --in case of instructions that involves a imm the immediate value is on 16 bit
    Q_IR_16 <= STD_LOGIC_VECTOR(resize(signed(Q_IR(IMM_OFFSET - 1 DOWNTO 0)), WORD_SIZE));
    --in case of jump the immediate value is on 26 bit
    Q_IR_26 <= STD_LOGIC_VECTOR(resize(signed(Q_IR(IMM_J_OFFSET - 1 DOWNTO 0)), WORD_SIZE));
    --in case of jump the immediate value is on 16 bit
    Q_IR_16_B <= STD_LOGIC_VECTOR(resize(signed(Q_IR(IMM_OFFSET - 1 DOWNTO 0)), WORD_SIZE));

    IMM_MUX : MUX_4to1
    GENERIC MAP(
        N => Nbit
    )
    PORT MAP(
        A => Q_IR_16,
        B => Q_IR_26,
        C => Q_IR_16_B,
        D => (OTHERS => '0'),
        SEL => SEL_M_I,
        Y => D_I
    );

    IMM : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => D_I,
        Q => Q_I,
        EN => EN_I,
        CLK => CLK,
        RST => RST
    );

    MUX_DEST : MUX21_GENERIC
    GENERIC MAP(
        NBIT => N_BitReg
    )
    PORT MAP(
        A => Q_IR (RD_OFFSET - 1 DOWNTO RD_OFFSET - N_BitReg),
        B => Q_IR (RD_OFFSET + N_BitReg - 1 DOWNTO RD_OFFSET),
        SEL => OR_reduce(Q_IR(WORD_SIZE - 1 DOWNTO WORD_SIZE - 6)),
        Y => DEST
    );

    --we decided to use 4 different registers in order to pipeline the destination register's address so that when the writing operation is performed in the stage of WRITING BACK the correct address is used.
    ADDR_WR_REG1 : reg
    GENERIC MAP(
        Nbit => N_BitReg
    )
    PORT MAP(
        D => DEST,
        Q => Q1,
        EN => EN_WR_REG1,
        CLK => CLK,
        RST => RST
    );

    ADDR_WR_REG2 : reg
    GENERIC MAP(
        Nbit => N_BitReg
    )
    PORT MAP(
        D => Q1,
        Q => Q2,
        EN => EN_WR_REG2,
        CLK => CLK,
        RST => RST
    );

    ADDR_WR_REG3 : reg
    GENERIC MAP(
        Nbit => N_BitReg
    )
    PORT MAP(
        D => Q2,
        Q => Q3,
        EN => EN_WR_REG3,
        CLK => CLK,
        RST => RST
    );

    --MUX to select in which register we have to write if Rd or R31 in case of jump
    WR_RF_MUX : MUX21_GENERIC
    GENERIC MAP(
        NBIT => N_BitReg
    )
    PORT MAP(
        A => Q3,
        B => LAST_REG,
        SEL => SEL_WR_RF,
        Y => ADDR_WR_RF
    );

    reg_file : register_file
    GENERIC MAP(
        NADD => N_BitReg
    )
    PORT MAP(
        CLK => CLK,
        RESET => RST_n,
        ENABLE => EN_RF,
        RD1 => EN_RD1,
        RD2 => EN_RD2,
        WR => EN_WR,
        ADD_WR => ADDR_WR_RF,
        ADD_RD1 => Q_IR (R1_OFFSET - 1 DOWNTO R1_OFFSET - N_BitReg),
        ADD_RD2 => Q_IR (R2_OFFSET - 1 DOWNTO R2_OFFSET - N_BitReg),
        DATAIN => Y_M3,
        OUT1 => RF_RA_IN,
        OUT2 => RF_RB_IN
    );

    --Dataforwarding componets
    DF1 : DATAFORWARDING
    GENERIC MAP(
        Nbit => N_BitReg
    )
    PORT MAP(
        EN => '1',
        IN1 => Q1,
        IN2 => Q2,
        INTARGET => Q_IR (R1_OFFSET - 1 DOWNTO R1_OFFSET - N_BitReg),
        OUTPUT => MUX_DF1_SEL
    );

    DF2 : DATAFORWARDING
    GENERIC MAP(
        Nbit => N_BitReg
    )
    PORT MAP(
        EN => NOR_reduce(Q_IR(WORD_SIZE - 1 DOWNTO WORD_SIZE - 6)),
        IN1 => Q1,
        IN2 => Q2,
        INTARGET => Q_IR (R2_OFFSET - 1 DOWNTO R2_OFFSET - N_BitReg),
        OUTPUT => MUX_DF2_SEL
    );

    DF1_MUX : MUX_4to1
    GENERIC MAP(
        N => Nbit
    )
    PORT MAP(
        A => RF_RA_IN,
        B => D_ALU,
        C => Q_ALU,
        D => D_ALU,
        SEL => MUX_DF1_SEL,
        Y => D_A
    );
    MUX_DF2_SEL_i <= MUX_DF2_SEL WHEN OR_reduce(Q_IR(WORD_SIZE - 1 DOWNTO WORD_SIZE - 6)) = '0' ELSE
        "00";

    DF2_MUX : MUX_4to1
    GENERIC MAP(
        N => Nbit
    )
    PORT MAP(
        A => RF_RB_IN,
        B => D_ALU,
        C => Q_ALU,
        D => D_ALU,
        SEL => MUX_DF2_SEL_i,
        Y => D_B
    );

    --EXE stage

    --register

    ALU_OUT : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => D_ALU,
        Q => Q_ALU,
        EN => EN_ALU,
        CLK => CLK,
        RST => RST
    );

    --Multiplexers instantiation
    MUX1 : MUX21_GENERIC
    GENERIC MAP(
        NBIT => Nbit
    )
    PORT MAP(
        A => Q_NPC2,
        B => Q_A,
        SEL => SEL_M1,
        Y => Y_M1
    );

    MUX2 : MUX21_GENERIC
    GENERIC MAP(
        NBIT => Nbit
    )
    PORT MAP(
        A => Q_B,
        B => Q_I,
        SEL => SEL_M2,
        Y => Y_M2
    );

    --ALU instantiation
    A_LU : ALU
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        FUNC => ALU_OPCODE,
        DATA1 => Y_M1,
        DATA2 => Y_M2,
        OUTALU => D_ALU
    );

    --branch component
    --check if zero:
    Zero : PROCESS (Q_A)
        VARIABLE isZero : STD_LOGIC;
    BEGIN
        isZero := NOR_reduce(Q_A); --It is equal to one if all bit of the vector are zero
        --EQZ contains if the branch is taken when is zero (EQZ = 1) or when is not zero (EQZ = 0): 
        --example isZero = 1 EQZ = 1 -> jump condition is true then isZero exor (not EQZ) = 1,
        --example isZero = 1 EQZ = 0 -> jump condition is false then isZero exor (not EQZ) = 0
        JumpTaken(0) <= isZero XOR (NOT EQZ);
    END PROCESS Zero;

    BRANCH_REG : reg
    GENERIC MAP(
        Nbit => 1
    )
    PORT MAP(
        D => JumpTaken,
        Q => Q_BRANCH,
        EN => EN_BRANCH,
        CLK => CLK,
        RST => RST
    );

    MUX_BRANCH : MUX_4to1
    GENERIC MAP(
        N => 1
    )
    PORT MAP(
        A => STD_LOGIC_VECTOR(to_unsigned(0, 1)),
        B => Q_BRANCH,
        C => STD_LOGIC_VECTOR(to_unsigned(1, 1)),
        D => STD_LOGIC_VECTOR(to_unsigned(0, 1)),
        SEL => JUMP_EN,
        Y => SEL_M4
    );

    --MEM stage
    --register
    MEM : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => DRAM_IN,
        Q => Q_MEM,
        EN => EN_MEM,
        CLK => CLK,
        RST => RST
    );

    --we used another reg because we need the right value of the ALU_OUT at the WB stage so we insert different register in order to pipline the values
    ALU_OUT1 : reg
    GENERIC MAP(
        Nbit => Nbit
    )
    PORT MAP(
        D => Q_ALU,
        Q => Q_ALU1,
        EN => EN_ALU1,
        CLK => CLK,
        RST => RST
    );

    --mux
    MUX4 : MUX21_GENERIC
    GENERIC MAP(
        NBIT => Nbit
    )
    PORT MAP(
        A => Q_NPC3,
        B => Q_ALU,
        SEL => SEL_M4(0),
        Y => Y_M4
    );

    DRAM_ADDR <= Q_ALU;
    DRAM_OUT <= Q_B2;

    --WB stage

    MUX3 : MUX_4to1
    GENERIC MAP(N => Nbit) --number of bits
    PORT MAP(
        A => Q_MEM,
        B => Q_ALU1,
        C => Q_NPC4,
        D => (OTHERS => '0'),
        SEL => SEL_M3,
        Y => Y_M3
    );

    --assingment of the corresponding bit in the CW to the correct driven control signals
    EN_PC <= RST OR PC_J_EN;
    EN_NPC <= NPC_LATCH_EN;
    EN_IR <= IR_LATCH_EN;
    EN_RF <= EN_STAGE2 OR EN_STAGE5;
    EN_RD1 <= RD1;
    EN_RD2 <= RD2;
    EN_WR <= RF_WE;
    EN_A <= EN_STAGE2;
    EN_B <= EN_STAGE2;
    EN_I <= EN_STAGE2;
    EN_WR_REG1 <= EN_STAGE2;
    SEL_M1 <= M1_SEL;
    SEL_M2 <= M2_SEL;
    EN_B2 <= EN_STAGE3;
    EN_WR_REG2 <= EN_STAGE3;
    EN_ALU <= EN_STAGE3;
    EN_BRANCH <= EN_STAGE4;
    EN_MEM <= EN_STAGE4;
    EN_ALU1 <= EN_STAGE4;
    EN_WR_REG3 <= EN_STAGE4;
    SEL_M3 <= M3_SEL;
    --reset signals 

END structural;