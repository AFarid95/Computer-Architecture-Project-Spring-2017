library ieee;
use ieee.std_logic_1164.all;

entity reg_1_bit is
  port(
    clk,enable,d: in std_logic;
    q : out std_logic
  );
end reg_1_bit;

architecture a_reg_1_bit of reg_1_bit is
begin
  
  process(clk)
  begin
     if clk'event and clk = '1' then
       if (enable = '1') then
 	       q <= d;
 	     end if;
 	   end if;
 	end process;
  
end a_reg_1_bit;
