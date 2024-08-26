LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

USE WORK.CONSTANTS.ALL;
USE work.myTypes.ALL;
USE work.alu_types.ALL;
USE work.ROCACHE_PKG.ALL;
USE work.RWCACHE_PKG.ALL;
ENTITY DLX IS
  GENERIC (
    IR_SIZE : INTEGER := 32; -- Instruction Register Size
    PC_SIZE : INTEGER := 32 -- Program Counter Size
  );
  PORT (
    -- Inputs
    CLK : IN STD_LOGIC; -- Clock
    RST : IN STD_LOGIC; -- Reset:Active-High

    IRAM_ADDRESS : OUT STD_LOGIC_VECTOR(Instr_size - 1 DOWNTO 0);
    IRAM_ISSUE : OUT STD_LOGIC;
    IRAM_READY : IN STD_LOGIC;
    IRAM_DATA : IN STD_LOGIC_VECTOR (2*Data_size - 1 DOWNTO 0); --(2 * Data_size - 1 DOWNTO 0);

    DRAM_ADDRESS : OUT STD_LOGIC_VECTOR(Instr_size - 1 DOWNTO 0);
    DRAM_ISSUE : OUT STD_LOGIC;
    DRAM_READNOTWRITE : OUT STD_LOGIC;
    DRAM_READY : IN STD_LOGIC;
    DRAM_DATA : INOUT STD_LOGIC_VECTOR (Data_size - 1 DOWNTO 0) --(2 * Data_size - 1 DOWNTO 0)
  );
END DLX;

-- This architecture is currently not complete
-- it just includes:
-- instruction register (complete)
-- program counter (complete)
-- instruction ram memory (complete)
ARCHITECTURE dlx_rtl OF DLX IS

  --------------------------------------------------------------------
  -- Components Declaration
  --------------------------------------------------------------------

  -- Instruction Ram And Data Ram are in the TestBench and you must connect it using

  --  		IRAM_ADDRESS			: out std_logic_vector(Instr_size - 1 downto 0);
  --		IRAM_ISSUE				: out std_logic;
  --		IRAM_READY				: in std_logic;
  --		IRAM_DATA				: in std_logic_vector(2*Data_size-1 downto 0);
  --
  --		DRAM_ADDRESS			: out std_logic_vector(Instr_size-1 downto 0);
  --		DRAM_ISSUE				: out std_logic;
  --		DRAM_READNOTWRITE		: out std_logic;
  --		DRAM_READY				: in std_logic;
  --		DRAM_DATA				: inout std_logic_vector(2*Data_size-1 downto 0)

  -- Datapath
  COMPONENT datapath
    GENERIC (
      Nbit : INTEGER := 32
    );
    PORT (
      --Data signals
      IRAM_ADDR : OUT WORD;
      IRAM_IN   : IN WORD;
      DRAM_ADDR : OUT STD_LOGIC_VECTOR (DRAM_ADDR_SIZE - 1 DOWNTO 0);
      DRAM_IN   : IN WORD;
      DRAM_OUT  : OUT WORD;

      --Control Word signals
      -- IF Control Signal
      PC_LATCH_EN  : IN STD_LOGIC;
      IR_LATCH_EN  : IN STD_LOGIC; -- Instruction Register Latch Enable
      NPC_LATCH_EN : IN STD_LOGIC; -- NextProgramCounter Register Latch Enable
      EN_STAGE1    : IN STD_LOGIC;

      -- ID Control Signals
      EN_STAGE2 : IN STD_LOGIC; -- Register A Latch Enable
      RD1       : IN STD_LOGIC;
      RD2       : IN STD_LOGIC;
      SEL_M_I   : IN STD_LOGIC_VECTOR (1 DOWNTO 0);

      -- EX Control Signals
      EN_STAGE3 : IN STD_LOGIC;
      M1_SEL    : IN STD_LOGIC; -- MUX-A Sel
      M2_SEL    : IN STD_LOGIC; -- MUX-B Sel
      EQZ       : IN STD_LOGIC; -- Branch if (not) Equal to Zero
      -- ALU Operation Code
      ALU_OPCODE : IN TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

      -- MEM Control Signals
      EN_STAGE4 : IN STD_LOGIC;
      JUMP_EN   : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
      PC_J_EN   : IN STD_LOGIC;                     -- Program Counter Latch Enable in case of jump/branch

      -- WB Control signals
      EN_STAGE5 : IN STD_LOGIC;
      M3_SEL    : IN STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
      SEL_WR_RF : IN STD_LOGIC;
      RF_WE     : IN STD_LOGIC; -- Register File Write Enable

      --clock and reset
      CLK : IN STD_LOGIC;
      RST : IN STD_LOGIC
    );
  END COMPONENT;

  -- Control Unit
  COMPONENT dlx_cu
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
  END COMPONENT;
  ----------------------------------------------------------------
  -- Signals Declaration
  ----------------------------------------------------------------

  
  -- Instruction Register (IR) and Program Counter (PC) declaration
  SIGNAL IR : STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0);
  SIGNAL PC : STD_LOGIC_VECTOR(PC_SIZE - 1 DOWNTO 0);

  -- Instruction Ram Bus signals
  SIGNAL IRam_DOut : STD_LOGIC_VECTOR(IR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
  SIGNAL IRAM_EN_i, IRAM_RDY_i : STD_LOGIC;

  -- Datapath Bus signals
  SIGNAL PC_BUS                : STD_LOGIC_VECTOR(PC_SIZE - 1 DOWNTO 0);
  SIGNAL DRAM_IN_i, DRAM_OUT_i : WORD;
  SIGNAL DRAM_ADDR_i           : STD_LOGIC_VECTOR (DRAM_ADDR_SIZE - 1 DOWNTO 0);
  SIGNAL DRAM_RDY_i, DRAM_EN_i : STD_LOGIC;

  -- Control Unit Bus signals

  -- IF Control Signal
  SIGNAL PC_LATCH_EN_i  : STD_LOGIC;
  SIGNAL IR_LATCH_EN_i  : STD_LOGIC; -- Instruction Register Latch Enable
  SIGNAL NPC_LATCH_EN_i : STD_LOGIC; -- NextProgramCounter Register Latch Enable
  SIGNAL EN_STAGE1_i    : STD_LOGIC;

  -- ID Control Signals
  SIGNAL EN_STAGE2_i : STD_LOGIC; -- Register A Latch Enable
  SIGNAL RD1_i       : STD_LOGIC;
  SIGNAL RD2_i       : STD_LOGIC;
  SIGNAL SEL_M_I_i   : STD_LOGIC_VECTOR (1 DOWNTO 0);

  -- EX Control Signals
  SIGNAL EN_STAGE3_i : STD_LOGIC;
  SIGNAL M1_SEL_i    : STD_LOGIC; -- MUX-A Sel
  SIGNAL M2_SEL_i    : STD_LOGIC; -- MUX-B Sel
  SIGNAL EQZ_i       : STD_LOGIC; -- Branch if (not) Equal to Zero
  -- ALU Operation Code
  SIGNAL ALU_OPCODE_i : TYPE_OP; -- choose between implicit or exlicit coding, like std_logic_vector(ALU_OPC_SIZE -1 downto 0);

  -- MEM Control Signals
  SIGNAL EN_STAGE4_i : STD_LOGIC;
  SIGNAL DRAM_RE_i   : STD_LOGIC;
  SIGNAL DRAM_WE_i   : STD_LOGIC;                     -- Data RAM Write Enable
  SIGNAL JUMP_EN_i   : STD_LOGIC_VECTOR (1 DOWNTO 0); -- JUMP Enable Signal for PC input MUX
  SIGNAL PC_J_EN_i   : STD_LOGIC;                     -- Program Counter Latch Enable in case of jump/branch

  -- WB Control signals
  SIGNAL EN_STAGE5_i : STD_LOGIC;
  SIGNAL M3_SEL_i    : STD_LOGIC_VECTOR (1 DOWNTO 0); -- Write Back MUX Sel
  SIGNAL SEL_WR_RF_i : STD_LOGIC;
  SIGNAL RF_WE_i     : STD_LOGIC; -- Register File Write Enable
  -- Data Ram Bus signals
BEGIN -- DLX

  PC_BUS <=  ("00" & PC(PC'left DOWNTO PC'right +2));
  -- Control Unit Instantiation
  CU_I : dlx_cu
  PORT MAP(
    Clk          => Clk,
    Rst          => Rst,
    IR_IN        => IRam_DOut,
    PC_LATCH_EN  => PC_LATCH_EN_i,
    IR_LATCH_EN  => IR_LATCH_EN_i,
    NPC_LATCH_EN => NPC_LATCH_EN_i,

    EN_STAGE1 => EN_STAGE1_i,

    -- ID Control Signals
    EN_STAGE2 => EN_STAGE2_i,

    RD1     => RD1_i,
    RD2     => RD2_i,
    SEL_M_I => SEL_M_I_i,

    -- EX Control Signals
    EN_STAGE3 => EN_STAGE3_i,

    M1_SEL => M1_SEL_i, -- MUX-A Sel
    M2_SEL => M2_SEL_i, -- MUX-B Sel
    EQZ    => EQZ_i,    -- Branch if (not) Equal to Zero
    -- ALU Operation Code
    ALU_OPCODE => ALU_OPCODE_i,

    -- MEM Control Signals
    EN_STAGE4 => EN_STAGE4_i,
    DRAM_RE   => DRAM_RE_i,
    DRAM_WE   => DRAM_WE_i, -- Data RAM Write Enable
    JUMP_EN   => JUMP_EN_i, -- JUMP Enable Signal for PC input MUX
    PC_J_EN   => PC_J_EN_i, -- Program Counter Latch Enable in case of jump/branch

    -- WB Control signals
    EN_STAGE5 => EN_STAGE5_i,
    M3_SEL    => M3_SEL_i, -- Write Back MUX Sel
    SEL_WR_RF => SEL_WR_RF_i,
    RF_WE     => RF_WE_i);

  -- DATAPATH Instantiation
  datapath_I : datapath
  GENERIC MAP(
    Nbit => 32
  )
  PORT MAP(
    IRAM_ADDR    => PC,
    IRAM_IN      => IRAM_DOut,
    DRAM_ADDR    => DRAM_ADDR_i,
    DRAM_IN      => DRAM_OUT_i,
    DRAM_OUT     => DRAM_OUT_i,
    PC_LATCH_EN  => PC_LATCH_EN_i,
    IR_LATCH_EN  => IR_LATCH_EN_i,
    NPC_LATCH_EN => NPC_LATCH_EN_i,
    EN_STAGE1    => EN_STAGE1_i,

    EN_STAGE2 => EN_STAGE2_i,

    RD1       => RD1_i,
    RD2       => RD2_i,
    SEL_M_I   => SEL_M_I_i,
    EN_STAGE3 => EN_STAGE3_i,

    M1_SEL     => M1_SEL_i,
    M2_SEL     => M2_SEL_i,
    EQZ        => EQZ_i,
    ALU_OPCODE => ALU_OPCODE_i,
    EN_STAGE4  => EN_STAGE4_i,

    JUMP_EN   => JUMP_EN_i,
    PC_J_EN   => PC_J_EN_i,
    EN_STAGE5 => EN_STAGE5_i,

    M3_SEL    => M3_SEL_i,
    SEL_WR_RF => SEL_WR_RF_i,
    RF_WE     => RF_WE_i,
    CLK       => CLK,
    RST       => RST
  );


  IRAM_ADDRESS <= PC;
  IRAM_ISSUE <= EN_STAGE1_i;
  IRAM_RDY_i <= IRAM_READY;
  IRam_DOut <= IRAM_DATA(WORD_SIZE -1 downto 0);
  --
  DRAM_ADDRESS <= DRAM_ADDR_i;
  DRAM_ISSUE <= DRAM_RE_i or DRAM_WE_i;
  DRAM_READNOTWRITE <= DRAM_RE_i OR NOT(DRAM_WE_i); --if read is DRAM_RE is enabled the DRAM reads if DRAM_RE is 0 the DRAM can be written
  DRAM_RDY_i <= DRAM_READY;
  DRAM_DATA <= DRAM_OUT_i;
  DRAM_IN_i <= DRAM_DATA;

END dlx_rtl;