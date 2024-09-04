-- Importing the std_logic library
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;
use ieee.std_logic_UNSIGNED.all;

entity CZFlagRegister is
    port (
        A : in std_logic_vector(15 downto 0);
        Z_in : out std_logic;
        C_in, Z_wen, C_wen : in std_logic;
        Z_out, C_out : out std_logic;
        clk, rst : in std_logic);
end entity CZFlagRegister;

architecture Behav of CZFlagRegister is
begin
    process (clk, rst)
    begin
        if (A = "0000000000000000") then
            Z_in <= '1';
        else
            Z_in <= '0';
        end if;

        if rst = '1' then
            Z_out <= '0';
            C_out <= '0';
        else
            if (falling_edge(clk)) then
                if (Z_wen = '1') then
                    if (A = "0000000000000000") then
                        Z_out <= '1';
                    else
                        Z_out <= '0';
                    end if;
                end if;

                if (C_wen = '1') then
                    C_out <= C_in;
                end if;
            end if;
        end if;
    end process;
end architecture Behav;