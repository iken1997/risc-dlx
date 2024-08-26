onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {CLOCK & RESET}
add wave -noupdate /tb_dlx/CLK
add wave -noupdate /tb_dlx/RST
add wave -noupdate /tb_dlx/dlx_inst/CU_I/OPERATION
add wave -noupdate -divider FETCH
add wave -noupdate -expand -group {PC MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/mux_PC/A
add wave -noupdate -expand -group {PC MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/mux_PC/B
add wave -noupdate -expand -group {PC MUX} /tb_dlx/dlx_inst/datapath_I/mux_PC/SEL
add wave -noupdate -expand -group {PC MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/mux_PC/Y
add wave -noupdate -expand -group NPC -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_NPC
add wave -noupdate -expand -group NPC -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_NPC1
add wave -noupdate -expand -group NPC -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_NPC2
add wave -noupdate -expand -group NPC -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_NPC3
add wave -noupdate -expand -group NPC -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_NPC4
add wave -noupdate -radix unsigned /tb_dlx/dlx_inst/datapath_I/Q_PC
add wave -noupdate -radix hexadecimal /tb_dlx/dlx_inst/datapath_I/Q_IR
add wave -noupdate -divider DECODE
add wave -noupdate -radix unsigned /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_RD1
add wave -noupdate -radix unsigned /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_RD2
add wave -noupdate -expand -group {REG FILE} /tb_dlx/dlx_inst/datapath_I/reg_file/ENABLE
add wave -noupdate -expand -group {REG FILE} /tb_dlx/dlx_inst/datapath_I/reg_file/RD1
add wave -noupdate -expand -group {REG FILE} /tb_dlx/dlx_inst/datapath_I/reg_file/RD2
add wave -noupdate -expand -group {REG FILE} /tb_dlx/dlx_inst/datapath_I/reg_file/WR
add wave -noupdate -expand -group {REG FILE} -radix unsigned /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_WR
add wave -noupdate -expand -group {REG FILE} -radix unsigned /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_RD1
add wave -noupdate -expand -group {REG FILE} -radix unsigned /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_RD2
add wave -noupdate -expand -group {REG FILE} -radix decimal /tb_dlx/dlx_inst/datapath_I/reg_file/DATAIN
add wave -noupdate -expand -group {REG FILE} -radix decimal /tb_dlx/dlx_inst/datapath_I/reg_file/OUT1
add wave -noupdate -expand -group {REG FILE} -radix decimal /tb_dlx/dlx_inst/datapath_I/reg_file/OUT2
add wave -noupdate -expand -group {REG FILE} -radix decimal /tb_dlx/dlx_inst/datapath_I/reg_file/REGISTERS
add wave -noupdate -group {IMM MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/IMM_MUX/A
add wave -noupdate -group {IMM MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/IMM_MUX/B
add wave -noupdate -group {IMM MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/IMM_MUX/C
add wave -noupdate -group {IMM MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/IMM_MUX/D
add wave -noupdate -group {IMM MUX} /tb_dlx/dlx_inst/datapath_I/IMM_MUX/SEL
add wave -noupdate -group {IMM MUX} -radix decimal /tb_dlx/dlx_inst/datapath_I/IMM_MUX/Y
add wave -noupdate -divider EXECUTE
add wave -noupdate /tb_dlx/dlx_inst/CU_I/OPERATION
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/ALU_OPCODE
add wave -noupdate -expand -group ALU /tb_dlx/dlx_inst/datapath_I/A_LU/FUNC
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/DATA1
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/DATA2
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/OUTALU
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/OUTALU_shift
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/OUTALU_s
add wave -noupdate -expand -group ALU -radix decimal /tb_dlx/dlx_inst/datapath_I/A_LU/OUTALU_lu
add wave -noupdate -expand -group ALU /tb_dlx/dlx_inst/datapath_I/A_LU/B_i
add wave -noupdate -expand -group ALU /tb_dlx/dlx_inst/datapath_I/A_LU/Cin_s
add wave -noupdate -expand -group ALU /tb_dlx/dlx_inst/datapath_I/A_LU/Cout_s
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_A
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_B
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_ALU
add wave -noupdate -group {MUX DATA 1} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX1/A
add wave -noupdate -group {MUX DATA 1} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX1/B
add wave -noupdate -group {MUX DATA 1} /tb_dlx/dlx_inst/datapath_I/MUX1/SEL
add wave -noupdate -group {MUX DATA 1} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX1/Y
add wave -noupdate -expand -group {MUX DATA 2} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX2/A
add wave -noupdate -expand -group {MUX DATA 2} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX2/B
add wave -noupdate -expand -group {MUX DATA 2} /tb_dlx/dlx_inst/datapath_I/MUX2/SEL
add wave -noupdate -expand -group {MUX DATA 2} -radix decimal /tb_dlx/dlx_inst/datapath_I/MUX2/Y
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/EN_B
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/EN_A
add wave -noupdate -divider MEMORY
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/datapath_I/Q_B2
add wave -noupdate -label {Q MEM} -radix decimal /tb_dlx/dlx_inst/datapath_I/MEM/Q
add wave -noupdate -group DRAM -radix decimal /tb_dlx/dlx_inst/DRAM_I/DATA_IN
add wave -noupdate -group DRAM -radix decimal /tb_dlx/dlx_inst/DRAM_I/DATA_OUT
add wave -noupdate -group DRAM -radix decimal /tb_dlx/dlx_inst/DRAM_I/ADDR
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/EN
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/RDY
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/R_EN
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/W_EN
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/CLK
add wave -noupdate -group DRAM /tb_dlx/dlx_inst/DRAM_I/RST
add wave -noupdate -divider {WRITE BACK}
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/SEL_M3
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/reg_file/WR
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/reg_file/ADD_WR
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/datapath_I/Y_M3
add wave -noupdate /tb_dlx/dlx_inst/IRAM_I/Rst
add wave -noupdate /tb_dlx/dlx_inst/IRAM_I/EN
add wave -noupdate /tb_dlx/dlx_inst/IRAM_I/RDY
add wave -noupdate -radix decimal /tb_dlx/dlx_inst/IRAM_I/Addr
add wave -noupdate /tb_dlx/dlx_inst/IRAM_I/Dout
add wave -noupdate /tb_dlx/dlx_inst/IRAM_I/IRAM_mem
add wave -noupdate -expand -group branchreg /tb_dlx/dlx_inst/datapath_I/BRANCH_REG/D
add wave -noupdate -expand -group branchreg /tb_dlx/dlx_inst/datapath_I/BRANCH_REG/Q
add wave -noupdate -expand -group branchreg /tb_dlx/dlx_inst/datapath_I/BRANCH_REG/EN
add wave -noupdate -expand -group branchreg /tb_dlx/dlx_inst/datapath_I/BRANCH_REG/CLK
add wave -noupdate -expand -group branchreg /tb_dlx/dlx_inst/datapath_I/BRANCH_REG/RST
add wave -noupdate -expand -group mux4 /tb_dlx/dlx_inst/datapath_I/MUX4/A
add wave -noupdate -expand -group mux4 /tb_dlx/dlx_inst/datapath_I/MUX4/B
add wave -noupdate -expand -group mux4 /tb_dlx/dlx_inst/datapath_I/MUX4/SEL
add wave -noupdate -expand -group mux4 /tb_dlx/dlx_inst/datapath_I/MUX4/Y
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/A
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/B
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/C
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/D
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/SEL
add wave -noupdate -expand -group muxbranch /tb_dlx/dlx_inst/datapath_I/MUX_BRANCH/Y
add wave -noupdate /tb_dlx/dlx_inst/datapath_I/JumpTaken
add wave -noupdate -expand -group DF1 /tb_dlx/dlx_inst/datapath_I/DF1/EN
add wave -noupdate -expand -group DF1 /tb_dlx/dlx_inst/datapath_I/DF1/IN1
add wave -noupdate -expand -group DF1 /tb_dlx/dlx_inst/datapath_I/DF1/IN2
add wave -noupdate -expand -group DF1 /tb_dlx/dlx_inst/datapath_I/DF1/INTARGET
add wave -noupdate -expand -group DF1 /tb_dlx/dlx_inst/datapath_I/DF1/OUTPUT
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {181950 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 336
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {177872 ps} {247592 ps}
