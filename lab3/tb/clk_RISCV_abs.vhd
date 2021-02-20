library ieee;
use ieee.std_logic_1164.all;

entity clk_RISCV_abs is
  port (
    CLK     : out std_logic;
    RST_n   : out std_logic;
    DUMP    : out std_logic);
end clk_RISCV_abs;

architecture beh of clk_RISCV_abs is

  signal CLK_i   : std_logic := '0';
  signal RST_n_i : std_logic := '0';
  signal DUMP_i  : std_logic := '0';
  
begin  -- beh

	RST_n_i <= '1' AFTER 35 ns;
        CLK_i   <= NOT(CLK_i) AFTER 7 ns;
        DUMP_i  <= '1' AFTER 1309 ns, '0' AFTER 1316 ns;
	

	CLK     <= CLK_i;
	RST_n	<= RST_n_i;
	DUMP	<= DUMP_i;
end beh;
