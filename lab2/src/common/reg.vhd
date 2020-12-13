LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE work.mypackage.all;

ENTITY reg IS
GENERIC (N: POSITIVE := 8);
PORT (
      CLK:	IN STD_LOGIC;
      RST_n:	IN STD_LOGIC;
      EN:	IN STD_LOGIC;
      D_IN:	IN STD_LOGIC_VECTOR(N-1 DOWNTO 0);
      D_OUT:	OUT STD_LOGIC_VECTOR(N-1 DOWNTO 0));
END ENTITY;

ARCHITECTURE behavioral OF reg IS

BEGIN

reg_process: process(CLK, RST_n)
  begin

    if RST_n = '0' then
      D_OUT <= (others => '0');

    elsif CLK'event and CLK = '1' then
      if EN = '1' then
        D_OUT <= D_IN;
      end if;
    end if;
  end process;

  END behavioral;
