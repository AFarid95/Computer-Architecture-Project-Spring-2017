library ieee;
use ieee.std_logic_1164.all;

entity reg_n_bit is
  generic (n : integer);
  port(
    Clk,En : in std_logic;
    d : in std_logic_vector(n-1 downto 0);
    q : out std_logic_vector(n-1 downto 0)
  );
end reg_n_bit;

Architecture a_reg_n_bit of reg_n_bit is
  
  component reg_1_bit is
  port(
    clk,enable,d: in std_logic;
    q : out std_logic
  );
  end component;

begin
  loop1: for i in 0 to n-1 generate
    fx: reg_1_bit port map(Clk,En,d(i),q(i));
  end generate;

end a_reg_n_bit;
