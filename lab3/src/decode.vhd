LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY decode IS
	PORT(	CLK	: IN std_logic;
	    	RST_n	: IN std_logic;
		WR	: IN std_logic;						-- from CU
		PC_i	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from FETCH STAGE
		NPC_i	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from FETCH STAGE
		INSTR	: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);		-- from INSTRUCTION MEMORY
		WR_ADDR	: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from WRITE BACK STAGE
		WR_DATA	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from WRITE BACK STAGE
		PC_o	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
		NPC_o	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
		OPCODE	: OUT std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);		-- to CU
		FUNC3	: OUT std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);		-- to CU
		FUNC7_30: OUT std_logic;					-- to CU
		DATA1	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
		DATA2	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
		IMM_o	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
		RS1_o	: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to EXECUTE STAGE&CU
		RS2_o	: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to EXECUTE STAGE&CU
		RD_o	: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0));	-- to EXECUTE STAGE
END ENTITY;


ARCHITECTURE struct OF decode IS


	COMPONENT register_file IS
		PORT(	CLK	: IN std_logic;
		    	RST_n	: IN std_logic;
			WR	: IN std_logic;
			ADD_WR	: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			ADD_RD1	: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			ADD_RD2	: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			DATA_IN	: IN std_logic_vector(nb-1 DOWNTO 0);
			DATA_OUT1:OUT std_logic_vector(nb-1 DOWNTO 0);
			DATA_OUT2:OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;



	COMPONENT immGen IS
		PORT(	INSTR	: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);
		    	IMMED	: OUT std_logic_vector(nb-1 DOWNTO 0));
	END COMPONENT;


	
	SIGNAL rs1_addr	: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAL rs2_addr	: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);

BEGIN

	PC_o		<= PC_i;
	NPC_o		<= NPC_i;
	OPCODE		<= INSTR(OPCODE_SIZE-1 DOWNTO 0);
	FUNC3		<= INSTR(FUNC3_END DOWNTO FUNC3_START);
	FUNC7_30	<= INSTR(30);
	rs1_addr	<= INSTR(RS1_END DOWNTO RS1_START);
	rs2_addr	<= INSTR(RS2_END DOWNTO RS2_START);
	RS1_o		<= rs1_addr;
	RS2_o		<= rs2_addr;
	RD_o		<= INSTR(RD_END DOWNTO RD_START);


	reg_file	: register_file PORT MAP(CLK, RST_n, WR, WR_ADDR, rs1_addr, rs2_addr, WR_DATA, DATA1, DATA2);
	immediate_gen	: immGen PORT MAP(INSTR, IMM_o);

END ARCHITECTURE;
