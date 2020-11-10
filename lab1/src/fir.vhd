LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY fir IS
PORT (
      CLK:	IN STD_LOGIC;
      RST_n:	IN STD_LOGIC;
      VIN:	IN STD_LOGIC;
      b:	IN STD_LOGIC_VECTOR (tot_bit-1 DOWNTO 0);
      DIN:	IN STD_LOGIC_VECTOR (nb-1 DOWNTO 0);	-- flatten array of coefficients
      DOUT:	OUT STD_LOGIC_VECTOR (nb-1 DOWNTO 0);
      VOUT:	OUT STD_LOGIC);
END ENTITY;

ARCHITECTURE structural OF fir IS

-- INTERNAL SIGNALS

SIGNAL din_reg:   REG_ARRAY;
SIGNAL b_reg: 	  STD_LOGIC_VECTOR(tot_bit-1 DOWNTO 0);
SIGNAL mult_sign: MULT_ARRAY;
SIGNAL add_sign:  ADD_ARRAY;
SIGNAL vin_s: 	  STD_LOGIC;


-- COMPONENTS

COMPONENT reg IS
GENERIC( N : positive := 8  );
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

-- DIN REG

REG_din: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => DIN,
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
         D_OUT(0) => vin_s
);

-- DOUT REG

REG_dout: reg
GENERIC MAP( N => nb)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN => std_logic_vector(add_sign(order-1)),
         D_OUT => DOUT
);

-- VOUT REG

REG_vout: reg
GENERIC MAP( N => 1)
PORT MAP(
         CLK => CLK,
         RST_n => RST_n,
         EN => '1',
         D_IN(0) => vin_s,
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
           EN => vin_s,
           D_IN => din_reg(i),
           D_OUT => din_reg(i+1)
  );
end generate;
-------------------------------------------------------

-- INTERNAL PRODUCTS

internal_products: for i in 0 to order generate
  mult_sign(i) <= signed(din_reg(i)) * signed(b_reg((tot_bit-1)-i*nb DOWNTO tot_bit-(i+1)*nb));		-- extraction of coefficients bi from the flatten array
end generate;
-------------------------------------------------------

-- INTERNAL SUMS

-- First sum is done outside of the for loop
add_sign(0) <= mult_sign(0)(2*nb-2 DOWNTO nb-1) + mult_sign(1)(2*nb-2 DOWNTO nb-1);

internal_sums: for i in 1 to order-1 generate
  add_sign(i) <= add_sign(i-1) + mult_sign(i+1)(2*nb-2 DOWNTO nb-1);
end generate;
-------------------------------------------------------

end architecture structural;
