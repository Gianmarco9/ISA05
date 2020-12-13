library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
USE work.mypackage.all;


library std;
use std.textio.all;

entity data_maker_mbe is
  port (
    CLK  : in  std_logic;
	RST_n: in  std_logic;
    DATA_A : out std_logic_vector(nb-1 downto 0);
	DATA_B : out std_logic_vector(nb-1 downto 0);
	END_SIM : out std_logic
	);
end data_maker_mbe;

architecture beh of data_maker_mbe is 

begin  -- beh

  process (CLK)
    file fp : text open read_mode is "../tb/inputs_mbe.hex";
    variable ptr : line;
    variable val : std_logic_vector(nb-1 downto 0);
  begin  -- process
	if RST_n = '0' then
		DATA_A <= (others => '0');
		DATA_B <= (others => '0');
		END_SIM <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (not(endfile(fp))) then
        readline(fp, ptr);
        hread(ptr, val);
		DATA_A <= val;
		
		readline(fp, ptr);
		hread(ptr, val);
		DATA_B <= val;
		END_SIM <= '0';
	  else
		END_SIM <= '1';
      end if;
    end if;
  end process;
 
end beh;
