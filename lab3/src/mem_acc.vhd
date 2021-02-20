LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY mem_acc IS
       PORT(	NPC_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
			NEW_ADDR	: IN std_logic_vector(nb-1 DOWNTO 0);		-- from EXECUTE STAGE
       		ALU_RES	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
       		IMM_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
		RD_i		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from EXECUTE STAGE
       		ALU_to_MUX	: IN std_logic_vector(1 DOWNTO 0);						-- from CU
		NPC_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to WRITE BACK STAGE
       		DATA_MUX	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to WRITE BACK STAGE
		RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0));	-- to WRITE BACK STAGE
END ENTITY;


ARCHITECTURE struct OF mem_acc IS

	
	COMPONENT mux31 IS
        GENERIC(NBIT : positive := 32);
        PORT(   A       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                B       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                C       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                SEL     : IN std_logic_vector(1 DOWNTO 0);
                Y       : OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;


BEGIN

	NPC_o		<= NPC_i;
	RD_o		<= RD_i;

	aluMux	: mux31 GENERIC MAP(NBIT => nb) PORT MAP(NEW_ADDR, IMM_i, ALU_RES, ALU_to_MUX, DATA_MUX);

END ARCHITECTURE;
