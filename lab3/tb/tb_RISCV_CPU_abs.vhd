LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE work.mypackage.all;

ENTITY tb_RISCV_CPU_abs IS
END ENTITY;

ARCHITECTURE tb OF tb_RISCV_CPU_abs IS

	COMPONENT RISCV_CPU_abs 
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
	END COMPONENT;
	
	COMPONENT IRAM 
		GENERIC(file_path	: string := "../tb/instruction_ram_dump.txt";
			nbit_ADDRESS	: integer := 12;		-- 4 kB => 2^12 x 8 bit
			nbit_WORD	: integer:= 8);
					
		PORT(	CLK		: IN  std_logic;
			RST_n		: IN  std_logic;	
			ADDRESS		: IN  std_logic_vector(nbit_ADDRESS-1 DOWNTO 0);
			DOUT		: OUT std_logic_vector(nb-1 DOWNTO 0)
			);
	END COMPONENT;

	COMPONENT DRAM 
		GENERIC	(file_path	: string  := "../tb/data_ram_dump.txt";
			 dump_path	: string  := "../tb/final_data_ram_dump.txt";
			 nbit_ADDRESS	: integer := 12;	-- 4 kB => 2^12 x 8 bit
			 nbit_WORD	: integer := 8);
				
		PORT(	CLK		: IN std_logic;
			RST_n		: IN std_logic;
			RD		: IN std_logic;
			WR		: IN std_logic;
			DUMP		: IN std_logic;
			ADDRESS		: IN std_logic_vector(nbit_ADDRESS-1 DOWNTO 0);
			DATAIN		: IN std_logic_vector(nb-1 DOWNTO 0);
			DATAOUT		: OUT std_logic_vector(nb-1 DOWNTO 0)
			);
	END COMPONENT;
	
	SIGNAL CLK_s 		: std_logic := '0';
	SIGNAL RST_n_s		: std_logic;
	SIGNAL INSTR_s		: std_logic_vector(INSTR_WIDTH-1 DOWNTO 0);
	SIGNAL READ_DATA_s	: std_logic_vector(nb-1 DOWNTO 0);
	SIGNAL PC_s			: std_logic_vector(nb-1 DOWNTO 0);
	SIGNAL ADDR_MEM_s	: std_logic_vector(nb-1 DOWNTO 0);
	SIGNAL WRITE_DATA_s	: std_logic_vector(nb-1 downto 0);
	SIGNAL MEM_WRITE_s	: std_logic;
	SIGNAL MEM_READ_s		: std_logic;
	SIGNAL DUMP_s		: std_logic := '0';

BEGIN

	RST_n_s	<= '0', '1' AFTER 35 ns;
	CLK_s 	<= NOT(CLK_s) AFTER 7 ns;
	DUMP_s  <= '1' AFTER 1309 ns, '0' AFTER 1316 ns;
	
	DUT			: RISCV_CPU_abs PORT MAP (CLK_s, RST_n_s, INSTR_s, READ_DATA_s, PC_s, ADDR_MEM_s, WRITE_DATA_s, MEM_WRITE_s, MEM_READ_s);
	
	INSTR_RAM	: IRAM		GENERIC MAP(file_path => "../tb/instruction_ram_dump_abs.txt") 
							PORT MAP (CLK_s, RST_n_s, PC_s(MEM_ADDR_SIZE-1 DOWNTO 0), INSTR_s);
							
	DATA_RAM	: DRAM		GENERIC MAP(dump_path => "../tb/final_data_ram_dump_abs.txt") 
							PORT MAP (CLK_s, RST_n_s, MEM_READ_s, MEM_WRITE_s, DUMP_s, ADDR_MEM_s(MEM_ADDR_SIZE-1 DOWNTO 0), WRITE_DATA_s, READ_DATA_s);
	
END ARCHITECTURE;
