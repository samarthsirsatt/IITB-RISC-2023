library ieee; -- importing ieee library
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pipeline_reg3 is
    port (
        p3_rc_in : in std_logic_vector(2 downto 0);
        p3_rf_d1_in : in std_logic_vector(15 downto 0);
        p3_rf_d2_in : in std_logic_vector(15 downto 0);
        p3_opcode_in : in std_logic_vector(3 downto 0);
        p3_complement_in : in std_logic;
        p3_cz_in : in std_logic_vector(1 downto 0);
        p3_se7_in : in std_logic_vector(15 downto 0);
        p3_se10_in : in std_logic_vector(15 downto 0);
        p3_pc_in : in std_logic_vector(15 downto 0);
        p3_ra_in : in std_logic_vector(2 downto 0);
        p3_rb_in : in std_logic_vector(2 downto 0);
        p3_rc_out : out std_logic_vector(2 downto 0);
        p3_rf_d1_out : out std_logic_vector(15 downto 0);
        p3_rf_d2_out : out std_logic_vector(15 downto 0);
        p3_opcode_out : out std_logic_vector(3 downto 0);
        p3_complement_out : out std_logic;
        p3_cz_out : out std_logic_vector(1 downto 0);
        p3_se7_out : out std_logic_vector(15 downto 0);
        p3_se10_out : out std_logic_vector(15 downto 0);
        p3_pc_out : out std_logic_vector(15 downto 0);
        p3_ra_out : out std_logic_vector(2 downto 0);
        p3_rb_out : out std_logic_vector(2 downto 0);
        p3_en : in std_logic;
        clock : in std_logic
    );
end entity pipeline_reg3;

architecture working of pipeline_reg3 is

begin
    p3_write_process : process (clock)
    begin
        if (falling_edge(clock)) then
            if (p3_en = '1') then
                p3_rc_out <= p3_rc_in;
                p3_rf_d1_out <= p3_rf_d1_in;
                p3_rf_d2_out <= p3_rf_d2_in;
                p3_opcode_out <= p3_opcode_in;
                p3_complement_out <= p3_complement_in;
                p3_cz_out <= p3_cz_in;
                p3_se7_out <= p3_se7_in;
                p3_se10_out <= p3_se10_in;
                p3_pc_out <= p3_pc_in;
                p3_ra_out <= p3_ra_in;
                p3_rb_out <= p3_rb_in;
            end if;
        end if;
    end process p3_write_process;
end architecture working;