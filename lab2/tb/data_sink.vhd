library ieee;
use work.mypackage.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity data_sink is
  port (
    CLK   : in std_logic;
    RST_n : in std_logic;
    DATA   : in std_logic_vector(nb-1 downto 0));
end data_sink;

architecture beh of data_sink is

begin  -- beh

  process (CLK, RST_n)
    file res_fp : text open WRITE_MODE is "./results.hex";
    variable count_pipe : integer := 0;	-- to avoid writing when the output is uninitialized (due to pipeline stages)
    variable line_out : line;    
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      count_pipe := 0;
    elsif CLK'event and CLK = '1' then  -- rising clock edge
        if count_pipe <= n_pipe+add_reg then	--n_pipe + additional_registers
		count_pipe := count_pipe + 1;
	else 
		hwrite(line_out, DATA);
       		writeline(res_fp, line_out);
	end if;
    end if;
  end process;

end beh;
