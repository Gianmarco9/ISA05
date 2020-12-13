LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY MBE IS
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B: 	IN std_logic_vector(nb-1 downto 0);
		DOUT: 	OUT std_logic_vector(n_prod-1 downto 0)
	);
END MBE;

ARCHITECTURE structural OF MBE IS

COMPONENT partial_block_first  
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+4-1 downto 0)
	);
END COMPONENT;

COMPONENT partial_block_intermediate 
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+5-1 downto 0)
	);
END COMPONENT;

COMPONENT partial_block_secondlast  
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+4-1 downto 0)
	);
END COMPONENT;	

COMPONENT partial_block_last  
	PORT(	A: 	IN std_logic_vector(nb-1 downto 0);
		B_sel:	IN std_logic_vector(exp_radix downto 0);	
		PP:	OUT std_logic_vector(nb+2-1 downto 0)
	);
END COMPONENT;	

COMPONENT dadda_pack 
	PORT(	PP0:		 IN std_logic_vector(nb+4-1 DOWNTO 0);
		PP_intermediate: IN PP_INTERMEDIATE_ARRAY ;
		PP_sec_last:	 IN std_logic_vector(nb+3+1-1 DOWNTO 0);
		PP_last:	 IN std_logic_vector(nb+2-1 DOWNTO 0);
		DOUT:		 OUT DADDA_ARRAY
		);
END COMPONENT;	

COMPONENT dadda_tree 
	PORT(	PP_IN:  	IN DADDA_ARRAY;
		PP_OUT1:	OUT STD_LOGIC_VECTOR(n_prod-1 DOWNTO 0);
		PP_OUT2:	OUT STD_LOGIC_VECTOR(n_prod-1 DOWNTO 0)
		);
END COMPONENT;

SIGNAL	PP0_s:			std_logic_vector(nb+4-1 downto 0);
SIGNAL	PP_intermediate_vec: 	PP_INTERMEDIATE_ARRAY;	
SIGNAL	PP_sec_last_s:		std_logic_vector(nb+4-1 downto 0);
SIGNAL	PP_last_s:		std_logic_vector(nb+2-1 downto 0);
SIGNAL	dadda_pack_array: 	DADDA_ARRAY;	
SIGNAL	op1_s,op2_s:		std_logic_vector(n_prod-1 downto 0);	

BEGIN

---------------------PARTIAL_BLOCKS-----------------------------------------------------
--PB(0)
PB_0: partial_block_first port map(
				   A		     =>  A,
				   B_sel(2 downto 1) =>  B(1 downto 0),
				   B_sel(0)	     =>  '0',
				   PP		     =>	 PP0_s
				  );

--from PB(1) to PB(n_PP-3)
PB_intermediate_gen: for i in 1 to N_PP-3 generate
	PB_i: partial_block_intermediate port map(A,B(2*i-1+2 downto 2*i-1),PP_intermediate_vec(i-1));
end generate;

--PB(n_PP-2)
PB_sec_last: partial_block_secondlast port map (A,B(nb-1 downto nb-3),PP_sec_last_s);

--PB(n_PP-1)
PB_last: partial_block_last port map(
				     A		       =>  A,
				     B_sel(2 downto 1) =>  "00",
				     B_sel(0)	       =>  B(nb-1),
				     PP		       =>  PP_last_s
				    );
----------------------------------------------------------------------------------------


---------------------DADDA_PACK---------------------------------------------------------
DP: dadda_pack port map(
			PP0 		  => PP0_s,
			PP_intermediate   => PP_intermediate_vec,
			PP_sec_last	  => PP_sec_last_s,
			PP_last		  => PP_last_s,
			DOUT		  => dadda_pack_array
		       );
----------------------------------------------------------------------------------------


---------------------DADDA_TREE---------------------------------------------------------

dadda_tree_comp: dadda_tree port map(dadda_pack_array,op1_s,op2_s);

----------------------------------------------------------------------------------------

---------------------BEHAVIOURAL ADDER--------------------------------------------------

DOUT <= std_logic_vector(unsigned(op1_s) + unsigned(op2_s));

----------------------------------------------------------------------------------------

END ARCHITECTURE;
