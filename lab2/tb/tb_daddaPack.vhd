LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY tb_daddapack IS
end tb_daddapack;

architecture tb of tb_daddapack IS

COMPONENT dadda_pack
	PORT(	PP0:	IN std_logic_vector(nb+4-1 DOWNTO 0);--32 bit + 3 s + 1 bit for 2A
		PPint:	IN PP_INTERMEDIATE_ARRAY;
		PP15:	IN std_logic_vector(nb+2+2-1 DOWNTO 0);
		PP16:	IN std_logic_vector(nb+2-1 DOWNTO 0);
		DOUT:	OUT DADDA_ARRAY
		);
END COMPONENT;

signal PP0_s: std_logic_vector(nb+4-1 DOWNTO 0);--32 bit + 3 s + 1 bit for 2A
signal PPint_s: PP_INTERMEDIATE_ARRAY;
signal PP15_s: std_logic_vector(nb+3+1-1 DOWNTO 0);
signal PP16_s: std_logic_vector(nb+2-1 DOWNTO 0);
signal DOUT_s: DADDA_ARRAY;

begin

UUT : dadda_pack port map (PP0_s,PPint_s,PP15_s,PP16_s,DOUT_s);

process
begin
PP0_s <= (others => '1');
PPint_s <= (others => (others => '1'));
PP15_s <= (others => '1');
PP16_s <= (others => '1');

wait;
end process;

end architecture;
