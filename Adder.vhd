library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;
entity Adder is
    port (
        A, B : in std_logic_vector(15 downto 0);
        X : out std_logic_vector(15 downto 0));
end entity Adder;

architecture Behav of Adder is
begin
    process (A, B)
    begin
        X <= A + B;
    end process;
end architecture Behav;