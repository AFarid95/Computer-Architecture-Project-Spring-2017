library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataMemory is
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
end DataMemory;

architecture DataMemory_arch of DataMemory is

	type ram_type is array (0 to 1023) of std_logic_vector(15 downto 0);
	signal ram : ram_type;
	signal zero :std_logic_vector(9 downto 0):= "0000000000";
	signal one :std_logic_vector(9 downto 0):= "0000000001";

begin

	process(clk) is
	begin
		if rising_edge(clk) then
			if MemWrite = '1' then
				ram(to_integer(unsigned(address))) <= data_in ;
			end if;
		end if;
	end process;
	
	data_out <= ram(to_integer(unsigned(address))) when MemRead='1';
	M0 <= ram(to_integer(unsigned(zero)));
	M1 <= ram(to_integer(unsigned(one)));

end DataMemory_arch;
