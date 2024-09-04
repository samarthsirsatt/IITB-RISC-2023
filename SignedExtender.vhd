library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SignedExtender is
    generic (N : integer := 10);
    port (
        A : in std_logic_vector(15 - N downto 0);
        X : out std_logic_vector(15 downto 0));
end entity SignedExtender;

architecture Behav of SignedExtender is
begin
    process (A)
    begin
        X <= std_logic_vector(to_unsigned(to_integer(unsigned(A)), 16));
    end process;
end Behav;