library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionMemory is
	port (
		address : in std_logic_vector(9 downto 0);
		data_out : out std_logic_vector(15 downto 0)
		);
end InstructionMemory;

architecture InstructionMemory_arch of InstructionMemory is

	type ram_type is array (0 to 1023) of std_logic_vector(15 downto 0);
	signal ram : ram_type;

begin

  data_out <= ram(to_integer(unsigned(address)));

end InstructionMemory_arch;
