LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY wrback IS
	PORT(	NPC		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
	    	DATA_MEM	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DATA MEMORY
		DATA_MUX	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
		RD_i		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from MEMORY STAGE
		MEM_to_MUX	: IN std_logic;						-- from CU
		MEM_to_REG	: IN std_logic;						-- from CU
		RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to DECODE STAGE
		WR_DATA		: OUT std_logic_vector(nb-1 DOWNTO 0));			-- to DECODE STAGE
END ENTITY;



ARCHITECTURE struct OF wrback IS

	COMPONENT mux21 IS
		GENERIC(NBIT	: positive := 32);
		PORT(	A	: IN std_logic_vector(nb-1 DOWNTO 0);
		    	B	: IN std_logic_vector(nb-1 DOWNTO 0);
			SEL	: IN std_logic;
			Y	: OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;

	SIGNAL MUX_to_MUX	: std_logic_vector(nb-1 DOWNTO 0);

BEGIN

	mux_from_MEM	: mux21 GENERIC MAP(NBIT => nb) PORT MAP(DATA_MEM, DATA_MUX, MEM_to_MUX, MUX_to_MUX);
	mux_to_REG	: mux21 GENERIC MAP(NBIT => nb) PORT MAP(MUX_to_MUX, NPC, MEM_to_REG, WR_DATA);

	RD_o	<= RD_i;

END ARCHITECTURE;
