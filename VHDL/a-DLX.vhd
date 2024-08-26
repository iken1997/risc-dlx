LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE work.CONSTANTS.ALL;
USE WORK.myTypes.ALL;
USE WORK.alu_types.ALL;

-------------------------------------------------------------------------------------------------------

ENTITY DLX IS
  GENERIC (
    IR_SIZE : INTEGER := 32; -- Instruction Register Size
    PC_SIZE : INTEGER := 32 -- Program Counter Size
  ); -- ALU_OPC_SIZE if explicit ALU Op Code Word Size
  PORT (
    Clk : IN STD_LOGIC;
    Rst : IN STD_LOGIC); -- Active Low
END DLX;

-------------------------------------------------------------------------------------------------------

ARCHITECTURE dlx_rtl OF DLX IS

  -------------------------------------------------------------------------------------------------------
  ---- Components Declaration
  -------------------------------------------------------------------------------------------------------

  --Instruction Ram
  COMPONENT IRAM
    GENERIC (
      RAM_DEPTH : INTEGER;
      I_SIZE : INTEGER);
    PORT (
      Rst : IN STD_LOGIC;
      EN : STD_LOGIC;
      RDY : STD_LOGIC;
      Addr : IN STD_LOGIC_VECTOR(I_SIZE - 1 DOWNTO 0);
      Dout : OUT STD_LOGIC_VECTOR(I_SIZE - 1 DOWNTO 0)
    );
  END COMPONENT;

  -- Data Ram
  COMPONENT DRAM
    GENERIC (
      MEM_SIZE : INTEGER := 512;
      NADD : INTEGER := 6
    );
    PORT (
      DATA_IN : IN WORD;
      DATA_OUT : OUT WORD;
      ADDR : IN STD_LOGIC_VECTOR (NADD - 1 DOWNTO 0);
      EN : STD_LOGIC;
      RDY : STD_LOGIC;
      R_EN : STD_LOGIC;
      W_EN : STD_LOGIC;
      CLK : STD_LOGIC;
      RST : STD_LOGIC
    );
  END COMPONENT;

  -- Datapath
  COMPONENT datapath
    GENERIC (
      Nbit : INTEGER := 32
    );
    PORT (
      --Data signals
      IRAM_ADDR : OUT WORD;
      IRAM_IN : IN WORD;
      DRAM_ADDR : OUT STD_LOGIC_VECTOR (DRAM_ADDR_SIZE - 1 downto 0);
      DRAM_IN : IN WORD;
      DRAM_OUT : OUT WORD;
      --Control signals
      IRAM_EN : OUT STD_LOGIC;
      IRAM_READY : OUT STD_LOGIC;
      DRAM_EN : OUT STD_LOGIC;
      DRAM_READY : OUT STD_LOGIC;
      DRAM_EN_R : OUT STD_LOGIC;
      DRAM_EN_W : OUT STD_LOGIC;

      --instr signals 
      IR_OUT : OUT STD_LOGIC_VECTOR (IR_SIZE - 1 DOWNTO 0);

      --Control Word signals
      -- IF Control Signal
      PC_LATCH_EN : IN STD_LOGIC;
      IR_LATCH_EN : IN STD_LOGIC; -- Instruction Register Latch Enable
      NPC_LATCH_EN : IN STD_LOGIC; -- NextProgramCounter Register Latch Enable
      EN_STAGE1 : IN STD_LOGIC;
      RST_STAGE1 : IN STD_LOGIC;

      -- ID Control Signals
      EN_STAGE2 : IN STD_LOGIC; -- Register A Latch Enable
      RST_STAGE2 : IN STD_LOGIC;
      RD1 : IN STD_LOGIC;
      RD2 : IN STD_LOGIC;
      SEL_M_I : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

      -- EX Control Signals
      EN_STAGE3 : IN STD_LOGIC;
      RST_STAGE3 : IN STD_LOGIC;
      M1_SEL : IN STD_LOGIC; -- MUX-A Sel
      M2_SEL : IN STD_LOGIC; -- MUX-B Sel
      EQZ : IN STD_LOGIC; -- Branch if (not) Equal to Zero
      -- ALU Operation Code
      ALU_OPCODE : IN TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

      -- MEM Control Signals
      EN_STAGE4 : IN STD_LOGIC;
      RST_STAGE4 : IN STD_LOGIC;
      JUMP_EN : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
      PC_J_EN : IN STD_LOGIC; -- Program Counter Latch Enable in case of jump/branch

      -- WB Control signals
      EN_STAGE5 : IN STD_LOGIC;
      RST_STAGE5 : IN STD_LOGIC;
      M3_SEL : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
      SEL_WR_RF : IN STD_LOGIC;
      RF_WE : IN STD_LOGIC; -- Register File Write Enable

      --clock and reset
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC
    );
  END COMPONENT;

  -- Control Unit
  COMPONENT dlx_cu
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
  END COMPONENT;
  -------------------------------------------------------------------------------------------------------
  ---- Signals Declaration
  -------------------------------------------------------------------------------------------------------

  -- Instruction Register (IR) and Program Counter (PC) declaration
  SIGNAL IR : STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);
  SIGNAL PC : STD_LOGIC_VECTOR(PC_SIZE - 1 DOWNTO 0);

  -- Instruction Ram Bus signals
  SIGNAL IRam_DOut : STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);
  SIGNAL IRAM_EN_i, IRAM_RDY_i : STD_LOGIC;

  -- Datapath Bus signals
  SIGNAL PC_BUS : STD_LOGIC_VECTOR(PC_SIZE - 1 DOWNTO 0);
  SIGNAL DRAM_IN_i, DRAM_OUT_i : WORD;
  SIGNAL DRAM_ADDR_i : STD_LOGIC_VECTOR (DRAM_ADDR_SIZE - 1 DOWNTO 0);
  SIGNAL DRAM_RDY_i, DRAM_EN_i : STD_LOGIC;

  -- Control Unit Bus signals

  -- IF Control Signal
  SIGNAL PC_LATCH_EN_i : STD_LOGIC;
  SIGNAL IR_LATCH_EN_i : STD_LOGIC; -- Instruction Register Latch Enable
  SIGNAL NPC_LATCH_EN_i : STD_LOGIC; -- NextProgramCounter Register Latch Enable
  SIGNAL EN_STAGE1_i : STD_LOGIC;
  SIGNAL RST_STAGE1_i : STD_LOGIC;

  -- ID Control Signals
  SIGNAL EN_STAGE2_i : STD_LOGIC; -- Register A Latch Enable
  SIGNAL RST_STAGE2_i : STD_LOGIC;
  SIGNAL RD1_i : STD_LOGIC;
  SIGNAL RD2_i : STD_LOGIC;
  SIGNAL SEL_M_I_i : STD_LOGIC_VECTOR (1 DOWNTO 0);

  -- EX Control Signals
  SIGNAL EN_STAGE3_i : STD_LOGIC;
  SIGNAL RST_STAGE3_i : STD_LOGIC;
  SIGNAL M1_SEL_i : STD_LOGIC; -- MUX-A Sel
  SIGNAL M2_SEL_i : STD_LOGIC; -- MUX-B Sel
  SIGNAL EQZ_i : STD_LOGIC; -- Branch if (not) Equal to Zero
  -- ALU Operation Code
  SIGNAL ALU_OPCODE_i : TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

  -- MEM Control Signals
  SIGNAL EN_STAGE4_i : STD_LOGIC;
  SIGNAL RST_STAGE4_i : STD_LOGIC;
  SIGNAL DRAM_RE_i : STD_LOGIC;
  SIGNAL DRAM_WE_i : STD_LOGIC; -- Data RAM Write Enable
  SIGNAL JUMP_EN_i : STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
  SIGNAL PC_J_EN_i : STD_LOGIC; -- Program Counter Latch Enable in case of jump/branch

  -- WB Control signals
  SIGNAL EN_STAGE5_i : STD_LOGIC;
  SIGNAL RST_STAGE5_i : STD_LOGIC;
  SIGNAL M3_SEL_i : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
  SIGNAL SEL_WR_RF_i : STD_LOGIC;
  SIGNAL RF_WE_i : STD_LOGIC; -- Register File Write Enable
  -- Data Ram Bus signals
BEGIN -- DLX

  -- This is the input to program counter: currently zero 
  -- so no uptade of PC happens
  -- TO BE REMOVED AS SOON AS THE DATAPATH IS INSERTED!!!!!
  -- a proper connection must be made here if more than one
  -- instruction must be executed

  -- purpose: Instruction Register Process
  -- type   : sequential
  -- inputs : Clk, Rst, IRam_DOut, IR_LATCH_EN_i
  -- outputs: IR_IN_i
  IR_P : PROCESS (Clk, Rst)
  BEGIN -- process IR_P
    IF Rst = '0' THEN -- asynchronous reset (active low)
      IR <= (OTHERS => '0');
    ELSIF Clk'event AND Clk = '1' THEN -- rising clock edge
      IF (IR_LATCH_EN_i = '1') THEN
        IR <= IRam_DOut;
      END IF;
    END IF;
  END PROCESS IR_P;
  -- purpose: Program Counter Process
  -- type   : sequential
  -- inputs : Clk, Rst, PC_BUS
  -- outputs: IRam_Addr
  PC_P : PROCESS (Clk, Rst)
  BEGIN -- process PC_P
    IF Rst = '0' THEN -- asynchronous reset (active low)
      PC <= (OTHERS => '0');
    ELSIF Clk'event AND Clk = '1' THEN -- rising clock edge
      IF (PC_LATCH_EN_i = '1') THEN
        PC <= PC_BUS;
      END IF;
    END IF;
  END PROCESS PC_P;

  -- Control Unit Instantiation
  CU_I : dlx_cu
  PORT MAP(
    Clk => Clk,
    Rst => Rst,
    IR_IN => IR,
    PC_LATCH_EN => PC_LATCH_EN_i,
    IR_LATCH_EN => IR_LATCH_EN_i,
    NPC_LATCH_EN => NPC_LATCH_EN_i,

    EN_STAGE1 => EN_STAGE1_i,
    RST_STAGE1 => RST_STAGE1_i,

    -- ID Control Signals
    EN_STAGE2 => EN_STAGE2_i,
    RST_STAGE2 => RST_STAGE2_i,
    RD1 => RD1_i,
    RD2 => RD2_i,
    SEL_M_I => SEL_M_I_i,

    -- EX Control Signals
    EN_STAGE3 => EN_STAGE3_i,
    RST_STAGE3 => RST_STAGE3_i,
    M1_SEL => M1_SEL_i, -- MUX-A Sel
    M2_SEL => M2_SEL_i, -- MUX-B Sel
    EQZ => EQZ_i, -- Branch if (not) Equal to Zero
    -- ALU Operation Code
    ALU_OPCODE => ALU_OPCODE_i,

    -- MEM Control Signals
    EN_STAGE4 => EN_STAGE4_i,
    RST_STAGE4 => EN_STAGE4_i,
    DRAM_RE => DRAM_RE_i,
    DRAM_WE => DRAM_WE_i, -- Data RAM Write Enable
    JUMP_EN => JUMP_EN_i, -- JUMP Enable Signal for PC input MUX
    PC_J_EN => PC_J_EN_i, -- Program Counter Latch Enable in case of jump/branch

    -- WB Control signals
    EN_STAGE5 => EN_STAGE5_i,
    RST_STAGE5 => RST_STAGE4_i,
    M3_SEL => M3_SEL_i, -- Write Back MUX Sel
    SEL_WR_RF => SEL_WR_RF_i,
    RF_WE => RF_WE_i);

  -- DATAPATH Instantiation
  datapath_I : datapath
  GENERIC MAP(
    Nbit => 32
  )
  PORT MAP(
    IRAM_ADDR => PC_BUS,
    IRAM_IN => IRam_DOut,
    DRAM_ADDR => DRAM_ADDR_i,
    DRAM_IN => DRAM_IN_i,
    DRAM_OUT => DRAM_OUT_i,
    IRAM_EN => IRAM_EN_i,
    IRAM_READY => IRAM_RDY_i,
    DRAM_EN => EN_STAGE4_i,
    DRAM_READY => DRAM_RDY_i,
    DRAM_EN_W => DRAM_WE_i,
    DRAM_EN_R => DRAM_RE_i,
    IR_OUT => IR,
    PC_LATCH_EN => PC_LATCH_EN_i,
    IR_LATCH_EN => IR_LATCH_EN_i,
    NPC_LATCH_EN => NPC_LATCH_EN_i,
    EN_STAGE1 => EN_STAGE1_i,
    RST_STAGE1 => RST_STAGE1_i,
    EN_STAGE2 => EN_STAGE2_i,
    RST_STAGE2 => RST_STAGE2_i,
    RD1 => RD1_i,
    RD2 => RD2_i,
    SEL_M_I => SEL_M_I_i,
    EN_STAGE3 => EN_STAGE3_i,
    RST_STAGE3 => RST_STAGE3_i,
    M1_SEL => M1_SEL_i,
    M2_SEL => M2_SEL_i,
    EQZ => EQZ_i,
    ALU_OPCODE => ALU_OPCODE_i,
    EN_STAGE4 => EN_STAGE4_i,
    RST_STAGE4 => RST_STAGE4_i,
    JUMP_EN => JUMP_EN_i,
    PC_J_EN => PC_J_EN_i,
    EN_STAGE5 => EN_STAGE5_i,
    RST_STAGE5 => RST_STAGE5_i,
    M3_SEL => M3_SEL_i,
    SEL_WR_RF => SEL_WR_RF_i,
    RF_WE => RF_WE_i,
    CLK => CLK,
    RST => RST
  );

  -- Instruction Ram Instantiation
  IRAM_I : IRAM
GENERIC MAP(
RAM_DEPTH => 48,
I_SIZE => 32
)
  PORT MAP(
    EN => EN_STAGE2_i,
    RDY => IRAM_RDY_i,
    Rst => Rst,
    Addr => PC,
    Dout => IRam_DOut);

    IRAM_EN_i <= EN_STAGE2_i;

  -- Data Ram Instantiation
  DRAM_I : DRAM
  GENERIC MAP(
    MEM_SIZE => DRAM_SIZE,
    NADD => DRAM_ADDR_SIZE
  )
  PORT MAP(
    DATA_IN => DRAM_IN_i,
    DATA_OUT => DRAM_OUT_i,
    ADDR => DRAM_ADDR_i,
    EN => DRAM_EN_i,
    RDY => DRAM_RDY_i,
    R_EN => DRAM_RE_i,
    W_EN => DRAM_WE_i,
    CLK => CLK,
    RST => RST
  );

  DRAM_EN_i <= EN_STAGE4_i;

END dlx_rtl;