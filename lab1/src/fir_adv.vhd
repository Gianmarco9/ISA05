LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;


-- DIN1 is x[3k]        DOUT1 is y[3k]
-- DIN2 is x[3k+1]      DOUT2 is y[3k+1]
-- DIN3 is x[3k+2]      DOUT3 is y[3k+2]

ENTITY fir_adv IS
PORT (
      CLK:	                IN STD_LOGIC;
      RST_n:	                IN STD_LOGIC;
      VIN:	                IN STD_LOGIC;
      b:	                IN STD_LOGIC_VECTOR (tot_bit-1 DOWNTO 0);	-- flatten array of coefficients
      DIN1, DIN2, DIN3:		IN STD_LOGIC_VECTOR (nb-1 DOWNTO 0);
      DOUT1, DOUT2, DOUT3:	OUT STD_LOGIC_VECTOR (nb-1 DOWNTO 0);
      VOUT:	                OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE structural OF fir_adv IS

-- INTERNAL SIGNALS

SIGNAL din_reg: 			   REG_ARRAY_UNF;
SIGNAL reg_pipe1,reg_pipe2,reg_pipe3: REG_ARRAY;
SIGNAL b_reg: 				   STD_LOGIC_VECTOR(tot_bit-1 DOWNTO 0);
SIGNAL mult_sign1, mult_sign2, mult_sign3: MULT_ARRAY;
SIGNAL add_sign1, add_sign2, add_sign3:    ADD_ARRAY;
SIGNAL vin_pipe: STD_LOGIC_VECTOR(n_pipe downto 0);


-- COMPONENTS

COMPONENT reg IS
GENERIC (N: POSITIVE := 8);
PORT (
      CLK:	IN STD_LOGIC;
      RST_n:	IN STD_LOGIC;
      EN:	IN STD_LOGIC;
      D_IN:	IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
      D_OUT:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END COMPONENT;


BEGIN

-------------------------------------------------------
-- INTERFACE REGISTERS

-- DIN1 REG
-- x[3k]

REG_din1: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => DIN1,
         D_OUT => din_reg(2)
);

-- DIN2 REG
-- x[3k+1]

REG_din2: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => DIN2,
         D_OUT => din_reg(1)
);

-- DIN3 REG
-- x[3k+2]

REG_din3: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => DIN3,
         D_OUT => din_reg(0)
);

-- VIN REG

REG_vin: reg
GENERIC MAP( N => 1)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN(0) => VIN,
         D_OUT(0) => vin_pipe(0)
);

-- DOUT1 REG
-- y[3k]

REG_dout1: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => std_logic_vector(add_sign1(order-1)),
         D_OUT => DOUT1
);

-- DOUT2 REG
-- y[3k+1]

REG_dout2: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => std_logic_vector(add_sign2(order-1)),
         D_OUT => DOUT2
);

-- DOUT3 REG
-- y[3k+2]

REG_dout3: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => std_logic_vector(add_sign3(order-1)),
         D_OUT => DOUT3
);

-- VOUT REG

REG_vout: reg
GENERIC MAP( N => 1)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN(0) => vin_pipe(n_pipe),
         D_OUT(0) => VOUT
);

-- b REG

REG_b: reg
GENERIC MAP( N => tot_bit)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => b,
         D_OUT => b_reg
);
-------------------------------------------------------

-- INTERNAL REGISTERS CHAIN

register_chain: for i in 0 to order-1 generate
  reg_i: reg
  GENERIC MAP( N => nb)
  PORT MAP(
           CLK => CLK,
           RST_n => RST_n,
           EN => vin_pipe(0),
           D_IN => din_reg(i),
           D_OUT => din_reg(i+3)
  );
end generate;
-------------------------------------------------------

-- INTERNAL PRODUCTS

internal_products: for i in 0 to order generate
  mult_sign1(i) <= signed(din_reg(i+2)) * signed(b_reg((tot_bit-1)-i*nb DOWNTO tot_bit-(i+1)*nb));	-- extraction of coefficients bi from the flatten array
  mult_sign2(i) <= signed(din_reg(i+1)) * signed(b_reg((tot_bit-1)-i*nb DOWNTO tot_bit-(i+1)*nb));
  mult_sign3(i) <= signed(din_reg(i)) * signed(b_reg((tot_bit-1)-i*nb DOWNTO tot_bit-(i+1)*nb));
end generate;
-------------------------------------------------------

-- PIPE1(3k) REGISTERS BETWEEN MULT AND ADD

register_pipe1: for i in 0 to order generate
  pip1_i: reg
  GENERIC MAP( N => nb)
  PORT MAP(
           CLK => CLK,
           RST_n => RST_n,
           EN => Vin_pipe(0),
	   D_IN => std_logic_vector(mult_sign1(i)(2*nb-2 DOWNTO nb-1)),
           D_OUT =>  reg_pipe1(i)
  );
end generate;

-------------------------------------------------------

-- PIPE2(3k+1) REGISTERS BETWEEN MULT AND ADD

register_pipe2: for i in 0 to order generate
  pip1_i: reg
  GENERIC MAP( N => nb)
  PORT MAP(
           CLK => CLK,
           RST_n => RST_n,
           EN => Vin_pipe(0),
	   D_IN => std_logic_vector(mult_sign2(i)(2*nb-2 DOWNTO nb-1)),
           D_OUT =>  reg_pipe2(i)
  );
end generate;

-------------------------------------------------------

-- PIPE3(3k+2) REGISTERS BETWEEN MULT AND ADD

register_pipe3: for i in 0 to order generate
  pip1_i: reg
  GENERIC MAP( N => nb)
  PORT MAP(
           CLK => CLK,
           RST_n => RST_n,
           EN => Vin_pipe(0),
	   D_IN => std_logic_vector(mult_sign3(i)(2*nb-2 DOWNTO nb-1)),
           D_OUT =>  reg_pipe3(i)
  );
end generate;

-------------------------------------------------------

-- INTERNAL SUMS

-- First sum of each unfolded adders chain is done outside of the "FOR" loop
add_sign1(0) <= signed(reg_pipe1(0)) + signed(reg_pipe1(1));
add_sign2(0) <= signed(reg_pipe2(0)) + signed(reg_pipe2(1));
add_sign3(0) <= signed(reg_pipe3(0)) + signed(reg_pipe3(1));

internal_sums: for i in 1 to order-1 generate
  add_sign1(i) <= add_sign1(i-1) + signed(reg_pipe1(i+1));
  add_sign2(i) <= add_sign2(i-1) + signed(reg_pipe2(i+1));
  add_sign3(i) <= add_sign3(i-1) + signed(reg_pipe3(i+1));
end generate;

---------------------------------------------------

--registers_pipe between vin and vout

Vin_pipe_CU: for i in 0 to n_pipe-1 generate
  Vin_i: reg
  GENERIC MAP( N => 1)
  PORT MAP(
           CLK => CLK,
           RST_n => RST_n,
           EN => '1',
		   D_IN(0) => Vin_pipe(i),
           D_OUT(0)=>  Vin_pipe(i+1)
  );
end generate;
-----------------------------------------------------

end structural;
