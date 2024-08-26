library IEEE;

use IEEE.std_logic_1164.all;
use WORK.CONSTANTS.all;

entity MUX21 is
	Port (	A:	In	std_logic;
			B:	In	std_logic;
			SEL:In	std_logic;
			Y:	Out	std_logic);
end MUX21;

architecture structural of MUX21 is
	begin
		Y <= (A AND (NOT SEL)) OR (B AND SEL);
end structural;
