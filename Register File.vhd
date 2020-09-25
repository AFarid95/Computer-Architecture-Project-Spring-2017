library ieee;
use ieee.std_logic_1164.all;

entity RegisterFile is
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
end RegisterFile;

architecture RegisterFile_arch of RegisterFile is
  
  component reg_n_bit is
  generic (n : integer);
  port(
    Clk,En : in std_logic;
    d : in std_logic_vector(n-1 downto 0);
    q : out std_logic_vector(n-1 downto 0)
  );
  end component;
  
  type reg_array is array (0 to 7) of std_logic_vector(15 downto 0);
  
  signal dreg,qreg : reg_array;
  signal en : std_logic_vector (5 downto 0);
  signal dCCR,qCCR : std_logic_vector(3 downto 0);
  
begin
  
  loop1: for i in 0 to 5 generate
    reg: reg_n_bit generic map (n=>16) port map(reverse_Clk,en(i),dreg(i),qreg(i));
  end generate;
  
  SP:reg_n_bit generic map (n=>16) port map (reverse_Clk,SPWrite,dreg(6),qreg(6));
  PC:reg_n_bit generic map (n=>16) port map (Clk,PCWrite,dreg(7),qreg(7));
  CCR:reg_n_bit generic map (n=>4) port map (reverse_Clk,CCRWrite,dCCR,qCCR);
  

  with read_address_1 select
	read_data_1 <= qreg(0) when "000",
		       qreg(1) when "001",
		       qreg(2) when "010",
		       qreg(3) when "011",
		       qreg(4) when "100",
		       qreg(5) when "101",
		       qreg(6) when "110",
		       qreg(7) when others;

  with read_address_2 select
	read_data_2 <= qreg(0) when "000",
		       qreg(1) when "001",
		       qreg(2) when "010",
		       qreg(3) when "011",
		       qreg(4) when "100",
		       qreg(5) when "101",
		       qreg(6) when "110",
		       qreg(7) when others;
  


  dreg(0) <= write_data when write_address = "000";
  dreg(1) <= write_data when write_address = "001";
  dreg(2) <= write_data when write_address = "010";
  dreg(3) <= write_data when write_address = "011";
  dreg(4) <= write_data when write_address = "100";
  dreg(5) <= write_data when write_address = "101";
  
  en <= "000001" when write_address="000" and RegWrite='1' else
		    "000010" when write_address="001" and RegWrite='1' else
		    "000100" when write_address="010" and RegWrite='1' else
		    "001000" when write_address="011" and RegWrite='1' else
		    "010000" when write_address="100" and RegWrite='1' else
		    "100000" when write_address="101" and RegWrite='1' else
		    "000000";
  
  dreg(6) <= "000000"&sp_write;
  dreg(7) <= "000000"&pc_write;
  dCCR <= ccr_write;
  sp_read <= qreg(6)(9 downto 0);
  pc_read <= qreg(7)(9 downto 0);
  ccr_read <= qCCR;

end RegisterFile_arch;
