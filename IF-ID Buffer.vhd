library ieee;
use ieee.std_logic_1164.all;

entity IF_ID_buffer is
  port(
    clk,IF_ID_write : in std_logic;
    data_IF : in std_logic_vector(15 downto 0);
    data_ID : out std_logic_vector(15 downto 0)
  );
end IF_ID_buffer;

architecture IF_ID_buffer_arch of IF_ID_buffer is
  
  component reg_n_bit is
  generic (n : integer);
  port(
  Clk,En : in std_logic;
  d : in std_logic_vector(n-1 downto 0);
  q : out std_logic_vector(n-1 downto 0)
  );
  end component;
  
  begin
    
    data: reg_n_bit generic map(n=>16) port map(clk,IF_ID_write,data_IF,data_ID);
  
end IF_ID_buffer_arch;
