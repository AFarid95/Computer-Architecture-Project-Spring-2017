library ieee;
use ieee.std_logic_1164.all;

entity ALU is
port (
  s:in std_logic_vector(3 downto 0); --selection line
  a:in std_logic_vector(15 downto 0); --operand 1
  b:in std_logic_vector(15 downto 0); --operand 2
  shamt:in std_logic_vector (3 downto 0); --shift amount (immediate value to be shifted with )
  c:out std_logic_vector(15 downto 0); -- output
  flagin :in std_logic_vector(3 downto 0 ); --input flags (0 for zero flag 1 for negtive flag 2 for carry flag  3 for overflow flag)
  flagout: out std_logic_vector (3 downto 0) --0 for zero flag 1 for negtive flag 2 for carry flag  3 for overflow flag
);
end ALU;

architecture ALU_arch of ALU is
  
  component my_nadder IS
  Generic (n : integer := 8);
  PORT    (a, b : in std_logic_vector(n-1 downto 0) ;
	cin : in std_logic;
	s : out std_logic_vector(n-1 downto 0);
	cout : out std_logic);
	END component my_nadder;
	
  signal addoutput,suboutput,incoutput,decoutput,negoutput,nota,notb,tempoutput,overflow1,overflow2 : std_logic_vector (15 downto 0);
  signal addcarry,subcarry,inccarry,deccarry,negcarry :std_logic;
  
begin
  
  nota<=not a;
  notb <=not b;
addition : my_nadder generic map (n => 16) port map(a,b ,'0',addoutput,addcarry);
subtraction : my_nadder generic map (n => 16) port map(a,notb ,'1',suboutput,subcarry);
increment : my_nadder generic map (n => 16) port map(a,"0000000000000000" ,'1',incoutput,inccarry);
decrement : my_nadder generic map (n => 16) port map(a,"1111111111111111" ,'0',decoutput,deccarry);
neg : my_nadder generic map (n => 16) port map(nota,"0000000000000000" ,'1',negoutput,negcarry);
overflow1<=a when (s="0001" or s="0010" or s="1011" or s="1100") else 
"0000000000000000";
overflow2<= b when s="0001" else
notb when s="0010" else
"0000000000000000" when s="1011" else
"1111111111111111" when s= "1100" else
"1111111111111111";

tempoutput<= a and b when s="0011" else
a or b when s="0100" else
not a when s="1001" else
'0'& a(15 downto 1) when s="1000" and shamt="0001" else --shr
"00"& a(15 downto 2) when s="1000" and shamt="0010" else
"000"& a(15 downto 3) when s="1000" and shamt="0011"else
"0000"& a(15 downto 4) when s="1000" and shamt="0100"else
"00000"& a(15 downto 5) when s="1000" and shamt="0101" else
"000000"& a(15 downto 6) when s="1000" and shamt="0110"else
"0000000"& a(15 downto 7) when s="1000" and shamt="0111"else
"00000000"& a(15 downto 8) when s="1000" and shamt="1000"else
"000000000"& a(15 downto 9) when s="1000" and shamt="1001" else
"0000000000"& a(15 downto 10) when s="1000" and shamt="1010" else
"00000000000"& a(15 downto 11) when s="1000" and shamt="1011" else
"000000000000"& a(15 downto 12) when s="1000" and shamt="1100" else
"0000000000000"& a(15 downto 13) when s="1000" and shamt="1101" else
"00000000000000"& a(15 downto 14) when s="1000" and shamt="1110" else
"000000000000000"& a(15) when s="1000" and shamt="1111" else
a when s="1000" and shamt="0000" else
 flagin(2) & a(15 downto 1) when s="0110" else --rrc
 a(14 downto 0)&'0' when s="0111" and shamt="0001" else --shl
 a(13 downto 0)&"00" when s="0111" and shamt="0010" else
 a(12 downto 0)&"000" when s="0111" and shamt="0011" else
 a(11 downto 0)&"0000" when s="0111" and shamt="0100"else
a(10 downto 0)&"00000"  when s="0111" and shamt="0101"else
 a(9 downto 0)&"000000" when s="0111" and shamt="0110"else
 a(8 downto 0)&"0000000" when s="0111" and shamt="0111"else
 a(7 downto 0)&"00000000" when s="0111" and shamt="1000"else
 a(6 downto 0)&"000000000" when s="0111" and shamt="1001" else
 a(5 downto 0)&"0000000000" when s="0111" and shamt="1010" else
 a(4 downto 0)&"00000000000" when s="0111" and shamt="1011" else
a(3 downto 0)&"000000000000"  when s="0111" and shamt="1100" else
 a(2 downto 0) &"0000000000000"when s="0111" and shamt="1101" else
 a(1 downto 0)&"00000000000000" when s="0111" and shamt="1110" else
 a(0)&"000000000000000" when s="0111" and shamt="1111" else
a when s="0111" and shamt="0000" else
 a(14 downto 0)& flagin(2) when s="0101" else --rlc
a when   s="0000"  else  --transfer
addoutput when s="0001" else --addition
suboutput when s="0010" else --subtraction
incoutput when s="1011" else --increment
decoutput when s="1100" else --decrement
negoutput when s="1010" else -- negative
negoutput when s="1101" else 
negoutput when s="1110" else
negoutput ;
c<=tempoutput;
flagout(0) <=  flagin (0) when  s="0000"  else  --preserve flags when transfer
'1' when tempoutput="0000000000000000" else
'0';
flagout(1) <= flagin(1) when   s="0000" --preserve flags when transfer
else tempoutput(15);

flagout(2) <= a(0) when s="0110" else --rrc
a(0)when  s="1000" and shamt="0001" else
a(1) when s="1000" and shamt="0010" else
a(2) when s="1000" and shamt="0011" else--shr
a(3) when s="1000" and shamt="0100"else
a(4) when s="1000" and shamt="0101"else
a(5) when s="1000" and shamt="0110"else
a(6) when s="1000" and shamt="0111"else
a(7) when s="1000" and shamt="1000"else
a(8) when s="1000" and shamt="1001" else
a(9) when s="1000" and shamt="1010" else
a(10) when s="1000" and shamt="1011" else
a(11) when s="1000" and shamt="1100" else
a(12) when s="1000" and shamt="1101" else
a(13) when s="1000" and shamt="1110" else
a(14) when s="1000" and shamt="1111" else
'0' when s="1000" and shamt="0000" else
a(15) when s="0101" else --rlc
a(15)when s="0111" and shamt="0001" else
a(14) when s="0111" and shamt="0010" else
a(13) when s="0111" and shamt="0011" else
a(12) when s="0111" and shamt="0100"else
a(11) when s="0111" and shamt="0101"else
a(10) when s="0111" and shamt="0110"else
a(9) when s="0111" and shamt="0111"else --shl
a(8) when s="0111" and shamt="1000"else
a(7) when s="0111" and shamt="1001" else
a(6) when s="0111" and shamt="1010" else
a(5) when s="0111" and shamt="1011" else
a(4) when s="0111" and shamt="1100" else
a(3) when s="0111" and shamt="1101" else
a(2) when s="0111" and shamt="1110" else
a(1) when s="0111" and shamt="1111" else
'0' when s="0111" and shamt="0000" else
addcarry when s="0001" else
not subcarry when s="0010" else
inccarry when s="1011" else
not deccarry when s="1100" else
flagin(2) when  s="0000" else --preserve flags when transfer
'0';
flagout(3)<= '1' when ((overflow1(15)=overflow2(15) and tempoutput(15) = not (overflow1(15)) and(s="0001" or s="0010" or s="1100" or s="1011"))) else --add or carry or increment or decrement
flagin(3) when  s="0000" --transfer 
else '0';

end ALU_arch;
