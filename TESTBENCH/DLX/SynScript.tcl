analyze -library WORK -format vhdl {constants.vhd
myTypes.vhd
alu_type.vhd
"../ALU/SHIFTER/shifter.vhd"
"../ALU/LOGIC UNIT/LOGIC_UNIT.vhd"
"../ALU/ADDER/fa.vhd"
"../ALU/ADDER/rca.vhd"
"../ALU/ADDER/g_block.vhd"
"../ALU/ADDER/pg_block.vhd"
"../ALU/ADDER/pg_network.vhd"
"../ALU/ADDER/CARRY_GENERATOR.vhd"
"../ALU/ADDER/MUX21.vhd"
"../ALU/ADDER/MUX21_GENERIC.vhd"
"../ALU/ADDER/CarrySelectBlock.vhd"
"../ALU/ADDER/SUM_GENERATOR.vhd"
"../ALU/ADDER/p4_adder.vhd"
"../ALU/ALU.vhd"
MUX41.vhd
reg.vhd
registerfile.vhd
Data_Forwarding.vhd
Datapath.vhd
CU.vhd
a-DLX.vhd}
elaborate dlx_rtl -architecture A -library WORK
compile
report_timing > DLX_ReportTiming_noConstraints.rpt
report_power > DLX_ReportPower_noConstraints.rpt
report_power -cell > DLX_ReportPower_Cell_noConstraints.rpt
report_power -net > DLX_ReportPower_Net_noConstraints.rpt
# Define a new variable Period equal to the value of the max delay obtained
set Period 0.50 
#Forces a clock of period Period connected to the input port CLK to constrain the synthesis
create_clock -name "CLK" -period $Period {"CLK"}
compile -exact_map
#Generating the constrainted timing report
report_timing > DLX_ReportTiming_Constraints.rpt
report_power > DLX_ReportPower_Constraints.rpt
report_power -cell > DLX_ReportPower_Cell_Constraints.rpt
report_power -net > DLX_ReportPower_Net_Constraints.rpt
# saving files
write -hierarchy -format ddc -output DLX-topt.ddc
write -hierarchy -format vhdl -output DLX-topt.vhdl
write -hierarchy -format verilog -output DLX-topt.v
