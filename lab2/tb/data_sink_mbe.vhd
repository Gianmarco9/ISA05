library ieee;
use work.mypackage.all;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_sink_mbe is
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    DATA   : in std_logic_vector(n_prod-1 downto 0));
end data_sink_mbe;

architecture beh of data_sink_mbe is

begin  -- beh

  process (CLK, RST_n)
    file res_fp : text open WRITE_MODE is "./results.hex";
    variable line_out : line;
	variable flag: boolean := false; --to ignore first result due to reset
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      flag := false;
    elsif CLK'event and CLK = '1' then  -- rising clock edge 
		if flag = false then
			flag := true;
		else
			hwrite(line_out, DATA);
			writeline(res_fp, line_out);
		end if;
	end if;
  end process;

end beh;
