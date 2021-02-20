LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

ENTITY mux21 IS
	GENERIC(NBIT : positive := 32);
	PORT (	A	: IN std_logic_vector(NBIT-1 downto 0) ;
		B	: IN std_logic_vector(NBIT-1 downto 0);
		SEL	: IN std_logic;
		Y	: OUT std_logic_vector(NBIT-1 downto 0));
END ENTITY;


architecture behav of mux21 is
begin
	Y <= A when SEL='1' else B;

end behav;
