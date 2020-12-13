LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY FA IS
	PORT(	A: 	IN std_logic;
		B: 	IN std_logic;
		Ci: 	IN std_logic;
		S: 	OUT std_logic;
		Co: 	OUT std_logic
	    );
END FA;

ARCHITECTURE behavioral OF FA IS

BEGIN

S <= A XOR B XOR Ci;
Co <= (A AND B) OR (A AND Ci) OR (B AND Ci);

END ARCHITECTURE;
