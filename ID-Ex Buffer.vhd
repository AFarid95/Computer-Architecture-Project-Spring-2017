library ieee;
use ieee.std_logic_1164.all;

entity ID_Ex_buffer is
  port(
    clk:in std_logic;
    read_data1_instage:in std_logic_vector (15 downto 0);
    read_data2_instage:in std_logic_vector(15 downto 0);
    readSP_instage: in std_logic_vector(9 downto 0);
    readPC_instage: in std_logic_vector(9 downto 0);
    readCCR_instage:in std_logic_vector(3 downto 0);
    Rsrc1_instage: in std_logic_vector(2 downto 0);
    Rsrc2_instage: in std_logic_vector(2 downto 0);
    Rdst_instage: in std_logic_vector(2 downto 0);
    imm_instage: in std_logic_vector(15 downto 0);
    shamt_instage: in std_logic_vector(3 downto 0);
    OutWrite_instage : in std_logic;
    ALUOp_instage:in std_logic_vector(3 downto 0);
    ALUSrc1_instage:in std_logic ;
    MemAddr_instage:in std_logic_vector(1 downto 0);
    MemData_instage: in std_logic ;
    WrittenSP_instage: in std_logic ;
    MemWrite_instage: in std_logic ;
    MemRead_instage: in std_logic ;
    WrittenData_instage: in std_logic_vector(1 downto 0) ;
    RegWrite_instage: in std_logic ;
    SPWrite_instage: in std_logic ;
    CCRWrite_instage: in std_logic ;
    JumpZero_instage : in std_logic;
    JumpNeg_instage : in std_logic;
    JumpCarry_instage : in std_logic;
    Ret_instage: in std_logic ;
    PreserveCCR_instage: in std_logic ;
    RestoreCCR_instage: in std_logic ;
    --Rsrc1Used_instage : in std_logic;
    --Rsrc2Used_instage : in std_logic;
    ChangeC_instage : in std_logic_vector(1 downto 0);
    
    --outputs
    read_data1_outstage:out std_logic_vector (15 downto 0);
    read_data2_outstage:out std_logic_vector(15 downto 0);
    readSP_outstage: out std_logic_vector(9 downto 0);
    readPC_outstage: out std_logic_vector(9 downto 0);
    readCCR_outstage:out std_logic_vector(3 downto 0);
    Rsrc1_outstage: out std_logic_vector(2 downto 0);
    Rsrc2_outstage: out std_logic_vector(2 downto 0);
    Rdst_outstage: out std_logic_vector(2 downto 0);
    imm_outstage: out std_logic_vector(15 downto 0);
    shamt_outstage: out std_logic_vector(3 downto 0);
    OutWrite_outstage : out std_logic;
    ALUOp_outstage:out std_logic_vector(3 downto 0);
    ALUSrc1_outstage:out std_logic ;
    MemAddr_outstage:out std_logic_vector (1 downto 0);
    MemData_outstage: out std_logic ;
    WrittenSP_outstage: out std_logic ;
    MemWrite_outstage: out std_logic ;
    MemRead_outstage: out std_logic ;
    WrittenData_outstage: out std_logic_vector(1 downto 0) ;
    RegWrite_outstage: out std_logic ;
    SPWrite_outstage: out std_logic ;
    CCRWrite_outstage: out std_logic ;
    JumpZero_outstage : out std_logic;
    JumpNeg_outstage : out std_logic;
    JumpCarry_outstage : out std_logic;
    Ret_outstage: out std_logic ;
    PreserveCCR_outstage: out std_logic;
    RestoreCCR_outstage: out std_logic;
    --Rsrc1Used_outstage : out std_logic;
    --Rsrc2Used_outstage : out std_logic;
    ChangeC_outstage : out std_logic_vector(1 downto 0)
  );
end ID_Ex_buffer;

architecture A_ID_Ex_buffer of ID_Ex_buffer is
  
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
    
    read_data1:reg_n_bit generic map(n=>16) port map(clk,'1',read_data1_instage,read_data1_outstage);
    read_data2:reg_n_bit generic map(n=>16) port map(clk,'1',read_data2_instage,read_data2_outstage);
    readSP:reg_n_bit generic map(n=>10) port map(clk,'1',readSP_instage,readSP_outstage);
    readPC: reg_n_bit generic map(n=>10) port map(clk,'1',readPC_instage,readPC_outstage);
    readCCR:reg_n_bit generic map(n=>4) port map(clk,'1',readCCR_instage,readCCR_outstage);
    Rsrc1: reg_n_bit generic map(n=>3) port map(clk,'1',Rsrc1_instage,Rsrc1_outstage);
    Rsrc2: reg_n_bit generic map(n=>3) port map(clk,'1',Rsrc2_instage,Rsrc2_outstage);
    Rdst: reg_n_bit generic map(n=>3) port map(clk,'1',Rdst_instage,Rdst_outstage);
    imm: reg_n_bit generic map(n=>16) port map(clk,'1',imm_instage,imm_outstage);
    shamt: reg_n_bit generic map(n=>4) port map(clk,'1',shamt_instage,shamt_outstage);
    OutWrite:reg_1_bit port map(clk,'1',OutWrite_instage,OutWrite_outstage);
    ALUOp:reg_n_bit generic map(n=>4) port map(clk,'1',ALUOp_instage,ALUOp_outstage);
    ALUSrc1:reg_1_bit port map (clk,'1',ALUSrc1_instage,ALUSrc1_outstage) ;
    MemAddr:reg_n_bit generic map(n=>2) port map(clk,'1',MemAddr_instage,MemAddr_outstage);
    MemData:reg_1_bit port map (clk,'1',MemData_instage,MemData_outstage) ; 
    WrittenSP: reg_1_bit port map (clk,'1',WrittenSP_instage,WrittenSP_outstage) ; 
    MemWrite: reg_1_bit port map (clk,'1',MemWrite_instage,MemWrite_outstage) ; 
    MemRead:reg_1_bit port map (clk,'1',MemRead_instage,MemRead_outstage) ; 
    WrittenData:reg_n_bit generic map(n=>2) port map(clk,'1',WrittenData_instage,WrittenData_outstage);
    RegWrite: reg_1_bit port map (clk,'1',RegWrite_instage,RegWrite_outstage) ;
    SPWrite: reg_1_bit port map (clk,'1',SPWrite_instage,SPWrite_outstage) ;
    CCRWrite: reg_1_bit port map (clk,'1',CCRWrite_instage,CCRWrite_outstage) ;
    JumpZero: reg_1_bit port map (clk,'1',JumpZero_instage,JumpZero_outstage) ; 
    JumpNeg: reg_1_bit port map (clk,'1',JumpNeg_instage,JumpNeg_outstage) ; 
    JumpCarry: reg_1_bit port map (clk,'1',JumpCarry_instage,JumpCarry_outstage) ; 
    Ret: reg_1_bit port map (clk,'1',Ret_instage,Ret_outstage) ;
    PreserveCCR: reg_1_bit port map (clk,'1',PreserveCCR_instage,PreserveCCR_outstage) ;
    RestoreCCR: reg_1_bit port map (clk,'1',RestoreCCR_instage,RestoreCCR_outstage) ;
    --Rsrc1Used: reg_1_bit port map (clk,'1',Rsrc1Used_instage,Rsrc1Used_outstage) ;
    --Rsrc2Used: reg_1_bit port map (clk,'1',Rsrc2Used_instage,Rsrc2Used_outstage) ;
    ChangeC: reg_n_bit generic map(n=>2) port map (clk,'1',ChangeC_instage,ChangeC_outstage) ;
  
end A_ID_Ex_buffer;
