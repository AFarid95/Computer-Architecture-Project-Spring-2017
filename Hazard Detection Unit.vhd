library ieee;
use ieee.std_logic_1164.all;

entity HazardDetectionUnit is
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
end HazardDetectionUnit;

architecture HazardDetectionUnit_arch of HazardDetectionUnit is
begin
  
  ID_Flush <=
  '1' when (ID_Ex_MemRead='1'
      and ((ID_Ex_Rdst=IF_ID_Rsrc1 and IF_ID_Rsrc1Used='1') or (ID_Ex_Rdst=IF_ID_Rsrc2 and IF_ID_Rsrc2Used='1')))
      or (ID_Ex_SPWrite='1' and IF_ID_SPUsed='1')
      or (ID_Ex_RestoreCCR='1' and IF_ID_CCRUsed='1')
      or CondJump='1' else
  '0';
  
  IF_ID_enable <=
  '0' when (ID_Ex_MemRead='1'
      and ((ID_Ex_Rdst=IF_ID_Rsrc1 and IF_ID_Rsrc1Used='1') or (ID_Ex_Rdst=IF_ID_Rsrc2 and IF_ID_Rsrc2Used='1')))
      or (ID_Ex_SPWrite='1' and IF_ID_SPUsed='1')
      or (ID_Ex_RestoreCCR='1' and IF_ID_CCRUsed='1') else
  '1';
  
  PCWrite <=
  '0' when (ID_Ex_MemRead='1'
      and ((ID_Ex_Rdst=IF_ID_Rsrc1 and IF_ID_Rsrc1Used='1') or (ID_Ex_Rdst=IF_ID_Rsrc2 and IF_ID_Rsrc2Used='1')))
      or (ID_Ex_SPWrite='1' and IF_ID_SPUsed='1')
      or (ID_Ex_RestoreCCR='1' and IF_ID_CCRUsed='1') else
  '1';
  
  IF_Flush <=
  '1' when UncondJump='1' or CondJump='1' or IF_ID_opcode="11011" or IF_ID_opcode="11100" or IF_ID_opcode="11101"
      or Ret='1' else
  '0';
  
end HazardDetectionUnit_arch;
