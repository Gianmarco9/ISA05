LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.mypackage.all;

ENTITY mux41 IS
	GENERIC(NBIT : positive := 32);
	PORT(	A	: IN std_logic_vector(NBIT-1 DOWNTO 0);
	    	B	: IN std_logic_vector(NBIT-1 DOWNTO 0);
		C	: IN std_logic_vector(NBIT-1 DOWNTO 0);
		D	: IN std_logic_vector(NBIT-1 DOWNTO 0);
		SEL	: IN std_logic_vector(1 DOWNTO 0);
		Y	: OUT std_logic_vector(NBIT-1 DOWNTO 0));
END ENTITY;



ARCHITECTURE behav OF mux41 IS
BEGIN

mux4_to_1: PROCESS(A, B, C, D, SEL)
	BEGIN
		CASE SEL IS
			WHEN "00"	=>
				Y <= A;
			WHEN "01"	=>
				Y <= B;
			WHEN "10"	=>
				Y <= C;
			WHEN OTHERS	=>
				Y <= D;
		END CASE;
	END PROCESS;
END ARCHITECTURE;
