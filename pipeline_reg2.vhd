library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_reg2 is
    port (
        p2_ra_in : in std_logic_vector(2 downto 0);
        p2_rb_in : in std_logic_vector(2 downto 0);
        p2_rc_in : in std_logic_vector(2 downto 0);
        p2_opcode_in : in std_logic_vector(3 downto 0);
        p2_complement_in : in std_logic;
        p2_cz_in : in std_logic_vector(1 downto 0);
        p2_se7_in : in std_logic_vector(15 downto 0);
        p2_se10_in : in std_logic_vector(15 downto 0);
        p2_pc_in : in std_logic_vector(15 downto 0);
        p2_ra_out : out std_logic_vector(2 downto 0);
        p2_rb_out : out std_logic_vector(2 downto 0);
        p2_rc_out : out std_logic_vector(2 downto 0);
        p2_opcode_out : out std_logic_vector(3 downto 0);
        p2_complement_out : out std_logic;
        p2_cz_out : out std_logic_vector(1 downto 0);
        p2_se7_out : out std_logic_vector(15 downto 0);
        p2_se10_out : out std_logic_vector(15 downto 0);
        p2_pc_out : out std_logic_vector(15 downto 0);
        p2_en : in std_logic;
        clock : in std_logic
    );
end entity pipeline_reg2;

architecture working of pipeline_reg2 is

begin
    p2_write_process : process (clock)
    begin
        if (falling_edge(clock)) then
            if (p2_en = '1') then
                p2_ra_out <= p2_ra_in;
                p2_rb_out <= p2_rb_in;
                p2_rc_out <= p2_rc_in;
                p2_opcode_out <= p2_opcode_in;
                p2_complement_out <= p2_complement_in;
                p2_cz_out <= p2_cz_in;
                p2_se7_out <= p2_se7_in;
                p2_se10_out <= p2_se10_in;
                p2_pc_out <= p2_pc_in;
            end if;
        end if;
    end process p2_write_process;
end architecture working;