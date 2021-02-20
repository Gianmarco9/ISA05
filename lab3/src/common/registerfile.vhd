library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.mypackage.all;

ENTITY register_file IS
PORT ( 
	CLK: 		IN std_logic;
	RST_n:		IN std_logic;
	WR: 		IN std_logic;
	ADD_WR:		IN std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	ADD_RD1:	IN std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	ADD_RD2:	IN std_logic_vector(REG_ADDR_SIZE-1 downto 0);
	DATA_IN:	IN std_logic_vector(nb-1 downto 0);
	DATA_OUT1:	OUT std_logic_vector(nb-1 downto 0);
	DATA_OUT2:	OUT std_logic_vector(nb-1 downto 0)
	);
END register_file;

ARCHITECTURE behavioral OF register_file IS

subtype REG_ADDR is natural range 0 to 2**(REG_ADDR_SIZE)-2; 
type REG_ARRAY is array(REG_ADDR) of std_logic_vector(nb-1 downto 0); 
signal REGISTERS : REG_ARRAY;
	
begin

read_regs: process(ADD_RD1, ADD_RD2, REGISTERS)
begin
	case (to_integer(unsigned(ADD_RD1))) is
		when 0 =>
			DATA_OUT1 <= (others => '0');
		when others =>
			DATA_OUT1 <= REGISTERS(to_integer(unsigned(ADD_RD1))-1);
	end case;

	case (to_integer(unsigned(ADD_RD2))) is
		when 0 =>
			DATA_OUT2 <= (others => '0');
		when others =>	
			DATA_OUT2 <= REGISTERS(to_integer(unsigned(ADD_RD2))-1);
	end case;
end process;



write_regs: process(RST_n,CLK)
begin
	if RST_n = '0' then
		REGISTERS(0 to 2**(REG_ADDR_SIZE)-2) <= (others=>(others => '0'));
	elsif CLK = '0' and CLK'event then
		if WR = '1' then
			if (to_integer(unsigned(ADD_WR)) = 0) then
				NULL;
			else
      				REGISTERS(to_integer(unsigned(ADD_WR))-1) <= DATA_IN;
			end if;
		end if;
	end if;		
end process;

end behavioral;
