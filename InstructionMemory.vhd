library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity InstructionMemory is
	port (
		A : in std_logic_vector(15 downto 0);
		D : out std_logic_vector(15 downto 0));
end entity InstructionMemory;

architecture Behav of InstructionMemory is
	type data_mem is array (0 to (2 ** 5) - 1) of std_logic_vector (15 downto 0);
	signal instruction_mem : data_mem := (
		-- INSERT AFTER HERE
		b"0011001000000011", b"0011010000000011", b"0011011000001000", b"0011100000001000", b"0011101000000010", b"0011110000001011", b"0011111000000011", b"0001001100100000", b"0000010010000111", b"0001011011010000", b"0010100001001000", b"0001010001011000", b"0001010011001010", others => x"EFFF"
	);
begin
	process (A)
	begin
		D <= instruction_mem(to_integer(unsigned(A)));
	end process;
end architecture Behav;