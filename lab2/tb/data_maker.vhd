library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_textio.all;
USE work.mypackage.all;


library std;
use std.textio.all;

entity data_maker is
  port (
    CLK  : in  std_logic;
	RST_n: in  std_logic;
    DATA : out std_logic_vector(nb-1 downto 0);
	END_SIM : out std_logic
	);
end data_maker;

architecture beh of data_maker is

 signal sEndSim : std_logic;
 signal END_SIM_i : std_logic_vector(0 to n_pipe-1+add_reg); --n_pipe + additional_registers 

begin  -- beh

  process (CLK)
    file fp : text open read_mode is "../tb/fp_samples.hex";
    variable ptr : line;
    variable val : std_logic_vector(nb-1 downto 0);
  begin  -- process
	if RST_n = '0' then
		DATA <= (others => '0');
		sEndSim <= '0';
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      if (not(endfile(fp))) then
        readline(fp, ptr);
        hread(ptr, val);
		DATA <= val;
		sEndSim <= '0';
	  else
		sEndSim <= '1';
      end if;
    end if;
  end process;
 
 
--process to generate the end of the simulation signal
end_of_sim:  process (CLK, RST_n)
  begin  -- process
    if RST_n = '0' then                 -- asynchronous reset (active low)
      END_SIM_i <= (others => '0');
    elsif CLK'event and CLK = '1' then  -- rising clock edge
      END_SIM_i(0) <= sEndSim;
      END_SIM_i(1 to n_pipe-1+add_reg) <= END_SIM_i(0 to n_pipe-2+add_reg);
    end if;
  end process;

  END_SIM <= END_SIM_i(n_pipe-1+add_reg);  

end beh;
