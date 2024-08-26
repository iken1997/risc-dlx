library ieee; 
use ieee.std_logic_1164.all; 
use ieee.std_logic_unsigned.all;
use work.constants.all;

entity carry_select_block is 
	generic (NBIT: integer:= NumBit);
	Port (	INPUT_1:	In	std_logic_vector(NBIT-1 downto 0);
		    INPUT_2:	In	std_logic_vector(NBIT-1 downto 0);
		    Ci_sel:	In	std_logic; -- carry out of the previous stage, used for selecting the "right" assumption
		    SUM:	Out	std_logic_vector(NBIT-1 downto 0));
		    --Co:	Out	std_logic); isn't needed because the carry out is provided to the other block by a carry_generator_block 
end carry_select_block; 


architecture STRUCTURAL of carry_select_block is
	
component MUX21_GENERIC is
GENERIC (NBIT: integer:= NBIT
		);
	Port (	A:	In	std_logic_vector(NBIT-1 downto 0) ;
			B:	In	std_logic_vector(NBIT-1 downto 0);
			SEL:	In	std_logic;
			Y:	Out	std_logic_vector(NBIT-1 downto 0));
end component;

component RCA is 
	generic (
			 NBIT: integer:= NBIT);
	Port (	
		A:	In	std_logic_vector(NBIT-1 downto 0);
		B:	In	std_logic_vector(NBIT-1 downto 0);
		Ci:	In	std_logic;
		S:	Out	std_logic_vector(NBIT-1 downto 0);
		Co:	Out	std_logic);
end component; 


  signal SUM_0 : std_logic_vector(NBIT-1 downto 0);
  signal SUM_1 : std_logic_vector(NBIT-1 downto 0);
  signal Co_signal: std_logic;

begin

 
  ADDER0:RCA -- instantiate a rca assuming the carry in equal to '0'  
	  generic map (NBIT => NBIT) 
	  Port Map (A => INPUT_1, B => INPUT_2, Ci => '0', S => SUM_0, Co => Co_signal); -- COMPONENT=>SIGNAL
  
  ADDER1:RCA -- instantiate a rca assuming the carry in equal to '1'  
	  generic map (NBIT => NBIT) 
	  Port Map (A => INPUT_1, B => INPUT_2, Ci => '1', S => SUM_1, Co => Co_signal); -- COMPONENT=>SIGNAL
  	

	MUX: MUX21_GENERIC -- instantiate MUX for selecting the right "assumption", i.e. if the carry in is equal to '1' or '0'
	  generic map (NBIT => NBIT) 
	  Port Map (A => SUM_0, B => SUM_1, SEL => Ci_sel, Y => SUM); -- COMPONENT=>SIGNAL

end STRUCTURAL;



