library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity DataMemory is
    port (
        A1 : in std_logic_vector(15 downto 0);
        D1 : out std_logic_vector(15 downto 0);
        A3, D3 : in std_logic_vector(15 downto 0);
        wen, clk : in std_logic);
end entity DataMemory;

architecture Behav of DataMemory is
    type data_array is array (0 to (2 ** 6) - 1) of std_logic_vector (15 downto 0);
    signal data_mem : data_array := (
        x"0000", x"0001", x"0002", x"0003",
        x"0004", x"0005", x"0006", x"0007",
        x"0008", x"0009", x"000A", x"000B",
        x"000C", x"000D", x"000E", x"000F",
        x"00F1", x"00F2", x"00F3", x"00F4",
        x"00F5", x"00F6", x"00F7", x"00F8",
        x"00F9", x"00FA", x"00FB", x"00FC",
        x"00FD", x"00FE", x"00FF", x"0FF1", others => x"0000");
begin

    -- reading data from mem_data
    data_read : process (A1)
    begin
        D1 <= data_mem(to_integer(unsigned(A1)));
    end process;

    -- writting data to mem_data
    data_write : process (clk)
    begin
        if (falling_edge(clk)) then
            if (wen = '1') then
                data_mem(to_integer(unsigned(A3))) <= D3;
            end if;
        end if;
    end process;

end architecture Behav;