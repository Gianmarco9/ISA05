library ieee;
use ieee.std_logic_1164.all;

package mypackage is

---------------------------------------------------------------------------------------------------------------------

--						   GENERAL CONSTANTS

---------------------------------------------------------------------------------------------------------------------

	constant nb					: positive	:= 32; -- internal parallelism
	constant INSTR_WIDTH				: positive	:= 32;
	constant MEM_ADDR_SIZE				: positive	:= 12;
	constant OPCODE_SIZE				: positive	:= 7;
	constant FUNC3_SIZE				: positive	:= 3;
	constant FUNC7_SIZE				: positive	:= 7;
	constant REG_ADDR_SIZE				: positive	:= 5;
	constant IMM_SIZE				: positive	:= FUNC7_SIZE + REG_ADDR_SIZE;
	constant EXT_IMM_SIZE				: positive	:= IMM_SIZE + REG_ADDR_SIZE + FUNC3_SIZE; -- extended immediate size


---------------------------------------------------------------------------------------------------------------------

--						    CU CONSTANTS

---------------------------------------------------------------------------------------------------------------------
	constant CW_SIZE_ABS			: positive	:= 13;
	constant CW_SIZE				: positive	:= 12;
	constant ALU_CONTROL_SIZE			: positive	:= 3;


---------------------------------------------------------------------------------------------------------------------

--					     IMMEDIATE GENERATOR CONSTANTS

---------------------------------------------------------------------------------------------------------------------

-- LSB POSITION OF THE FIELD INSIDE THE INSTRUCTION
	constant RD_START				: positive	:= OPCODE_SIZE;			-- 7
	constant FUNC3_START				: positive	:= RD_START + REG_ADDR_SIZE;	-- 12
	constant RS1_START				: positive	:= FUNC3_START + FUNC3_SIZE;	-- 15
	constant RS2_START				: positive	:= RS1_START + REG_ADDR_SIZE;	-- 20
	constant FUNC7_START				: positive	:= RS2_START + REG_ADDR_SIZE;	-- 25
-- MSB POSITION OF THE FIELD INSIDE THE INSTRUCTION
	constant RD_END					: positive	:= FUNC3_START-1;		-- 11
	constant FUNC3_END				: positive	:= RS1_START-1;			-- 14
	constant RS1_END				: positive	:= RS2_START-1;			-- 19
	constant RS2_END				: positive	:= FUNC7_START-1;		-- 24
	constant FUNC7_END				: positive	:= FUNC7_START + FUNC7_SIZE-1;	-- 31


---------------------------------------------------------------------------------------------------------------------

--						INSTRUCTIONS CONSTANTS

---------------------------------------------------------------------------------------------------------------------
-- R-Type instruction

	---> OPCODE field
	constant R_TYPE					: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0110011";          
	---> FUNC3 field
	constant FUNC3_ADD				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "000"; 
	constant FUNC3_XOR				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "100";
	constant FUNC3_SLT				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "010"; 
   	---> FUNC7 30th BIT
	constant FUNC7_30_ADD				: std_logic	:= '0'; 
	constant FUNC7_30_XOR				: std_logic	:= '0';
	constant FUNC7_30_SLT				: std_logic	:= '0';
	
-- I-Type 

	---> OPCODE field
	constant I_TYPE_ARITH				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0010011";
	constant I_TYPE_LOAD				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0000011";
	---> FUNC3 field
	constant FUNC3_ADDI				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "000"; 
	constant FUNC3_SRAI				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "101";
	constant FUNC3_ANDI				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "111"; 
	constant FUNC3_ABS				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "001"; 
	constant FUNC3_LW				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "010"; 
	---> FUNC7 30th BIT
	constant FUNC7_30_SRAI				: std_logic	:= '1'; 
	
-- S-Type	

	---> OPCODE field
	constant S_TYPE					: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0100011";
	---> FUNC3 field
	constant FUNC3_SW				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "010"; 
	
-- SB-Type	

	---> OPCODE field
	constant SB_TYPE				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "1100011";
	---> FUNC3 field
	constant FUNC3_BEQ				: std_logic_vector(FUNC3_SIZE - 1 downto 0)	:= "000";

-- U-Type	

	---> OPCODE field
	constant U_TYPE_LUI				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0110111";
	constant U_TYPE_AUIPC				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "0010111";

-- UJ-Type	

	---> OPCODE field
	constant UJ_TYPE_JAL				: std_logic_vector(OPCODE_SIZE - 1 downto 0)	:= "1101111";
	
-- ALU control constant identifiers
	constant ADD_C					: std_logic_vector(ALU_CONTROL_SIZE-1 downto 0)	:= "000";
	constant AND_C					: std_logic_vector(ALU_CONTROL_SIZE-1 downto 0)	:= "001";
	constant XOR_C					: std_logic_vector(ALU_CONTROL_SIZE-1 downto 0)	:= "010";
	constant SRAI_C					: std_logic_vector(ALU_CONTROL_SIZE-1 downto 0)	:= "011";
	constant SLT_C					: std_logic_vector(ALU_CONTROL_SIZE-1 downto 0)	:= "100";


end mypackage;
