LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE work.mypackage.all;

ENTITY CU IS
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
END ENTITY;


ARCHITECTURE behav OF CU IS

SIGNAL flush		: std_logic;	-- raise the signal if a flush is needed
SIGNAL stall		: std_logic;	-- raise the signal if a stall is needed
SIGNAL mode_sel		: std_logic;	-- select NORMAL MODE or FLUSH MODE
SIGNAL cw		: std_logic_vector(CW_SIZE-1 DOWNTO 0);
SIGNAL cw_op		: std_logic_vector(CW_SIZE-1 DOWNTO 0);
SIGNAL cw_E		: std_logic_vector(CW_SIZE-1 DOWNTO 0);
SIGNAL cw_M		: std_logic_vector(CW_SIZE-1-4 DOWNTO 0);
SIGNAL cw_W		: std_logic_vector(CW_SIZE-1-4-5 DOWNTO 0);
SIGNAL ALU_CONTROL_sig	: std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);
SIGNAL ALU_CONTROL_op	: std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0);
SIGNAL EN_branch	: std_logic;	
SIGNAL AND_branch	: std_logic;
SIGNAL EN_jump 		: std_logic;
SIGNAL J_B_taken	: std_logic;
SIGNAL J_B_taken_delayed: std_logic;

BEGIN

-- DECODE
mode_sel	<= flush OR stall;

-- EXECUTE
EN_EtoM		<= cw_E(11);
ALU_Src		<= cw_E(10);
EN_branch	<= cw_E(9);
EN_jump		<= cw_E(8);

AND_branch	<= EN_branch AND ALU_ZFLAG;
J_B_taken	<= AND_branch OR EN_jump;
PC_Src		<= J_B_taken;

-- MEMORY
EN_MtoW		<= cw_M(7);
MEM_WRITE	<= cw_M(6);
MEM_READ	<= cw_M(5);
ALU_to_MUX	<= cw_M(4 DOWNTO 3);

-- WRITE BACK
MEM_to_MUX	<= cw_W(2);
MEM_to_REG	<= cw_W(1);
REG_WRITE	<= cw_W(0);


-----------------------------------------------------------------------------------------------------

--					OPCODE TRANSLATOR

-----------------------------------------------------------------------------------------------------

OP_CODE_TRANSLATOR: PROCESS(OPCODE, FUNC3, FUNC7_30)
BEGIN
	CASE OPCODE IS


		WHEN R_TYPE	=>
			CASE FUNC3 IS
				WHEN FUNC3_ADD	=>
					CASE FUNC7_30 IS
						WHEN FUNC7_30_ADD	=>
							cw_op		<= "100010010011";
							ALU_CONTROL_op	<= ADD_C;
						WHEN OTHERS		=>	--disable pipe regs
							cw_op		<= (others => '0'); 
							ALU_CONTROL_op	<= ADD_C;
					END CASE;


				WHEN FUNC3_XOR	=>
					CASE FUNC7_30 IS
						WHEN FUNC7_30_XOR	=>
							cw_op		<= "100010010011";
							ALU_CONTROL_op	<= XOR_C;
						WHEN OTHERS		=>	--disable pipe regs
							cw_op		<= (others => '0'); 
							ALU_CONTROL_op	<= ADD_C;
					END CASE;


				WHEN FUNC3_SLT	=>
					CASE FUNC7_30 IS
						WHEN FUNC7_30_SLT	=>
							cw_op		<= "100010010011";
							ALU_CONTROL_op	<= SLT_C;
						WHEN OTHERS		=>	--disable pipe regs
							cw_op		<= (others => '0'); 
							ALU_CONTROL_op	<= ADD_C;						
					END CASE;
				WHEN OTHERS	=>	--disable pipe regs
					cw_op		<= (others => '0'); 
					ALU_CONTROL_op	<= ADD_C;										
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN I_TYPE_ARITH	=>
			CASE FUNC3 IS
				WHEN FUNC3_ADDI	=>
					cw_op		<= "110010010011";
					ALU_CONTROL_op	<= ADD_C;


				WHEN FUNC3_SRAI	=>
					CASE FUNC7_30 IS
						WHEN FUNC7_30_SRAI	=>
							cw_op		<= "110010010011";
							ALU_CONTROL_op	<= SRAI_C;
						WHEN OTHERS		=>	--disable pipe regs
							cw_op		<= (others => '0'); 
							ALU_CONTROL_op	<= ADD_C;						
					END CASE; 


				WHEN FUNC3_ANDI	=>
					cw_op		<= "110010010011";
					ALU_CONTROL_op	<= AND_C;
				WHEN OTHERS	=>	--disable pipe regs
					cw_op		<= (others => '0'); 
					ALU_CONTROL_op	<= ADD_C;						
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN I_TYPE_LOAD	=>
			CASE FUNC3 IS
				WHEN FUNC3_LW	=>
					cw_op		<= "110010110111";
					ALU_CONTROL_op	<= ADD_C;
				WHEN OTHERS	=>	--disable pipe regs
					cw_op		<= (others => '0'); 
					ALU_CONTROL_op	<= ADD_C;						
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN S_TYPE		=>
			CASE FUNC3 IS
				WHEN FUNC3_SW	=>
					cw_op		<= "110011010010";
					ALU_CONTROL_op	<= ADD_C;
				WHEN OTHERS	=>	--disable pipe regs
					cw_op		<= (others => '0'); 
					ALU_CONTROL_op	<= ADD_C;						
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN SB_TYPE		=>
			CASE FUNC3 IS
				WHEN FUNC3_BEQ	=>
					cw_op		<= "101010010010";
					ALU_CONTROL_op	<= XOR_C;
				WHEN OTHERS	=>	--disable pipe regs
					cw_op		<= (others => '0'); 
					ALU_CONTROL_op	<= ADD_C;						
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN U_TYPE_LUI		=>
			cw_op		<= "110010001011";
			ALU_CONTROL_op <= ADD_C;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN U_TYPE_AUIPC	=>
			cw_op		<= "110010000011";
			ALU_CONTROL_op	<= ADD_C;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN UJ_TYPE_JAL	=>
			cw_op		<= "110110010001";
			ALU_CONTROL_op	<= ADD_C;


		WHEN OTHERS		=>	--disable pipe regs
			cw_op		<= (others => '0'); 
			ALU_CONTROL_op	<= ADD_C;						
	END CASE;
END PROCESS;
-----------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------

--			   		  CONTROL HAZARD CU

-----------------------------------------------------------------------------------------------------

FF_J_B: process(CLK, RST_n)
	begin
		if RST_n = '0' then
			J_B_taken_delayed <= '0';

		else
			if CLK = '1' and CLK'event then
				J_B_taken_delayed <= J_B_taken;
			end if;
		end if;
	end process FF_J_B;


flush <= J_B_taken OR J_B_taken_delayed;
-----------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------

--		  			DATA HAZARD CU

-----------------------------------------------------------------------------------------------------

D_HAZARD_CU: process(RST_n, cw_E(5), RS1_D, RS2_D, RD_E)
	begin
		if RST_n = '0' then
			EN_PC 	<= '0';
			EN_FtoD	<= '0';
			EN_DtoE	<= '0';
			stall	<= '0';
		elsif (cw_E(5) = '1') AND (RD_E /= "00000") then
			if (RS1_D = RD_E) OR (RS2_D = RD_E) then
				EN_PC	<= '0';
				EN_FtoD	<= '0';
				EN_DtoE	<= '1';
				stall	<= '1';
			else
				EN_PC	<= '1';
				EN_FtoD	<= '1';
				EN_DtoE	<= '1';
				stall <= '0';
			end if;
		else 
			EN_PC	<= '1';
			EN_FtoD	<= '1';
			EN_DtoE	<= '1';
			stall	<= '0';
		end if;
	end process D_HAZARD_CU;
-----------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------

--			   	NORMAL / FLUSH MODE MULTIPLEXER

-----------------------------------------------------------------------------------------------------
	
MODE_MUX: process(cw_op, ALU_CONTROL_op, mode_sel)
	begin
		case mode_sel is
			when '0' => cw			<= cw_op;
				    ALU_CONTROL_sig	<= ALU_CONTROL_op;

			when '1' => cw			<= (others => '0');
				    ALU_CONTROL_sig	<= ADD_C;

			when others => cw		<= (others => 'X');
				       ALU_CONTROL_sig	<= (others => 'X');
		end case;
	end process MODE_MUX;
-----------------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------------

--			   		  FORWARDING CU

-----------------------------------------------------------------------------------------------------
FORWARDING_CU: process(RST_n, cw_M(0), cw_W(0), RS1_E, RS2_E, RD_M, RD_W)

	begin

	if RST_n = '0' then
		ALU_FORW_Src1	<= "00";
		ALU_FORW_Src2	<= "00";
	else
	
		if (cw_M(0) = '1' AND RS1_E /= "00000" AND RS1_E = RD_M ) then
			ALU_FORW_Src1	<= "01";
		elsif (cw_M(0) = '1' AND RS1_E /= "00000" AND RS1_E /= RD_M) then
			if (cw_W(0) = '1' AND RS1_E /= "00000" AND RS1_E = RD_W) then
				ALU_FORW_Src1	<= "10";
			else
				ALU_FORW_Src1	<= "00";
			end if;
		elsif (cw_M(0) = '0' AND cw_W(0) = '1' AND RS1_E /= "00000" AND RS1_E = RD_W) then
			ALU_FORW_Src1	<= "10";
		else
			ALU_FORW_Src1	<= "00";
		end if;
	
		if (cw_M(0) = '1' AND RS2_E /= "00000" AND RS2_E = RD_M ) then
			ALU_FORW_Src2	<= "01";
		elsif (cw_M(0) = '1' AND RS2_E /= "00000" AND RS2_E /= RD_M) then
			if (cw_W(0) = '1' AND RS2_E /= "00000" AND RS2_E = RD_W) then
				ALU_FORW_Src2	<= "10";
			else
				ALU_FORW_Src2	<= "00";
			end if;
		elsif (cw_M(0) = '0' AND cw_W(0) = '1' AND RS2_E /= "00000" AND RS2_E = RD_W) then
			ALU_FORW_Src2	<= "10";
		else
			ALU_FORW_Src2	<= "00";
		end if;
	end if;	
end process;
-----------------------------------------------------------------------------------------------------




-----------------------------------------------------------------------------------------------------

--			   			CW PIPE

-----------------------------------------------------------------------------------------------------

CW_PIPE: process(CLK, RST_n)
	begin
		if RST_n = '0' then
			cw_E	<= (others => '0');
			cw_M	<= (others => '0');
			cw_W	<= (others => '0');
			ALU_CONTROL <= ADD_C;

		else		
			if CLK = '1' and CLK'event then
					cw_E	<= cw;
					cw_M	<= cw_E(CW_SIZE-1-4 downto 0);
					cw_W	<= cw_M(CW_SIZE-1-4-5 downto 0);
					ALU_CONTROL <= ALU_CONTROL_sig;
			end if;
		end if; 
end process CW_PIPE;
-----------------------------------------------------------------------------------------------------



END ARCHITECTURE;
