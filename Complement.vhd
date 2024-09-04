library ieee;
library work;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Flipper is
    port (
        A : in std_logic_vector(15 downto 0);
        X : out std_logic_vector(15 downto 0));
end entity Flipper;

architecture Behav of Flipper is
begin
    process (A)
    begin
        X <= A nand x"FFFF";
    end process;
end Behav;