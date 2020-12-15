LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.numeric_std.all;
USE work.mypackage.all;

ENTITY tb_daddapack IS
end tb_daddapack;

architecture tb of tb_daddapack IS

COMPONENT dadda_pack
	PORT(	PP0:		 IN std_logic_vector(nb+4-1 DOWNTO 0);   --not(S) + S + S + SHF + nb
		PP_intermediate: IN PP_INTERMEDIATE_ARRAY; 	--'1' + not(S) + SHF + nb + '0' + S
		PP_sec_last:	 IN std_logic_vector(nb+2+2-1 DOWNTO 0); --not(S) + SHF + nb + '0' + S
		PP_last:	 IN std_logic_vector(nb+2-1 DOWNTO 0);   --nb + '0' + S
		DOUT:		 OUT DADDA_ARRAY
	    );
END COMPONENT;

signal PP0_s: std_logic_vector(nb+4-1 DOWNTO 0);--32 bit + 3 s + 1 bit for 2A
signal PP_intermediate_s: PP_INTERMEDIATE_ARRAY;
signal PP_sec_last_s: std_logic_vector(nb+3+1-1 DOWNTO 0);
signal PP_last_s: std_logic_vector(nb+2-1 DOWNTO 0);
signal DOUT_s: DADDA_ARRAY;

begin

UUT : dadda_pack port map (PP0_s,PP_intermediate_s,PP_sec_last_s,PP_last_s,DOUT_s);

process
begin
PP0_s <= (others => '1');
PP_intermediate_s <= (others => (others => '1'));
PP_sec_last_s <= (others => '1');
PP_last_s <= (others => '1');

wait;
end process;

end architecture;
