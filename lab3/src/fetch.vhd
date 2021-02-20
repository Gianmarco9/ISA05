LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.mypackage.all;

ENTITY fetch IS
	PORT(	CLK		: IN std_logic;
		RST_n		: IN std_logic;
		NEW_ADDR	: IN std_logic_vector(nb-1 DOWNTO 0);	-- from MEMORY STAGE
		EN_PC		: IN std_logic;				-- from CU
	    	PC_Src		: IN std_logic;				-- from CU
		PC		: OUT std_logic_vector(nb-1 DOWNTO 0);	-- to DECODE STAGE & to INSTRUCTION MEMORY
		NPC		: OUT std_logic_vector(nb-1 DOWNTO 0));	-- to DECODE STAGE
END ENTITY;


ARCHITECTURE struct OF fetch IS

	COMPONENT reg 
	GENERIC (N: POSITIVE := 8);
	PORT (
		  CLK:	IN STD_LOGIC;
		  RST_n:	IN STD_LOGIC;
		  EN:	IN STD_LOGIC;
		  D_IN:	IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		  D_OUT:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT adder IS
        	PORT(	A	: IN std_logic_vector(nb-1 DOWNTO 0);
			B	: IN std_logic_vector(nb-1 DOWNTO 0);
			S	: OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;



	COMPONENT mux21 IS
		GENERIC(NBIT	: positive := 32);
		PORT(	A	: IN std_logic_vector(NBIT-1 downto 0);
			B	: IN std_logic_vector(NBIT-1 downto 0);
			SEL	: IN std_logic;
			Y	: OUT std_logic_vector(NBIT-1 downto 0));
	END COMPONENT;



	SIGNAL next_PC, PC_in, PC_out	: std_logic_vector(nb-1 DOWNTO 0);

BEGIN

PC_MUX: mux21 GENERIC MAP(NBIT => nb) PORT MAP(NEW_ADDR, next_PC, PC_Src, PC_in);
PC_reg: reg GENERIC MAP(N => nb) PORT MAP(CLK, RST_n, EN_PC, PC_in, PC_out);
ADD: adder PORT MAP(PC_out, std_logic_vector(to_unsigned(4, nb)), next_PC);

PC	<= PC_out;
NPC	<= next_PC;

END ARCHITECTURE;
