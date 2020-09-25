library ieee;
use ieee.std_logic_1164.all;

entity JumpUnit is
  port(
    JumpZero : in std_logic;
    JumpNeg : in std_logic;
    JumpCarry : in std_logic;
    Z,N,C : in std_logic;
    CondJump : out std_logic
  );
end JumpUnit;

architecture JumpUnit_arch of JumpUnit is
begin
  
  CondJump <= '1' when (Z='1' and JumpZero='1') or (N='1' and JumpNeg='1') or (C='1' and JumpCarry='1') else
              '0';
  
end JumpUnit_arch;
