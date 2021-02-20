library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_textio.all;
use std.textio.all;
use work.mypackage.all;

entity DRAM is
	generic	(file_path	: string  := "../tb/data_ram_dump.txt";
		 dump_path	: string  := "../tb/final_data_ram_dump.txt";
		 nbit_ADDRESS	: integer := 12;	-- 4 kB => 2^12 x 8 bit
		 nbit_WORD	: integer := 8);
			
	port(	CLK		: IN std_logic;
		RST_n		: IN std_logic;
		RD		: IN std_logic;
		WR		: IN std_logic;
		DUMP		: IN std_logic;
		ADDRESS		: IN std_logic_vector(nbit_ADDRESS-1 downto 0);
		DATAIN		: IN std_logic_vector(nb-1 downto 0);
		DATAOUT		: OUT std_logic_vector(nb-1 downto 0)
		);
end DRAM;

architecture behav of DRAM is

subtype MEM_ADDR is natural range 0 to (2**nbit_ADDRESS)-1; 
type MEM_ARRAY is array(MEM_ADDR) of std_logic_vector(nbit_WORD-1 downto 0); 
signal Memory : MEM_ARRAY;

begin

w_r_dram: process(RST_n,CLK)

file mem_fp		: text open READ_MODE is file_path;
variable file_line	: line;
variable index		: integer := 0;
variable tmp_data	: std_logic_vector(nb-1 DOWNTO 0);

begin

	if RST_n = '0' then
		while not endfile(mem_fp) loop
			readline(mem_fp, file_line);
			read(file_line, tmp_data);
			Memory(index)	<= tmp_data(7 downto 0);
			Memory(index+1)	<= tmp_data(15 downto 8);
			Memory(index+2)	<= tmp_data(23 downto 16);
			Memory(index+3)	<= tmp_data(31 downto 24);
			index := index + 4;
		end loop;

	elsif CLK'EVENT and CLK = '0' then  
		if WR = '1' then
			Memory(to_integer(unsigned(ADDRESS)))	<= DATAIN(7 downto 0);
			Memory(to_integer(unsigned(ADDRESS))+1)	<= DATAIN(15 downto 8);
			Memory(to_integer(unsigned(ADDRESS))+2)	<= DATAIN(23 downto 16);
			Memory(to_integer(unsigned(ADDRESS))+3)	<= DATAIN(31 downto 24);

		elsif RD = '1' then
			DATAOUT(7 downto 0)	<= Memory(to_integer(unsigned(ADDRESS)));
			DATAOUT(15 downto 8)	<= Memory(to_integer(unsigned(ADDRESS))+1);
			DATAOUT(23 downto 16)	<= Memory(to_integer(unsigned(ADDRESS))+2);
			DATAOUT(31 downto 24)	<= Memory(to_integer(unsigned(ADDRESS))+3);
		end if;
	end if;                               

end process;  

dump_data: process(CLK, RST_n)
file dump_fp		: text open WRITE_MODE is dump_path;
variable line_out	: line;
variable tmp_data_out	: std_logic_vector(nb-1 DOWNTO 0);

begin
	if RST_n = '0' then
		null;
	elsif CLK'EVENT AND CLK = '1' then
		if DUMP = '1' then
			for i in 0 to 2**(nbit_ADDRESS-2) - 1 loop
				tmp_data_out := Memory(4*i+3) & Memory(4*i+2) & Memory(4*i+1) & Memory(4*i);
				hwrite(line_out, std_logic_vector(to_unsigned(4*i,nbit_ADDRESS)), right, 6);
            			hwrite(line_out, tmp_data_out, right, 15);
				writeline(dump_fp, line_out);
			end loop;
		end if;
	else
		null;
	end if;
end process;

end behav;


