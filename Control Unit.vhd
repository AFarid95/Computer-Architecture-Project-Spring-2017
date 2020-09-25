library ieee;
use ieee.std_logic_1164.all;

entity ControlUnit is
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
end ControlUnit;

architecture ControlUnit_arch of ControlUnit is
begin
    
    -- 1 when out instruction, 0 otherwise
    OutWrite <= '1' when op="01110" else
                '0';
    
    with op select  -- ALU operation
    ALUOp <=
    "0001" when "00010",
    "0010" when "00011",
    "0011" when "00100",
    "0100" when "00101",
    "0101" when "00110",
    "0110" when "00111",
    "0111" when "01000",
    "1000" when "01001",
    "1001" when "10000",
    "1010" when "10001",
    "1011" when "10010",
    "1100" when "10011",
    "0000" when others;
    
    -- selects 1st operand of ALU. 0 selects read data 1. 1 selects input port
    ALUSrc1 <=  '1' when op="01111" else
                '0';
    
    -- selects 2nd operand of ALU. 0 selects read data 2. 1 selects immediate value
    --ALUSrc2 <= '1' when op="01000" or op="01001" else
    --           '0';
    
    -- selects memory address
    MemAddr <= "00" when op="01100" or op="11000" or op="11110" else -- SP
               "01" when op="01101" or op="11001" or op="11010" else  -- SP+1
               "10"; -- immediate
    
    -- selects data written to memory
    MemData <=  '1' when op="11000" or op="11110" else -- PC+1
                '0'; -- ALU result
    
    -- selects the new SP written to register file
    WrittenSP <=  '1' when op="01100" or op="11000" or op="11110" else -- SP=SP-1
                  '0'; -- SP=SP+1
    
    -- determines whether to write to memory. 1 if yes
    MemWrite <=  '1' when op="01100" or op="11000" or op="11101" or op="11110" else
                 '0';
    
    -- determines whether to read from memory. 1 if yes
    MemRead <=  '1' when op="01101" or op="11001" or op="11010" or op="11100" else
                '0';
    
    -- selects data written to register file
    WrittenData <=  "01" when op="01101" or op="11100" else -- data read from memory
                    "10" when op="11011" else  -- immediate
                    "00"; -- ALU result
    
    -- determines whether to write to registers. 1 if yes
    RegWrite <=  '1' when not(op="00000" or op="01010" or op="01011" or op="01100" or op="01110" or op="10100"
                       or op="10101" or op="10110" or op="10111" or op="11000" or op="11001" or op="11010"
                       or op="11101" or op="11110" or op="UUUUU") else
                 '0';
    
    -- determines whether to write to SP. 1 if yes
    SPWrite <=  '1' when op="01100" or op="01101" or op="11000" or op="11001" or op="11010" or op="11110" else
                '0';
    
    -- determines whether to write to CCR. 1 if yes
    CCRWrite <=  '1' when op="00010" or op="00011" or op="00100" or op="00101" or op="00110" or op="00111"
                       or op="01010" or op="01011" or op="10000" or op="10001" or op="10010" or op="10011"
                       or op="11010" else
                 '0';
    
    JumpZero <= '1' when op="10100" else
                '0';
    
    JumpNeg <= '1' when op="10101" else
               '0';
    
    JumpCarry <= '1' when op="10110" else
                 '0';
    
    -- selects new PC
    UncondJump <= '1' when op="10111" or op="11000" else -- PC = the PC in jmp
                  '0';  -- PC = PC + 2
    
    -- selects new PC. Has priority over the Jump MUX
    Ret <=  '1' when op="11001" or op="11010" else  -- PC = the popped PC in ret
            '0';  -- PC = the PC selected in the Jump MUX
    
    -- preserve CCR in CCR buffer (INTR)
    PreserveCCR <= '1' when op="11110" else
                   '0';
    
    -- restores the CCR preserved before by INTR
    RestoreCCR <= '1' when op="11010" else
                  '0';
    
    Rsrc1Used <= '1' when not(op="00000" or op="01010" or op="01011" or op="01101" or op="01111" or op="11001"
                     or op="11010" or op="11011" or op="11100" or op="UUUUU") else
                 '0';
    
    Rsrc2Used <= '1' when op="00010" or op="00011" or op="00100" or op="00101" else
                 '0';
    
    SPUsed <= '1' when op="01100" or op="01101" or op="11000" or op="11001" or op="11010" or op="11110" else
              '0';
    
    CCRUsed <= '1' when op="10101" or op="10110" or op="10111" or op="11110" else
               '0';
    
    ChangeC <= "01" when op="01010" else
               "10" when op="01011" else
               "00";
    
end ControlUnit_arch;