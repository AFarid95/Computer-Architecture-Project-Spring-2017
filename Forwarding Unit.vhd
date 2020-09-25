library ieee;
use ieee.std_logic_1164.all;

entity ForwardingUnit is
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
end ForwardingUnit;

architecture ForwardingUnit_arch of ForwardingUnit is
begin
  
  Rsrc1Fwd <=
  "01" when Ex_Mem_RegWrite='1' and Ex_Mem_Rdst=ID_Ex_Rsrc1 else
  "10" when Mem_WB_RegWrite='1' and Mem_WB_Rdst=ID_Ex_Rsrc1 else
  "00";
  
  Rsrc2Fwd <=
  "01" when Ex_Mem_RegWrite='1' and Ex_Mem_Rdst=ID_Ex_Rsrc2 else
  "10" when Mem_WB_RegWrite='1' and Mem_WB_Rdst=ID_Ex_Rsrc2 else
  "00";
  
  CCRFwd <=
  "01" when Ex_Mem_CCRWrite='1' else
  "10" when Mem_WB_CCRWrite='1' else
  "00";
  
  SPFwd <=
  '1' when Mem_WB_SPWrite='1' else
  '0';
  
end ForwardingUnit_arch;
