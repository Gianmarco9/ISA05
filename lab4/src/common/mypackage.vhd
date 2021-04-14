LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

PACKAGE mypackage IS

--FPMUL

	CONSTANT nb	 : positive := 32;		--input data parallelism
	CONSTANT n_pipe	 : positive := 4;		--number of pipe stages
	CONSTANT add_reg : positive := 2;		--number of additional registers added to the structure (1 when only input regs are present,
							--2 when also internal pipe between stage2 and stage3 is present)


	CONSTANT nb_exp  : positive := 8;		--number of bits of exponent for FP
	CONSTANT nb_SIG	 : positive := 28;		--number of bits used by STAGE2 to express significands

--MBE

	CONSTANT exp_radix : positive := 2;		--exponent of the radix (radix 4 => exp 2)
	CONSTANT n_PP : positive := (nb/exp_radix)+1;	--number of partial products
	CONSTANT n_prod : positive := 2*nb;		--mbe output data parallelism
	
	TYPE PP_INTERMEDIATE_ARRAY IS ARRAY (0 to (n_PP-3)-1) OF STD_LOGIC_VECTOR(nb+(3+2)-1 DOWNTO 0);	--2D vector of intermediate partial products
													--(from PP(1) to PP(n_PP-3))

	TYPE DADDA_ARRAY IS ARRAY (0 to n_PP-1) OF STD_LOGIC_VECTOR(n_prod-1 downto 0);			--2D vector packing all the partial products

END PACKAGE mypackage;
