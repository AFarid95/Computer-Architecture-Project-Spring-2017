library ieee;
use ieee.std_logic_1164.all;

entity Ex_Mem_buffer is
  port(
  clk,MemData_in,WrittenSP_in,MemWrite_in,MemRead_in,RegWrite_in,SPWrite_in,CCRWrite_in,Ret_in,PreserveCCR_in,RestoreCCR_in : in std_logic;
 	MemData_out,WrittenSP_out,MemWrite_out,MemRead_out,RegWrite_out,SPWrite_out,CCRWrite_out,Ret_out,PreserveCCR_out,RestoreCCR_out : out std_logic;
	MemAddr_in,WrittenData_in : in std_logic_vector (1 downto 0);
	MemAddr_out,WrittenData_out : out std_logic_vector (1 downto 0);
	Rdst_in : in std_logic_vector (2 downto 0);
	Rdst_out : out std_logic_vector (2 downto 0);
	imm_in : in std_logic_vector (15 downto 0);
	imm_out : out std_logic_vector (15 downto 0);
	CCR_in : in std_logic_vector (3 downto 0);
	CCR_out : out std_logic_vector (3 downto 0);
	PC_in,SP_in,SPP1_in,SPM1_in : in std_logic_vector (9 downto 0);
	PC_out,SP_out,SPP1_out,SPM1_out : out std_logic_vector (9 downto 0);
	ALU_in : in std_logic_vector (15 downto 0);
	ALU_out : out std_logic_vector (15 downto 0)
  );
end Ex_Mem_buffer;

architecture A_Ex_Mem_buffer of Ex_Mem_buffer is
  
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
    
  reg1: reg_1_bit port map(clk,'1',MemData_in,MemData_out);    
	reg2: reg_1_bit port map(clk,'1',WrittenSP_in,WrittenSP_out);
	reg3: reg_1_bit port map(clk,'1',MemWrite_in,MemWrite_out);    
	reg4: reg_1_bit port map(clk,'1',MemRead_in,MemRead_out);
	reg5: reg_1_bit port map(clk,'1',RegWrite_in,RegWrite_out);    
	reg6: reg_1_bit port map(clk,'1',SPWrite_in,SPWrite_out);
	reg7: reg_1_bit port map(clk,'1',CCRWrite_in,CCRWrite_out);    
	reg8: reg_1_bit port map(clk,'1',Ret_in,Ret_out);
	reg9: reg_1_bit port map(clk,'1',PreserveCCR_in,PreserveCCR_out);
	reg10: reg_1_bit port map(clk,'1',RestoreCCR_in,RestoreCCR_out);
	reg11: reg_n_bit generic map(n=>2) port map(clk,'1',MemAddr_in,MemAddr_out);
	reg12: reg_n_bit generic map(n=>2) port map(clk,'1',WrittenData_in,WrittenData_out);
	reg13: reg_n_bit generic map(n=>3) port map(clk,'1',Rdst_in,Rdst_out);
	reg14: reg_n_bit generic map(n=>4) port map(clk,'1',CCR_in,CCR_out);
	reg15: reg_n_bit generic map(n=>10) port map(clk,'1',PC_in,PC_out);
	reg16: reg_n_bit generic map(n=>10) port map(clk,'1',SP_in,SP_out);
	reg17: reg_n_bit generic map(n=>10) port map(clk,'1',SPP1_in,SPP1_out);
	reg18: reg_n_bit generic map(n=>10) port map(clk,'1',SPM1_in,SPM1_out);
	reg19: reg_n_bit generic map(n=>16) port map(clk,'1',ALU_in,ALU_out);
	reg20: reg_n_bit generic map(n=>16) port map(clk,'1',imm_in,imm_out);
  
end A_Ex_Mem_buffer;
