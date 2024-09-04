library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Comparator is
    port (
        A, B : in std_logic_vector(15 downto 0);
        less_than, equal : out std_logic);
end entity Comparator;

architecture Behav of Comparator is
begin
    process (A, B)
    begin
        if A < B then
            less_than <= '1';
        else
            less_than <= '0';
        end if;

        if A = B then
            equal <= '1';
        else
            equal <= '0';
        end if;
    end process;
end architecture Behav;