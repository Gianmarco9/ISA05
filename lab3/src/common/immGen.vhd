LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.all;
USE work.mypackage.all;

ENTITY immGen IS
	PORT(	INSTR 	: IN std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);
		IMMED 	: OUT std_logic_vector(nb-1 DOWNTO 0));
END ENTITY;

ARCHITECTURE behav OF immGen IS

SIGNAL OPCODE	: std_logic_vector(OPCODE_SIZE-1 DOWNTO 0);
SIGNAL FUNC3	: std_logic_vector(FUNC3_SIZE-1 DOWNTO 0);
SIGNAL FUNC7_30	: std_logic;

BEGIN

-- INSTRUCTION UNPACKING
OPCODE 		<= INSTR(OPCODE_SIZE-1 DOWNTO 0);
FUNC3 		<= INSTR(FUNC3_END DOWNTO FUNC3_START);
FUNC7_30	<= INSTR(30);

imm_selection: PROCESS(OPCODE, FUNC3, FUNC7_30)
BEGIN
	CASE OPCODE IS
		WHEN I_TYPE_ARITH | I_TYPE_LOAD	=>	
			CASE FUNC3 IS
				WHEN FUNC3_ADDI | FUNC3_ANDI | FUNC3_LW =>
					-- lower part is the command word value
					IMMED(IMM_SIZE-1 DOWNTO 0) <= INSTR(FUNC7_END DOWNTO RS2_START);
					-- upper part is the sign extension
					IMMED(nb-1 DOWNTO IMM_SIZE) <= (OTHERS => INSTR(FUNC7_END));
				WHEN FUNC3_SRAI =>
					CASE FUNC7_30 IS
						WHEN FUNC7_30_SRAI =>
							IMMED(REG_ADDR_SIZE-1 DOWNTO 0) <= INSTR(RS2_END DOWNTO RS2_START);
							IMMED(nb-1 DOWNTO REG_ADDR_SIZE) <= (OTHERS => '0');	
						WHEN OTHERS => IMMED <= (OTHERS => '0');
					END CASE;
				WHEN OTHERS => IMMED <= (OTHERS => '0');
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
					
		WHEN S_TYPE	=> 
			CASE FUNC3 IS
				WHEN FUNC3_SW => 
					IMMED(IMM_SIZE-1 DOWNTO 0) <= INSTR(FUNC7_END DOWNTO FUNC7_START) & INSTR(RD_END DOWNTO RD_START);
					IMMED(nb-1 DOWNTO IMM_SIZE) <= (OTHERS => INSTR(FUNC7_END));	-- sign extension
				WHEN OTHERS => IMMED <= (OTHERS => '0');
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN SB_TYPE =>
			CASE FUNC3 IS
				WHEN FUNC3_BEQ => 
					-- adding a zero to the LSB to get the left shift
					IMMED(IMM_SIZE DOWNTO 0) <= INSTR(FUNC7_END) & INSTR(RD_START) & INSTR(FUNC7_END-1 DOWNTO FUNC7_START) & INSTR(RD_END DOWNTO RD_START+1) & '0';
					IMMED(nb-1 DOWNTO IMM_SIZE+1) <= (OTHERS => INSTR(FUNC7_END));	-- sign extension
				WHEN OTHERS => IMMED <= (OTHERS => '0');
			END CASE;

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN U_TYPE_LUI | U_TYPE_AUIPC =>
			IMMED(nb-1 DOWNTO nb-EXT_IMM_SIZE) <= INSTR(FUNC7_END DOWNTO FUNC3_START);
			IMMED(nb-EXT_IMM_SIZE-1 DOWNTO 0) <= (OTHERS => '0');	-- zero filling

--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

		WHEN UJ_TYPE_JAL =>
			-- adding a zero to the LSB to get the left shift
			IMMED(EXT_IMM_SIZE DOWNTO 0) <= INSTR(FUNC7_END) & INSTR(RS1_END DOWNTO FUNC3_START) & INSTR(RS2_START) & INSTR(FUNC7_END-1 DOWNTO RS2_START+1) & '0';
			IMMED(nb-1 DOWNTO EXT_IMM_SIZE+1) <= (OTHERS => INSTR(FUNC7_END));	-- sign extension


		WHEN OTHERS => IMMED <= (OTHERS => '0');
	END CASE;
END PROCESS;

END ARCHITECTURE;
