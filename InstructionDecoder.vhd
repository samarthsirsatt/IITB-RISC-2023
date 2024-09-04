library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity InstructionDecoder is
    port (
        ir : in std_logic_vector(15 downto 0);
        opcode : out std_logic_vector(3 downto 0);
        RA, RB, RC : out std_logic_vector(2 downto 0);
        cmp : out std_logic;
        cz : out std_logic_vector(1 downto 0);
        imm6 : out std_logic_vector(5 downto 0);
        imm9 : out std_logic_vector(8 downto 0));
end entity InstructionDecoder;

architecture Behav of InstructionDecoder is
begin
    process (ir)
    begin
        opcode <= ir(15 downto 12);

        cmp <= ir(2);
        cz <= ir(1 downto 0);

        imm6 <= ir(5 downto 0);
        imm9 <= ir(8 downto 0);

        if ir(15 downto 12) = "0000" then
            RA <= ir(11 downto 9);
            RB <= ir(5 downto 3);
            RC <= ir(8 downto 6);
        elsif ir(15 downto 12) = "0011" then
            RC <= ir(11 downto 9);
            RB <= ir(8 downto 6);
            RA <= ir(5 downto 3);
        elsif ir(15 downto 12) = "0100" then
            RC <= ir(11 downto 9);
            RA <= ir(8 downto 6);
            RB <= ir(5 downto 3);
        elsif ir(15 downto 12) = "0101" then
            RB <= ir(11 downto 9);
            RA <= ir(8 downto 6);
            RC <= ir(5 downto 3);
        elsif ir(15 downto 12) = "1000" or ir(15 downto 12) = "1001" or ir(15 downto 12) = "1010" then
            RA <= ir(11 downto 9);
            RB <= ir(8 downto 6);
            RC <= "000";
        elsif ir(15 downto 12) = "1100" or ir(15 downto 12) = "1101" then
            RC <= ir(11 downto 9);
            RB <= ir(8 downto 6);
            RA <= ir(5 downto 3);
        else
            RA <= ir(11 downto 9);
            RB <= ir(8 downto 6);
            RC <= ir(5 downto 3);
        end if;
    end process;
end architecture Behav;