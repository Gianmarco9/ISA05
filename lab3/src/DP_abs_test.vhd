LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY DP_abs IS
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
		EN_ABS		: IN std_logic;						-- from CU
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

END ENTITY;


ARCHITECTURE struct OF DP_abs IS

	COMPONENT reg
		GENERIC (N: POSITIVE := 8);
		PORT (
		      	CLK		: IN STD_LOGIC;
		      	RST_n		: IN STD_LOGIC;
		      	EN		: IN STD_LOGIC;
		      	D_IN		: IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
		      	D_OUT		: OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
	END COMPONENT;
	
	
	COMPONENT fetch
		PORT(	CLK		: IN std_logic;
			RST_n		: IN std_logic;
			NEW_ADDR	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
			EN_PC		: IN std_logic;			     		   	-- from CU
		    	PC_Src		: IN std_logic;			     		   	-- from CU
			PC		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to DECODE STAGE & to INSTRUCTION MEMORY
			NPC		: OUT std_logic_vector(nb-1 DOWNTO 0));			-- to DECODE STAGE
	END COMPONENT;
	
	
	COMPONENT decode
		PORT(	CLK		: IN std_logic;
		    	RST_n		: IN std_logic;
			WR		: IN std_logic;						-- from CU
			PC_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from FETCH STAGE
			NPC_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from FETCH STAGE
			INSTR		: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);		-- from INSTRUCTION MEMORY
			WR_ADDR		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from WRITE BACK STAGE
			WR_DATA		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from WRITE BACK STAGE
			PC_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
			NPC_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
			OPCODE		: OUT std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);		-- to CU
			FUNC3		: OUT std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);		-- to CU
			FUNC7_30	: OUT std_logic;					-- to CU
			DATA1		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
			DATA2		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
			IMM_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to EXECUTE STAGE
			RS1_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to EXECUTE STAGE&CU
			RS2_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to EXECUTE STAGE&CU
			RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0));	-- to EXECUTE STAGE
	END COMPONENT;
	
	
	COMPONENT execute_abs IS
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
	END COMPONENT;
	
	
	COMPONENT mem_acc_abs
	       PORT(	NPC_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
				NEW_ADDR	: IN std_logic_vector(nb-1 DOWNTO 0);		-- from EXECUTE STAGE
	       		ALU_RES		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
				ABS_RES		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
	       		IMM_i		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from EXECUTE STAGE
			RD_i		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from EXECUTE STAGE
	       		ALU_to_MUX	: IN std_logic_vector(1 DOWNTO 0);						-- from CU
			NPC_o		: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to WRITE BACK STAGE
	       		DATA_MUX	: OUT std_logic_vector(nb-1 DOWNTO 0);			-- to WRITE BACK STAGE
			RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0));	-- to WRITE BACK STAGE
	END COMPONENT;
	
	
	COMPONENT wrback
		PORT(	NPC		: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
		    	DATA_MEM	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from DATA MEMORY
			DATA_MUX	: IN std_logic_vector(nb-1 DOWNTO 0);			-- from MEMORY STAGE
			RD_i		: IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from MEMORY STAGE
			MEM_to_MUX	: IN std_logic;						-- from CU
			MEM_to_REG	: IN std_logic;						-- from CU
			RD_o		: OUT std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- to DECODE STAGE
			WR_DATA		: OUT std_logic_vector(nb-1 DOWNTO 0));			-- to DECODE STAGE
	END COMPONENT;

	COMPONENT monitor_abs 
		PORT(	CLK		        : IN std_logic;						                -- from TB
				RST_n		    : IN std_logic;						                -- from TB

				-- FETCH            
				PC		        : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from INSTRUCTION MEMORY

				-- DECODE
				OPCODE		    : IN std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);		-- from DP
				FUNC3		    : IN std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);		-- from DP
				RD 		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
				RS1 		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
				RS2	    	    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- from DP
				IMM		        : IN std_logic_vector(nb-1 DOWNTO 0);			    -- form DP
				FUNC7_30	    : IN std_logic;					                    -- from DP


				-- EXECUTE
				NOP_inject	    : IN std_logic;						                -- from CU
				ALU_FORW_Src1	: IN std_logic_vector(1 DOWNTO 0);	                -- from CU
				ALU_FORW_Src2	: IN std_logic_vector(1 DOWNTO 0);	                -- from CU
			NEW_ADDR 		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP 
				ALU_RES		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
				ABS_RES		    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP


				-- MEMORY
				ADDR_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
				DATA_W_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);			    -- from DP
				DATA_R_MEM	    : IN std_logic_vector(nb-1 DOWNTO 0);               -- from DATA MEMORY


				-- WRITE BACK
				WR		        : IN std_logic;						                -- from CU
				RD_ADDR		    : IN std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);    -- from DP
				WR_DATA		    : IN std_logic_vector(nb-1 DOWNTO 0)			    -- from DP
		);

	END COMPONENT;


	-- FETCH SIGNALS
	SIGNAL PC_sig_F, NPC_sig_F 			: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUTS

	-- DECODE SIGNALS
	SIGNAL INSTR_sig_D				: std_logic_vector(nb-1 DOWNTO 0);		-- INPUTS
	SIGNAL PC_i_sig_D, NPC_i_sig_D 			: std_logic_vector(nb-1 DOWNTO 0);		-- INPUT BUFFERS
	SIGNAL PC_o_sig_D, NPC_o_sig_D 			: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUT BUFFERS
	SIGNAL RS1_sig_D, RS2_sig_D, RD_sig_D 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- OUTPUT BUFFERS
	SIGNAL DATA1_sig_D, DATA2_sig_D, IMM_sig_D 	: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUTS
	SIGNAL OPCODE_sig_D				: std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);	-- OUTPUT
	SIGNAL FUNC3_sig_D				: std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);	-- OUTPUT
	SIGNAL FUNC7_30_sig_D				: std_logic;					-- OUTPUT
	
	-- EXECUTE SIGNALS
	SIGNAL PC_sig_E, OPA_sig_E			: std_logic_vector(nb-1 DOWNTO 0);		-- INPUTS
	SIGNAL NPC_i_sig_E, OPB_MUX_sig_E, IMM_MUX_sig_E: std_logic_vector(nb-1 DOWNTO 0);		-- INPUT BUFFERS
	SIGNAL RD_i_sig_E 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- INPUT BUFFERS
	SIGNAL NPC_o_sig_E, MEM_DATA_sig_E, IMM_o_sig_E : std_logic_vector(nb-1 DOWNTO 0);		-- INPUT BUFFERS
	SIGNAL RD_o_sig_E 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- OUTPUT BUFFERS
	SIGNAL ALU_RES_sig_E, NEW_ADDR_sig_E, ABS_RES_sig_E 		: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUTS
	SIGNAL NOP_inject				: std_logic;					-- OUTPUTS

	-- MEMORY SIGNALS
	SIGNAL ALU_RES_sig_M, IMM_i_sig_M, NEW_ADDR_sig_M, ABS_RES_sig_M 		: std_logic_vector(nb-1 DOWNTO 0);		-- INPUTS
	SIGNAL NPC_i_sig_M		 		: std_logic_vector(nb-1 DOWNTO 0);		-- INPUT BUFFERS
	SIGNAL RD_i_sig_M 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- INPUT BUFFERS
	SIGNAL NPC_o_sig_M		 		: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUT BUFFERS
	SIGNAL RD_o_sig_M 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- OUTPUT BUFFERS
	SIGNAL MEM_DATA_sig_M, DATA_MUX_sig_M 		: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUT

	-- WRITE BACK SIGNALS
	SIGNAL NPC_sig_W, DATA_MEM_sig_W, DATA_MUX_sig_W: std_logic_vector(nb-1 DOWNTO 0);		-- INPUTS
	SIGNAL RD_i_sig_W 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- INPUT BUFFER
	SIGNAL RD_o_sig_W 				: std_logic_vector(REG_ADDR_SIZE-1 DOWNTO 0);	-- OUTPUT BUFFER
	SIGNAL WR_DATA_sig_W 				: std_logic_vector(nb-1 DOWNTO 0);		-- OUTPUT

BEGIN

	fetch_stage 	: fetch		PORT MAP(
						 CLK	  => CLK,
						 RST_n	  => RST_n,	
                                                 NEW_ADDR => NEW_ADDR_sig_E,
                                                 EN_PC	  => EN_PC,
                                                 PC_Src	  => PC_Src,
                                                 PC	  => PC_sig_F,
                                                 NPC	  => NPC_sig_F
					);


	----------------------------------------------------------------------------------------------------------
	--					FETCH / DECODE PIPELINE
	----------------------------------------------------------------------------------------------------------
	
	reg_NPC_F_D	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_FtoD, NPC_sig_F, NPC_i_sig_D);

	reg_PC_F_D	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_FtoD, PC_sig_F, PC_i_sig_D);

	reg_INSTR_F_D	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_FtoD, INSTR, INSTR_sig_D);

	----------------------------------------------------------------------------------------------------------


	decode_stage	: decode	PORT MAP(
						 CLK	  => CLK,
                                                 RST_n	  => RST_n,
                                                 WR	  => WR,
                                                 PC_i	  => PC_i_sig_D,
                                                 NPC_i	  => NPC_i_sig_D,
                                                 INSTR	  => INSTR_sig_D,
                                                 WR_ADDR  => RD_o_sig_W,
                                                 WR_DATA  => WR_DATA_sig_W,
                                                 PC_o	  => PC_o_sig_D,
                                                 NPC_o	  => NPC_o_sig_D,
                                                 OPCODE	  => OPCODE_sig_D,
                                                 FUNC3	  => FUNC3_sig_D,
                                                 FUNC7_30 => FUNC7_30_sig_D,
                                                 DATA1	  => DATA1_sig_D,
                                                 DATA2	  => DATA2_sig_D,
                                                 IMM_o	  => IMM_sig_D,
												 RS1_o	  => RS1_sig_D,
												 RS2_o	  => RS2_sig_D,
                                                 RD_o	  => RD_sig_D
					);


	----------------------------------------------------------------------------------------------------------
	--					DECODE / EXECUTE PIPELINE
	----------------------------------------------------------------------------------------------------------
	
	reg_NPC_D_E	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_DtoE, NPC_o_sig_D, NPC_i_sig_E);

	reg_PC_D_E	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_DtoE, PC_o_sig_D, PC_sig_E);

	reg_DATA1_D_E	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_DtoE, DATA1_sig_D, OPA_sig_E);

	reg_DATA2_D_E	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_DtoE, DATA2_sig_D, OPB_MUX_sig_E);

	reg_IMM_D_E	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_DtoE, IMM_sig_D, IMM_MUX_sig_E);
	
	reg_RS1_D_E	: reg		GENERIC MAP(N => REG_ADDR_SIZE)
					PORT MAP(CLK, RST_n, EN_DtoE, RS1_sig_D, RS1_E);
				
	reg_RS2_D_E	: reg		GENERIC MAP(N => REG_ADDR_SIZE)
					PORT MAP(CLK, RST_n, EN_DtoE, RS2_sig_D, RS2_E);			

	reg_RD_D_E	: reg		GENERIC MAP(N => REG_ADDR_SIZE)
					PORT MAP(CLK, RST_n, EN_DtoE, RD_sig_D, RD_i_sig_E);

	----------------------------------------------------------------------------------------------------------


	execute_stage	: execute_abs	PORT MAP(
						 PC	  	=> PC_sig_E,
                                                 NPC_i	  	=> NPC_i_sig_E,
                                                 OPA_MUX  	=> OPA_sig_E,
                                                 OPB_MUX  	=> OPB_MUX_sig_E,
                                                 IMM_MUX  	=> IMM_MUX_sig_E,
						 ALU_RES_forw	=> DATA_MUX_sig_M,
						 WR_DATA_forw	=> WR_DATA_sig_W,
                                                 RD_i	  	=> RD_i_sig_E,
                                                 ALU_CTRL 	=> ALU_CTRL,
                                                 ALU_Src  	=> ALU_Src,
												 EN_ABS		=> EN_ABS,
						 ALU_FORW_Src1	=> ALU_FORW_Src1,
						 ALU_FORW_Src2	=> ALU_FORW_Src2,
                                                 NEW_ADDR 	=> NEW_ADDR_sig_E,
                                                 NPC_o	  	=> NPC_o_sig_E,
                                                 ALU_RES	=> ALU_RES_sig_E,
												 ABS_RES	=> ABS_RES_sig_E,
                                                 MEM_DATA 	=> MEM_DATA_sig_E,
                                                 IMM_o 	  	=> IMM_o_sig_E,
                                                 RD_o	  	=> RD_o_sig_E,
                                                 ZERO_F	  	=> ZERO_F
					);


	----------------------------------------------------------------------------------------------------------
	--					EXECUTE / MEMORY PIPELINE
	----------------------------------------------------------------------------------------------------------

	reg_NPC_E_M	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, NPC_o_sig_E, NPC_i_sig_M);

	reg_NEW_ADDR_E_M	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, NEW_ADDR_sig_E, NEW_ADDR_sig_M);

	reg_ALU_RES_E_M	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, ALU_RES_sig_E, ALU_RES_sig_M);
					
	reg_ABS_RES_E_M	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, ABS_RES_sig_E, ABS_RES_sig_M);				

	reg_MEM_DATA_E_M: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, MEM_DATA_sig_E, MEM_DATA_sig_M);

	reg_IMM_E_M	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_EtoM, IMM_o_sig_E, IMM_i_sig_M);

	reg_RD_E_M	: reg		GENERIC MAP(N => REG_ADDR_SIZE)
					PORT MAP(CLK, RST_n, EN_EtoM, RD_o_sig_E, RD_i_sig_M);

	----------------------------------------------------------------------------------------------------------


	memory_stage	: mem_acc_abs	PORT MAP(
						 NPC_i	    => NPC_i_sig_M,
						 NEW_ADDR	=> NEW_ADDR_sig_M, 
                                                 ALU_RES    => ALU_RES_sig_M,
												 ABS_RES	=> ABS_RES_sig_M,
                                                 IMM_i	    => IMM_i_sig_M,
                                                 RD_i	    => RD_i_sig_M,
                                                 ALU_to_MUX => ALU_to_MUX,
                                                 NPC_o	    => NPC_o_sig_M,
                                                 DATA_MUX   => DATA_MUX_sig_M,
                                                 RD_o	    => RD_o_sig_M
					);


	----------------------------------------------------------------------------------------------------------
	--					MEMORY / WRITEBACK PIPELINE
	----------------------------------------------------------------------------------------------------------

	reg_NPC_M_W	: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_MtoW, NPC_o_sig_M, NPC_sig_W);

	reg_DATA_MEM_M_W: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_MtoW, DATA_R_MEM, DATA_MEM_sig_W);

	reg_DATA_MUX_M_W: reg		GENERIC MAP(N => nb)
					PORT MAP(CLK, RST_n, EN_MtoW, DATA_MUX_sig_M, DATA_MUX_sig_W);

	reg_RD_M_W	: reg		GENERIC MAP(N => REG_ADDR_SIZE)
					PORT MAP(CLK, RST_n, EN_MtoW, RD_o_sig_M, RD_i_sig_W);

	----------------------------------------------------------------------------------------------------------


	write_back_stage: wrback	PORT MAP(
						 NPC	    => NPC_sig_W,	
                                                 DATA_MEM   => DATA_MEM_sig_W,
                                                 DATA_MUX   => DATA_MUX_sig_W,
                                                 RD_i	    => RD_i_sig_W,
                                                 MEM_to_MUX => MEM_to_MUX,
                                                 MEM_to_REG => MEM_to_REG,
                                                 RD_o	    => RD_o_sig_W,
                                                 WR_DATA    => WR_DATA_sig_W
					);

	----------------------------------------------------------------------------------------------------------

	monitor_data	: monitor_abs	PORT MAP(
						 CLK		=> CLK,
                                                 RST_n		=> RST_n,
                                                 PC	        => PC_sig_F,
                                                 OPCODE		=> OPCODE_sig_D,
                                                 FUNC3		=> FUNC3_sig_D,
						 RD		=> RD_sig_D,
                                                 RS1 		=> RS1_sig_D,
                                                 RS2	    	=> RS2_sig_D,
                                                 IMM		=> IMM_sig_D,
                                                 FUNC7_30	=> FUNC7_30_sig_D,
                                                 NOP_inject	=> NOP_inject,
                                                 ALU_FORW_Src1  => ALU_FORW_Src1,
                                                 ALU_FORW_Src2	=> ALU_FORW_Src2,
                                                 NEW_ADDR 	=> NEW_ADDR_sig_E,
                                                 ALU_RES	=> ALU_RES_sig_E,
						 ABS_RES	=> ABS_RES_sig_E,
                                                 ADDR_MEM	=> ALU_RES_sig_M,
                                                 DATA_W_MEM	=> MEM_DATA_sig_M,
                                                 DATA_R_MEM	=> DATA_R_MEM,
                                                 WR		=> WR,
                                                 RD_ADDR	=> RD_o_sig_W,
                                                 WR_DATA	=> WR_DATA_sig_W
					);
					
	-- OUTPUT TO INSTRUCTION MEMORY
	PC		<= PC_sig_F;

	-- OUTPUT TO DATA MEMORY
	ADDR_MEM	<= ALU_RES_sig_M;
	DATA_W_MEM	<= MEM_DATA_sig_M;

	-- OUTPUT TO CONTROL UNIT
	OPCODE		<= OPCODE_sig_D;
	FUNC3		<= FUNC3_sig_D;
	FUNC7_30	<= FUNC7_30_sig_D;
	RS1_D		<= RS1_sig_D;
	RS2_D		<= RS2_sig_D;
	RD_E		<= RD_i_sig_E;
	RD_M		<= RD_i_sig_M;
	RD_W		<= RD_i_sig_W;

	-- OUTPUT TO MONITOR
	NOP_inject	<= NOT(EN_EtoM);
END ARCHITECTURE;
