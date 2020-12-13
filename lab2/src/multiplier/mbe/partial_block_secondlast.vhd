LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY partial_block_secondlast IS 
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+4-1 downto 0) --not(S) + SHF + nb + '0' + S
	    );
END ENTITY;	

ARCHITECTURE behavioral OF partial_block_secondlast IS

SIGNAL PP_BR,B_MSB_extend: std_logic_vector(nb downto 0);

BEGIN
------------------R4_BR_MUX----------------------------
R4_BR_MUX: process(A,B_sel)

BEGIN

	case B_sel is
		when "000" => PP_BR <= (others => '0');
		when "001" => PP_BR <= '0' & A;
		when "010" => PP_BR <= '0' & A;
		when "011" => PP_BR <= A & '0';
		when "100" => PP_BR <= A & '0';
		when "101" => PP_BR <= '0' & A;
		when "110" => PP_BR <= '0' & A;
		when "111" => PP_BR <= (others => '0');
		when others => PP_BR <= (others => 'X');
	end case;

END PROCESS;
-------------------------------------------------------


------------------CONTROLLED_NOT & SIGN EXT------------
B_MSB_extend 		<= (others => B_sel(exp_radix));
PP(0)			<= B_sel(0);
PP(1)			<= '0';
PP(nb+2 downto 2) 	<= PP_BR xor B_MSB_extend;
PP(nb+3)		<= not(B_sel(exp_radix)); 
-------------------------------------------------------

	
END ARCHITECTURE;
