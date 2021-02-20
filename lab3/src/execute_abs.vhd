LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY execute_abs IS
	PORT(	PC		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DECODE STAGE 
		NPC_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DECODE STAGE 
	    	OPA_MUX		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DECODE STAGE 
		OPB_MUX		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DECODE STAGE 
		IMM_MUX		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DECODE STAGE
		ALU_RES_forw	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
		WR_DATA_forw	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from WRITE BACK STAGE
		RD_i		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DECODE STAGE 
		ALU_CTRL	: IN std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);	-- from CU
		ALU_Src		: IN std_logic;						-- from CU
		EN_ABS		: IN std_logic;						-- from CU
		ALU_FORW_Src1	: IN std_logic_vector(1 DOWNTO 0);			-- from CU
		ALU_FORW_Src2	: IN std_logic_vector(1 DOWNTO 0);			-- from CU
		NEW_ADDR	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		NPC_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		ALU_RES		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		ABS_RES		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		MEM_DATA	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		IMM_o 		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to MEMORY STAGE
		RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to MEMORY STAGE
		ZERO_F		: OUT std_logic);					-- to CU
END ENTITY;



ARCHITECTURE struct OF execute_abs IS



	COMPONENT mux31 IS
        GENERIC(NBIT : positive := 32);
        PORT(   A       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                B       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                C       : IN std_logic_vector(NBIT-1 DOWNTO 0);
                SEL     : IN std_logic_vector(1 DOWNTO 0);
                Y       : OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;



	COMPONENT adder IS
		PORT(	A	: IN std_logic_vector(nb-1 DOWNTO 0);
		    	B	: IN std_logic_vector(nb-1 DOWNTO 0);
			S	: OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;
	
	
	
	COMPONENT alu IS
		PORT(	ALU_CONTROL: IN std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);
		    	DATA1	: IN std_logic_vector(nb-1 DOWNTO 0);
			DATA2	: IN std_logic_vector(nb-1 DOWNTO 0);
			Z	: OUT std_logic;
			DATA_OUT: OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;
	
	
	
	COMPONENT mux21 IS
		GENERIC(NBIT	: positive := 32);
		PORT(	A	: IN std_logic_vector(NBIT-1 DOWNTO 0);
		    	B	: IN std_logic_vector(NBIT-1 DOWNTO 0);
			SEL	: IN std_logic;
			Y	: OUT std_logic_vector(NBIT-1 DOWNTO 0));
	END COMPONENT;

	COMPONENT ABS_MODULE IS
		PORT(
			EN_ABS		: IN std_logic; --from CU
			DATA_IN		: IN std_logic_vector(nb-1 DOWNTO 0); --from DP
			DATA_OUT	: OUT std_logic_vector(nb-1 DOWNTO 0) --to DP
		);
	END COMPONENT;

SIGNAL OPB, OPA	: std_logic_vector(nb-1 DOWNTO 0);
SIGNAL OPB_forw	: std_logic_vector(nb-1 DOWNTO 0);

BEGIN

	addr_add	: adder PORT MAP(PC, IMM_MUX, NEW_ADDR);

	mux1_forw	: mux31	GENERIC MAP(NBIT => nb) PORT MAP(OPA_MUX, ALU_RES_forw, WR_DATA_forw, ALU_FORW_Src1, OPA);
	mux2_forw	: mux31	GENERIC MAP(NBIT => nb) PORT MAP(OPB_MUX, ALU_RES_forw, WR_DATA_forw, ALU_FORW_Src2, OPB_forw);

	OPB_mux21	: mux21 GENERIC MAP(NBIT => nb) PORT MAP(IMM_MUX, OPB_forw, ALU_Src, OPB);
	abs_calc	: ABS_MODULE PORT MAP (EN_ABS, OPA, ABS_RES);
	alu_exec	: alu PORT MAP(ALU_CTRL, OPA, OPB, ZERO_F, ALU_RES);

	NPC_o	<= NPC_i;
	MEM_DATA<= OPB_MUX;
	IMM_o 	<= IMM_MUX;
	RD_o	<= RD_i;

END ARCHITECTURE;
