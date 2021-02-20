LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE ieee.std_logic_misc.all;
USE work.mypackage.all;

entity ALU is
	port(
		ALU_CONTROL	: IN std_logic_vector(ALU_CONTROL_SIZE-1 DOWNTO 0); --from CU
		DATA1		: IN std_logic_vector(nb-1 DOWNTO 0); --from DP
		DATA2		: IN std_logic_vector(nb-1 DOWNTO 0); --from DP
		Z		: OUT std_logic; --to CU
		DATA_OUT	: OUT std_logic_vector(nb-1 DOWNTO 0) --to DP
	);
end ALU;

ARCHITECTURE behavioral OF ALU is

BEGIN

P_ALU: PROCESS(ALU_CONTROL,DATA1,DATA2)

variable var : std_logic_vector(nb-1 DOWNTO 0);

BEGIN
	CASE ALU_CONTROL IS
		WHEN ADD_C	=>	var := std_logic_vector(signed(DATA1) + signed(DATA2));
		WHEN AND_C	=>	var := DATA1 AND DATA2;
		WHEN XOR_C	=>	var := DATA1 XOR DATA2;
		WHEN SRAI_C	=>	var := DATA1;
						var := std_logic_vector(shift_right(signed(DATA1),to_integer(unsigned(DATA2))));
		WHEN SLT_C	=>	if (DATA1 < DATA2) then
							var(0) := '1';
							var(nb-1 DOWNTO 1) := (others => '0');
						else
							var := (others => '0');
						end if;
		WHEN OTHERS	=>	var := (others => 'X');				
	END CASE;	
	
	Z <= not(or_reduce(var));
	DATA_OUT <= var;
	
END PROCESS;

END ARCHITECTURE;
