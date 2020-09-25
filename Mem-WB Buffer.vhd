library ieee;
use ieee.std_logic_1164.all;

entity Mem_WB_buffer is
  port(
  clk : in std_logic;
	CCR_IN : in std_logic_vector ( 3 downto 0);
	CCR_OUT : out std_logic_vector ( 3 downto 0);
	ALU_RES_IN : in std_logic_vector ( 15 downto 0);
	ALU_RES_OUT : out std_logic_vector ( 15 downto 0);
	Read_Data_IN : in std_logic_vector ( 15 downto 0);
	Read_Data_OUT : out std_logic_vector ( 15 downto 0);
	SP_IN : in std_logic_vector ( 9 downto 0);
	SP_OUT : out std_logic_vector ( 9 downto 0);
	Rdst_IN : in std_logic_vector ( 2 downto 0);
	Rdst_OUT : out std_logic_vector ( 2 downto 0);
	imm_IN : in std_logic_vector ( 15 downto 0);
	imm_OUT : out std_logic_vector ( 15 downto 0);
	Written_Data_IN : in std_logic_vector ( 1 downto 0);
	Written_Data_OUT : out std_logic_vector ( 1 downto 0);
	Reg_Write_IN : in std_logic;
	Reg_Write_OUT : out std_logic;
	SP_Write_IN : in std_logic;
	SP_Write_OUT : out std_logic;
	CCR_Write_IN : in std_logic;
	CCR_Write_OUT : out std_logic;
	RET_IN : in std_logic;
	RET_OUT: out std_logic
  );
end Mem_WB_buffer;

architecture A_Mem_WB_buffer of Mem_WB_buffer is
  
  component reg_1_bit is
    port(
      clk,enable,d: in std_logic;
      q : out std_logic
    );
  end component;
  
  component reg_n_bit is
  generic (n : integer);
  port(
  Clk,En : in std_logic;
  d : in std_logic_vector(n-1 downto 0);
  q : out std_logic_vector(n-1 downto 0)
  );
  end component;
  
  begin
    
 	CCR_REG: reg_n_bit generic map(n=>4) port map(clk,'1',CCR_IN,CCR_OUT);    
  ALU_RES_REG: reg_n_bit generic map(n=>16) port map(clk,'1',ALU_RES_IN,ALU_RES_OUT);
	Read_Data_REG: reg_n_bit generic map(n=>16) port map(clk,'1',Read_Data_IN,Read_Data_OUT);
	SP_REG: reg_n_bit generic map(n=>10) port map(clk,'1',SP_IN,SP_OUT);
	Rdst_REG: reg_n_bit generic map(n=>3) port map(clk,'1',Rdst_IN,Rdst_OUT);
	Imm_REG: reg_n_bit generic map(n=>16) port map(clk,'1',imm_IN,imm_OUT);
	Written_Data_REG: reg_n_bit generic map(n=>2) port map(clk,'1',Written_Data_IN,Written_Data_OUT);
	Reg_Write_REG: reg_1_bit port map(clk,'1',Reg_Write_IN,Reg_Write_OUT);
	SP_Write_REG: reg_1_bit port map(clk,'1',SP_Write_IN,SP_Write_OUT);
	CCR_Write_REG: reg_1_bit port map(clk,'1',CCR_Write_IN,CCR_Write_OUT);
	RET_REG: reg_1_bit port map(clk,'1',RET_IN,RET_OUT);
  
end A_Mem_WB_buffer;
