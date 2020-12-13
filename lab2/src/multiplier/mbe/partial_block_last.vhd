LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY partial_block_last IS 
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+2-1 downto 0) --nb + '0' + S
	    );
END ENTITY;	

ARCHITECTURE behavioral OF partial_block_last IS

SIGNAL PP_BR: std_logic_vector(nb-1 downto 0);

BEGIN
------------------R4_BR_MUX----------------------------
R4_BR_MUX: process(A,B_sel)

BEGIN

	case B_sel is
		when "000" => PP_BR <= (others => '0');
		when "001" => PP_BR <= A;
		when others => PP_BR <= (others => 'X');
	end case;

END PROCESS;
-------------------------------------------------------


------------------SIGN_EXT-----------------------------
PP(0)			<=B_sel(0);
PP(1)			<= '0';
PP(nb+1 downto 2) 	<= PP_BR;
-------------------------------------------------------

END ARCHITECTURE;
