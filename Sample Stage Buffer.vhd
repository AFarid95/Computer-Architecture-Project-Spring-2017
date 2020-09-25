library ieee;
use ieee.std_logic_1164.all;

entity sample_stage_buffer is
  port(
    clk : in std_logic;
    reg1_instage : in std_logic_vector(15 downto 0);
    reg1_outstage : out std_logic_vector(15 downto 0);
    reg2_instage : in std_logic_vector(9 downto 0);
    reg2_outstage : out std_logic_vector(9 downto 0)
  );
end sample_stage_buffer;

architecture sample_stage_buffer_arch of sample_stage_buffer is
  
  component reg_n_bit is
  generic (n : integer);
  port(
  Clk : in std_logic;
  d : in std_logic_vector(n-1 downto 0);
  q : out std_logic_vector(n-1 downto 0)
  );
  end component;
  
  begin
    
    reg1: reg_n_bit generic map(n=>16) port map(clk,reg1_instage,reg1_outstage);    
    reg2: reg_n_bit generic map(n=>10) port map(clk,reg2_instage,reg2_outstage);
  
end sample_stage_buffer_arch;
