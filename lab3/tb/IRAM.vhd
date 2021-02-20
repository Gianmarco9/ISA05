library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use std.textio.all;
use work.mypackage.all;

entity IRAM is
	generic(file_path	: string := "../tb/instruction_ram_dump.txt";
		nbit_ADDRESS	: integer := 12;		-- 4 kB => 2^12 x 8 bit
		nbit_WORD	: integer:= 8);
				
	port(	CLK		: in  std_logic;
		RST_n		: in  std_logic;	
		ADDRESS		: in  std_logic_vector(nbit_ADDRESS-1 downto 0);
		DOUT		: out std_logic_vector(nb-1 downto 0)
		);
end IRAM;

architecture behavioral of IRAM is

subtype MEM_ADDR is natural range 0 to (2**nbit_ADDRESS)-1;
type MEM_ARRAY is array (MEM_ADDR) of std_logic_vector(nbit_WORD-1 downto 0);
signal Memory : MEM_ARRAY;
	
begin

process (RST_n,CLK)

file mem_fp		: text open READ_MODE is file_path; 
variable file_line 	: line;
variable index 		: integer := 0;
variable tmp_data	: std_logic_vector(nb-1 downto 0);

begin
	
	if (Rst_n = '0') then
		while not endfile(mem_fp) loop
			readline(mem_fp, file_line);
			read(file_line, tmp_data);
			Memory(index)	<= tmp_data(7 downto 0);
			Memory(index+1)	<= tmp_data(15 downto 8);
			Memory(index+2)	<= tmp_data(23 downto 16);
			Memory(index+3)	<= tmp_data(31 downto 24);
			index := index + 4;
		end loop;

	else
		if (CLK'EVENT and CLK = '0') then
			DOUT(7 downto 0)   <= Memory(to_integer(unsigned(ADDRESS)));	
			DOUT(15 downto 8)  <= Memory(to_integer(unsigned(ADDRESS))+1);	
			DOUT(23 downto 16) <= Memory(to_integer(unsigned(ADDRESS))+2);	
			DOUT(31 downto 24) <= Memory(to_integer(unsigned(ADDRESS))+3);	
		end if;
	end if;	
	
end process;

end behavioral;


