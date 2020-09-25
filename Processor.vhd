library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity processor is
  port(
    clk,reset,intr : in std_logic;
    in_port : in std_logic_vector(15 downto 0);
    out_port : out std_logic_vector(15 downto 0)
  );
end processor;

architecture processor_arch of processor is
  
  component reg_n_bit is
  generic (n : integer);
  port(
    Clk,En : in std_logic;
    d : in std_logic_vector(n-1 downto 0);
    q : out std_logic_vector(n-1 downto 0)
  );
  end component;
  
  component ALU is
  port (
    s:in std_logic_vector(3 downto 0); --selection line
    a:in std_logic_vector(15 downto 0); --operand 1
    b:in std_logic_vector(15 downto 0); --operand 2
    shamt:in std_logic_vector (3 downto 0); --shift amount (immediate value to be shifted with )
    c:out std_logic_vector(15 downto 0); -- output
    flagin :in std_logic_vector(3 downto 0 ); --input flags (0 for zero flag 1 for negtive flag 2 for carry flag  3 for overflow flag)
    flagout: out std_logic_vector (3 downto 0) --0 for zero flag 1 for negtive flag 2 for carry flag  3 for overflow flag
  );
  end component;
  
  component RegisterFile is
  port(
    Clk,reverse_Clk : in std_logic;
    read_address_1,read_address_2,write_address:in std_logic_vector (2 downto 0);
    write_data:in std_logic_vector (15 downto 0);
    pc_write,sp_write:in std_logic_vector (9 downto 0);
    ccr_write : in std_logic_vector (3 downto 0);
    read_data_1,read_data_2:out std_logic_vector (15 downto 0);
    pc_read,sp_read:out std_logic_vector (9 downto 0);
    ccr_read : out std_logic_vector (3 downto 0);
    PCWrite,RegWrite,SPWrite,CCRWrite : in std_logic
  );
  end component;
  
  component InstructionMemory is
	port (
		address : in std_logic_vector(9 downto 0);
		data_out : out std_logic_vector(15 downto 0)
		);
  end component;
  
  component DataMemory is
	port ( 
		clk : in std_logic;
		MemWrite : in std_logic;
		MemRead : in std_logic;
		address : in std_logic_vector(9 downto 0);
		data_in : in std_logic_vector(15 downto 0);
		data_out : out std_logic_vector(15 downto 0);
		M0 : out std_logic_vector(15 downto 0);
		M1 : out std_logic_vector(15 downto 0)
		);
  end component;
  
  component ControlUnit is
  port(
    op : in std_logic_vector(4 downto 0);
    OutWrite : out std_logic;
    ALUOp : out std_logic_vector(3 downto 0);
    ALUSrc1 : out std_logic;
    MemAddr : out std_logic_vector(1 downto 0);
    MemData : out std_logic;
    WrittenSP : out std_logic;
    MemWrite : out std_logic;
    MemRead : out std_logic;
    WrittenData : out std_logic_vector(1 downto 0);
    RegWrite : out std_logic;
    SPWrite : out std_logic;
    CCRWrite : out std_logic;
    JumpZero : out std_logic;
    JumpNeg : out std_logic;
    JumpCarry : out std_logic;
    UncondJump : out std_logic;
    Ret : out std_logic;
    PreserveCCR : out std_logic;
    RestoreCCR : out std_logic;
    Rsrc1Used : out std_logic;
    Rsrc2Used : out std_logic;
    SPUsed : out std_logic;
    CCRUsed : out std_logic;
    ChangeC : out std_logic_vector(1 downto 0)
    );
  end component;
  
  component ForwardingUnit is
  port(
    Ex_Mem_RegWrite : in std_logic;
    Mem_WB_RegWrite : in std_logic;
    Ex_Mem_CCRWrite : in std_logic;
    Mem_WB_CCRWrite : in std_logic;
    Mem_WB_SPWrite : in std_logic;
    Ex_Mem_Rdst : in std_logic_vector(2 downto 0);
    Mem_WB_Rdst : in std_logic_vector(2 downto 0);
    ID_Ex_Rsrc1 : in std_logic_vector(2 downto 0);
    ID_Ex_Rsrc2 : in std_logic_vector(2 downto 0);
    Rsrc1Fwd : out std_logic_vector(1 downto 0);
    Rsrc2Fwd : out std_logic_vector(1 downto 0);
    CCRFwd : out std_logic_vector(1 downto 0);
    SPFwd : out std_logic
  );
  end component;
  
  component HazardDetectionUnit is
  port(
    IF_ID_opcode : in std_logic_vector(4 downto 0);
    ID_Ex_MemRead : in std_logic;
    ID_Ex_Rdst : in std_logic_vector(2 downto 0);
    IF_ID_Rsrc1 : in std_logic_vector(2 downto 0);
    IF_ID_Rsrc2 : in std_logic_vector(2 downto 0);
    IF_ID_Rsrc1Used : in std_logic;
    IF_ID_Rsrc2Used : in std_logic;
    ID_Ex_SPWrite : in std_logic;
    IF_ID_SPUsed : in std_logic;
    ID_Ex_RestoreCCR : in std_logic;
    IF_ID_CCRUsed : in std_logic;
    UncondJump : in std_logic;
    CondJump : in std_logic;
    Ret : in std_logic;
    PCWrite : out std_logic;
    IF_ID_enable : out std_logic;
    IF_Flush : out std_logic;
    ID_Flush : out std_logic
  );
  end component;
  
  component JumpUnit is
  port(
    JumpZero : in std_logic;
    JumpNeg : in std_logic;
    JumpCarry : in std_logic;
    Z,N,C : in std_logic;
    CondJump : out std_logic
  );
  end component;
  
  component IF_ID_buffer is
  port(
    clk,IF_ID_write : in std_logic;
    data_IF : in std_logic_vector(15 downto 0);
    data_ID : out std_logic_vector(15 downto 0)
  );
  end component;
  
  component ID_Ex_buffer is
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
  end component;
  
  component Ex_Mem_buffer is
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
  end component;
  
  component Mem_WB_buffer is
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
  end component;
  
  signal reverse_clk : std_logic;
  
  -- HDU signals
  signal IF_Flush : std_logic;
  signal ID_flush : std_logic;
  signal IF_ID_enable : std_logic;
  signal PCWrite : std_logic;
  signal Ret_HDU : std_logic;
  
  -- IF signals (farid)
  signal fetched_instr,chosen_instr,M0,M1 : std_logic_vector(15 downto 0);
  signal Written_PC : std_logic_vector(9 downto 0);
  signal UncondJump,CondJump : std_logic;
  
  -- ID signals (hadidi)
  signal IF_ID_instr : std_logic_vector(15 downto 0);
  signal IF_ID_ctrl : std_logic_vector(4 downto 0); 
  signal Rsrc1_ID,Rsrc2_ID,Rdst_ID: std_logic_vector(2 downto 0);
  signal shamt_ID : std_logic_vector(3 downto 0); 
  signal Read_data1,Read_data2: std_logic_vector(15 downto 0);
  signal Read_SP,Read_PC: std_logic_vector(9 downto 0);
  signal Read_CCR: std_logic_vector (3 downto 0);
  
  signal OutWrite_ID : std_logic;
  signal ALUOp_ID : std_logic_vector(3 downto 0);
  signal ALUSrc1_ID : std_logic;
  signal MemAddr_ID : std_logic_vector(1 downto 0);
  signal MemData_ID : std_logic;
  signal WrittenSP_ID : std_logic;
  signal MemWrite_ID : std_logic;
  signal MemRead_ID : std_logic;
  signal WrittenData_ID : std_logic_vector(1 downto 0);
  signal RegWrite_ID : std_logic;
  signal SPWrite_ID : std_logic;
  signal CCRWrite_ID : std_logic;
  signal JumpZero_ID : std_logic;
  signal JumpNeg_ID : std_logic;
  signal JumpCarry_ID : std_logic;
  signal Ret_ID : std_logic;
  signal PreserveCCR_ID : std_logic;
  signal RestoreCCR_ID : std_logic;
  signal Rsrc1Used : std_logic;
  signal Rsrc2Used : std_logic;
  signal SPUsed : std_logic;
  signal CCRUsed : std_logic;
  signal ChangeC_ID : std_logic_vector(1 downto 0);
   
  signal OutWrite_ID_chosen : std_logic;
  signal ALUOp_ID_chosen : std_logic_vector(3 downto 0);
  signal ALUSrc1_ID_chosen : std_logic;
  signal MemAddr_ID_chosen : std_logic_vector(1 downto 0);
  signal MemData_ID_chosen : std_logic;
  signal WrittenSP_ID_chosen : std_logic;
  signal MemWrite_ID_chosen : std_logic;
  signal MemRead_ID_chosen : std_logic;
  signal WrittenData_ID_chosen : std_logic_vector(1 downto 0);
  signal RegWrite_ID_chosen : std_logic;
  signal SPWrite_ID_chosen : std_logic;
  signal CCRWrite_ID_chosen : std_logic;
  signal JumpZero_ID_chosen : std_logic;
  signal JumpNeg_ID_chosen : std_logic;
  signal JumpCarry_ID_chosen : std_logic;
  signal Ret_ID_chosen : std_logic;
  signal PreserveCCR_ID_chosen : std_logic;
  signal RestoreCCR_ID_chosen : std_logic;
  signal ChangeC_ID_chosen : std_logic_vector(1 downto 0);
  
  -- Ex signals (megz)
  signal read_data1_Ex:  std_logic_vector (15 downto 0);
  signal read_data2_Ex:  std_logic_vector(15 downto 0);
  signal readSP_Ex:   std_logic_vector(9 downto 0);
  signal readPC_Ex:   std_logic_vector(9 downto 0);
  signal readCCR_Ex:  std_logic_vector(3 downto 0);
  signal Rsrc1_Ex:   std_logic_vector(2 downto 0);
  signal Rsrc2_Ex:   std_logic_vector(2 downto 0);
  signal Rdst_Ex:   std_logic_vector(2 downto 0);
  signal imm_Ex:   std_logic_vector(15 downto 0);
  signal SP_Ex,SPP1_Ex,SPM1_Ex :  std_logic_vector (9 downto 0);
  signal operand1,operand2 ,choose_forward1,ALU_output : std_logic_vector (15 downto 0);
  signal chosen_SP: std_logic_vector (9 downto 0);
  signal input_flags,tmp_flags,output_flags : std_logic_vector (3 downto 0);
  
  signal OutWrite : std_logic;
  signal ALUOp:  std_logic_vector(3 downto 0);
  signal ALUSrc1:  std_logic ;
  signal MemAddr_Ex:  std_logic_vector (1 downto 0);
  signal MemData_Ex:   std_logic ;
  signal WrittenSP_Ex:   std_logic ;
  signal MemWrite_Ex:   std_logic ;
  signal MemRead_Ex:   std_logic ;
  signal WrittenData_Ex:   std_logic_vector(1 downto 0) ;
  signal RegWrite_Ex:   std_logic ;
  signal SPWrite_Ex:   std_logic ;
  signal CCRWrite_Ex:   std_logic ;
  signal JumpZero :  std_logic;
  signal JumpNeg :  std_logic; 
  signal JumpCarry :  std_logic;
  signal Ret_Ex:   std_logic ;
  signal PreserveCCR_Ex:   std_logic ;
  signal RestoreCCR_Ex:   std_logic ;
  signal ChangeC:  std_logic_vector(1 downto 0);
  
  signal forwarded_from_memory :  std_logic_vector (15 downto 0); --data_out from data memory
  signal forwarded_from_alu :  std_logic_vector (15 downto 0); -- the forwarded from alu is the output ALU from EX-MEM
  signal forwarded_ccr_from_memory :  std_logic_vector (3 downto 0); 
  signal forwarded_ccr_from_alu :  std_logic_vector (3 downto 0); -- the forwarded from alu is the output CCR from EX-MEM
  signal forwarded_SP_from_memory,forwarded_SP_from_alu:  std_logic_vector (9 downto 0);
  
  signal Rsrc1Fwd :  std_logic_vector(1 downto 0); --output from forwarding unit
  signal Rsrc2Fwd :   std_logic_vector(1 downto 0); --output from forwarding unit
  signal CCRFwd :  std_logic_vector(1 downto 0); --outputs from forwarding unit
  signal SPFwd :  std_logic; --outputs from forwarding unit
  
  signal shamt_Ex: std_logic_vector (3 downto 0); --from instruction
  
  -- Mem signals (khamis)
  signal ALU_Result_Mem : std_logic_vector (15 downto 0 );
	signal ALU_Flags_Mem: std_logic_vector(3 downto 0);
	signal PC_Mem: std_logic_vector ( 9 downto 0 );
	signal SP_Plus_ONE_Mem : std_logic_vector ( 9 downto 0 );
	signal SP_Minus_ONE_Mem : std_logic_vector ( 9 downto 0);
	signal SP_Mem : std_logic_vector ( 9 downto 0);
	signal Rdst_Mem : std_logic_vector ( 2 downto 0);
	signal Imm_Value_Mem : std_logic_vector ( 15 downto 0);
	signal CCR_buffer_output : std_logic_vector(3 downto 0);
	signal OUT_CCR : std_logic_vector ( 3 downto 0);
	signal DataMemory_Address : std_logic_vector ( 9 downto 0 );
	signal DataMemory_Data : std_logic_vector ( 15 downto 0);
	signal written_SP_Mem : std_logic_vector ( 9 downto 0);
	signal read_data_Mem : std_logic_vector (15 downto 0);
	
	signal MemAddr : std_logic_vector (1 downto 0);
	signal MemData : std_logic;
	signal WrittenSP : std_logic;
	signal MemWrite : std_logic;
	signal MemRead : std_logic;
	signal PreserveCCR : std_logic;
	signal RestoreCCR : std_logic;
	signal WrittenData_Mem : std_logic_vector (1 downto 0);
	signal RegWrite_Mem : std_logic;
	signal SPWrite_Mem : std_logic;
	signal CCRWrite_Mem : std_logic;
	signal Ret_Mem : std_logic;
  
  -- WB signals (farid)
  signal ALU_result_WB : std_logic_vector(15 downto 0);
  signal read_data_WB : std_logic_vector(15 downto 0);
  signal imm_WB : std_logic_vector(15 downto 0);
  signal Rdst_WB : std_logic_vector(2 downto 0);
  signal written_data_WB : std_logic_vector(15 downto 0);
  signal written_SP_WB : std_logic_vector(9 downto 0);
  signal written_CCR_WB : std_logic_vector(3 downto 0);
  
  signal WrittenData : std_logic_vector(1 downto 0);
  signal RegWrite : std_logic;
  signal SPWrite : std_logic;
  signal CCRWrite : std_logic;
  signal Ret : std_logic;
  
begin
  
  reverse_clk <= not(clk);
  
  -- HDU
  Ret_HDU <= Ret_ID or Ret_Ex or Ret_Mem or Ret;
  
  -- IF (farid)
  chosen_instr <= "1111000000000000" when intr='1' else
                  "0000000000000000" when IF_Flush='1' else
                  fetched_instr;
  Written_PC <= M0(9 downto 0) when reset='1' else
                M1(9 downto 0) when intr='1' else
                read_data_WB(9 downto 0) when Ret='1' else
                choose_forward1(9 downto 0) when CondJump='1' else
                Read_data1(9 downto 0) when UncondJump='1' else
                std_logic_vector(unsigned(Read_PC) + "0000000001");
  
  -- ID (hadidi)
  IF_ID_ctrl <= IF_ID_instr(15 downto 11);
  Rdst_ID <= IF_ID_instr(10 downto 8);
  Rsrc1_ID <= IF_ID_instr(7 downto 5);
  Rsrc2_ID <= IF_ID_instr(4 downto 2);
  shamt_ID <= IF_ID_instr(4 downto 1);
  
  OutWrite_ID_chosen <= OutWrite_ID when ID_flush='0'
                        else '0';
  ALUOp_ID_chosen <= ALUOp_ID when ID_flush='0'
                     else "0000";
  ALUSrc1_ID_chosen <= ALUSrc1_ID when ID_flush='0'
                       else '0';
  MemAddr_ID_chosen <= MemAddr_ID when ID_flush='0'
                       else "00";
  MemData_ID_chosen <= MemData_ID when ID_flush='0'
                       else '0';
  WrittenSP_ID_chosen <= WrittenSP_ID when ID_flush='0'
                         else '0';
  MemWrite_ID_chosen <= MemWrite_ID when ID_flush='0'
                        else '0';
  MemRead_ID_chosen <= MemRead_ID when ID_flush='0'
                       else '0';
  WrittenData_ID_chosen <= WrittenData_ID when ID_flush='0'
                           else "00";
  RegWrite_ID_chosen <= RegWrite_ID when ID_flush='0'
                        else '0';
  SPWrite_ID_chosen <= SPWrite_ID when ID_flush='0'
                       else '0';
  CCRWrite_ID_chosen <= CCRWrite_ID when ID_flush='0'
                        else '0';
  JumpZero_ID_chosen <= JumpZero_ID when ID_flush='0'
                        else '0';
  JumpNeg_ID_chosen <= JumpNeg_ID when ID_flush='0'
                       else '0';
  JumpCarry_ID_chosen <= JumpCarry_ID when ID_flush='0'
                         else '0';
  Ret_ID_chosen <= Ret_ID when ID_flush='0'
                   else '0';
  PreserveCCR_ID_chosen <= PreserveCCR_ID when ID_flush='0'
                           else '0';
  RestoreCCR_ID_chosen <= RestoreCCR_ID when ID_flush='0'
                          else '0';
  ChangeC_ID_chosen <= ChangeC_ID when ID_flush='0'
                       else "00";
  
  -- Ex (megz)
  forwarded_from_memory <= written_data_WB;
  forwarded_from_alu <= ALU_Result_Mem;
  forwarded_ccr_from_memory <= written_CCR_WB; 
  forwarded_ccr_from_alu <= ALU_Flags_Mem;
  forwarded_SP_from_memory <= written_SP_WB;
  --forwarded_SP_from_alu <= SP_Mem;
  
  choose_forward1 <= forwarded_from_memory when Rsrc1Fwd="10" else
  forwarded_from_alu when Rsrc1Fwd ="01" else
  read_data1_Ex;
  
  operand1<= choose_forward1 when ALUSrc1 ='0' else
  in_port;
  
  operand2 <= forwarded_from_memory when Rsrc2Fwd="10" else
  forwarded_from_alu when Rsrc2Fwd ="01" else
  read_data2_Ex;
  
  tmp_flags <= forwarded_ccr_from_memory when CCRFwd="10" else
  forwarded_ccr_from_alu when CCRFwd="01" else
  readCCR_Ex;
  
  input_flags(0)<= tmp_flags(0);
  input_flags(1)<= tmp_flags(1);
  input_flags(3)<= tmp_flags(3);
  
  input_flags(2)<= '0' when ChangeC="10" else
  '1' when ChangeC ="01"else
  tmp_flags(2);
  
  chosen_SP <=forwarded_SP_from_memory when SPFwd ='1' else
  --forwarded_SP_from_alu when SPFwd="01" else
  readSP_Ex;
  
  SP_Ex <= chosen_SP;
  SPP1_Ex <=std_logic_vector(unsigned(chosen_SP)+1);
  SPM1_Ex <= std_logic_vector(unsigned(chosen_SP)-1);
  
  -- Mem (khamis)
  OUT_CCR <= CCR_buffer_output when RestoreCCR= '1' else
			       ALU_Flags_Mem;
	
	DataMemory_Address <= SP_Mem when MemAddr ="00" else
						            SP_Plus_ONE_Mem when MemAddr = "01" else
						            Imm_Value_Mem( 9 downto 0);
						  
	DataMemory_Data <= "000000" & PC_Mem when  MemData ='1' else
					           ALU_Result_Mem;
	
	
	written_SP_Mem <= SP_Plus_ONE_Mem when WrittenSP = '0' else
					          SP_Minus_ONE_Mem;
  
  -- WB (farid)
  with WrittenData select
  written_data_WB <=
  ALU_result_WB when "00",
  read_data_WB when "01",
  imm_WB when others;
  
  ALU_instance: ALU port map (
    ALUOp,
    operand1,
    operand2,
    shamt_Ex,
    ALU_output,
    input_flags,
    output_flags
  );
  RegFile: RegisterFile port map (
    clk,reverse_clk,
    Rsrc1_ID,Rsrc2_ID,Rdst_WB,
    written_data_WB,
    Written_PC,written_SP_WB,
    written_CCR_WB,
    Read_data1,Read_data2,
    Read_PC,Read_SP,
    Read_CCR,
    PCWrite,RegWrite,SPWrite,CCRWrite
  );
  InstrMem: InstructionMemory port map (
    Read_PC,
    fetched_instr
  );
  DataMem: DataMemory port map (
    clk,
		MemWrite,
		MemRead,
		DataMemory_Address,
		DataMemory_Data,
		read_data_Mem,
		M0,
		M1
  );
  CU: ControlUnit port map (
    IF_ID_ctrl,
    OutWrite_ID,
    ALUOp_ID,
    ALUSrc1_ID,
    MemAddr_ID,
    MemData_ID,
    WrittenSP_ID,
    MemWrite_ID,
    MemRead_ID,
    WrittenData_ID,
    RegWrite_ID,
    SPWrite_ID,
    CCRWrite_ID,
    JumpZero_ID,
    JumpNeg_ID,
    JumpCarry_ID,
    UncondJump,
    Ret_ID,
    PreserveCCR_ID,
    RestoreCCR_ID,
    Rsrc1Used,
    Rsrc2Used,
    SPUsed,
    CCRUsed,
    ChangeC_ID
  );
  FU: ForwardingUnit port map (
    RegWrite_Mem,
    RegWrite,
    CCRWrite_Mem,
    CCRWrite,
    SPWrite,
    Rdst_Mem,
    Rdst_WB,
    Rsrc1_Ex,
    Rsrc2_Ex,
    Rsrc1Fwd,
    Rsrc2Fwd,
    CCRFwd,
    SPFwd
  );
  HDU: HazardDetectionUnit port map (
    IF_ID_ctrl,
    MemRead_Ex,
    Rdst_Ex,
    Rsrc1_ID,
    Rsrc2_ID,
    Rsrc1Used,
    Rsrc2Used,
    SPWrite_Ex,
    SPUsed,
    RestoreCCR_Ex,
    CCRUsed,
    UncondJump,
    CondJump,
    Ret_HDU,
    PCWrite,
    IF_ID_enable,
    IF_Flush,
    ID_Flush
  );
  JU: JumpUnit port map (
    JumpZero,
    JumpNeg,
    JumpCarry,
    input_flags(0),input_flags(1),input_flags(2),
    CondJump
  );
  IF_ID: IF_ID_buffer port map (
    clk,IF_ID_enable,
    chosen_instr,
    IF_ID_instr
  );
  ID_Ex: ID_Ex_buffer port map (
    clk,
    Read_data1,
    Read_data2,
    Read_SP,
    Read_PC,
    Read_CCR,
    Rsrc1_ID,
    Rsrc2_ID,
    Rdst_ID,
    fetched_instr,
    shamt_ID,
    OutWrite_ID_chosen,
    ALUOp_ID_chosen,
    ALUSrc1_ID_chosen,
    MemAddr_ID_chosen,
    MemData_ID_chosen,
    WrittenSP_ID_chosen,
    MemWrite_ID_chosen,
    MemRead_ID_chosen,
    WrittenData_ID_chosen,
    RegWrite_ID_chosen,
    SPWrite_ID_chosen,
    CCRWrite_ID_chosen,
    JumpZero_ID_chosen,
    JumpNeg_ID_chosen,
    JumpCarry_ID_chosen,
    Ret_ID_chosen,
    PreserveCCR_ID_chosen,
    RestoreCCR_ID_chosen,
    --Rsrc1Used_ID_chosen,
    --Rsrc2Used_ID_chosen,
    ChangeC_ID_chosen,
    read_data1_Ex,
    read_data2_Ex,
    readSP_Ex,
    readPC_Ex,
    readCCR_Ex,
    Rsrc1_Ex,
    Rsrc2_Ex,
    Rdst_Ex,
    imm_Ex,
    shamt_Ex,
    OutWrite,
    ALUOp,
    ALUSrc1,
    MemAddr_Ex,
    MemData_Ex,
    WrittenSP_Ex,
    MemWrite_Ex,
    MemRead_Ex,
    WrittenData_Ex,
    RegWrite_Ex,
    SPWrite_Ex,
    CCRWrite_Ex,
    JumpZero,
    JumpNeg,
    JumpCarry,
    Ret_Ex,
    PreserveCCR_Ex,
    RestoreCCR_Ex,
    --Rsrc1Used,
    --Rsrc2Used,
    ChangeC
  );
  Ex_Mem: Ex_Mem_buffer port map (
    clk,MemData_Ex,WrittenSP_Ex,MemWrite_Ex,MemRead_Ex,RegWrite_Ex,SPWrite_Ex,CCRWrite_Ex,Ret_Ex,PreserveCCR_Ex,RestoreCCR_Ex,
   	MemData,WrittenSP,MemWrite,MemRead,RegWrite_Mem,SPWrite_Mem,CCRWrite_Mem,Ret_Mem,PreserveCCR,RestoreCCR,
 		MemAddr_Ex,WrittenData_Ex,
 		MemAddr,WrittenData_Mem,
 		Rdst_Ex,
 		Rdst_Mem,
 		imm_Ex,
 		Imm_Value_Mem,
 		output_flags,
 		ALU_Flags_Mem,
 		readPC_Ex,SP_Ex,SPP1_Ex,SPM1_Ex,
 		PC_Mem,SP_Mem,SP_Plus_ONE_Mem,SP_Minus_ONE_Mem,
 		ALU_output,
 		ALU_Result_Mem
  );
  Mem_WB: Mem_WB_buffer port map (
    clk,
    OUT_CCR,
    written_CCR_WB,
    ALU_Result_Mem,
    ALU_result_WB,
    read_data_Mem,
    read_data_WB,
    written_SP_Mem,
    written_SP_WB,
    Rdst_Mem,
    Rdst_WB,
    Imm_Value_Mem,
    imm_WB,
    WrittenData_Mem,
    WrittenData,
    RegWrite_Mem,
    RegWrite,
    SPWrite_Mem,
    SPWrite,
    CCRWrite_Mem,
    CCRWrite,
    Ret_Mem,
    Ret
  );
  CCRBuffer: reg_n_bit generic map (n=>4) port map(clk,PreserveCCR,ALU_Flags_Mem,CCR_buffer_output);
  OutReg: reg_n_bit generic map (n=>16) port map(clk,OutWrite,choose_forward1,out_port);
    
end processor_arch;
