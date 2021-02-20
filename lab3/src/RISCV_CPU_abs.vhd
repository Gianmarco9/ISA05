LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY RISCV_CPU_abs IS
	PORT(	CLK		: IN std_logic;
		RST_n		: IN std_logic;
		INSTR		: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);
		READ_DATA	: IN std_logic_vector(nb-1 DOWNTO 0);
		PC			: OUT std_logic_vector(nb-1 DOWNTO 0);
		ADDR_MEM	: OUT std_logic_vector(nb-1 DOWNTO 0);
		WRITE_DATA	: OUT std_logic_vector(nb-1 downto 0);
		MEM_WRITE	: OUT std_logic;
		MEM_READ	: OUT std_logic
	);	
END ENTITY;

ARCHITECTURE struct OF RISCV_CPU_abs IS

	COMPONENT CU_abs 
		PORT(
			CLK		: IN std_logic;
			RST_n		: IN std_logic;

			OPCODE 		: IN std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);
			FUNC3 		: IN std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);
			FUNC7_30	: IN std_logic;

				-- for STALL CHECK
			RS1_D		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			RS2_D		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			RD_E		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);

				-- for BRANCH CHECK
			ALU_ZFLAG	: IN std_logic;

				-- for FORWARDING CHECK
			RS1_E		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			RS2_E		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			RD_M		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
			RD_W		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);

			--------------------------------------------------------------------

			-- FETCH OUT
			EN_PC		: OUT std_logic;
			EN_FtoD		: OUT std_logic;

			-- DECODE OUT
			EN_DtoE		: OUT std_logic;

			-- EXECUTE OUT
			EN_EtoM		: OUT std_logic;
			ALU_Src		: OUT std_logic;
			EN_ABS		: OUT std_logic;
			ALU_FORW_Src1	: OUT std_logic_vector(1 DOWNTO 0);
			ALU_FORW_Src2	: OUT std_logic_vector(1 DOWNTO 0);
			ALU_CONTROL	: OUT std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);

			-- MEMORY OUT
			EN_MtoW		: OUT std_logic;
			PC_Src		: OUT std_logic;
			MEM_WRITE	: OUT std_logic;
			MEM_READ	: OUT std_logic;
			ALU_to_MUX	: OUT std_logic_vector(1 DOWNTO 0);

			-- WRITE BACK OUT
			MEM_to_MUX	: OUT std_logic;
			MEM_to_REG	: OUT std_logic;
			REG_WRITE	: OUT std_logic
		);
	END COMPONENT;

	COMPONENT DP_abs 
		PORT(	CLK		: IN std_logic;						-- from TB
			RST_n		: IN std_logic;						-- from TB

			-- FETCH IN
			EN_PC		: IN std_logic;						-- from CU
				PC_Src		: IN std_logic;						-- from CU
			INSTR		: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);		-- from INSTRUCTION MEMORY

			EN_FtoD		: IN std_logic;						-- from CU

			-- DECODE IN
			WR		: IN std_logic;						-- from CU

			EN_DtoE		: IN std_logic;						-- from CU

			-- EXECUTE IN
			ALU_CTRL	: IN std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);	-- from CU
			ALU_Src		: IN std_logic;						-- from CU
			EN_ABS		: IN std_logic;
			ALU_FORW_Src1	: IN std_logic_vector(1 DOWNTO 0);			-- from CU
			ALU_FORW_Src2	: IN std_logic_vector(1 DOWNTO 0);			-- from CU

			EN_EtoM		: IN std_logic;						-- from CU

			-- MEMORY IN
				ALU_to_MUX	: IN std_logic_vector(1 DOWNTO 0);						-- from CU
				DATA_R_MEM	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DATA MEMORY

			EN_MtoW		: IN std_logic;						-- from CU

			-- WRITE BACK IN
			MEM_to_MUX	: IN std_logic;						-- from CU
			MEM_to_REG	: IN std_logic;						-- from CU

			--------------------------------------------------------------------------------------------------

			-- FETCH OUT
			PC		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to INSTRUCTION MEMORY
			
			-- DECODE OUT
			OPCODE		: OUT std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);		-- to CU
			FUNC3		: OUT std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);		-- to CU
			RS1_D		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to CU
			RS2_D		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to CU
			FUNC7_30	: OUT std_logic;					-- to CU

			-- EXECUTE OUT
			RD_E		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);		-- to CU
			ZERO_F		: OUT std_logic;					-- to CU
			RS1_E		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);		-- to CU
			RS2_E		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);		-- to CU
			
			-- MEMORY OUT
			ADDR_MEM	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to DATA MEMORY
			DATA_W_MEM	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to DATA MEMORY
			RD_M		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);		-- to CU

			-- WRITE BACK
			RD_W		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0)	-- to CU
		);
	END COMPONENT;

--CU input/DP output
	SIGNAL OPCODE_s			: std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);
	SIGNAL FUNC3_s			: std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);
	SIGNAL RS1_D_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAL RS2_D_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAL FUNC7_30_s		: std_logic;
	SIGNAL RD_E_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAL ALU_ZFLAG_s		: std_logic;
	SIGNAL RS1_E_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAL RS2_E_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAl RD_M_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
	SIGNAl RD_W_s			: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);
--CU output/DP input	
	SIGNAL EN_PC_s			: std_logic;
	SIGNAL EN_FtoD_s		: std_logic;
	SIGNAL EN_DtoE_s		: std_logic;
	SIGNAL EN_EtoM_s		: std_logic;
	SIGNAL ALU_Src_s		: std_logic;
	SIGNAL EN_ABS_s			: std_logic; 	
	SIGNAL ALU_FORW_Src1_s	: std_logic_vector(1 DOWNTO 0);
	SIGNAL ALU_FORW_Src2_s	: std_logic_vector(1 DOWNTO 0);
	SIGNAL ALU_CONTROL_s	: std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);
	SIGNAL EN_MtoW_s		: std_logic;
	SIGNAL PC_Src_s			: std_logic;
	SIGNAL ALU_to_MUX_s		: std_logic_vector(1 DOWNTO 0);
	SIGNAL MEM_to_MUX_s		: std_logic;
	SIGNAL MEM_to_REG_s		: std_logic;
	SIGNAL REG_WRITE_s		: std_logic;

BEGIN

	control_unit	: CU_abs	PORT MAP(
											CLK				=> CLK,
											RST_n			=> RST_n,
											OPCODE			=> OPCODE_s,
											FUNC3			=> FUNC3_s,
											RS1_D			=> RS1_D_s,
											RS2_D			=> RS2_D_s,
											FUNC7_30		=> FUNC7_30_s,
											RD_E			=> RD_E_s,
											ALU_ZFLAG		=> ALU_ZFLAG_s,
											RS1_E			=> RS1_E_s,
											RS2_E			=> RS2_E_s,
											RD_M			=> RD_M_s,
											RD_W			=> RD_W_s,
											EN_PC			=> EN_PC_s,
											EN_FtoD			=> EN_FtoD_s,
											EN_DtoE			=> EN_DtoE_s,
											EN_EtoM			=> EN_EtoM_s,
											ALU_Src			=> ALU_Src_s,
											EN_ABS			=> EN_ABS_s,
											ALU_FORW_Src1	=> ALU_FORW_Src1_s,
											ALU_FORW_Src2	=> ALU_FORW_Src2_s,
											ALU_CONTROL		=> ALU_CONTROL_s,
											EN_MtoW			=> EN_MtoW_s,
											PC_Src			=> PC_Src_s,
											MEM_WRITE		=> MEM_WRITE,
											MEM_READ		=> MEM_READ,
											ALU_to_MUX		=> ALU_to_MUX_s,
											MEM_to_MUX		=> MEM_to_MUX_s,
											MEM_to_REG		=> MEM_to_REG_s,
											REG_WRITE		=> REG_WRITE_s
					);
					
	data_path		: DP_abs	PORT MAP(
											CLK				=> CLK,
											RST_n			=> RST_n,
											EN_PC			=> EN_PC_s,
											PC_Src			=> PC_Src_s,
											INSTR			=> INSTR,
											DATA_R_MEM		=> READ_DATA,
											EN_FtoD			=> EN_FtoD_s,
											WR				=> REG_WRITE_s,
											EN_DtoE			=> EN_DtoE_s,
											EN_EtoM			=> EN_EtoM_s,
											ALU_Src			=> ALU_Src_s,
											EN_ABS			=> EN_ABS_s,
											ALU_FORW_Src1	=> ALU_FORW_Src1_s,
											ALU_FORW_Src2	=> ALU_FORW_Src2_s,
											ALU_CTRL		=> ALU_CONTROL_s,
											EN_MtoW			=> EN_MtoW_s,
											ALU_to_MUX		=> ALU_to_MUX_s,
											MEM_to_MUX		=> MEM_to_MUX_s,
											MEM_to_REG		=> MEM_to_REG_s,
											OPCODE			=> OPCODE_s,
											FUNC3			=> FUNC3_s,
											RS1_D			=> RS1_D_s,
											RS2_D			=> RS2_D_s,
											FUNC7_30		=> FUNC7_30_s,
											RD_E			=> RD_E_s,
											ZERO_F			=> ALU_ZFLAG_s,
											RS1_E			=> RS1_E_s,
											RS2_E			=> RS2_E_s,
											RD_M			=> RD_M_s,
											RD_W			=> RD_W_s,
											PC				=> PC,
											DATA_W_MEM		=> WRITE_DATA,
											ADDR_MEM		=> ADDR_MEM
											
					);
END ARCHITECTURE;