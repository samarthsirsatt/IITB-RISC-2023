library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;

entity ALU is
    port (
        A, B : in std_logic_vector(15 downto 0);
        X : out std_logic_vector(15 downto 0);
        IR : in std_logic;
        carry_out : out std_logic);
end entity ALU;

architecture Behav of ALU is
begin
    process (A, B, IR)
    begin
        if (IR = '0') then
            X <= A + B;
            if (to_integer(unsigned(A)) + to_integer(unsigned(B))) > 65535 then
                carry_out <= '1';
            else
                carry_out <= '0';
            end if;
        else
            X <= A nand B;
            carry_out <= '1';
        end if;
    end process;
end architecture Behav;