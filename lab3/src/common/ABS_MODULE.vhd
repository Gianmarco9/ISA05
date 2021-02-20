LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

entity ABS_MODULE is
	port(
		EN_ABS		: IN std_logic; --from CU
		DATA_IN		: IN std_logic_vector(nb-1 DOWNTO 0); --from DP
		DATA_OUT	: OUT std_logic_vector(nb-1 DOWNTO 0) --to DP
	);
end ABS_MODULE;

ARCHITECTURE behavioral OF ABS_MODULE IS

BEGIN

P_ABS:	PROCESS(EN_ABS, DATA_IN)

BEGIN

	if (EN_ABS = '1') then 
		if (DATA_IN(nb-1) = '1') then
			DATA_OUT <= std_logic_vector(unsigned(not(DATA_IN)) + 1);
		else
			DATA_OUT <= DATA_IN;
		end if;
	else
		DATA_OUT <= DATA_IN;
	end if;

END PROCESS;

END ARCHITECTURE; 