LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY dadda_pack IS
	PORT(	PP0:		 IN std_logic_vector(nb+4-1 DOWNTO 0);   --not(S) + S + S + SHF + nb
		PP_intermediate: IN PP_INTERMEDIATE_ARRAY; 	--'1' + not(S) + SHF + nb + '0' + S
		PP_sec_last:	 IN std_logic_vector(nb+2+2-1 DOWNTO 0); --not(S) + SHF + nb + '0' + S
		PP_last:	 IN std_logic_vector(nb+2-1 DOWNTO 0);   --nb + '0' + S
		DOUT:		 OUT DADDA_ARRAY
	    );
END ENTITY;


ARCHITECTURE behavioral OF dadda_pack IS

BEGIN

Fill_matrix_DOUT: PROCESS(PP0, PP_intermediate, PP_sec_last, PP_last)

VARIABLE local_matrix: DADDA_ARRAY ;
VARIABLE i: integer;
            
BEGIN

---------------PARALLELOGRAM MATRIX-----------------------------------
local_matrix(0)(nb+4-1 DOWNTO 0) := PP0;
DOUT(0)(nb+4-1 DOWNTO 0) <= PP0;
local_matrix(n_PP-1-1)(n_prod-1 DOWNTO n_prod-PP_sec_last'length) := PP_sec_last;
DOUT(n_PP-1-1)(nb+4-1 DOWNTO 0) <= local_matrix(n_PP-1-1)(nb+4-1 DOWNTO 0);
local_matrix(N_PP-1)(n_prod-1 DOWNTO n_prod-PP_last'length) := PP_last;
DOUT(n_PP-1)(nb+4-1 DOWNTO 0) <= local_matrix(n_PP-1)(nb+4-1 DOWNTO 0);

FOR riga IN 1 TO n_PP-2-1 LOOP
	local_matrix(riga)(nb+(3+2)-1 + 2*(riga-1) DOWNTO 2*(riga-1)) := PP_intermediate(riga-1);
	DOUT(riga)(nb+4-1 DOWNTO 0) <= local_matrix(riga)(nb+4-1 DOWNTO 0);
END LOOP;
----------------------------------------------------------------------


-----------------TRIANGLE MATRIX--------------------------------------
FOR col in n_prod-1 downto nb+4 loop
	i := col;                       
	for riga in 0 to N_PP-(((col-nb+1)/2)+1-2)-1 loop	--n_shift = ((col-nb+1)/2)+1-2
		DOUT(riga)(col) <= local_matrix(((col-nb+1)/2)+1-2+riga)(col);
	end loop;	
end loop;
----------------------------------------------------------------------
END PROCESS;


END ARCHITECTURE;
