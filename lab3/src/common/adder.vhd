LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.mypackage.all;

ENTITY adder IS
	PORT(	A	: IN std_logic_vector(nb-1 DOWNTO 0);
	    	B	: IN std_logic_vector(nb-1 DOWNTO 0);
		S	: OUT std_logic_vector(nb-1 DOWNTO 0));
END ENTITY;



ARCHITECTURE behav OF adder IS
BEGIN
	S <= std_logic_vector(unsigned(A) + unsigned(B));
END ARCHITECTURE;
